--
-- drawers/lua/tag/init.lua
--
-- tag is the entity thet keeps track of drawers in a cabinet
-- (used to be called visual)

-- may be referenced as dt or dtag
drawers.tag = {}
-- hacky cache to keep track of tags
-- TODO: make sure deactivated ones are dereferenced unless that makes no sense
drawers.tag.tags = {}

dofile(drawers.modpath .. '/lua/tag/gui.lua')
dofile(drawers.modpath .. '/lua/tag/map.lua')
dofile(drawers.modpath .. '/lua/tag/tag.lua')
dofile(drawers.modpath .. '/lua/tag/register.lua')

