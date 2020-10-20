--
-- register to cabinet connector, aka trim, node
--

if drawers.has_mcl_core then
	minetest.register_node('drawers:trim', {
		description = S('Wooden Trim'),
		tiles = { 'drawers_trim.png' },
		groups = {
			axey = 1,
			building_block = 1,
			drawers_connector = 1,
			flammable = 3,
			handy = 1,
			material_wood = 1,
			wood = 1,
		},
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
else
	minetest.register_node('drawers:trim', {
		description = S('Wooden Trim'),
		tiles = { 'drawers_trim.png' },
		groups = {
			choppy = 3,
			drawers_connector = 1,
			oddly_breakable_by_hand = 2,
		},
	})
end

