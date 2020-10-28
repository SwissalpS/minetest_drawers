--
--- drawers/lua/controller/controller.lua
--

-- TODO
-- add digiline command: has_item; only give bool back
-- test how orientation of controller to orientation of cabinets affects output

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
end

--- checks if all fields are set in net_index table
-- helper for drawers.controller.get_drawer_index()
-- old but may need to be used in case meta got corrupted for some reason
local function is_valid_index(net_index, item_name)
	return net_index and
			net_index[item_name] and
			net_index[item_name].pos_cabinet and
			net_index[item_name].pos_cabinet.x and
			net_index[item_name].pos_cabinet.y and
			net_index[item_name].pos_cabinet.z and
			net_index[item_name].tag_id
end -- is_valid_index

--- helper to wrap in table
-- old
local function index_drawer(pos_cabinet, tag_id)
	return { pos_cabinet = pos_cabinet, tag_id = tag_id }
end -- index_drawer

--- TODO I don't see this used anywhere
--- iterator for iterating from 1/-1 to last
local function range(last)
	local i = 0
	return function()
		if i == last then
			return nil
		end
		if 0 < last then
			i = i + 1
		else
			i = i - 1
		end
		return i, i
	end
end -- range

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

-- old way
function drawers.controller.add_cabinet_to_inventory(cabinet_inventory, pos_cabinet)
	local handler = drawers.cabinet.handler_for(pos_cabinet)
	if not handler then
		-- this is either a trim or controller node
		return
	end
	local item_name, override, handler2, index_cabinet2, space2
	local id = handler.drawer_count
	repeat
		item_name = handler:name_in(id)
		if '' == item_name and not cabinet_inventory[EMPTY] then
			cabinet_inventory[EMPTY] = index_drawer(pos_cabinet, id)
		elseif '' ~= item_name then
			-- If we already indexed this item previously, check which drawer
			-- has the most space and have that one be the one indexed
			override = true
			if cabinet_inventory[item_name] then
				index_cabinet2 = cabinet_inventory[item_name]
				handler2 = drawers.cabinet.handler_for(index_cabinet2.pos_cabinet)
				if not handler2 then
					-- seems this cabinet no longer exists
					-- TODO may need some cleanup of stray entities here
					override = true
				else
					space2 = handler2:free_space_in(index_cabinet2.tag_id)
					override = space2 < handler:free_space_in(id)
				end
			end
			-- If the already indexed drawer has less space, we override the
			-- table index for that item with the new drawer
			if override then
				cabinet_inventory[item_name] = index_drawer(pos_cabinet, id)
			end
		end
		id = id - 1
	until 0 == id
end -- drawers.controller.add_cabinet_to_inventory

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
	else
	end
	-- and stash this index for later reference
	local meta = minetest.get_meta(pos_controller)
	meta:set_string('cabinets', minetest.serialize(all_cabinets))
	meta:set_string('compactors', minetest.serialize(all_compactors))
	drawers.controller.scan_cabinets(pos_controller)
end -- drawers.controller.update_network_caches

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

-- aka generate net_index using cached index of connected cabinets
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
end -- drawers.controller.scan_cabinets

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

-- old
function drawers.controller.index_cabinets(pos_controller)
	--[[
	We store the item name as a string key and the value is a table with position x,
	position y, position z, and tag_id. Those are all strings as well with the
	values assigned to them that way we don't need to worry about the ordering of
	the table. The count and max count are not stored as those values have a high
	potential of being outdated quickly. It's better to grab the values from the
	cabinet handler when needed so you know you are working with accurate numbers.
	]]

	local cabinet_inventory = {}
	local connected_cabinets = drawers.controller.find_connected(pos_controller)
	local index = #connected_cabinets
	if 0 == index then
		return cabinet_inventory
	end
	local pos_cabinet
	repeat
		pos_cabinet = connected_cabinets[index]
		drawers.controller.add_cabinet_to_inventory(cabinet_inventory, pos_cabinet)
		index = index - 1
	until 0 == index

	return cabinet_inventory
end -- index_cabinets

--- get an index of a cabinet that has a drawer for item.
-- Returns a table of all stored item names in the drawer network with their
-- cabinet position and tag_id.
--
-- It uses the cached data, if possible, but if the item_name is not contained
-- the network is reindexed.
-- old
function drawers.controller.get_drawer_index(pos_controller, item_name)
	-- If the index has not been created, the item isn't in the index, the
	-- item in the drawer is no longer the same item in the index, or the item
	-- is in the index but it's full, run the index_cabinets function.
	local meta = minetest.get_meta(pos_controller)
	local net_index = minetest.deserialize(meta:get_string('net_index'))
	local scan_needed = false
	if is_valid_index(net_index, item_name) then
		-- There is a valid entry in the index: check that the entry is still up-to-date
		local entry = net_index[item_name]
		local handler = drawers.cabinet.handler_for(entry.pos_cabinet, true)
		if handler then
			if handler:name_in(entry.tag_id) ~= item_name
				or 0 >= handler:free_space_in(entry.tag_id)
			then
				-- if there is none with less content, this one will be added again
				scan_needed = true
			end
		else
			scan_needed = true
		end -- if got handler or not
	else
		-- If the index has not been created
		-- If the item isn't in the index (or the index is corrupted)
		-- search for cabinets and index them again
		scan_needed = true
	end -- if have valid entry or not
	if scan_needed then
		net_index = drawers.controller.index_cabinets(pos_controller)
		meta:set_string('net_index', minetest.serialize(net_index))
	end
	return net_index
end -- drawers.controller.get_drawer_index

-- old
function drawers.controller.insert_to_empty_drawer(pos_controller, stack)
	local item_name = stack:get_name()
	local net_index = drawers.controller.get_drawer_index(pos_controller, item_name)
	if not net_index[EMPTY] then
		return stack
	end
	local pos_cabinet = net_index[EMPTY].pos_cabinet
	local tag_id = net_index[EMPTY].tag_id
	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		return stack
	end
	-- If the drawer is still empty we put the items in the drawer
	-- TODO add support for locked drawers that may be just as empty.
	--	possibly this is not required though, as the locked ones would be found
	--	and filled first
	if '' == handler:name_in(tag_id) then
		local leftover = handler:fill_cabinet(tag_id, stack, true)

		-- Add the item to the drawers table index and set the empty one to nil
		net_index[EMPTY] = nil
		net_index[item_name] = index_drawer(pos_cabinet, tag_id)

		-- Set the controller metadata
		minetest.get_meta(pos_controller):set_string('net_index',
												minetest.serialize(net_index))

		return leftover
	end -- if empty
end -- drawers.controller.insert_to_empty_drawer

function drawers.controller.insert_to_drawers(pos_controller, stack)

	local use_all = 0 < minetest.get_meta(pos_controller):get_int('use_all')
	local item_name = stack:get_name()
	local stack_count = stack:get_count()
	local meta = minetest.get_meta(pos_controller)
	local net_index = minetest.deserialize(meta:get_string('net_index'))
	local item_index = net_index[item_name]
	local empty_index = net_index[EMPTY]
	local handler
	local index
	local pos_cabinet
	local checked
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
end -- drawers.controller.insert_to_drawers

function drawers.controller.can_dig(pos_controller, player)
	local meta = minetest.get_meta(pos_controller);
	local inventory = meta:get_inventory()
	return inventory:is_empty('src')
end

function drawers.controller.on_construct(pos_controller)
	local meta = minetest.get_meta(pos_controller)
	meta:set_string('net_index', '')
	meta:set_int('use_all', 0)
	meta:set_string('formspec', drawers.controller.gui.formspec(pos_controller))
	meta:get_inventory():set_size('src', 1)
	-- TODO add inventory for upgrades that can be distributed to all cabinets
	--	needs to be discussed how many slots to make avaailable
	--meta:get_inventory():set_size('upgrades', 3)
	drawers.controller.update_controllers_near(pos_controller)
end -- drawers.controller.on_construct

function drawers.controller.on_blast(pos_controller)
	local drops = {}
	default.get_inventory_drops(pos_controller, 'src', drops)
--	default.get_inventory_drops(pos_controller, 'upgrades', drops)
	table.insert(drops, 'drawers:controller')
	minetest.remove_node(pos_controller)
	return drops
end -- drawers.controller.on_blast

--- check if stack can be inserted
-- called by inventory activity, when items are put into slot in formspec
-- called also when tubes inquire about inserting items
-- return amount of items that can be put (up to stacks count)
function drawers.controller.allow_metadata_inventory_put(
								pos_controller, list_name, index, stack, player)

print('controller_allow_metadata_inventory_put')
	if 'src' ~= list_name or not player then
		return 0
	end
	if minetest.is_protected(pos_controller, player:get_player_name()) then
		return 0
	end
	local space = drawers.controller.has_space_for(pos_controller, stack)
	return space
end -- drawers.controller.allow_metadata_inventory_put

function drawers.controller.has_space_for(pos_controller, stack, have_scanned)
	local use_all = 0 < minetest.get_meta(pos_controller):get_int('use_all')
	local item_name = stack:get_name()
print(item_name, stack:get_count(), stack:get_stack_max())
	local meta = minetest.get_meta(pos_controller)
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
		return drawers.controller.has_space_for(pos_controller, stack, true)
	end
	return space_found
end -- drawers.controller.has_space_for

--- called when user moves items around inventories
-- TODO: check when and what really happens
-- return amount of items that can be put
function drawers.controller.allow_metadata_inventory_move(pos_controller,
						from_list, from_index, to_list, to_index, count, player)

	local meta = minetest.get_meta(pos_controller)
	local inventory = meta:get_inventory()
	local stack = inventory:get_stack(from_list, from_index)
	return drawers.controller.allow_metadata_inventory_put(
						pos_controller, to_list, to_index, stack, player)
end -- drawers.controller.allow_metadata_inventory_move

--- called when player takes stack out of formspec inventory
-- return amount of items allowed to be removed
function drawers.controller.allow_metadata_inventory_take(pos_controller,
												list_name, index, stack, player)

	if minetest.is_protected(pos_controller, player:get_player_name()) then
		return 0
	end
	-- let them have any amount, seeing that they got it in there already
	return stack:get_count()
end -- drawers.controller.allow_metadata_inventory_take

--- called after allow_metadata_inventory_put when player puts stack into
-- formspec inventory.
function drawers.controller.on_metadata_inventory_put(pos_controller, list_name,
														index, stack, player)

print('controller_on_metadata_inventory_put')
	if 'src' ~= list_name then
		return
	end
	local inventory = minetest.get_meta(pos_controller):get_inventory()

	local complete_stack = inventory:get_stack(list_name, 1)
	local leftover = drawers.controller.insert_to_drawers(pos_controller,
															complete_stack)

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

