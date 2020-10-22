--
-- drawers/lua/tag/map.lua
--
-- maps tags to cabinets and deals with spawning and destroying tags
drawers.tag.map = {}

-- so we don't need to update this code in many places
function drawers.tag.map.tags_for(pos_cabinet)
	local pos_hash = minetest.hash_node_position(pos_cabinet)
	return drawers.tag.tags[pos_hash]
end

-- fetch reference to tag object with id for cabinet at position
-- tag_id may be: empty string, string containing 1-4, or number 1-4
function drawers.tag.map.tag_at(pos_cabinet, tag_id)
	local tags = drawers.tag.map.tags_for(pos_cabinet)
	if not tags then
		return nil
	end
	-- clean id
	tag_id = tonumber(tag_id) or 1
	return tags[tag_id]
end -- drawers.tag.map.tag_at

-- helper for spawn_for()
local function cleanup_tmp()
	drawers.tmp.new_tag_id = nil
	drawers.tmp.new_tag_texture = nil
	drawers.tmp.new_cabinet_drawer_count = nil
	drawers.tmp.new_pos_cabinet = nil
end
-- helper for spawn_for()
local function rotate_tag(bdir, object)
	if bdir.x < 0 then object:set_yaw(0.5 * math.pi) end
	if bdir.z < 0 then object:set_yaw(math.pi) end
	if bdir.x > 0 then object:set_yaw(1.5 * math.pi) end
end

-- create tags for the cabinet at position pos
function drawers.tag.map.spawn_for(pos)
	local node = minetest.get_node_or_nil(pos)
	if not node then return end

	local node_def = minetest.registered_nodes[node.name]
	local drawer_count = node_def.groups.drawers

	-- data for the new tag entity
	drawers.tmp.new_pos_cabinet = pos
	drawers.tmp.new_cabinet_drawer_count = drawer_count

	local cabinet_meta = minetest.get_meta(pos)
	local item_name = cabinet_meta:get_string('name1')
	local bdir = minetest.facedir_to_dir(node.param2)
	local entity_name = 'drawers:visual'
	local object
	local pos_entity

	if 1 == drawer_count then
		-- 1x1 cabinet

		drawers.tmp.new_tag_id = '1'
		drawers.tmp.new_tag_texture = drawers.tag.gui.get_image(item_name)

		local fdir = vector.new(-bdir.x, 0, -bdir.z)
		pos_entity = vector.add(pos, vector.multiply(fdir, 0.45))

		object = minetest.add_entity(pos_entity, entity_name)
		if not object then return cleanup_tmp() end

		rotate_tag(bdir, object)

	elseif 2 == drawer_count then
		-- 1x2 cabinet

		local fdir1
		local fdir2
		if 0 == node.param2 or 0 == node.param2 then
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x, -0.5, -bdir.z)
		else
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x, -0.5, -bdir.z)
		end

		drawers.tmp.new_tag_id = '1'
		drawers.tmp.new_tag_texture = drawers.tag.gui.get_image(item_name)
		pos_entity = vector.add(pos, vector.multiply(fdir1, 0.45))
		object = core.add_entity(pos_entity, entity_name)
		rotate_tag(bdir, object)

		item_name = cabinet_meta:get_string('name2')
		drawers.tmp.new_tag_id = '2'
		drawers.tmp.new_tag_texture = drawers.tag.gui.get_image(item_name)
		pos_entity = vector.add(pos, vector.multiply(fdir2, 0.45))
		object = core.add_entity(pos_entity, entity_name)
		rotate_tag(bdir, object)

	else
		-- 2x2 cabinet

		local fdir1
		local fdir2
		local fdir3
		local fdir4
		if 0 == node.param2 then
			fdir1 = vector.new(-bdir.x - 0.5, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x + 0.5, 0.5, -bdir.z)
			fdir3 = vector.new(-bdir.x - 0.5, -0.5, -bdir.z)
			fdir4 = vector.new(-bdir.x + 0.5, -0.5, -bdir.z)
		elseif 1 == node.param2 then
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z + 0.5)
			fdir2 = vector.new(-bdir.x, 0.5, -bdir.z - 0.5)
			fdir3 = vector.new(-bdir.x, -0.5, -bdir.z + 0.5)
			fdir4 = vector.new(-bdir.x, -0.5, -bdir.z - 0.5)
		elseif 2 == node.param2 then
			fdir1 = vector.new(-bdir.x + 0.5, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x - 0.5, 0.5, -bdir.z)
			fdir3 = vector.new(-bdir.x + 0.5, -0.5, -bdir.z)
			fdir4 = vector.new(-bdir.x - 0.5, -0.5, -bdir.z)
		else
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z - 0.5)
			fdir2 = vector.new(-bdir.x, 0.5, -bdir.z + 0.5)
			fdir3 = vector.new(-bdir.x, -0.5, -bdir.z - 0.5)
			fdir4 = vector.new(-bdir.x, -0.5, -bdir.z + 0.5)
		end

		drawers.tmp.new_tag_id = '1'
		drawers.tmp.new_tag_texture = drawers.tag.gui.get_image()
		pos_entity = vector.add(pos, vector.multiply(fdir1, 0.45))
		object = minetest.add_entity(pos_entity, entity_name)
		rotate_tag(bdir, object)

		item_name = cabinet_meta:get_string('name2')
		drawers.tmp.new_tag_id = '2'
		drawers.tmp.new_tag_texture = drawers.tag.gui.get_image(item_name)
		pos_entity = vector.add(pos, vector.multiply(fdir2, 0.45))
		object = minetest.add_entity(pos_entity, entity_name)
		rotate_tag(bdir, object)

		item_name = cabinet_meta:get_string('name3')
		drawers.tmp.new_tag_id = '3'
		drawers.tmp.new_tag_texture = drawers.tag.gui.get_image(item_name)
		pos_entity = vector.add(pos, vector.multiply(fdir3, 0.45))
		object = minetest.add_entity(pos_entity, entity_name)
		rotate_tag(bdir, object)

		item_name = cabinet_meta:get_string('name4')
		drawers.tmp.new_tag_id = '4'
		drawers.tmp.new_tag_texture = drawers.tag.gui.get_image(item_name)
		pos_entity = vector.add(pos, vector.multiply(fdir4, 0.45))
		object = minetest.add_entity(pos_entity, entity_name)
		rotate_tag(bdir, object)

	end -- switch cabinet type
end -- drawers.tag.map.spawn_for

-- remove tags for cabinet at position pos
function drawers.tag.map.remove_for(pos)
	local objects = minetest.get_objects_inside_radius(pos, 0.56)
	if not objects then return end

	local luaentity
	for _, object in ipairs(objects) do
		luaentity = object:get_luaentity()
		if luaentity and 'drawers:visual' == entity.name then
			object:remove()
		end
	end

	local pos_hash = minetest.hash_node_position(pos)
	drawers.tag.tags[pos_hash] = nil
end -- drawers.tag.map.remove_for

