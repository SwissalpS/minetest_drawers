--
-- drawers/lua/cabinet/init.lua
--
-- may be referenced as dc or dcab
drawers.cabinet = {}

dofile(drawers.modpath .. '/lua/cabinet/gui.lua')
dofile(drawers.modpath .. '/lua/cabinet/upgrade.lua')
dofile(drawers.modpath .. '/lua/cabinet/trim.lua')
dofile(drawers.modpath .. '/lua/cabinet/cabinet.lua')
dofile(drawers.modpath .. '/lua/cabinet/register.lua')

