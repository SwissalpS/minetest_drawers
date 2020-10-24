--
-- drawers/lua/tag/register.lua
--

local entity_def = {
	initial_properties = {
		collide_with_objects = false,
		collisionbox = { -0.4374, -0.4374, 0,  0.4374, 0.4374, 0 }, -- for param2 0, 2
		hp_max = 1,
		initial_sprite_basepos = { x = 0, y = 0 },
		is_visible = true,
		physical = false,
		spritediv = { x = 1, y = 1 },
		textures = { 'blank.png' },
		visual = 'upright_sprite', -- 'wielditem' for items without inv img?
		visual_size = { x = 0.6, y = 0.6 },
	},

	-- this is called when entity is deactivated, it MUST return a string.
	-- this string will be passed to on_activate when entity is restored.
	get_staticdata = drawers.tag.get_serialized_static_data,
	-- this is called when entity is activated for first time or reactivated.
	on_activate = drawers.tag.on_activate,
	-- called when player right clicks entity with or without something in hand.
	-- to put items in
	on_rightclick = drawers.tag.handle_use_put,
	-- to take items out
	on_punch = drawers.tag.handle_punch_take,
	-- custom field, was renamed
	update_infotext = drawers.tag.update_infotext,
	-- called whenever items are put in or taken out manually
	-- custom field, could be renamed
	play_interact_sound = drawers.tag.play_interact_sound,
	migrate_cabinet_meta = drawers.tag.migrate_cabinet_meta

} -- entity_def

local function lbm_action(pos, node)
	local meta = minetest.get_meta(pos)
	-- create drawer upgrade inventory
	meta:get_inventory():set_size('upgrades', 5)

	-- set the formspec
	meta:set_string('formspec', drawers.cabinet.formspec)

	-- count the drawer tags
	local drawer_count = minetest.registered_nodes[node.name].groups.drawers
	local found_tags = 0
	local objects = minetest.get_objects_inside_radius(pos, 0.56)
	local luaentity
	if objects then
		for _, object in ipairs(objects) do
			luaentity = object:get_luaentity()
			-- TODO: test if we need to check for nil objects and luaentities
			if 'drawers:visual' == luaentity.name then
				found_tags = found_tags + 1
			end -- if
		end -- loop all found objects
	end -- if any objects found at all

	-- if all drawer tags were found, return
	if found_tags == drawer_count then
		return
	end

	-- not enough tags found, remove existing and create new ones
	drawers.tag.map.remove_for(pos)
	drawers.tag.map.spawn_for(pos)

end -- lbm_action

local lbm_def = {
	name = 'drawers:restore_visual',
	nodenames = { 'group:drawers' },
	run_at_every_load = true,
	action  = lbm_action
}

minetest.register_entity('drawers:visual', entity_def)
minetest.register_lbm(lbm_def)

