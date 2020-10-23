--
-- drawers/lua/cabinet/cabinet.lua
--
--
-- cabinet functions that are not part of register or in Handler
--

-- probably will contain most of what was in api.lua
local S, NS = dofile(drawers.modpath .. '/intllib.lua')

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
end -- drawers.tag.drop_stack

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
		count = handler:count_for(id)
		item_name = handler:item_name_for(id)
		item_stack_max = handler:item_stack_max_for(id)
		max_count = handler:max_count_for(id)
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
		-- TODO: this is not nice to modify from here
		handler.count[id] = count
		handler:update_infotext(id)
		id = id - 1
	until 0 == id
	handler:write_meta()
end -- drawers.cabinet.drop_overload

function drawers.cabinet.update_upgrades(pos_cabinet, list_name)
	-- only do anything if adding to upgrades
	if 'upgrades' ~= list_name then
		return
	end

	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		-- this is unlikely to happen
		return
	end

	-- storage percent with all upgrades
	local storage_percent = 100

	-- get info of all upgrades
	local inventory = handler.meta:get_inventory()
	local list = inventory:get_list('upgrades')
	local name, item_def, add_to_percent
	for _, stack in ipairs(list) do
		name = stack:get_name()
		item_def = minetest.registered_items[name]
		add_to_percent = item_def.groups.drawer_upgrade or 0
		storage_percent = storage_percent + add_to_percent
	end

	local node_def = minetest.registered_nodes[handler.cabinet_node.name]
	-- default number of slots stack
	local stack_max_factor = node_def.drawers_stack_max_factor
	-- i.e.: 150% / 100 => 1.50
	stack_max_factor = math.floor(stack_max_factor * (storage_percent * 0.01))
	-- calculate stack_max factor for a single drawer
	stack_max_factor = math.floor(stack_max_factor / handler.drawer_count)

	handler:set_stack_max_factor(stack_max_factor)

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
		tags[id]:update_infotext(handler:infotext_for(id))
		id = id - 1
	until 0 == id

end -- drawers.cabinet.update_upgrades

function drawers.cabinet.randomize_pos(pos)
	local pos_rand = table.copy(pos)
	local x = math.random(-50, 50) * 0.01
	local z = math.random(-50, 50) * 0.01
	pos_rand.x = pos_rand.x + x
	pos_rand.y = pos_rand.y + 0.25
	pos_rand.z = pos_rand.z + z
	return pos_rand
end -- drawers.cabinet.randomize_pos-- construct drawer

function drawers.cabinet.on_construct(pos_cabinet)
	local node = minetest.get_node(pos_cabinet)
	local node_def = minetest.registered_nodes[node.name]
	local drawer_count = node_def.groups.drawers

	local base_stack_max = minetest.nodedef_default.stack_max or 99
	local stack_max_factor = node_def.drawers_stack_max_factor or 24 -- 3x8
	stack_max_factor = math.floor(stack_max_factor / drawer_count)
	local max_count = base_stack_max * stack_max_factor

	-- meta
	local meta = core.get_meta(pos_cabinet)

	local id = drawer_count
	local infotext
	-- TODO: this feels like a duplication of what tag.save_metadata does
	-- TODO: call handler:init(stack_max_factor, base_stack_max) or similar
	while 0 < id do
		meta:set_string('name' .. id, '')
		meta:set_int('count' .. id, 0)
		meta:set_int('max_count' .. id, max_count)
		meta:set_int('base_stack_max' .. id, base_stack_max)
		meta:set_int('stack_max_factor' .. id, stack_max_factor)
		infotext = drawers.tag.gui.generate_info_text(
						S('Empty'), 0, stack_max_factor, base_stack_max)

		meta:set_string('entity_infotext' .. id, infotext)

		id = id - 1
	end
	-- create drawer upgrade inventory
	meta:get_inventory():set_size('upgrades', 5)

	-- set the formspec
	meta:set_string('formspec', drawers.cabinet.gui.formspec)

	-- spawn all tag entities
	drawers.tag.map.spawn_for(pos_cabinet)
end -- drawers.cabinet.on_construct

-- destruct drawer
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
		return
	end

	local count, name, stack_max, count_stacks, pos_rand
	local id = handler.drawer_count
	-- TODO: add easter egg for 13th Fridays if drawer with glass inside is dug
	--		drop fragments instead of glass
	--		maybe only if server is booted on a Friday the 13th to avoid
	--		calculations for something trivial like this. There are also other
	--		ways to avoid checking here more than a flag.
	repeat
		count = handler:count_for(id)
		name = handler:item_name_for(id)
		stack_max = handler:item_stack_max_for(id)

		count_stacks = math.floor(count / stack_max) + 1
		-- TODO: test if this works when empty, in could, as we + 1
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

-- return number of items allowed to put
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

--function drawers.cabinet.add_drawer_upgrade(pos, list_name, index, stack, player)
function drawers.cabinet.add_drawer_upgrade(pos_cabinet, list_name)
-- TODO: when this works, remove these two functions and link directly
	drawers.cabinet.update_upgrades(pos_cabinet, list_name)
end -- drawers.cabinet.add_drawer_upgrade

--function drawers.cabinet.remove_drawer_upgrade(pos, list_name, index, stack, player)
function drawers.cabinet.remove_drawer_upgrade(pos_cabinet, list_name)
	drawers.cabinet.update_upgrades(pos_cabinet, list_name)
end -- drawers.cabinet.remove_drawer_upgrade

-- Inserts an incoming stack into a specific drawer of a cabinet.
function drawers.cabinet.insert_object(pos_cabinet, stack, tag_id)
	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		-- this is unlikely to happen
		return
	end
	return handler:try_insert_stack(tag_id, stack, true)
end -- drawers.cabinet.insert_object

-- Inserts an incoming stack into a cabinet and uses all drawers
function drawers.cabinet.insert_object_from_tube(pos_cabinet, node, stack, direction)
	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		-- this is unlikely to happen
		return
	end

	-- first try to insert in the correct drawer (if there are already items)
	local leftover = stack
	local item_name = stack:get_name()
	local id = handler.drawer_count
	repeat
		if item_name == handler:item_name_for(id) then
			leftover = handler:try_insert_stack(id, leftover, true)
		end
		id = id - 1
	until 0 == id

	-- if there's still something left, also use other drawers
	if 0 < leftover:get_count() then
		id = handler.drawer_count
		repeat
			leftover = handler:try_insert_stack(id, leftover, true)
			id = id - 1
		until 0 == id or 0 >= leftover:get_count()
	end
-- TODO: make sure tags are updated
	return leftover
end -- drawers.cabinet.insert_object_from_tube

-- Returns how much (count) of a stack can be inserted to a cabinet drawer.
function drawers.cabinet.can_insert_stack(pos_cabinet, stack, tag_id)
	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		-- this is unlikely to happen if called through node methods
		return
	end
	return handler:how_many_can_insert(tag_id, stack)
end -- drawers.cabinet.can_insert_stack

-- Returns whether a stack can be (partially) inserted to any drawer of a cabinet.
function drawers.cabinet.can_insert_stack_from_tube(pos_cabinet, node, stack, direction)
	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		-- this is unlikely to happen if called through node methods
		return
	end
	local id = handler.drawer_count
	repeat
		if 0 < handler:how_many_can_insert(id, stack) then
			return true
		end
		id = id - 1
	until 0 == id

	return false
end -- drawers.cabinet.can_insert_stack_from_tube

function drawers.cabinet.take_item(pos_cabinet, stack)
	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		-- this is unlikely to happen if called through node methods
		return ItemStack()
	end
	-- limit count to stack_max
	local count = math.min(stack:get_count(), stack:get_stack_max())
	local name = stack:get_name()
	local id = handler.drawer_count
	repeat
		if handler:item_name_for(id) == name then
			return handler:take_items(id, count)
		end
		id = id - 1
	until 0 == id
	return ItemStack()
end -- drawers.cabinet.take_item

-- TODO: figure out what needs this or if we can drop it
-- Returns the content of a cabinet's drawer.
function drawers.cabinet.get_content(pos, tag_id)
	local meta = core.get_meta(pos)
	return {
		count = meta:get_int('count' .. tag_id),
		name = meta:get_string('name' .. tag_id),
		max_count = meta:get_int('max_count' .. tag_id),
	}
end -- drawers.cabinet.get_content

