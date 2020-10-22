--
-- register to cabinet connector, aka trim, node
--
local S, NS = dofile(drawers.modpath .. '/intllib.lua')

if drawers.has_mcl_core then
	minetest.register_node('drawers:trim', {
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
		description = S('Wooden Trim'),
		groups = {
			axey = 1,
			building_block = 1,
			drawers_connector = 1,
			flammable = 3,
			handy = 1,
			material_wood = 1,
			wood = 1,
		},
		tiles = { 'drawers_trim.png' },
	})
else
	minetest.register_node('drawers:trim', {
		description = S('Wooden Trim'),
		groups = {
			choppy = 3,
			drawers_connector = 1,
			oddly_breakable_by_hand = 2,
		},
		tiles = { 'drawers_trim.png' },
	})
end

