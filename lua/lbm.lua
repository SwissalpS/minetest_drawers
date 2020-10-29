--
--- drawers/lua/lbm.lua
--
local function lbm_cabinet_action(pos_cabinet, node)
	local key_count = 'count'
	local key_item_name = 'name'
	local key_slots_per_drawer = 'slots_per_drawer'

	local meta = minetest.get_meta(pos_cabinet)
	-- create drawer upgrade inventory
	meta:get_inventory():set_size('upgrades', 5)
	-- set the formspec
	meta:set_string('formspec', drawers.cabinet.gui.formspec)
	-- migrate data
	local drawer_count = minetest.registered_nodes[node.name].groups.drawers
	local tag_id, tag_id_old, max_count, base_stack_max, slots_per_drawer
	local is_single = 1 == drawer_count
	for id = 1, drawer_count, 1 do
		-- single drawer cabinets did not have number
		if is_single then
			tag_id_old = ''
		else
			tag_id_old = tostring(id)
		end
		tag_id = tostring(id)
		if 1 == id then
			max_count = meta:get_int('max_count' .. tag_id_old)
			base_stack_max = meta:get_int('base_stack_max' .. tag_id_old)
			slots_per_drawer = max_count / base_stack_max
			meta:set_int(key_slots_per_drawer, slots_per_drawer)
		end
		meta:set_int(key_count .. tag_id, meta:get_int('count' .. tag_id_old))
		meta:set_string(key_item_name .. tag_id, meta:get_int('name' .. tag_id_old))
		if is_single then
			meta:set_string('base_stack_max', '')
			meta:set_string('count', '')
			meta:set_string('entity_infotext', '')
			meta:set_string('max_count', '')
			meta:set_string('name', '')
			meta:set_string('stack_max_factor', '')
		else
			meta:set_string('base_stack_max' .. tag_id_old, '')
			meta:set_string('entity_infotext' .. tag_id_old, '')
			meta:set_string('max_count' .. tag_id_old, '')
			meta:set_string('stack_max_factor' .. tag_id_old, '')
		end
	end -- loop all drawers in cabinet
	-- this happens once and is easiest way to upgrade,
	-- remove existing and create new ones
	drawers.tag.map.remove_for(pos_cabinet)
	drawers.tag.map.spawn_for(pos_cabinet)
end -- lbm_cabinet_action

local function lbm_controller_action(pos_controller, node)
	local meta = minetest.get_meta(pos_controller)
	-- move old digiline channel to new field
	meta:set_string('channel', meta:get_string('digilineChannel'))
	meta:set_string('digilineChannel', '')
	-- remove old index
	meta:set_string('drawers_table_index', '')
	-- create new index and also set formspec etc.
	drawers.controller.on_construct(pos_controller)
end -- lbm_controller_action

local lbm_cabinet_def = {
	name = 'drawers:rewrite202010cabinet',
	nodenames = { 'group:drawers' },
	run_at_every_load = false,
	action  = lbm_cabinet_action
}

local lbm_controller_def = {
	name = 'drawers:rewrite202010controller',
	nodenames = { 'drawers:controller' },
	run_at_every_load = false,
	action  = lbm_controller_action
}

--minetest.register_lbm(lbm_cabinet_def)
--minetest.register_lbm(lbm_controller_def)

