--
-- drawers/lua/cabinet/cabinet.lua
--
--
-- cabinet functions that are not part of register
--

-- probably will contain most of what was in api.lua
local S, NS = dofile(drawers.modpath .. '/intllib.lua')

function drawers.cabinet.update_upgrades(pos)
	local node = minetest.get_node(pos)
	local node_definition = minetest.registered_nodes[node.name]
	local drawer_count = node_definition.groups.drawers

	-- default number of slots stackf
	local stack_max_factor = node_definition.drawers_stack_max_factor

	-- storage percent with all upgrades
	local storage_percent = 100

	-- get info of all upgrades
	local inventory = minetest.get_meta(pos):get_inventory():get_list('upgrades')
	pd(inventory)
	for _, stack in ipairs(inventory) do
		local name = stack:get_name()
		local item_def = minetest.registered_items[name]
		local add_to_percent = item_def.groups.drawer_upgrade or 0

		storage_percent = storage_percent + add_to_percent
	end

	-- i.e.: 150% / 100 => 1.50
	stack_max_factor = math.floor(stack_max_factor * (storage_percent * 0.01))
	-- calculate stack_max factor for a single drawer
	stack_max_factor = math.floor(stack_max_factor / drawer_count)

	-- set the new stack max factor in all tags
	local tags = drawers.tag.map.tags_for(pos)
	if not tags then
		return
	end

	for _, tag in ipairs(tags) do
		tag:set_stack_max_factor(stack_max_factor)
	end
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

function drawers.cabinet.on_construct(pos)
	local node = minetest.get_node(pos)
	local node_def = minetest.registered_nodes[node.name]
	local drawer_count = node_def.groups.drawers

	local base_stack_max = minetest.nodedef_default.stack_max or 99
	local stack_max_factor = node_def.drawers_stack_max_factor or 24 -- 3x8
	stack_max_factor = math.floor(stack_max_factor / drawer_count)
	local max_count = base_stack_max * stack_max_factor

	-- meta
	local meta = core.get_meta(pos)

	local id = drawer_count
	local infotext
	-- TODO: this feels like a duplication of what tag.save_metadata does
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

	-- spawn all tag entities
	drawers.tag.map.spawn_for(pos)

	-- create drawer upgrade inventory
	meta:get_inventory():set_size('upgrades', 5)

	-- set the formspec
	meta:set_string('formspec', drawers.cabinet.gui.formspec)
end -- drawers.cabinet.on_construct

-- destruct drawer
function drawers.cabinet.on_destruct(pos)
	drawers.tag.map.remove_for(pos)
end -- drawers.cabinet.on_destruct

-- drop all items
function drawers.cabinet.on_dig(pos, node, player)
	local player_name = player:get_player_name()
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return 0
	end

	local node_def = minetest.registered_nodes[node.name]
	local drawer_count = node_def.groups.drawers
	local meta = minetest.get_meta(pos)

	local count, name, stack_max, count_stacks, pos_rand
	local id = drawer_count
	-- TODO: add easter egg for 13th Fridays if drawer with glass inside is dug
	--		drop fragments instead of glass
	--		maybe only if server is booted on a Friday the 13th to avoid
	--		calculations for something trivial like this. There are also other
	--		ways to avoid checking here more than a flag.
	while 0 < id do
		count = meta:get_int('count' .. id)
		name = meta:get_string('name' .. id)
		stack_max = ItemStack(name):get_stack_max()

		count_stacks = math.floor(count / stack_max) + 1
		while 0 < count_stacks do
			pos_rand = drawers.cabinet.randomize_pos(pos)
			if 1 == count_stacks then
				minetest.add_item(pos_rand, name .. ' ' .. (count % stack_max))
			else
				minetest.add_item(pos_rand, name .. ' ' .. stack_max)
			end
			count_stacks = count_stacks - 1
		end -- loop stacks
		id = id - 1
	end -- loop id

	-- drop all drawer upgrades
	local upgrade_slots = meta:get_inventory():get_list('upgrades')
	if upgrade_slots then
		for _, stack in ipairs(upgrade_slots) do
			if 0 < stack:get_count() then
				pos_rand = drawers.cabinet.randomize_pos(pos)
				minetest.add_item(pos_rand, stack:get_name())
			end
		end
	end -- if got list

	-- remove node
	core.node_dig(pos, node, player)
end -- drawers.cabinet.on_dig

function drawers.cabinet.allow_upgrade_change(pos, list_name, index, stack, player)
	local player_name = player:get_player_name()
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return 0
	end

	if 'upgrades' ~= list_name then
		return 0
	end

	-- TODO: test if this works as expected with stackable upgrades
	if 1 < stack:get_count() then
		return 0
	end

	if 1 > minetest.get_item_group(stack:get_name(), 'drawers_increment') then
		return 0
	end

	return 1
end -- drawers.cabinet.allow_upgrade_change

--function drawers.cabinet.add_drawer_upgrade(pos, list_name, index, stack, player)
function drawers.cabinet.add_drawer_upgrade(pos, list_name)
	-- only do anything if adding to upgrades
	if 'upgrades' ~= list_name then
		return
	end

	drawers.cabinet.update_drawer_upgrades(pos)
end -- drawers.cabinet.add_drawer_upgrade

--function drawers.cabinet.remove_drawer_upgrade(pos, list_name, index, stack, player)
function drawers.cabinet.remove_drawer_upgrade(pos, list_name)
	-- only do anything if revoving from upgrades
	if 'upgrades' ~= list_name then
		return
	end

	drawers.cabinet.update_drawer_upgrades(pos)
end -- drawers.cabinet.remove_drawer_upgrade

-- Inserts an incoming stack into a specific drawer of a cabinet.
function drawers.cabinet.insert_object(pos, stack, tag_id)
	local tag = drawers.tag.map.tag_at(pos, tag_id)
	if not tag then
		return stack
	end

	return tag:try_insert_stack(stack, true)
end -- drawers.cabinet.insert_object


-- Inserts an incoming stack into a cabinet and uses all drawers
function drawers.cabinet.insert_object_from_tube(pos, node, stack, direction)
	local tags = drawers.tag.map.tags_for(pos)
	if not tags then
		return stack
	end

	-- first try to insert in the correct drawer (if there are already items)
	local leftover = stack
	local item_name = stack:get_name()
	for _, tag in ipairs(tags) do
		if item_name == tag.item_name then
			leftover = tag:try_insert_stack(leftover, true)
		end
	end

	-- if there's still something left, also use other drawers
	if 0 < leftover:get_count() then
		for _, tag in ipairs(tags) do
			leftover = tag:try_insert_stack(leftover, true)
		end
	end

	return leftover
end -- drawers.cabinet.insert_object_from_tube

-- Returns how much (count) of a stack can be inserted to a cabinet drawer.
function drawers.cabinet.can_insert_stack(pos, stack, tag_id)
	local tag = drawers.tag.map.tag_at(pos, tag_id)
	if not tag then
		return 0
	end

	return tag:can_insert_stack(stack)
end -- drawers.cabinet.can_insert_stack

-- Returns whether a stack can be (partially) inserted to any drawer of a cabinet.
function drawers.cabinet.can_insert_stack_from_tube(pos, node, stack, direction)
	local tags = drawers.tag.map.tags_for(pos)
	if not tags then
		return false
	end

	for _, tag in ipairs(tags) do
		if 0 < tag:can_insert_stack(stack) then
			return true
		end
	end
	return false
end -- drawers.cabinet.can_insert_stack_from_tube

function drawers.cabinet.take_item(pos, stack)
	local tags = drawers.tag.map.tags_for(pos)
	if not tags then
		return ItemStack()
	end

	-- limit count to stack_max
	local count = math.min(stack:get_count(), stack:get_stack_max())

	local name = stack:get_name()
	for _, tag in ipairs(tags) do
		if name == tag.item_name then
			return tag:take_items(count)
		end
	end

	return ItemStack()
end -- drawers.cabinet.take_item

-- Returns the content of a cabinet's drawer.
function drawers.cabinet.get_content(pos, tag_id)
	local meta = core.get_meta(pos)
	return {
		count = meta:get_int('count' .. tag_id),
		name = meta:get_string('name' .. tag_id),
		max_count = meta:get_int('max_count' .. tag_id),
	}
end -- drawers.cabinet.get_content

