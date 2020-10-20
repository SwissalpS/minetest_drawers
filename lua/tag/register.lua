--
-- drawers/lua/tag/register.lua
--
-- Load support for intllib.
local S, NS = dofile(drawers.modpath .. '/intllib.lua')

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
	-- take n items from drawer
	-- custom field, could be renamed
	take_items = drawers.tag.take_items,
	-- take a stack from drawer
	-- custom field, could be renamed
	take_stack = drawers.tag.take_stack,
	-- investigate how many would fit in from given ItemStack
	-- custom field, was renamed
	how_many_can_insert = drawers.tag.how_many_can_insert,
	-- insert as many as can fit
	-- custom field, could be renamed
	try_insert_stack = drawers.tag.try_insert_stack,
	-- custom field, was renamed
	update_infotext = drawers.tag.update_infotext,
	-- custom field, was renamed
	update_texture = drawers.tag.update_texture,
	-- when upgrades are removed. called by drop_overload
	-- custom field, was renamed
	drop_stack = drawers.tag.drop_stack,
	-- drop overflow when upgrades are removed and items no longer fit
	-- custom field, was renamed
	drop_overload = drawers.tag.drop_overload,
	-- called when upgrades are removed (or added)
	-- custom field, was renamed
	set_stack_max_factor = drawers.tag.set_stack_max_factor,
	-- called whenever items are put in or taken out manually
	-- custom field, could be renamed
	play_interact_sound = drawers.tag.play_interact_sound,
	-- dump our parameters into cabinet meta data
	-- custom field, was renamed
	save_metadata = drawers.tag.save_metadata,

} -- entity_def

local function lbm_action(pos, node)
	local meta = minetest.get_meta(pos)
	-- create drawer upgrade inventory
	meta:get_inventory():set_size('upgrades', 5)

	-- set the formspec
	meta:set_string('formspec', drawers.cabinet.formspec)

	-- count the drawer tags
	local drawer_type = minetest.registered_nodes[node.name].groups.drawers
	local found_tags = 0
	local objects = minetest.get_objects_inside_radius(pos, 0.56)
	local luaentity
	if objects then
		for _, object in pairs(objects) do
			luaentity = object:get_luaentity()
			-- TODO: test if we need to check for nil objects and luaentities
			if 'drawers:visual' == luaentity().name then
				found_tags = found_tags + 1
			end -- if
		end -- loop all found objects
	end -- if any objects found at all

	-- if all drawer tags were found, return
	if found_tags == drawer_type then
		return
	end

	-- not enough tags found, remove existing and create new ones
	drawers.tag.remove_tags(pos)
	drawers.tag.spawn_tags(pos)

end -- lbm_action

local lbm_def = {
	name = 'drawers:restore_visual',
	nodenames = { 'group:drawers' },
	run_at_every_load = true,
	action  = lbm_action
}

minetest.register_entity('drawers:visual', entity_def)
minetest.register_lbm(lbm_def)

