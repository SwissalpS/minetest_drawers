--
-- drawers/lua/settings.lua
--
-- may be referenced locally as ds or dset
drawers.settings = {}

drawers.settings.chest_itemstring = 'chest'
drawers.settings.wood_itemstring = 'group:wood'
drawers.settings.base_slot_count = 4 * 8

if drawers.has_default then
	drawers.settings.chest_itemstring = 'default:chest'
	drawers.settings.wood_sounds = default.node_sound_wood_defaults()
elseif drawers.has_mcl_core then  -- MineClone 2
	drawers.settings.chest_itemstring = 'mcl_chests:chest'
	if drawers.has_mcl_sounds then
		drawers.settings.wood_sounds = mcl_sounds.node_sound_wood_defaults()
	end
	drawers.settings.base_slot_count = 4 * 9
end

-- jumpdrive compat, read comment in settingtypes.txt
drawers.settings.after_jump_delay = math.abs(tonumber(minetest.settings:get(
										'drawers_after_jump_delay') or 1.3))

-- log more info about activity
drawers.settings.be_verbose = minetest.settings:get_bool('drawers_be_verbose', false)

-- radius to index cabinets around controllers
drawers.settings.controller_range = tonumber(minetest.settings:get(
										'drawers_controller_range_max') or 14)

drawers.settings.max_network_nodes = tonumber(minetest.settings:get(
										'drawers_max_network_nodes') or 4000)

-- Time limit when indexing the network, in seconds
drawers.settings.max_us = 1000000 * tonumber(minetest.settings:get(
										'drawers_max_seconds') or 0.75)

-- which cabinet sizes are available on this server
drawers.settings.use_cabinet_1x1 = not minetest.settings:get_bool(
										'drawers_disable_1x1', false)
drawers.settings.use_cabinet_1x2 = not minetest.settings:get_bool(
										'drawers_disable_1x2', false)
drawers.settings.use_cabinet_2x2 = not minetest.settings:get_bool(
										'drawers_disable_2x2', false)

