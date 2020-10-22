--
-- drawers/lua/tag/gui.lua
--
--
-- Load support for intllib.
local S, NS = dofile(drawers.modpath .. '/intllib.lua')

drawers.tag.gui = {}

function drawers.tag.gui.generate_info_text(basename, count, factor, stack_max)
	-- TODO: collect all places that do this math and use one function
	local max_count = stack_max * factor
	local percent = count / max_count * 100
	-- round the number (float -> int)
	percent = math.floor(percent + 0.5)

	if 0 == count then
		return S('@1 (@2% full)', basename, tostring(percent))
	else
		return S('@1 @2 (@3% full)', tostring(count), basename, tostring(percent))
	end
end -- drawers.tag.gui.generate_info_text

function drawers.tag.gui.get_image(name)
	local texture = 'blank.png'
	local item_def = minetest.registered_items[name]
	if not item_def then return end

	if item_def.inventory_image and 0 < #item_def.inventory_image then
		texture = item_def.inventory_image
	else
		if not item_def.tiles then return texture end
		local tiles = table.copy(item_def.tiles)

		for k, v in pairs(tiles) do
			if 'table' == type(v) then
				tiles[k] = v.name
			end
		end

		-- tiles: up, down, right, left, back, front
		-- inventorycube: up, front, right
		if 2 >= #tiles then
			texture = minetest.inventorycube(tiles[1], tiles[1], tiles[1])
		elseif 5 >= #tiles then
			texture = minetest.inventorycube(tiles[1], tiles[3], tiles[3])
		else -- full tileset
			texture = minetest.inventorycube(tiles[1], tiles[6], tiles[3])
		end
	end

	return texture
end -- drawers.tag.gui.get_image

