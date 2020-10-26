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
		if value >= drawers.settings.controller_range then
			return false
		end
		index = index - 1
	until 0 == index
	return true
end -- pos_in_range

function drawers.controller.add_cabinet_to_inventory(cabinet_inventory, pos_cabinet)
	local handler = drawers.cabinet.handler_for(pos_cabinet, true)
	if not handler then
		-- this is unlikely to happen
		return
	end
	local item_name, override, handler2, index_cabinet2, space2
	local id = handler.drawer_count
	repeat
		item_name = handler:item_name_for(id)
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
					space2 = handler2:free_space_for(index_cabinet2.tag_id)
					override = space2 < handler:free_space_for(id)
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

--- search for cabinets that are connected to controller
--find_connected_drawers
function drawers.controller.find_connected_drawers(pos_controller, pos_next, found_positions)
	found_positions = found_positions or {}
	pos_next = pos_next or pos_controller

	local new_positions = minetest.find_nodes_in_area(
		vector.subtract(pos_next, 1), vector.add(pos_next, 1),
		{ 'group:drawers', 'group:drawers_connector' }
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
			--not is_same_pos(pos_next, pos_new) and not
			contains_pos(found_positions, pos_new)
			and pos_in_range(pos_controller, pos_new)
		then
			-- add new position
			table.insert(found_positions, pos_new)
			-- search for other drawers from the new position
			drawers.controller.find_connected_drawers(pos_controller, pos_new, found_positions)
		end
		index = index - 1
	until 0 == index

	return found_positions
end -- drawers.controller.find_connected_drawers

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
	local connected_cabinets = find_connected_cabinets(pos_controller)
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
			local content = handler:contents_for(entry.tag_id)
			if content.name ~= item_name
				or content.count >= content.max_count
			then
				-- if there is none with less content, it will be added again
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
	if '' == handler:item_name_for(tag_id) then
		local leftover = handler:try_insert_stack(tag_id, stack, true)

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
	-- Inizialize metadata
	local meta = minetest.get_meta(pos_controller)
	local item_name = stack:get_name()
	local use_all = 0 < meta:get_int('use_all')
	local leftover = stack

	local net_index = drawers.controller.get_drawer_index(pos_controller, item_name)

	-- We check if there is a drawer with the item and it isn't full. We will
	-- put the items we can into it.
	if net_index[item_name] then
		local pos_cabinet = net_index[item_name].pos_cabinet
		local tag_id = net_index[item_name].tag_id
		local handler = drawers.cabinet.handler_for(pos_cabinet, true)
		if not handler then
			-- should not happen, but if it does we fail silently
			return leftover
		end
		-- If the the item in the drawer is the same as the one we are trying to
		-- store, the drawer is not full, we will put the items in the drawer
		if handler:item_name_for(tag_id) == item_name
			and 0 < handler:free_space_for(tag_id)
		then
			leftover = handler:try_insert_stack(tag_id, stack, true)
			if 0 < leftover:get_count() and use_all then
				leftover = drawers.controller.insert_to_empty_drawer(pos_controller, leftover)
			end
		elseif use_all then
			leftover = drawers.controller.insert_to_empty_drawer(pos_controller, stack)
		end
	else
		leftover = drawers.controller.insert_to_empty_drawer(pos_controller, stack)
	end

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
-- return amount of items that can be put
function drawers.controller.allow_metadata_inventory_put(
								pos_controller, list_name, index, stack, player)

print('controller_allow_metadata_inventory_put')
	if 'src' ~= list_name or not player then
		return 0
	end
	if minetest.is_protected(pos_controller, player:get_player_name()) then
		return 0
	end

	local use_all = 0 < minetest.get_meta(pos_controller):get_int('use_all')
	local item_name = stack:get_name()
print(item_name, stack:get_count(), stack:get_stack_max())
	local net_index = drawers.controller.get_drawer_index(pos_controller, item_name)
	local index = net_index[item_name]
	local index_empty = drawer_net_index[EMPTY]

	if index then
		local pos_cabinet = index.pos_cabinet
		local tag_id = index.tag_id
		handler = drawers.cabinet.handler_for(pos_cabinet, true)
		if not handler then
			-- TODO see if this ever happens, for now refuse to take items
			return 0
		end

		if handler:item_name_for(tag_id) == item_name then
			local fits = handler:how_many_can_insert(tag_id, stack)
print('fit', fits, 'use_all', use_all)
			local diff = stack:get_count() - fits
			if use_all and 0 < diff then
print('need additional drawer')
				-- check if there is an empty drawer available
				-- TODO: (in another round of changes)
				--       refactor the way drawers deal with max size
				--       and add capability to handle stacks bigger than what
				--       can fit in one drawer
				if index_empty then
					local handler2 = drawers.cabinet.handler_for(index_empty.pos_cabinet, true)
					if handler2 then
						if '' == handler2:item_name_for(index_empty.tag_id) then
							local leftover = ItemStack({ name = item_name, count = diff })
							fits = fits + handler:how_many_can_insert(index_empty.tag_id, leftover)
						end
					end -- if got handler 2
				end
			end -- if spill over into other cabinet
			return fit
		end -- if got handler
	end -- if got index for item

	if index_empty then
		handler = drawers.cabinet.handler_for(index_empty.pos_cabinet, true)
		if not handler then
			return 0
		end
		if '' == handler:item_name_for(index_empty.tag_id) then
			return handler:how_many_can_insert(index_empty.tag_id, stack)
		end
	end -- if got empty drawer

	return 0
end -- allow_metadata_inventory_put

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

	local complete_staick = inventory:get_stack(list_name, 1)
	local leftover = drawers.controller.insert_to_drawers(pos_controller, complete_stack)
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

