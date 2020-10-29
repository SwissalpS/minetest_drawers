--
-- upgrades to cabinets to increase drawer sizes
--
local S, NS = dofile(drawers.modpath .. '/intllib.lua')

-- may be referenced as du or dupg
drawers.upgrade = {}

local base_slot_count = drawers.settings.base_slot_count

-- helper function to register craftitems and recipes for upgrades
function drawers.upgrade.register(name, def)
	def.groups = def.groups or {}
	-- custom group entry
	def.groups.drawers_increment = def.groups.drawers_increment or base_slot_count

	def.inventory_image = def.inventory_image or 'drawers_upgrade_template.png'
	-- TODO: discuss stack_max for upgrades
	def.stack_max = 5 -- minetest.nodedef_default.stack_max or 99

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
		description = S('Steel Cabinet Upgrade (+@1 slots)', base_slot_count),
		groups = { drawers_increment = base_slot_count },
		inventory_image = 'drawers_upgrade_steel.png',
		recipe_item = 'default:steel_ingot'
	})

	drawers.upgrade.register('drawers:upgrade_gold', {
		description = S('Gold Cabinet Upgrade (+@1 slots)', 2 * base_slot_count),
		groups = { drawers_increment = 2 * base_slot_count },
		inventory_image = 'drawers_upgrade_gold.png',
		recipe_item = 'default:gold_ingot'
	})

	drawers.upgrade.register('drawers:upgrade_obsidian', {
		description = S('Obsidian Cabinet Upgrade (+@1 slots)', 3 * base_slot_count),
		groups = { drawers_increment = 3 * base_slot_count },
		inventory_image = 'drawers_upgrade_obsidian.png',
		recipe_item = 'default:obsidian'
	})

	drawers.upgrade.register('drawers:upgrade_diamond', {
		description = S('Diamond Cabinet Upgrade (+@1 slots)', 7 * base_slot_count),
		groups = { drawers_increment = 7 * base_slot_count },
		inventory_image = 'drawers_upgrade_diamond.png',
		recipe_item = 'default:diamond'
	})
elseif drawers.has_mcl_core then
	drawers.upgrade.register('drawers:upgrade_iron', {
		description = S('Iron Cabinet Upgrade (+@1 slots)', base_slot_count),
		groups = { drawers_increment = base_slot_count },
		inventory_image = 'drawers_upgrade_iron.png',
		recipe_item = 'mcl_core:iron_ingot'
	})

	drawers.upgrade.register('drawers:upgrade_gold', {
		description = S('Gold Cabinet Upgrade (+@1 slots)', 2 * base_slot_count),
		groups = { drawers_increment = 2 * base_slot_count },
		inventory_image = 'drawers_upgrade_gold.png',
		recipe_item = 'mcl_core:gold_ingot'
	})

	drawers.upgrade.register('drawers:upgrade_obsidian', {
		description = S('Obsidian Cabinet Upgrade (+@1 slots)', 3 * base_slot_count),
		groups = { drawers_increment = 3 * base_slot_count },
		inventory_image = 'drawers_upgrade_obsidian.png',
		recipe_item = 'mcl_core:obsidian'
	})

	drawers.upgrade.register('drawers:upgrade_diamond', {
		description = S('Diamond Cabinet Upgrade (+@1 slots)', 7 * base_slot_count),
		groups = { drawers_increment = 7 * base_slot_count },
		inventory_image = 'drawers_upgrade_diamond.png',
		recipe_item = 'mcl_core:diamond'
	})

	drawers.upgrade.register('drawers:upgrade_emerald', {
		description = S('Emerald Cabinet Upgrade (+@1 slots)', 12 * base_slot_count),
		groups = { drawers_increment = 12 * base_slot_count },
		inventory_image = 'drawers_upgrade_emerald.png',
		recipe_item = 'mcl_core:emerald'
	})
end

if drawers.has_moreores then
	drawers.upgrade.register('drawers:upgrade_mithril', {
		description = S('Mithril Cabinet Upgrade (+@1 slots)', 12 * base_slot_count),
		groups = { drawers_increment = 12 * base_slot_count },
		inventory_image = 'drawers_upgrade_mithril.png',
		recipe_item = 'moreores:mithril_ingot'
	})
end

