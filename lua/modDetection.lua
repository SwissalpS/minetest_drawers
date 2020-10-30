--
-- drawers/lua/modDetection.lua
-- detect which other mods are being used
--
drawers.has_default = minetest.get_modpath('default')
						and minetest.global_exists('default')

drawers.has_digilines = minetest.get_modpath('digilines')
						and minetest.global_exists('digilines')

drawers.has_jumpdrive = minetest.get_modpath('jumpdrive')
						and minetest.global_exists('jumpdrive')

-- MineClone 2
drawers.has_mcl_core = minetest.get_modpath('mcl_core')
						and minetest.global_exists('mcl_core')

drawers.has_mcl_sounds = minetest.get_modpath('mcl_sounds')
						and minetest.global_exists('mcl_sounds')

drawers.has_mesecons_mvps = minetest.get_modpath('mesecons_mvps')
						and minetest.global_exists('mesecons_mvps')

drawers.has_moreores = minetest.get_modpath('moreores')
						and minetest.global_exists('moreores')

drawers.has_pipeworks = minetest.get_modpath('pipeworks')
						and minetest.global_exists('pipeworks')

drawers.has_screwdriver = minetest.get_modpath('screwdriver')
						and minetest.global_exists('screwdriver')

