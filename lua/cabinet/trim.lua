--
-- register to cabinet connector, aka trim, node
--
local S, NS = dofile(drawers.modpath .. '/intllib.lua')

drawers.trim = {}

drawers.trim.craft_def = {
	output = 'drawers:trim 6',
	recipe = {
		{ 'group:stick', 'group:wood', 'group:stick' },
		{ 'group:wood',  'group:wood',  'group:wood' },
		{ 'group:stick', 'group:wood', 'group:stick' },
	}
}

if drawers.has_mcl_core then
	drawers.trim.node_def = {
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
		description = S('Wooden Trim'),
		groups = {
			axey = 1,
			building_block = 1,
			flammable = 3,
			handy = 1,
			material_wood = 1,
			wood = 1,
		},
		tiles = { 'drawers_trim.png' },
	}
else
	drawers.trim.node_def = {
		description = S('Wooden Trim'),
		groups = {
			choppy = 3,
			oddly_breakable_by_hand = 2,
		},
		tiles = { 'drawers_trim.png' },
	}
end

drawers.trim.node_def.groups.drawers_connector = 1
drawers.trim.node_def.after_destruct = drawers.controller.net_item_removed
drawers.trim.node_def.on_construct = drawers.controller.net_item_placed

