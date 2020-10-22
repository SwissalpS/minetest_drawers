--
-- upgrades to cabinets to increase drawer sizes
--
local S, NS = dofile(drawers.modpath .. '/intllib.lua')

-- may be referenced as du or dupg
drawers.upgrade = {}

-- helper function to register craftitems and recipes for upgrades
function drawers.upgrade.register(name, def)
	def.groups = def.groups or {}
	-- custom group entry
	def.groups.drawers_increment = def.groups.drawers_increment or 100
	def.inventory_image = def.inventory_image or 'drawers_upgrade_template.png'
	-- TODO: discuss if this had a good reason to be 1 and if 5 makes sense
	--		or if we simply set to 99 for default and 1 for MCL servers, since
	--		I suspect that to be the reason for 1 to have been used.
	--		Another possibility is that original coders did not want to deal with
	--		players putting them in the drawers instead of the upgrade slots.
	--		since unstackables can't be put in drawers...
	def.stack_max = 5 -- 99

	-- extract recipe item, this is not cached in item definition
	local recipe_item = def.recipe_item or 'air'
	def.recipe_item = nil

	-- register the craft item
	minetest.register_craftitem(name, def)

	-- does this one require a crafting recipe to be registered?
	if not def.no_craft then
		local crafting_definition = {
			output = name,
			recipe = {
				{ recipe_item, 'group:stick', recipe_item },
				{ 'group:stick', 'drawers:upgrade_template', 'group:stick' },
				{ recipe_item, 'group:stick', recipe_item }
			}
		}
		minetest.register_craft(crafting_definition)
	end -- if
end -- drawers.cabinet.register_upgrade

--
-- Register drawer upgrades recipes
--
-- TODO: discuss wether it would make sense to declare these as a table and then
--		itterate over them
if drawers.has_default then
	drawers.upgrade.register('drawers:upgrade_steel', {
		description = S('Steel Drawer Upgrade (x2)'),
		groups = { drawers_increment = 100 },
		inventory_image = 'drawers_upgrade_steel.png',
		recipe_item = 'default:steel_ingot'
	})

	drawers.upgrade.register('drawers:upgrade_gold', {
		description = S('Gold Drawer Upgrade (x3)'),
		groups = { drawers_increment = 200 },
		inventory_image = 'drawers_upgrade_gold.png',
		recipe_item = 'default:gold_ingot'
	})

	drawers.upgrade.register('drawers:upgrade_obsidian', {
		description = S('Obsidian Drawer Upgrade (x4)'),
		groups = { drawers_increment = 300 },
		inventory_image = 'drawers_upgrade_obsidian.png',
		recipe_item = 'default:obsidian'
	})

	drawers.upgrade.register('drawers:upgrade_diamond', {
		description = S('Diamond Drawer Upgrade (x8)'),
		groups = { drawers_increment = 700 },
		inventory_image = 'drawers_upgrade_diamond.png',
		recipe_item = 'default:diamond'
	})
elseif drawers.has_mcl_core then
	drawers.upgrade.register('drawers:upgrade_iron', {
		description = S('Iron Drawer Upgrade (x2)'),
		groups = { drawers_increment = 100 },
		inventory_image = 'drawers_upgrade_iron.png',
		recipe_item = 'mcl_core:iron_ingot'
	})

	drawers.upgrade.register('drawers:upgrade_gold', {
		description = S('Gold Drawer Upgrade (x3)'),
		groups = { drawers_increment = 200 },
		inventory_image = 'drawers_upgrade_gold.png',
		recipe_item = 'mcl_core:gold_ingot'
	})

	drawers.upgrade.register('drawers:upgrade_obsidian', {
		description = S('Obsidian Drawer Upgrade (x4)'),
		groups = { drawers_increment = 300 },
		inventory_image = 'drawers_upgrade_obsidian.png',
		recipe_item = 'mcl_core:obsidian'
	})

	drawers.upgrade.register('drawers:upgrade_diamond', {
		description = S('Diamond Drawer Upgrade (x8)'),
		groups = { drawers_increment = 700 },
		inventory_image = 'drawers_upgrade_diamond.png',
		recipe_item = 'mcl_core:diamond'
	})

	drawers.upgrade.register('drawers:upgrade_emerald', {
		description = S('Emerald Drawer Upgrade (x13)'),
		groups = { drawers_increment = 1200 },
		inventory_image = 'drawers_upgrade_emerald.png',
		recipe_item = 'mcl_core:emerald'
	})
end

if drawers.has_moreores then
	drawers.upgrade.register('drawers:upgrade_mithril', {
		description = S('Mithril Drawer Upgrade (x13)'),
		groups = { drawers_increment = 1200 },
		inventory_image = 'drawers_upgrade_mithril.png',
		recipe_item = 'moreores:mithril_ingot'
	})
end

