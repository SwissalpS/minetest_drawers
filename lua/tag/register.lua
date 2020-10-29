--
-- drawers/lua/tag/register.lua
--

local entity_def = {
	initial_properties = {
		collide_with_objects = false,
		-- for param2 0, 2
		collisionbox = { -0.4374, -0.4374, 0,  0.4374, 0.4374, 0 },
		hp_max = 1,
		initial_sprite_basepos = { x = 0, y = 0 },
		is_visible = true,
		physical = false,
		spritediv = { x = 1, y = 1 },
		textures = { 'blank.png' },
		-- 'wielditem' for items without inv img?
		visual = 'upright_sprite',
		visual_size = { x = 0.6, y = 0.6 },
	},

	-- this is called when entity is deactivated, it MUST return a string.
	-- this string will be passed to on_activate when entity is restored.
	get_staticdata = drawers.tag.get_serialized_static_data,
	-- this is called when entity is activated for first time or reactivated.
	on_activate = drawers.tag.on_activate,
	-- called when player right clicks entity with or without something in hand.
	-- to put items in
	-- TODO rename to fill and take to be consistent with other methods
	on_rightclick = drawers.tag.handle_use_put,
	-- to take items out
	on_punch = drawers.tag.handle_punch_take,
	update = drawers.tag.update,
	-- custom field, was renamed
	update_infotext = drawers.tag.update_infotext,
	-- called whenever items are put in or taken out manually
	-- custom field, could be renamed
	play_interact_sound = drawers.tag.play_interact_sound,

} -- entity_def

minetest.register_entity('drawers:visual', entity_def)

