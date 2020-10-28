--
-- drawers/lua/cabinet/init.lua
--
-- may be referenced as dc or dcab
drawers.cabinet = {}

-- code object that helps handle drawers contents
dofile(drawers.modpath .. '/lua/cabinet/handler.lua')
dofile(drawers.modpath .. '/lua/cabinet/gui.lua')
dofile(drawers.modpath .. '/lua/cabinet/upgrade.lua')
dofile(drawers.modpath .. '/lua/cabinet/cabinet.lua')
dofile(drawers.modpath .. '/lua/cabinet/register.lua')

