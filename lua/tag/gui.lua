--
-- drawers/lua/tag/gui.lua
--
--
-- Load support for intllib.
local S, NS = dofile(drawers.modpath .. '/intllib.lua')

drawers.tag.gui = {}

function drawers.tag.gui.generate_infotext(description, count, max_count, locked_to)
	-- calculate percentage
	local percent = count / max_count * 100
	-- round the number (float -> int)
	percent = math.floor(percent + 0.5)
	local text
	if 0 == count then
		-- empty drawer
		text = S('Empty (0% full)')
	else
		text = S('@1 @2 (@3% full)', tostring(count), description, tostring(percent))
	end
	if locked_to then
		text = text .. '\13' .. S('Locked to: ') .. locked_to
	end
	return text
end -- drawers.tag.gui.generate_infotext

function drawers.tag.gui.get_image(name)
	local texture = 'blank.png'
	local item_def = minetest.registered_items[name]
	if not item_def then return texture end

	if item_def.inventory_image and 0 < #item_def.inventory_image then
		texture = item_def.inventory_image
	else
		if not item_def.tiles then return texture end
		local tiles = table.copy(item_def.tiles)

		for k, v in ipairs(tiles) do
			if 'table' == type(v) then
				tiles[k] = v.name
			end
		end

		-- tiles: up, down, right, left, back, front
		-- inventorycube: up, front, right
		-- returns a string
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

