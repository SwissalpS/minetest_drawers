--
-- drawers/lua/cabinet/registerMCL.lua
--
local S, NS = dofile(drawers.modpath .. '/intllib.lua')
--
-- Register cabinet craft recipes
--

drawers.cabinet.register('drawers:oakwood', {
	_mcl_blast_resistance = 15,
	_mcl_hardness = 2,
	description = S('Oak Wood'),
	groups = {
		handy = 1, axey = 1, flammable = 3, wood = 1,
		building_block = 1, material_wood = 1
	},
	material = drawers.settings.wood_itemstring,
	sounds = drawers.settings.wood_sounds,
	tiles1 = drawers.cabinet.tiles_front_other('drawers_oak_wood_front_1.png',
												'drawers_oak_wood.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_oak_wood_front_2.png',
												'drawers_oak_wood.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_oak_wood_front_4.png',
												'drawers_oak_wood.png'),
})
drawers.cabinet.register('drawers:acaciawood', {
	_mcl_blast_resistance = 15,
	_mcl_hardness = 2,
	description = S('Acacia Wood'),
	groups = {
		handy = 1, axey = 1, flammable = 3, wood = 1,
		building_block = 1, material_wood = 1
	},
	material = 'mcl_core:acaciawood',
	sounds = drawers.settings.wood_sounds,
	tiles1 = drawers.cabinet.tiles_front_other('drawers_acacia_wood_mcl_front_1.png',
												'drawers_acacia_wood_mcl.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_acacia_wood_mcl_front_2.png',
												'drawers_acacia_wood_mcl.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_acacia_wood_mcl_front_4.png',
												'drawers_acacia_wood_mcl.png'),
})
drawers.cabinet.register('drawers:birchwood', {
	_mcl_blast_resistance = 15,
	_mcl_hardness = 2,
	description = S('Birch Wood'),
	groups = {
		handy = 1, axey = 1, flammable = 3, wood = 1,
		building_block = 1, material_wood = 1
	},
	material = 'mcl_core:birchwood',
	sounds = drawers.settings.wood_sounds,
	tiles1 = drawers.cabinet.tiles_front_other('drawers_birch_wood_front_1.png',
												'drawers_birch_wood.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_birch_wood_front_2.png',
												'drawers_birch_wood.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_birch_wood_front_4.png',
												'drawers_birch_wood.png'),
})
drawers.cabinet.register('drawers:darkwood', {
	_mcl_blast_resistance = 15,
	_mcl_hardness = 2,
	description = S('Dark Oak Wood'),
	groups = {
		handy = 1, axey = 1, flammable = 3, wood = 1,
		building_block = 1, material_wood = 1
	},
	material = 'mcl_core:darkwood',
	sounds = drawers.settings.wood_sounds,
	tiles1 = drawers.cabinet.tiles_front_other('drawers_dark_oak_wood_front_1.png',
												'drawers_dark_oak_wood.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_dark_oak_wood_front_2.png',
												'drawers_dark_oak_wood.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_dark_oak_wood_front_4.png',
												'drawers_dark_oak_wood.png'),
})
drawers.cabinet.register('drawers:junglewood', {
	_mcl_blast_resistance = 15,
	_mcl_hardness = 2,
	description = S('Junglewood'),
	groups = {
		handy = 1, axey = 1, flammable = 3, wood = 1,
		building_block = 1, material_wood = 1
	},
	material = 'mcl_core:junglewood',
	sounds = drawers.settings.wood_sounds,
	tiles1 = drawers.cabinet.tiles_front_other('drawers_junglewood_mcl_front_1.png',
												'drawers_junglewood_mcl.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_junglewood_mcl_front_2.png',
												'drawers_junglewood_mcl.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_junglewood_mcl_front_4.png',
												'drawers_junglewood_mcl.png'),
})
drawers.cabinet.register('drawers:sprucewood', {
	_mcl_blast_resistance = 15,
	_mcl_hardness = 2,
	description = S('Spruce Wood'),
	groups = {
		handy = 1, axey = 1, flammable = 3, wood = 1,
		building_block = 1, material_wood = 1
	},
	material = 'mcl_core:sprucewood',
	sounds = drawers.settings.wood_sounds,
	tiles1 = drawers.cabinet.tiles_front_other('drawers_spruce_wood_front_1.png',
												'drawers_spruce_wood.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_spruce_wood_front_2.png',
												'drawers_spruce_wood.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_spruce_wood_front_4.png',
												'drawers_spruce_wood.png'),
})

-- backwards compatibility
minetest.register_alias('drawers:wood1', 'drawers:oakwood1')
minetest.register_alias('drawers:wood2', 'drawers:oakwood2')
minetest.register_alias('drawers:wood4', 'drawers:oakwood4')

