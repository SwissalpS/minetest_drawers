--
--- drawers/lua/controller/controller.lua
--
local EMPTY = drawers.controller.key_empty

--- helper for contains_pos()
local function is_same_pos(pos1, pos2)
	return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z
end

-- checks if position pos is in list of positions
local function contains_pos(list, pos)
	local index = #list
	if 0 == index then
		return false
	end

	repeat
		if is_same_pos(pos, list[index]) then
			return true
		end

		index = index - 1
	until 0 == index

	return false
end -- contains_pos

local function pos_in_range(pos1, pos2)
	local diff = {
		pos1.x - pos2.x,
		pos1.y - pos2.y,
		pos1.z - pos2.z
	}
	local index = 3
	local value
	repeat
		value = math.abs(diff[index])
		if value > drawers.settings.controller_range then
			return false
		end

		index = index - 1
	until 0 == index

	return true
end -- pos_in_range

-- TODO SwissalpS wants to drop the caching of contents
-- the cache is nearly always out of date and needs to be remade.
-- It would be faster in most case just to ask each cabinet until space or items
-- are found. Scanning all the cabinets first seems like overkill.
local function add_cabinet_to_index(pos_cabinet, net_index)
	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		-- this should not happen, since this has already been checked
		return
	end

	local item_name
	local free_space
	local last_best
	local id = handler.drawer_count
	repeat
		item_name = handler:name_in(id)
		if '' == item_name then
			item_name = EMPTY
		end
		free_space = handler:free_space_in(id)
		if not net_index[item_name] then
			net_index[item_name] = {
				-- using short field names as this table will be in meta
				-- and sereialized a lot
				-- p = primary; c = coordinate; s = space; i = id
				-- a = alternatives --> a[n].c and a[n].i
				p = { c = pos_cabinet, s = free_space, i = id },
				a = {}
			}
		elseif free_space > net_index[item_name].p.s then
			last_best = net_index[item_name].p
			last_best.s = nil
			table.insert(net_index[item_name].a, last_best)
			--net_index[item_name].a[#net_index[item_name].a + 1] = last_best
			net_index[item_name].p = { c = pos_cabinet, s = free_space, i = id }
		else
			table.insert(net_index[item_name].a, { c = pos_cabinet, i = id })
		end
		id = id - 1
	until 0 == id
end -- add_cabinet_to_index

--- called when user moves items around inventories
-- TODO: check when and what really happens, don't think this is used any more
-- return amount of items that can be put
function drawers.controller.allow_metadata_inventory_move(pos_controller,
						from_list, from_index, to_list, to_index, count, player)

	local meta = minetest.get_meta(pos_controller)
	local inventory = meta:get_inventory()
	local stack = inventory:get_stack(from_list, from_index)

	return drawers.controller.allow_metadata_inventory_put(
						pos_controller, to_list, to_index, stack, player)
end -- drawers.controller.allow_metadata_inventory_move

--- check if stack can be inserted
-- called by inventory activity, when items are put into slot in formspec
-- called also when tubes inquire about inserting items
-- return amount of items that can be put (up to stacks count)
function drawers.controller.allow_metadata_inventory_put(
								pos_controller, list_name, index, stack, player)

	if 'src' ~= list_name then
		return 0
	end

	-- when request is from tubes, then there is no player to check
	if player and minetest.is_protected(pos_controller, player:get_player_name()) then
		return 0
	end

	local space = drawers.controller.can_insert(pos_controller, stack)

	return space
end -- drawers.controller.allow_metadata_inventory_put

--- called when player takes stack out of formspec inventory
-- which is unlikely to ever happen since we check for space before player can
-- put anything in inventory slot or tubes
-- return amount of items allowed to be removed
function drawers.controller.allow_metadata_inventory_take(pos_controller,
												list_name, index, stack, player)

	if minetest.is_protected(pos_controller, player:get_player_name()) then
		return 0
	end

	-- let them have any amount, seeing that they got it in there already
	return stack:get_count()
end -- drawers.controller.allow_metadata_inventory_take

function drawers.controller.can_dig(pos_controller, player)
	local meta = minetest.get_meta(pos_controller);
	local inventory = meta:get_inventory()

	return inventory:is_empty('src')
end

function drawers.controller.can_insert(pos_controller, stack, have_scanned)
	local item_name = stack:get_name()
	local meta = minetest.get_meta(pos_controller)
	local use_all = 0 < meta:get_int('use_all')
	local net_index = minetest.deserialize(meta:get_string('net_index'))
	local item_index = net_index[item_name]
	local empty_index = net_index[EMPTY]
	local space_found = 0
	local scan_needed = false
	local stack_count = stack:get_count()
	local handler
	local index
	local pos_cabinet
	local checked

	-- using short field names as this table will be in meta
	-- and sereialized a lot
	-- p = priority; c = coordinate; s = space; i = id; a = alternatives
	-- item_index = {
	--	p = { c = pos, s = space, i = id },
	--	a = {
	--		{ c = pos, i = id }, { ... }, ...
	--	}
	--}
	if item_index then
		-- there seem to be drawers with this item in them
		pos_cabinet = item_index.p.c
		handler = drawers.cabinet.handler_for(pos_cabinet)
		if handler then
			space_found = handler:can_insert(stack)
			if space_found >= stack_count then
				return stack_count
			end

			if not use_all then
				return space_found
			end

			index = #item_index.a
			if 0 == index then
				scan_needed = true
			else
				checked = { table.copy(pos_cabinet) }
				repeat
					pos_cabinet = item_index.a[index].c
					if not contains_pos(checked, pos_cabinet) then
						table.insert(checked, table.copy(pos_cabinet))
						handler = drawers.cabinet.handler_for(pos_cabinet)
						if handler then
							space_found = space_found
								+ handler:can_insert(stack)

							if space_found >= stack_count then
								return stack_count
							end

						else
							scan_needed = true
							break
						end -- if got handler
					end -- if position not yet checked

					index = index - 1
				until 0 == index
			end -- if got alternatives
			-- if we are here we either did not have alternatives or there was
			-- not enough space for them
			-- TODO refactor at least this part as it is almost identical to when
			--	first no match was found
			if empty_index and not scan_needed then
				-- there seem to be empty drawers that can be filled
				pos_cabinet = empty_index.p.c
				handler = drawers.cabinet.handler_for(pos_cabinet)
				if handler then
					space_found = space_found + handler:can_insert(stack)
					if space_found >= stack_count then
						return stack_count
					end

					index = #empty_index.a
					if 0 == index then
						scan_needed = true
					else
						checked = { table.copy(pos_cabinet) }
						repeat
							pos_cabinet = empty_index.a[index].c
							if not contains_pos(checked, pos_cabinet) then
								table.insert(checked, table.copy(pos_cabinet))
								handler = drawers.cabinet.handler_for(pos_cabinet)
								if handler then
									space_found = space_found
										+ handler:can_insert(stack)

									if space_found >= stack_count then
										return stack_count
									end

								else
									scan_needed = true
									break
								end -- if got handler

							end -- if position not yet checked

							index = index - 1
						until 0 == index
					end -- if got alternatives
				else
					-- no handler for primary empty
					scan_needed = true
				end
			end -- if need to check empty
		else
			-- no handler for primary
			scan_needed = true
		end
	elseif empty_index then
		-- there seem to be empty drawers that can be filled
		pos_cabinet = empty_index.p.c
		handler = drawers.cabinet.handler_for(pos_cabinet)
		if handler then
			space_found = handler:can_insert(stack)
			if space_found >= stack_count then
				return stack_count
			end

			if not use_all then
				return space_found
			end

			index = #empty_index.a
			if 0 == index then
				scan_needed = true
			else
				checked = { table.copy(pos_cabinet) }
				repeat
					pos_cabinet = empty_index.a[index].c
					if not contains_pos(checked, pos_cabinet) then
						table.insert(checked, table.copy(pos_cabinet))
						handler = drawers.cabinet.handler_for(pos_cabinet)
						if handler then
							space_found = space_found
								+ handler:can_insert(stack)

							if space_found >= stack_count then
								return stack_count
							end

						else
							scan_needed = true
							break
						end -- if got handler
					end -- if position not yet checked

					index = index - 1
				until 0 == index
			end -- if got alternatives
		else
			-- no handler for primary empty
			scan_needed = true
		end
	else
		-- no space, maybe reindexing may help
		scan_needed = true
	end

	if scan_needed then
		if have_scanned then
			return space_found
		end

		drawers.controller.scan_cabinets(pos_controller)

		return drawers.controller.can_insert(pos_controller, stack, true)
	end

	return space_found
end -- drawers.controller.can_insert

--- fill in as much of stack as fits according to use_all settings
-- returns leftover ItemStack
-- this method assumes that space had been checked beforehand which means
-- net_index is up to date.
function drawers.controller.fill_net(pos_controller, stack)
	local use_all = 0 < minetest.get_meta(pos_controller):get_int('use_all')
	local item_name = stack:get_name()
	local stack_count = stack:get_count()
	local meta = minetest.get_meta(pos_controller)
	local net_index = minetest.deserialize(meta:get_string('net_index'))
	local item_index = net_index[item_name]
	local empty_index = net_index[EMPTY]
	local handler, index, pos_cabinet, checked
	local leftover = stack

	if item_index then
		pos_cabinet = item_index.p.c
		handler = drawers.cabinet.handler_for(pos_cabinet)
		if not handler then
			-- should not happen, but if it does we fail silently
			return leftover
		end

		leftover = handler:fill_cabinet(leftover)
		if not use_all or 0 >= leftover:get_count() then
			return leftover
		end

		index = #item_index.a
		if 0 < index then
			checked = { table.copy(pos_cabinet) }
			repeat
				pos_cabinet = item_index.a[index].c
				if not contains_pos(checked, pos_cabinet) then
					handler = drawers.cabinet.handler_for(pos_cabinet)
					if handler then
						leftover = handler:fill_cabinet(leftover)
						if 0 >= leftover:get_count() then
							return leftover
						end

					end -- if got handler
				end -- if position not yet used

				index = index - 1
			until 0 == index
		end -- if got any alternatives
	end -- if got primary
	-- if we got here, there was no primary or all the primaries have been filled
	-- and we now need to fill empty drawers.
	if empty_index then
		pos_cabinet = empty_index.p.c
		handler = drawers.cabinet.handler_for(pos_cabinet)
		if not handler then
			-- should not happen, but if it does we fail silently
			return leftover
		end

		leftover = handler:fill_cabinet(leftover)
		if not use_all or 0 >= leftover:get_count() then
			return leftover
		end

		index = #empty_index.a
		if 0 < index then
			checked = { table.copy(pos_cabinet) }
			repeat
				pos_cabinet = empty_index.a[index].c
				if not contains_pos(checked, pos_cabinet) then
					handler = drawers.cabinet.handler_for(pos_cabinet)
					if handler then
						leftover = handler:fill_cabinet(leftover)
						if 0 >= leftover:get_count() then
							return leftover
						end

					end -- if got handler
				end -- if position not yet used

				index = index - 1
			until 0 == index
		end -- if got any alternatives
	end -- if got empty primary

	return leftover
end -- drawers.controller.fill_net

--- search for cabinets, trim that are connected to controller
function drawers.controller.find_connected(pos_controller, pos_next, found_positions)
	found_positions = found_positions or {}
	pos_next = pos_next or pos_controller

	local new_positions = minetest.find_nodes_in_area(
		vector.subtract(pos_next, 1), vector.add(pos_next, 1),
		{ 'group:drawers_connector' }
	)
	local index = #new_positions
	if 0 == index then
		return found_positions
	end

	local pos_new
	repeat
		pos_new = new_positions[index]
		-- check that this node hasn't been indexed yet and is in range
		-- TODO probably don't need to compare positins as the current one is already in found_positions
		if
			--not is_same_pos(pos_next, pos_new) and
			not contains_pos(found_positions, pos_new)
			and pos_in_range(pos_controller, pos_new)
		then
			-- add new position
			table.insert(found_positions, pos_new)
			-- search for other drawers from the new position
			drawers.controller.find_connected(pos_controller, pos_new, found_positions)
		end

		index = index - 1
	until 0 == index

	return found_positions
end -- drawers.controller.find_connected

--- called when a cabinet, trim, controller or compactor is placed
-- search for controllers in area and have them re-index
function drawers.controller.net_item_placed(pos_node)
	drawers.controller.update_controllers_near(pos_node)
end --

--- called when a cabinet, trim, controller or compactor is dug
-- search for controllers in area and have them re-index
function drawers.controller.net_item_removed(pos_node)
	drawers.controller.update_controllers_near(pos_node)
end --

function drawers.controller.on_blast(pos_controller)
	local drops = {}
	default.get_inventory_drops(pos_controller, 'src', drops)
--	default.get_inventory_drops(pos_controller, 'upgrades', drops)
	table.insert(drops, 'drawers:controller')
	minetest.remove_node(pos_controller)

	return drops
end -- drawers.controller.on_blast

function drawers.controller.on_construct(pos_controller)
	local meta = minetest.get_meta(pos_controller)
	meta:set_string('net_index', '')
	meta:set_string('cabinets', '')
	meta:set_string('compactors', '')
	meta:set_int('use_all', 0)
	meta:set_string('formspec', drawers.controller.gui.formspec(pos_controller))
	meta:get_inventory():set_size('src', 1)
	-- TODO add inventory for upgrades that can be distributed to all cabinets
	--	needs to be discussed how many slots to make avaailable
	--meta:get_inventory():set_size('upgrades', 3)
	drawers.controller.update_controllers_near(pos_controller)
end -- drawers.controller.on_construct

--- called after allow_metadata_inventory_put when player puts stack into
-- formspec inventory or when tube inserts stack
function drawers.controller.on_metadata_inventory_put(pos_controller, list_name,
														index, stack, player)

	if 'src' ~= list_name then
		return
	end
	local inventory = minetest.get_meta(pos_controller):get_inventory()

	local complete_stack = inventory:get_stack(list_name, 1)
	local leftover = drawers.controller.fill_net(pos_controller, complete_stack)

	inventory:set_stack(list_name, 1, leftover)
end -- drawers.controller.on_metadata_inventory_put

function drawers.controller.on_receive_fields(pos_controller, formname, fields, sender)
	local meta = minetest.get_meta(pos_controller)
	if fields.save_channel then
		meta:set_string('channel', fields.channel)
	end

	if fields.use_all then
		-- keep as int to a) reduce space used in meta
		-- b) permit possible later extension to be a hash of toggles
		local value = 0
		if 'true' == fields.use_all then value = 1 end
		meta:set_int('use_all', value)
		meta:set_string('formspec', drawers.controller.gui.formspec(pos_controller))
	end
end -- drawers.controller.on_receive_fields

--- aka generate net_index using cached index of connected cabinets
-- stores the map in meta and
-- returns the table
function drawers.controller.scan_cabinets(pos_controller)
	local net_index = {}
	local meta = minetest.get_meta(pos_controller)
	local all_cabinets = minetest.deserialize(meta:get_string('cabinets'))
	local index = #all_cabinets
	if 0 < index then
		repeat
			add_cabinet_to_index(all_cabinets[index], net_index)
			index = index - 1
		until 0 == index
	end
	meta:set_string('net_index', minetest.serialize(net_index))

	return net_index
end -- drawers.controller.scan_cabinets

--- take from drawers according to settings
-- if use_all is off, only the priority cabinet is checked for items
-- if use_all is on, then items are gathered from any cabinet until request
-- can be satisfied or there is nothing more to take
function drawers.controller.take(pos_controller, stack)
	local item_name = stack:get_name()
	if not minetest.registered_items[item_name] then
		return ItemStack()
	end

	-- the net_index is always out of date, so the easy fix is to scan again
	-- any time items are requested. This saves us a lot of possible bugs like
	-- the one where wrong items were returned.
	-- SwissalpS thinks this makes a strong argument for keeping net_index in ram
	-- instead of passing the list by serialize and deserialize
	local net_index = drawers.controller.scan_cabinets(pos_controller)
	local meta = minetest.get_meta(pos_controller)
	--local net_index = minetest.deserialize(meta:get_string('net_index'))
	local item_index = net_index[item_name]
	if not item_index then
		-- we can't do anything: the requested item doesn't exist
		return ItemStack()
	end

	-- limit request to valid stack size, cabinet handler will do the same
	local stack_max = minetest.registered_items[item_name].stack_max
	local requested_count = math.min(stack:get_count(), stack_max)
	local pos_cabinet = item_index.p.c
	local taken_stack = drawers.cabinet.take(pos_cabinet, stack)
	local taken_count = taken_stack:get_count()
	local use_all = 0 < meta:get_int('use_all')
	if taken_count == requested_count or (not use_all) then
		return taken_stack
	end

	local index = #item_index.a
	if 0 == index then
		-- no alternatives, return what we got
		return taken_stack
	end

	local checked = { pos_cabinet }
	-- we initialize here with name and not with taken_stack because taken_stack
	-- could have name of ''
	local return_stack = ItemStack({ name = item_name, count = taken_count })
	local count = requested_count - taken_count
	stack:set_count(count)
	repeat
		pos_cabinet = item_index.a[index].c
		if not contains_pos(checked, pos_cabinet) then
			table.insert(checked, pos_cabinet)
			taken_stack = drawers.cabinet.take(pos_cabinet, stack)
			taken_count = taken_stack:get_count()
			count = count - taken_count
			stack:set_count(count)
			-- we don't do return_stack:add(taken_stack) because taken_stack
			-- could have name of ''
			return_stack:set_count(return_stack:get_count() + taken_count)
		end

		index = index - 1
	until 0 == index or 0 >= count
	-- make sure name is set correctly
	return_stack:set_name(item_name)

	return return_stack
end -- drawers.controller.take

--- called when a cabinet, trim, controller or compactor is dug or placed
function drawers.controller.update_controllers_near(pos_node)
	local positions = minetest.find_nodes_in_area(
		vector.subtract(pos_node, drawers.settings.controller_range),
		vector.add(pos_node, drawers.settings.controller_range),
		{ 'drawers:controller' }
	)

	local index = #positions
	if 0 == index then
		return
	end

	local pos_controller
	repeat
		pos_controller = positions[index]
		drawers.controller.update_network_caches(pos_controller)
		index = index - 1
	until 0 == index
end -- drawers.controller.update_controllers_near

--- called whenever cache needs updating due to digging or placing of
-- cabinets, trims, or controllers (soon also compacters)
function drawers.controller.update_network_caches(pos_controller)
	-- this list also contains other controller, compactor and trim nodes
	local all_conected = drawers.controller.find_connected(pos_controller)
	-- now we need to clean out all but cabinet nodes
	local all_cabinets = {}
	local all_compactors = {}
	local pos_node, handler, id
	local index = #all_conected
	if 0 < index then
		repeat
			pos_node = all_conected[index]
			handler = drawers.cabinet.handler_for(pos_node)
			-- only get valid handler for actual drawers, not trim or controller
			if handler then
				table.insert(all_cabinets, pos_node)
			else
				-- TODO check if it's a compactor
				table.insert(all_compactors, pos_node)
			end -- if a cabinet
			index = index - 1
		until 0 == index
	end
	-- and stash this index for later reference
	local meta = minetest.get_meta(pos_controller)
	meta:set_string('cabinets', minetest.serialize(all_cabinets))
	meta:set_string('compactors', minetest.serialize(all_compactors))
	drawers.controller.scan_cabinets(pos_controller)
end -- drawers.controller.update_network_caches

