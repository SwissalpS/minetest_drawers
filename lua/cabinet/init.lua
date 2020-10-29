--
-- drawers/lua/cabinet/init.lua
--
-- cabinet contains drawers which are identified by tag entities.
-- All meta access is handled by Handler object.

-- may be referenced as dc or dcab
drawers.cabinet = {}

-- code object that handles drawers contents
dofile(drawers.modpath .. '/lua/cabinet/handler.lua')
dofile(drawers.modpath .. '/lua/cabinet/gui.lua')
dofile(drawers.modpath .. '/lua/cabinet/upgrade.lua')
dofile(drawers.modpath .. '/lua/cabinet/cabinet.lua')
dofile(drawers.modpath .. '/lua/cabinet/register.lua')

