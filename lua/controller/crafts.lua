local S, NS = dofile(drawers.modpath .. '/intllib.lua')

--
-- Register drawers (cabinet) craft recipes
--

if drawers.has_default then
	drawers.register_cabinet('drawers:wood', {
		description = S('Wooden'),
		tiles1 = drawers.node_tiles_front_other('drawers_wood_front_1.png',
												'drawers_wood.png'),
		tiles2 = drawers.node_tiles_front_other('drawers_wood_front_2.png',
												'drawers_wood.png'),
		tiles4 = drawers.node_tiles_front_other('drawers_wood_front_4.png',
												'drawers_wood.png'),
		groups = { choppy = 3, oddly_breakable_by_hand = 2 },
		sounds = drawers.config.wood_sounds,
		drawer_stack_max_factor = 32, -- 4 * 8 normal chest size
		material = drawers.config.wood_itemstring
	})
	drawers.register_cabinet('drawers:acacia_wood', {
		description = S('Acacia Wood'),
		tiles1 = drawers.node_tiles_front_other('drawers_acacia_wood_front_1.png',
												'drawers_acacia_wood.png'),
		tiles2 = drawers.node_tiles_front_other('drawers_acacia_wood_front_2.png',
												'drawers_acacia_wood.png'),
		tiles4 = drawers.node_tiles_front_other('drawers_acacia_wood_front_4.png',
												'drawers_acacia_wood.png'),
		groups = { choppy = 3, oddly_breakable_by_hand = 2 },
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 32, -- 4 * 8 normal mcl chest size
		material = 'default:acacia_wood'
	})
	drawers.register_cabinet('drawers:aspen_wood', {
		description = S('Aspen Wood'),
		tiles1 = drawers.node_tiles_front_other('drawers_aspen_wood_front_1.png',
												'drawers_aspen_wood.png'),
		tiles2 = drawers.node_tiles_front_other('drawers_aspen_wood_front_2.png',
												'drawers_aspen_wood.png'),
		tiles4 = drawers.node_tiles_front_other('drawers_aspen_wood_front_4.png',
												'drawers_aspen_wood.png'),
		groups = { choppy = 3, oddly_breakable_by_hand = 2 },
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 32, -- 4 * 8 normal chest size
		material = 'default:aspen_wood'
	})
	drawers.register_cabinet('drawers:junglewood', {
		description = S('Junglewood'),
		tiles1 = drawers.node_tiles_front_other('drawers_junglewood_front_1.png',
												'drawers_junglewood.png'),
		tiles2 = drawers.node_tiles_front_other('drawers_junglewood_front_2.png',
												'drawers_junglewood.png'),
		tiles4 = drawers.node_tiles_front_other('drawers_junglewood_front_4.png',
												'drawers_junglewood.png'),
		groups = { choppy = 3, oddly_breakable_by_hand = 2 },
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 32, -- 4 * 8 normal mcl chest size
		material = 'default:junglewood'
	})
	drawers.register_cabinet('drawers:pine_wood', {
		description = S('Pine Wood'),
		tiles1 = drawers.node_tiles_front_other('drawers_pine_wood_front_1.png',
												'drawers_pine_wood.png'),
		tiles2 = drawers.node_tiles_front_other('drawers_pine_wood_front_2.png',
												'drawers_pine_wood.png'),
		tiles4 = drawers.node_tiles_front_other('drawers_pine_wood_front_4.png',
												'drawers_pine_wood.png'),
		groups = { choppy = 3, oddly_breakable_by_hand = 2 },
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 32, -- 4 * 8 normal chest size
		material = 'default:pine_wood'
	})
elseif drawers.has_mcl_core then
	drawers.register_cabinet('drawers:oakwood', {
		description = S('Oak Wood'),
		tiles1 = drawers.node_tiles_front_other('drawers_oak_wood_front_1.png',
												'drawers_oak_wood.png'),
		tiles2 = drawers.node_tiles_front_other('drawers_oak_wood_front_2.png',
												'drawers_oak_wood.png'),
		tiles4 = drawers.node_tiles_front_other('drawers_oak_wood_front_4.png',
												'drawers_oak_wood.png'),
		groups = {
			handy = 1, axey = 1, flammable = 3, wood = 1,
			building_block = 1, material_wood = 1
		},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36, -- 4 * 9 normal mcl chest size
		material = drawers.WOOD_ITEMSTRING,
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_cabinet('drawers:acaciawood', {
		description = S('Acacia Wood'),
		tiles1 = drawers.node_tiles_front_other('drawers_acacia_wood_mcl_front_1.png',
												'drawers_acacia_wood_mcl.png'),
		tiles2 = drawers.node_tiles_front_other('drawers_acacia_wood_mcl_front_2.png',
												'drawers_acacia_wood_mcl.png'),
		tiles4 = drawers.node_tiles_front_other('drawers_acacia_wood_mcl_front_4.png',
												'drawers_acacia_wood_mcl.png'),
		groups = {
			handy = 1, axey = 1, flammable = 3, wood = 1,
			building_block = 1, material_wood = 1
		},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36, -- 4 * 9 normal mcl chest size
		material = 'mcl_core:acaciawood',
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_cabinet('drawers:birchwood', {
		description = S('Birch Wood'),
		tiles1 = drawers.node_tiles_front_other('drawers_birch_wood_front_1.png',
												'drawers_birch_wood.png'),
		tiles2 = drawers.node_tiles_front_other('drawers_birch_wood_front_2.png',
												'drawers_birch_wood.png'),
		tiles4 = drawers.node_tiles_front_other('drawers_birch_wood_front_4.png',
												'drawers_birch_wood.png'),
		groups = {
			handy = 1, axey = 1, flammable = 3, wood = 1,
			building_block = 1, material_wood = 1
		},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36, -- 4 * 9 normal mcl chest size
		material = 'mcl_core:birchwood',
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_cabinet('drawers:darkwood', {
		description = S('Dark Oak Wood'),
		tiles1 = drawers.node_tiles_front_other('drawers_dark_oak_wood_front_1.png',
												'drawers_dark_oak_wood.png'),
		tiles2 = drawers.node_tiles_front_other('drawers_dark_oak_wood_front_2.png',
												'drawers_dark_oak_wood.png'),
		tiles4 = drawers.node_tiles_front_other('drawers_dark_oak_wood_front_4.png',
												'drawers_dark_oak_wood.png'),
		groups = {
			handy = 1, axey = 1, flammable = 3, wood = 1,
			building_block = 1, material_wood = 1
		},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36, -- 4 * 9 normal mcl chest size
		material = 'mcl_core:darkwood',
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_cabinet('drawers:junglewood', {
		description = S('Junglewood'),
		tiles1 = drawers.node_tiles_front_other('drawers_junglewood_mcl_front_1.png',
												'drawers_junglewood_mcl.png'),
		tiles2 = drawers.node_tiles_front_other('drawers_junglewood_mcl_front_2.png',
												'drawers_junglewood_mcl.png'),
		tiles4 = drawers.node_tiles_front_other('drawers_junglewood_mcl_front_4.png',
												'drawers_junglewood_mcl.png'),
		groups = {
			handy = 1, axey = 1, flammable = 3, wood = 1,
			building_block = 1, material_wood = 1
		},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36, -- 4 * 9 normal mcl chest size
		material = 'mcl_core:junglewood',
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_cabinet('drawers:sprucewood', {
		description = S('Spruce Wood'),
		tiles1 = drawers.node_tiles_front_other('drawers_spruce_wood_front_1.png',
												'drawers_spruce_wood.png'),
		tiles2 = drawers.node_tiles_front_other('drawers_spruce_wood_front_2.png',
												'drawers_spruce_wood.png'),
		tiles4 = drawers.node_tiles_front_other('drawers_spruce_wood_front_4.png',
												'drawers_spruce_wood.png'),
		groups = {
			handy = 1, axey = 1, flammable = 3, wood = 1,
			building_block = 1, material_wood = 1
		},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36, -- 4 * 9 normal mcl chest size
		material = 'mcl_core:sprucewood',
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})

	-- backwards compatibility
	core.register_alias('drawers:wood1', 'drawers:oakwood1')
	core.register_alias('drawers:wood2', 'drawers:oakwood2')
	core.register_alias('drawers:wood4', 'drawers:oakwood4')
else
	drawers.register_cabinet('drawers:wood', {
		description = S('Wooden'),
		tiles1 = drawers.node_tiles_front_other('drawers_wood_front_1.png',
												'drawers_wood.png'),
		tiles2 = drawers.node_tiles_front_other('drawers_wood_front_2.png',
												'drawers_wood.png'),
		tiles4 = drawers.node_tiles_front_other('drawers_wood_front_4.png',
												'drawers_wood.png'),
		groups = { choppy = 3, oddly_breakable_by_hand = 2 },
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 32, -- 4 * 8 normal chest size
		material = drawers.WOOD_ITEMSTRING
	})
end


--
-- Register drawer upgrades recipes
--

if drawers.has_default then
	drawers.register_drawer_upgrade('drawers:upgrade_steel', {
		description = S('Steel Drawer Upgrade (x2)'),
		inventory_image = 'drawers_upgrade_steel.png',
		groups = { drawer_upgrade = 100 },
		recipe_item = 'default:steel_ingot'
	})

	drawers.register_drawer_upgrade('drawers:upgrade_gold', {
		description = S('Gold Drawer Upgrade (x3)'),
		inventory_image = 'drawers_upgrade_gold.png',
		groups = { drawer_upgrade = 200 },
		recipe_item = 'default:gold_ingot'
	})

	drawers.register_drawer_upgrade('drawers:upgrade_obsidian', {
		description = S('Obsidian Drawer Upgrade (x4)'),
		inventory_image = 'drawers_upgrade_obsidian.png',
		groups = { drawer_upgrade = 300 },
		recipe_item = 'default:obsidian'
	})

	drawers.register_drawer_upgrade('drawers:upgrade_diamond', {
		description = S('Diamond Drawer Upgrade (x8)'),
		inventory_image = 'drawers_upgrade_diamond.png',
		groups = { drawer_upgrade = 700 },
		recipe_item = 'default:diamond'
	})
elseif drawers.has_mcl_core then
	drawers.register_drawer_upgrade('drawers:upgrade_iron', {
		description = S('Iron Drawer Upgrade (x2)'),
		inventory_image = 'drawers_upgrade_iron.png',
		groups = { drawer_upgrade = 100 },
		recipe_item = 'mcl_core:iron_ingot'
	})

	drawers.register_drawer_upgrade('drawers:upgrade_gold', {
		description = S('Gold Drawer Upgrade (x3)'),
		inventory_image = 'drawers_upgrade_gold.png',
		groups = { drawer_upgrade = 200 },
		recipe_item = 'mcl_core:gold_ingot'
	})

	drawers.register_drawer_upgrade('drawers:upgrade_obsidian', {
		description = S('Obsidian Drawer Upgrade (x4)'),
		inventory_image = 'drawers_upgrade_obsidian.png',
		groups = { drawer_upgrade = 300 },
		recipe_item = 'mcl_core:obsidian'
	})

	drawers.register_drawer_upgrade('drawers:upgrade_diamond', {
		description = S('Diamond Drawer Upgrade (x8)'),
		inventory_image = 'drawers_upgrade_diamond.png',
		groups = { drawer_upgrade = 700 },
		recipe_item = 'mcl_core:diamond'
	})

	drawers.register_drawer_upgrade('drawers:upgrade_emerald', {
		description = S('Emerald Drawer Upgrade (x13)'),
		inventory_image = 'drawers_upgrade_emerald.png',
		groups = { drawer_upgrade = 1200 },
		recipe_item = 'mcl_core:emerald'
	})
end

if drawers.has_moreores then
	drawers.register_drawer_upgrade('drawers:upgrade_mithril', {
		description = S('Mithril Drawer Upgrade (x13)'),
		inventory_image = 'drawers_upgrade_mithril.png',
		groups = { drawer_upgrade = 1200 },
		recipe_item = 'moreores:mithril_ingot'
	})
end

--
-- Register drawer trim
--

if drawers.has_mcl_core then
	minetest.register_node('drawers:trim', {
		description = S('Wooden Trim'),
		tiles = { 'drawers_trim.png' },
		groups = {
			drawer_connector = 1, handy = 1, axey = 1, flammable = 3,
			wood = 1, building_block = 1, material_wood = 1
		},
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
else
	minetest.register_node('drawers:trim', {
		description = S('Wooden Trim'),
		tiles = { 'drawers_trim.png' },
		groups = { drawer_connector = 1, choppy = 3, oddly_breakable_by_hand = 2 },
	})
end

