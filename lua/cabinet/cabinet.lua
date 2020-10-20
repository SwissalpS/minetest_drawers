--
-- drawers/lua/cabinet/cabinet.lua
--
--
-- cabinet functions that are not part of register
--

-- probably will contain most of what was in api.lua
local S, NS = dofile(drawers.modpath .. '/intllib.lua')

function drawers.cabinet.update_upgrades(pos)
	local node = core.get_node(pos)
	local ndef = core.registered_nodes[node.name]
	local drawerType = ndef.groups.drawers

	-- default number of slots/stacks
	local stackMaxFactor = ndef.drawer_stack_max_factor

	-- storage percent with all upgrades
	local storagePercent = 100

	-- get info of all upgrades
	local inventory = core.get_meta(pos):get_inventory():get_list("upgrades")
	for _,itemStack in pairs(inventory) do
		local iname = itemStack:get_name()
		local idef = core.registered_items[iname]
		local addPercent = idef.groups.drawer_upgrade or 0

		storagePercent = storagePercent + addPercent
	end

	--						i.e.: 150% / 100 => 1.50
	stackMaxFactor = math.floor(stackMaxFactor * (storagePercent / 100))
	-- calculate stack_max factor for a single drawer
	stackMaxFactor = stackMaxFactor / drawerType

	-- set the new stack max factor in all visuals
	local drawer_visuals = drawers.drawer_visuals[core.serialize(pos)]
	if not drawer_visuals then return end

	for _,visual in pairs(drawer_visuals) do
		visual:setStackMaxFactor(stackMaxFactor)
	end
end -- drawers.cabinet.update_upgrades

function drawers.cabinet.randomize_pos(pos)
	local rndpos = table.copy(pos)
	local x = math.random(-50, 50) * 0.01
	local z = math.random(-50, 50) * 0.01
	rndpos.x = rndpos.x + x
	rndpos.y = rndpos.y + 0.25
	rndpos.z = rndpos.z + z
	return rndpos
end -- drawers.cabinet.randomize_pos-- construct drawer

function drawers.drawer_on_construct(pos)
	local node = core.get_node(pos)
	local ndef = core.registered_nodes[node.name]
	local drawerType = ndef.groups.drawer

	local base_stack_max = core.nodedef_default.stack_max or 99
	local stack_max_factor = ndef.drawer_stack_max_factor or 24 -- 3x8
	stack_max_factor = math.floor(stack_max_factor / drawerType) -- drawerType => number of drawers in node

	-- meta
	local meta = core.get_meta(pos)

	local i = 1
	while i <= drawerType do
		local vid = i
		-- 1x1 drawers don't have numbers in the meta fields
		if drawerType == 1 then vid = "" end
		meta:set_string("name"..vid, "")
		meta:set_int("count"..vid, 0)
		meta:set_int("max_count"..vid, base_stack_max * stack_max_factor)
		meta:set_int("base_stack_max"..vid, base_stack_max)
		meta:set_string("entity_infotext"..vid, drawers.gen_info_text(S("Empty"), 0,
			stack_max_factor, base_stack_max))
		meta:set_int("stack_max_factor"..vid, stack_max_factor)

		i = i + 1
	end

	-- spawn all visuals
	drawers.spawn_visuals(pos)

	-- create drawer upgrade inventory
	meta:get_inventory():set_size("upgrades", 5)

	-- set the formspec
	meta:set_string("formspec", drawers.drawer_formspec)
end

-- destruct drawer
function drawers.drawer_on_destruct(pos)
	drawers.remove_visuals(pos)

	-- clean up visual cache
	if drawers.drawer_visuals[core.serialize(pos)] then
		drawers.drawer_visuals[core.serialize(pos)] = nil
	end
end

-- drop all items
function drawers.drawer_on_dig(pos, node, player)
	local drawerType = 1
	if core.registered_nodes[node.name] then
		drawerType = core.registered_nodes[node.name].groups.drawer
	end
	if core.is_protected(pos,player:get_player_name()) then
	   core.record_protection_violation(pos,player:get_player_name())
	   return 0
	end
	local meta = core.get_meta(pos)

	local k = 1
	while k <= drawerType do
		-- don't add a number in meta fields for 1x1 drawers
		local vid = tostring(k)
		if drawerType == 1 then vid = "" end
		local count = meta:get_int("count"..vid)
		local name = meta:get_string("name"..vid)

		-- drop the items
		local stack_max = ItemStack(name):get_stack_max()

		local j = math.floor(count / stack_max) + 1
		local i = 1
		while i <= j do
			local rndpos = drawers.randomize_pos(pos)
			if not (i == j) then
				core.add_item(rndpos, name .. " " .. stack_max)
			else
				core.add_item(rndpos, name .. " " .. count % stack_max)
			end
			i = i + 1
		end
		k = k + 1
	end

	-- drop all drawer upgrades
	local upgrades = meta:get_inventory():get_list("upgrades")
	if upgrades then
		for _,itemStack in pairs(upgrades) do
			if itemStack:get_count() > 0 then
				local rndpos = drawers.randomize_pos(pos)
				core.add_item(rndpos, itemStack:get_name())
			end
		end
	end

	-- remove node
	core.node_dig(pos, node, player)
end

function drawers.drawer_allow_metadata_inventory_put(pos, listname, index, stack, player)
	if core.is_protected(pos,player:get_player_name()) then
	   core.record_protection_violation(pos,player:get_player_name())
	   return 0
	end
	if listname ~= "upgrades" then
		return 0
	end
	if stack:get_count() > 1 then
		return 0
	end
	if core.get_item_group(stack:get_name(), "drawer_upgrade") < 1 then
		return 0
	end
	return 1
end

function drawers.add_drawer_upgrade(pos, listname, index, stack, player)
	-- only do anything if adding to upgrades
	if listname ~= "upgrades" then return end

	drawers.update_drawer_upgrades(pos)
end

function drawers.remove_drawer_upgrade(pos, listname, index, stack, player)
	-- only do anything if adding to upgrades
	if listname ~= "upgrades" then return end

	drawers.update_drawer_upgrades(pos)
end

--[[
	Inserts an incoming stack into a specific slot of a drawer.
]]
function drawers.drawer_insert_object(pos, stack, visualid)
	local visual = drawers.get_visual(pos, visualid)
	if not visual then
		return stack
	end

	return visual:try_insert_stack(stack, true)
end

--[[
	Inserts an incoming stack into a drawer and uses all slots.
]]
function drawers.drawer_insert_object_from_tube(pos, node, stack, direction)
	local drawer_visuals = drawers.drawer_visuals[core.serialize(pos)]
	if not drawer_visuals then
        return stack
    end

	-- first try to insert in the correct slot (if there are already items)
	local leftover = stack
	for _, visual in pairs(drawer_visuals) do
		if visual.itemName == stack:get_name() then
			leftover = visual:try_insert_stack(leftover, true)
		end
	end

	-- if there's still something left, also use other slots
	if leftover:get_count() > 0 then
		for _, visual in pairs(drawer_visuals) do
			leftover = visual:try_insert_stack(leftover, true)
		end
	end
	return leftover
end

--[[
	Returns how much (count) of a stack can be inserted to a drawer slot.
]]
function drawers.drawer_can_insert_stack(pos, stack, visualid)
	local visual = drawers.get_visual(pos, visualid)
	if not visual then
		return 0
	end

	return visual:can_insert_stack(stack)
end

--[[
	Returns whether a stack can be (partially) inserted to any slot of a drawer.
]]
function drawers.drawer_can_insert_stack_from_tube(pos, node, stack, direction)
	local drawer_visuals = drawers.drawer_visuals[core.serialize(pos)]
	if not drawer_visuals then
		return false
	end

	for _, visual in pairs(drawer_visuals) do
	   if visual:can_insert_stack(stack) > 0 then
	      return true
	   end
	end
	return false
end

function drawers.drawer_take_item(pos, itemstack)
	local drawer_visuals = drawers.drawer_visuals[core.serialize(pos)]

	if not drawer_visuals then
		return ItemStack("")
	end

	-- check for max count
	if itemstack:get_count() > itemstack:get_stack_max() then
		itemstack:set_count(itemstack:get_stack_max())
	end

	for _, visual in pairs(drawer_visuals) do
		if visual.itemName == itemstack:get_name() then
			return visual:take_items(itemstack:get_count())
		end
	end

	return ItemStack()
end

--[[
	Returns the content of a drawer slot.
]]
function drawers.drawer_get_content(pos, visualid)
	local drawer_meta = core.get_meta(pos)

	return {
		name = drawer_meta:get_string("name" .. visualid),
		count = drawer_meta:get_int("count" .. visualid),
		maxCount = drawer_meta:get_int("max_count" .. visualid)
	}
end

