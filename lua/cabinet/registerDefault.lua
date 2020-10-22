--
-- drawers/lua/cabinet/registerDefault.lua
--
local S, NS = dofile(drawers.modpath .. '/intllib.lua')
--
-- Register cabinet craft recipes when default mod is available
--
-- 4 x 8 = 32 normal chest size
local _base_stack_count = 4 * 8

drawers.cabinet.register('drawers:wood', {
	description = S('Wooden'),
	drawers_stack_max_factor = _base_stack_count,
	groups = { choppy = 3, oddly_breakable_by_hand = 2 },
	material = drawers.settings.wood_itemstring,
	sounds = drawers.settings.wood_sounds,
	tiles1 = drawers.cabinet.tiles_front_other('drawers_wood_front_1.png',
												'drawers_wood.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_wood_front_2.png',
												'drawers_wood.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_wood_front_4.png',
												'drawers_wood.png'),
})
drawers.cabinet.register('drawers:acacia_wood', {
	description = S('Acacia Wood'),
	drawers_stack_max_factor = _base_stack_count,
	groups = { choppy = 3, oddly_breakable_by_hand = 2 },
	material = 'default:acacia_wood',
	sounds = drawers.settings.wood_sounds,
	tiles1 = drawers.cabinet.tiles_front_other('drawers_acacia_wood_front_1.png',
												'drawers_acacia_wood.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_acacia_wood_front_2.png',
												'drawers_acacia_wood.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_acacia_wood_front_4.png',
												'drawers_acacia_wood.png'),
})
drawers.cabinet.register('drawers:aspen_wood', {
	description = S('Aspen Wood'),
	drawers_stack_max_factor = _base_stack_count,
	groups = { choppy = 3, oddly_breakable_by_hand = 2 },
	material = 'default:aspen_wood',
	sounds = drawers.settings.wood_sounds,
	tiles1 = drawers.cabinet.tiles_front_other('drawers_aspen_wood_front_1.png',
												'drawers_aspen_wood.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_aspen_wood_front_2.png',
												'drawers_aspen_wood.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_aspen_wood_front_4.png',
												'drawers_aspen_wood.png'),
})
drawers.cabinet.register('drawers:junglewood', {
	description = S('Junglewood'),
	drawers_stack_max_factor = _base_stack_count,
	groups = { choppy = 3, oddly_breakable_by_hand = 2 },
	material = 'default:junglewood',
	sounds = drawers.settings.wood_sounds,
	tiles1 = drawers.cabinet.tiles_front_other('drawers_junglewood_front_1.png',
												'drawers_junglewood.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_junglewood_front_2.png',
												'drawers_junglewood.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_junglewood_front_4.png',
												'drawers_junglewood.png'),
})
drawers.cabinet.register('drawers:pine_wood', {
	description = S('Pine Wood'),
	drawers_stack_max_factor = _base_stack_count,
	groups = { choppy = 3, oddly_breakable_by_hand = 2 },
	material = 'default:pine_wood',
	sounds = drawers.settings.wood_sounds,
	tiles1 = drawers.cabinet.tiles_front_other('drawers_pine_wood_front_1.png',
												'drawers_pine_wood.png'),
	tiles2 = drawers.cabinet.tiles_front_other('drawers_pine_wood_front_2.png',
												'drawers_pine_wood.png'),
	tiles4 = drawers.cabinet.tiles_front_other('drawers_pine_wood_front_4.png',
												'drawers_pine_wood.png'),
})

