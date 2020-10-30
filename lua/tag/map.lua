--
-- drawers/lua/tag/map.lua
--
-- maps tags to cabinets and deals with spawning and destroying tags
-- TODO: this could now be moved back into tag.lua, not sure if it needs to
drawers.tag.map = {}

-- helper for spawn_for()
-- TODO this hardly earns it's own method anymore
local function cleanup_tmp()
	drawers.tmp.new_tag_id = nil
end

-- helper for spawn_for()
local function rotate_tag(bdir, object)
	if bdir.x < 0 then object:set_yaw(0.5 * math.pi) end
	if bdir.z < 0 then object:set_yaw(math.pi) end
	if bdir.x > 0 then object:set_yaw(1.5 * math.pi) end
end

--- add tag reference to hash table for quick lookup
function drawers.tag.map.cache_tag(tag)
	local pos_hash = minetest.hash_node_position(tag.pos_cabinet)
	if not drawers.tag.tags[pos_hash] then
		drawers.tag.tags[pos_hash] = {}
	end

	local id = tonumber(tag.tag_id)
	-- TODO do we still get nil id on migration?
	if nil == id or 0 == id then
		id = 1
	end
	drawers.tag.tags[pos_hash][id] = tag
end -- drawers.tag.map.cache_tag

-- remove tags for cabinet at position pos
function drawers.tag.map.remove_for(pos_cabinet)
	local objects = minetest.get_objects_inside_radius(pos_cabinet, 0.56)
	if not objects then
		return
	end

	local luaentity, object
	local index = #objects
	if 0 == index then
		return
	end

	repeat
		object = objects[index]
		luaentity = object:get_luaentity()
		if luaentity and 'drawers:visual' == luaentity.name then
			object:remove()
		end
		index = index - 1
	until 0 == index

	local pos_hash = minetest.hash_node_position(pos_cabinet)
	drawers.tag.tags[pos_hash] = nil
end -- drawers.tag.map.remove_for

-- create tags for the cabinet at position pos_cabinet
function drawers.tag.map.spawn_for(pos_cabinet)
	local node = minetest.get_node_or_nil(pos_cabinet)
	if not node then return end

	local node_def = minetest.registered_nodes[node.name]
	local drawer_count = node_def.groups.drawers

	local bdir = minetest.facedir_to_dir(node.param2)
	local entity_name = 'drawers:visual'
	local object
	local pos_entity

	if 1 == drawer_count then
		-- 1x1 cabinet

		drawers.tmp.new_tag_id = '1'

		local fdir = vector.new(-bdir.x, 0, -bdir.z)
		pos_entity = vector.add(pos_cabinet, vector.multiply(fdir, 0.45))

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
		pos_entity = vector.add(pos_cabinet, vector.multiply(fdir1, 0.45))
		object = minetest.add_entity(pos_entity, entity_name)
		rotate_tag(bdir, object)

		drawers.tmp.new_tag_id = '2'
		pos_entity = vector.add(pos_cabinet, vector.multiply(fdir2, 0.45))
		object = minetest.add_entity(pos_entity, entity_name)
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
		pos_entity = vector.add(pos_cabinet, vector.multiply(fdir1, 0.45))
		object = minetest.add_entity(pos_entity, entity_name)
		rotate_tag(bdir, object)

		drawers.tmp.new_tag_id = '2'
		pos_entity = vector.add(pos_cabinet, vector.multiply(fdir2, 0.45))
		object = minetest.add_entity(pos_entity, entity_name)
		rotate_tag(bdir, object)

		drawers.tmp.new_tag_id = '3'
		pos_entity = vector.add(pos_cabinet, vector.multiply(fdir3, 0.45))
		object = minetest.add_entity(pos_entity, entity_name)
		rotate_tag(bdir, object)

		drawers.tmp.new_tag_id = '4'
		pos_entity = vector.add(pos_cabinet, vector.multiply(fdir4, 0.45))
		object = minetest.add_entity(pos_entity, entity_name)
		rotate_tag(bdir, object)

	end -- switch cabinet type
end -- drawers.tag.map.spawn_for

function drawers.tag.map.tag_for(pos_cabinet, tag_id)
	local tags = drawers.tag.map.tags_for(pos_cabinet)
	if tags then
		local id = tonumber(tag_id)
		if 0 == id then
			id = 1
		end

		return tags[id]
	end

	return nil
end -- drawers.tag.map.tag_for

-- so we don't need to update this code in many places
function drawers.tag.map.tags_for(pos_cabinet)
	local pos_hash = minetest.hash_node_position(pos_cabinet)
	return drawers.tag.tags[pos_hash]
end -- drawers.tag.map.tags_for

