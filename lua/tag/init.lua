--
-- drawers/lua/tag/init.lua
--
-- tag is the entity thet shows what is in drawers of a cabinet
-- (used to be called visual)
-- It refers to handler for player interactions and to get data on what to
-- show players. It no longer plays a vital role in storing data. All it needs
-- to know, is it's tag_id (index within cabinet) And even if that should be
-- lost/corrupted, that has no influence for player's storage.

-- may be referenced as dt or dtag
drawers.tag = {}
-- cache to keep track of tags
drawers.tag.tags = {}

dofile(drawers.modpath .. '/lua/tag/gui.lua')
dofile(drawers.modpath .. '/lua/tag/map.lua')
dofile(drawers.modpath .. '/lua/tag/tag.lua')
dofile(drawers.modpath .. '/lua/tag/register.lua')

