--
--- drawers/lua/lbm.lua
--
-- lbm is run after entities have already been restored.
-- need to migrate in handler for most part.
local function lbm_cabinet_action(pos_cabinet, node)

	local meta = minetest.get_meta(pos_cabinet)
	-- create drawer upgrade inventory
	meta:get_inventory():set_size('upgrades', 5)
	-- set the formspec
	meta:set_string('formspec', drawers.cabinet.gui.formspec)

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
	name = 'drawers:rewrite20201031cabinet',
	nodenames = { 'group:drawers' },
	run_at_every_load = false,
	action  = lbm_cabinet_action
}

local lbm_controller_def = {
	name = 'drawers:rewrite20201031controller',
	nodenames = { 'drawers:controller' },
	run_at_every_load = false,
	action  = lbm_controller_action
}

minetest.register_lbm(lbm_cabinet_def)
minetest.register_lbm(lbm_controller_def)

