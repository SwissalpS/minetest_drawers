--
-- drawers/lua/tag/map.lua
--
-- maps tags to cabinets and deals with spawning and destroying tags
drawers.tag.map = {}

-- fetch reference to tag object with id for cabinet at position
-- tag_id may be: empty string, string containing 1-4, or number 1-4
function drawers.tag.map.tag_at(cabinet_pos, tag_id)
	-- TODO: proper location and hashing
	local drawer_tags = drawers.drawer_visuals[core.serialize(pos)]
	if not drawer_tags then
		return nil
	end

	-- clean id
	tag_id = tonumber(tag_id) or 1

	return drawer_tags[tag_id]
end -- drawers.tag.map.tag_at

-- create tags for cabinet at position pos
function drawers.tag.map.spawn_for(pos)
	local node = core.get_node(pos)
	local ndef = core.registered_nodes[node.name]
	local drawerType = ndef.groups.drawer

	-- data for the new visual
	drawers.last_drawer_pos = pos
	drawers.last_drawer_type = drawerType

	if drawerType == 1 then -- 1x1 drawer
		drawers.last_visual_id = ""
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name"))

		local bdir = core.facedir_to_dir(node.param2)
		local fdir = vector.new(-bdir.x, 0, -bdir.z)
		local pos2 = vector.add(pos, vector.multiply(fdir, 0.45))

		local obj = core.add_entity(pos2, "drawers:visual")
		if not obj then return end

		if bdir.x < 0 then obj:set_yaw(0.5 * math.pi) end
		if bdir.z < 0 then obj:set_yaw(math.pi) end
		if bdir.x > 0 then obj:set_yaw(1.5 * math.pi) end

		drawers.last_texture = nil
	elseif drawerType == 2 then
		local bdir = core.facedir_to_dir(node.param2)

		local fdir1
		local fdir2
		if node.param2 == 2 or node.param2 == 0 then
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x, -0.5, -bdir.z)
		else
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x, -0.5, -bdir.z)
		end

		local objs = {}

		drawers.last_visual_id = 1
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name1"))
		local pos1 = vector.add(pos, vector.multiply(fdir1, 0.45))
		objs[1] = core.add_entity(pos1, "drawers:visual")

		drawers.last_visual_id = 2
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name2"))
		local pos2 = vector.add(pos, vector.multiply(fdir2, 0.45))
		objs[2] = core.add_entity(pos2, "drawers:visual")

		for i,obj in pairs(objs) do
			if bdir.x < 0 then obj:set_yaw(0.5 * math.pi) end
			if bdir.z < 0 then obj:set_yaw(math.pi) end
			if bdir.x > 0 then obj:set_yaw(1.5 * math.pi) end
		end
	else -- 2x2 drawer
		local bdir = core.facedir_to_dir(node.param2)

		local fdir1
		local fdir2
		local fdir3
		local fdir4
		if node.param2 == 2 then
			fdir1 = vector.new(-bdir.x + 0.5, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x - 0.5, 0.5, -bdir.z)
			fdir3 = vector.new(-bdir.x + 0.5, -0.5, -bdir.z)
			fdir4 = vector.new(-bdir.x - 0.5, -0.5, -bdir.z)
		elseif node.param2 == 0 then
			fdir1 = vector.new(-bdir.x - 0.5, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x + 0.5, 0.5, -bdir.z)
			fdir3 = vector.new(-bdir.x - 0.5, -0.5, -bdir.z)
			fdir4 = vector.new(-bdir.x + 0.5, -0.5, -bdir.z)
		elseif node.param2 == 1 then
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z + 0.5)
			fdir2 = vector.new(-bdir.x, 0.5, -bdir.z - 0.5)
			fdir3 = vector.new(-bdir.x, -0.5, -bdir.z + 0.5)
			fdir4 = vector.new(-bdir.x, -0.5, -bdir.z - 0.5)
		else
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z - 0.5)
			fdir2 = vector.new(-bdir.x, 0.5, -bdir.z + 0.5)
			fdir3 = vector.new(-bdir.x, -0.5, -bdir.z - 0.5)
			fdir4 = vector.new(-bdir.x, -0.5, -bdir.z + 0.5)
		end

		local objs = {}

		drawers.last_visual_id = 1
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name1"))
		local pos1 = vector.add(pos, vector.multiply(fdir1, 0.45))
		objs[1] = core.add_entity(pos1, "drawers:visual")

		drawers.last_visual_id = 2
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name2"))
		local pos2 = vector.add(pos, vector.multiply(fdir2, 0.45))
		objs[2] = core.add_entity(pos2, "drawers:visual")

		drawers.last_visual_id = 3
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name3"))
		local pos3 = vector.add(pos, vector.multiply(fdir3, 0.45))
		objs[3] = core.add_entity(pos3, "drawers:visual")

		drawers.last_visual_id = 4
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name4"))
		local pos4 = vector.add(pos, vector.multiply(fdir4, 0.45))
		objs[4] = core.add_entity(pos4, "drawers:visual")


		for i,obj in pairs(objs) do
			if bdir.x < 0 then obj:set_yaw(0.5 * math.pi) end
			if bdir.z < 0 then obj:set_yaw(math.pi) end
			if bdir.x > 0 then obj:set_yaw(1.5 * math.pi) end
		end
	end
end -- drawers.tag.map.spawn_for

-- remove tags for cabinet at position pos
function drawers.tag.map.remove_for(pos)
	local objs = core.get_objects_inside_radius(pos, 0.56)
	if not objs then return end

	for _, obj in pairs(objs) do
		if obj and obj:get_luaentity() and
				obj:get_luaentity().name == "drawers:visual" then
			obj:remove()
		end
	end
end -- drawers.tag.map.remove_for

