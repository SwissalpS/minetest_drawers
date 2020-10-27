local load_start = os.clock()

-- home sweet home
drawers = {}
drawers.modpath = minetest.get_modpath(minetest.get_current_modname())
-- place to cache some data during runtime
drawers.tmp = {}

-- mod availability detection
dofile(drawers.modpath .. '/lua/modDetection.lua')
-- hard shared gui items
dofile(drawers.modpath .. '/lua/gui.lua')
-- server settings and hard coded values
dofile(drawers.modpath .. '/lua/settings.lua')
-- load tag code aka visual, the entity showing what is in drawer
dofile(drawers.modpath .. '/lua/tag/init.lua')
-- load cabinet code aka drawer node and trim, register crafts and nodes
-- stores meta for drawers within a cabinet
-- handles tube traffic
dofile(drawers.modpath .. '/lua/cabinet/init.lua')
-- load compactor
dofile(drawers.modpath .. '/lua/compactor/init.lua')
-- load controller code, register crafts and nodes
-- stores cache of network
-- handles tubes and digiline
dofile(drawers.modpath .. '/lua/controller/init.lua')
--------------------------------------------------------------------------------
print(('[drawers] loaded in %f seconds'):format(os.clock() - load_start))

