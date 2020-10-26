--
-- drawers/lua/controller/init.lua
--
drawers.controller = {}

drawers.controller.key_empty = '0'

dofile(drawers.modpath .. '/lua/controller/gui.lua')
dofile(drawers.modpath .. '/lua/controller/digilines.lua')
dofile(drawers.modpath .. '/lua/controller/controller.lua')
dofile(drawers.modpath .. '/lua/controller/crafts.lua')
dofile(drawers.modpath .. '/lua/controller/nodes.lua')
dofile(drawers.modpath .. '/lua/controller/register.lua')

