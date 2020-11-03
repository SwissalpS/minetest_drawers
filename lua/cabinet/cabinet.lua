--
-- drawers/lua/cabinet/cabinet.lua
--
-- cabinet functions that are not part of register or in Handler

-- return number of upgrade items allowed to put
function drawers.cabinet.allow_upgrade_put(pos_cabinet, list_name, index, stack, player)
	-- no need to continue if it's not upgrades list.
	if 'upgrades' ~= list_name then
		return 0
	end
	-- check player protection
	local player_name = player:get_player_name()
	if minetest.is_protected(pos_cabinet, player_name) then
		minetest.record_protection_violation(pos_cabinet, player_name)
		return 0
	end
	-- check that is actually an upgrade
	if 1 > minetest.get_item_group(stack:get_name(), 'drawers_increment') then
		return 0
	end

	-- don't allow stacking in upgrade inventory
	local upgrade_inventory = minetest.get_meta(pos_cabinet):get_inventory()
	local slot_count = upgrade_inventory:get_list('upgrades')[index]:get_count()
	if 0 < slot_count then
		return 0
	end

	-- allow just one into the empty slot
	return 1
end -- drawers.cabinet.allow_upgrade_put

-- return number of items allowed to take
function drawers.cabinet.allow_upgrade_take(pos_cabinet, list_name, index, stack, player)
	-- no need to continue if it's not upgrades list.
	if 'upgrades' ~= list_name then
		return 0
	end
	-- check player protection
	local player_name = player:get_player_name()
	if minetest.is_protected(pos_cabinet, player_name) then
		minetest.record_protection_violation(pos_cabinet, player_name)
		return 0
	end

	-- permit to take any amount of anything out as there is a trick to get
	-- any amount of anything in there
	return stack:get_count()
end -- drawers.cabinet.allow_upgrade_take

-- Returns whether a stack can be (partially) inserted to any drawer of a cabinet.
-- called by pipeworks when attempting to insert something
function drawers.cabinet.can_insert(pos_cabinet, node, stack, direction)
	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		-- this is unlikely to happen if called through node methods
		return false
	end

	-- TODO shouldn't we pass the count on, since it's already calculated?
	return 0 < handler:can_insert(stack)
end -- drawers.cabinet.can_insert

-- is called when upgrades are changed
function drawers.cabinet.drop_overload(pos_cabinet)
	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		-- this is unlikely to happen
		return
	end

	local id = handler.drawer_count
	local stack, item_name, count, max_count, item_stack_max, remove_count
	repeat
		count = handler:count_in(id)
		item_name = handler:name_in(id)
		item_stack_max = handler:stack_max_in(id)
		max_count = handler:max_count_in(id)
		-- drop stacks until there are no more items than allowed
		while count > max_count do
			-- remove the overflow
			-- if this is too much for a single stack, only take the
			-- stack limit
			remove_count = math.min(item_stack_max, count - max_count)
			-- remove this amount from the drawer
			count = count - remove_count
			-- create a new item stack having the size of the remove count
			stack = ItemStack(item_name)
			stack:set_count(remove_count)
			-- drop the stack
			drawers.cabinet.drop_stack(pos_cabinet, stack)
		end

		-- this is not nice to modify from here, but for now it's OK
		-- at least it is not messing with meta directly
		handler.count[id] = count
		handler:update_visibles_in(id)
		id = id - 1
	until 0 == id

	handler:write_meta()
end -- drawers.cabinet.drop_overload

-- called by drop_overload which is called when upgrades are changed
function drawers.cabinet.drop_stack(pos_cabinet, stack)
	-- TODO: this looks like a debugging entry, see if we can remove it
	-- print warning if dropping higher stack counts than allowed
	if stack:get_count() > stack:get_stack_max() then
		minetest.log('warning', '[drawers] Dropping item stack with higher count than allowed')
	end
	-- find a position containing air
	local pos_drop = minetest.find_node_near(pos_cabinet, 1, { 'air' }, false)
	-- if no pos found then drop on the top of the drawer
	if not pos_drop then
		-- TODO: check better, there may be something there, or is this standard
		--		behaviour? I think tp-tubes do the same
		pos_drop = table.copy(pos_cabinet)
		pos_drop.y = pos_drop.y + 1
	end

	-- drop the item stack
	minetest.item_drop(stack, nil, pos_drop)
end -- drawers.cabinet.drop_stack

-- Inserts an incoming stack into a cabinet and uses all drawers
function drawers.cabinet.fill_cabinet(pos_cabinet, node, stack, direction)
	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		-- this is unlikely to happen
		return stack
	end

	return handler:fill_cabinet(stack)
end -- drawers.cabinet.fill_cabinet

function drawers.cabinet.on_construct(pos_cabinet)
	-- meta
	local meta = minetest.get_meta(pos_cabinet)
	-- create drawer upgrade inventory
	meta:get_inventory():set_size('upgrades', 5)
	-- set the formspec
	meta:set_string('formspec', drawers.cabinet.gui.formspec)
	-- spawn all tag entities
	-- this also triggers handler object to be created
	drawers.tag.map.spawn_for(pos_cabinet)
	-- tell any nearby controllers about this new cabinet
	drawers.controller.net_item_placed(pos_cabinet)
end -- drawers.cabinet.on_construct

-- destruct cabinet
function drawers.cabinet.on_destruct(pos_cabinet)
	-- remove the entities
	drawers.tag.map.remove_for(pos_cabinet)
	-- also remove handler object
	drawers.cabinet.remove_handler_for(pos_cabinet)
end -- drawers.cabinet.on_destruct

-- drop all items
function drawers.cabinet.on_dig(pos_cabinet, node, player)
	local player_name = player:get_player_name()
	if minetest.is_protected(pos_cabinet, player_name) then
		minetest.record_protection_violation(pos_cabinet, player_name)
		return 0
	end

	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		-- this is unlikely to happen since, we are about to dig it
		return 0
	end

	local count, name, stack_max, count_stacks, pos_rand
	local id = handler.drawer_count
	-- TODO: add easter egg for 13th Fridays if drawer with glass inside is dug
	--		drop fragments instead of glass
	--		maybe only if server is booted on a Friday the 13th to avoid
	--		calculations for something trivial like this. There are also other
	--		ways to avoid checking here more than a flag.
	repeat
		count = handler:count_in(id)
		name = handler:name_in(id)
		stack_max = handler:stack_max_in(id)

		count_stacks = math.floor(count / stack_max) + 1
		repeat
			pos_rand = drawers.cabinet.randomize_pos(pos_cabinet)
			if 1 == count_stacks then
				minetest.add_item(pos_rand, name .. ' ' .. (count % stack_max))
			else
				minetest.add_item(pos_rand, name .. ' ' .. stack_max)
			end
			count_stacks = count_stacks - 1
		until 0 == count_stacks
		id = id - 1
	until 0 == id

	-- drop all drawer upgrades
	local stack, index
	local upgrade_slots = handler.meta:get_inventory():get_list('upgrades')
	if upgrade_slots then
		index = #upgrade_slots
		repeat
			stack = upgrade_slots[index]
			if 0 < stack:get_count() then
				pos_rand = drawers.cabinet.randomize_pos(pos_cabinet)
				minetest.add_item(pos_rand, stack:get_name())
			end
			index = index - 1
		until 0 == index
	end -- if got list

	-- remove node
	minetest.node_dig(pos_cabinet, node, player)
end -- drawers.cabinet.on_dig

--- called while jumpdrive is moving all nodes
-- see https://github.com/mt-mods/jumpdrive/blob/d836cc0569b26f1e155d7eb53cb1e1b13ad927da/move/move.lua#L148
-- returns nothing
function drawers.cabinet.on_jump(pos_from, pos_to, context)
	-- remove old tags and handler
	minetest.after(drawers.settings.after_jump_delay,
					drawers.cabinet.on_destruct, pos_from)

	-- spawn new entities which also creates new handler instance
	minetest.after(drawers.settings.after_jump_delay,
					drawers.tag.map.spawn_for, pos_to)
end -- drawers.cabinet.on_jump

function drawers.cabinet.randomize_pos(pos)
	local pos_rand = table.copy(pos)
	local x = math.random(-50, 50) * 0.01
	local z = math.random(-50, 50) * 0.01
	pos_rand.x = pos_rand.x + x
	pos_rand.y = pos_rand.y + 0.25
	pos_rand.z = pos_rand.z + z
	return pos_rand
end -- drawers.cabinet.randomize_pos

function drawers.cabinet.take(pos_cabinet, stack)
	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		-- this is unlikely to happen if called through node methods
		return ItemStack()
	end

	return handler:take(stack)
end -- drawers.cabinet.take

function drawers.cabinet.upgrade_update(pos_cabinet, list_name)
	-- only do anything if adding to upgrades
	if 'upgrades' ~= list_name then
		return
	end

	-- fetch handler for this cabinet
	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		-- this is unlikely to happen
		return
	end

	local slot_count = drawers.settings.base_slot_count

	-- get info of all upgrades
	local inventory = handler.meta:get_inventory()
	local list = inventory:get_list('upgrades')
	local name, item_def, increment
	local index = #list
	repeat
		name = list[index]:get_name()
		item_def = minetest.registered_items[name]
		increment = item_def.groups.drawers_increment or 0
		slot_count = slot_count + increment
		index = index - 1
	until 0 == index

	local slots_per_drawer = math.floor(slot_count / handler.drawer_count)
	handler:set_slots_per_drawer(slots_per_drawer)

	drawers.cabinet.drop_overload(pos_cabinet)

	-- force tags to update
	local tags = drawers.tag.map.tags_for(pos_cabinet)
	if not tags then
		-- they should exist! create them.
		drawers.tag.map.spawn_for(pos_cabinet)
		return
	end

	local id = #tags
	repeat
		tags[id]:update_infotext(handler:infotext_in(id))
		id = id - 1
	until 0 == id

end -- drawers.cabinet.upgrade_update

