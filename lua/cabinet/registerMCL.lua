--
-- drawers/lua/cabinet/registerMCL.lua
--
local S, NS = dofile(drawers.modpath .. '/intllib.lua')
--
-- Register cabinet craft recipes
--
-- 4 x 9 = 36 normal mcl chest size
local _base_stack_count = 4 * 9

drawers.cabinet.register('drawers:oakwood', {
	description = S('Oak Wood'),
	tiles1 = drawers.cabinet.tiles_front_other('drawers_oak_wood_front_1.png',
												'drawers_oak_wood.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_oak_wood_front_2.png',
												'drawers_oak_wood.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_oak_wood_front_4.png',
												'drawers_oak_wood.png'),
	groups = {
		handy = 1, axey = 1, flammable = 3, wood = 1,
		building_block = 1, material_wood = 1
	},
	sounds = drawers.settings.wood_sounds,
	drawer_stack_max_factor = _base_stack_count,
	material = drawers.settings.wood_itemstring,
	_mcl_blast_resistance = 15,
	_mcl_hardness = 2,
})
drawers.cabinet.register('drawers:acaciawood', {
	description = S('Acacia Wood'),
	tiles1 = drawers.cabinet.tiles_front_other('drawers_acacia_wood_mcl_front_1.png',
												'drawers_acacia_wood_mcl.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_acacia_wood_mcl_front_2.png',
												'drawers_acacia_wood_mcl.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_acacia_wood_mcl_front_4.png',
												'drawers_acacia_wood_mcl.png'),
	groups = {
		handy = 1, axey = 1, flammable = 3, wood = 1,
		building_block = 1, material_wood = 1
	},
	sounds = drawers.settings.wood_sounds,
	drawer_stack_max_factor = _base_stack_count,
	material = 'mcl_core:acaciawood',
	_mcl_blast_resistance = 15,
	_mcl_hardness = 2,
})
drawers.cabinet.register('drawers:birchwood', {
	description = S('Birch Wood'),
	tiles1 = drawers.cabinet.tiles_front_other('drawers_birch_wood_front_1.png',
												'drawers_birch_wood.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_birch_wood_front_2.png',
												'drawers_birch_wood.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_birch_wood_front_4.png',
												'drawers_birch_wood.png'),
	groups = {
		handy = 1, axey = 1, flammable = 3, wood = 1,
		building_block = 1, material_wood = 1
	},
	sounds = drawers.settings.wood_sounds,
	drawer_stack_max_factor = _base_stack_count,
	material = 'mcl_core:birchwood',
	_mcl_blast_resistance = 15,
	_mcl_hardness = 2,
})
drawers.cabinet.register('drawers:darkwood', {
	description = S('Dark Oak Wood'),
	tiles1 = drawers.cabinet.tiles_front_other('drawers_dark_oak_wood_front_1.png',
												'drawers_dark_oak_wood.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_dark_oak_wood_front_2.png',
												'drawers_dark_oak_wood.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_dark_oak_wood_front_4.png',
												'drawers_dark_oak_wood.png'),
	groups = {
		handy = 1, axey = 1, flammable = 3, wood = 1,
		building_block = 1, material_wood = 1
	},
	sounds = drawers.settings.wood_sounds,
	drawer_stack_max_factor = _base_stack_count,
	material = 'mcl_core:darkwood',
	_mcl_blast_resistance = 15,
	_mcl_hardness = 2,
})
drawers.cabinet.register('drawers:junglewood', {
	description = S('Junglewood'),
	tiles1 = drawers.cabinet.tiles_front_other('drawers_junglewood_mcl_front_1.png',
												'drawers_junglewood_mcl.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_junglewood_mcl_front_2.png',
												'drawers_junglewood_mcl.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_junglewood_mcl_front_4.png',
												'drawers_junglewood_mcl.png'),
	groups = {
		handy = 1, axey = 1, flammable = 3, wood = 1,
		building_block = 1, material_wood = 1
	},
	sounds = drawers.settings.wood_sounds,
	drawer_stack_max_factor = _base_stack_count,
	material = 'mcl_core:junglewood',
	_mcl_blast_resistance = 15,
	_mcl_hardness = 2,
})
drawers.cabinet.register('drawers:sprucewood', {
	description = S('Spruce Wood'),
	tiles1 = drawers.cabinet.tiles_front_other('drawers_spruce_wood_front_1.png',
												'drawers_spruce_wood.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_spruce_wood_front_2.png',
												'drawers_spruce_wood.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_spruce_wood_front_4.png',
												'drawers_spruce_wood.png'),
	groups = {
		handy = 1, axey = 1, flammable = 3, wood = 1,
		building_block = 1, material_wood = 1
	},
	sounds = drawers.settings.wood_sounds,
	drawer_stack_max_factor = _base_stack_count,
	material = 'mcl_core:sprucewood',
	_mcl_blast_resistance = 15,
	_mcl_hardness = 2,
})

-- backwards compatibility
minetest.register_alias('drawers:wood1', 'drawers:oakwood1')
minetest.register_alias('drawers:wood2', 'drawers:oakwood2')
minetest.register_alias('drawers:wood4', 'drawers:oakwood4')

