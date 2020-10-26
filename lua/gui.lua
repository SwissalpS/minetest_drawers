--
-- drawers/lua/gui.lua
--
-- common formspec snippets

-- Load support for intllib.
--local S, NS = dofile(drawers.modpath .. '/intllib.lua')

-- may be referenced locally as dg or dgui
drawers.gui = {}

drawers.gui.background = 'bgcolor[#080808BB;true]'
drawers.gui.slots = 'listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]'
if drawers.has_mcl_core then
	drawers.gui.background_image = 'background[5,5;1,1;crafting_creative_bg.png;true]'
else
	drawers.gui.background_image = 'background[5,5;1,1;gui_formbg.png;true]'
end

drawers.gui.node_box_simple = {
	{ -0.5,    -0.5,    -0.4375, 0.5,     0.5,     0.5 },
	{ -0.5,    -0.5,    -0.5,   -0.4375,  0.5,    -0.4375 },
	{  0.4375, -0.5,    -0.5,    0.5,     0.5,    -0.4375 },
	{ -0.4375,  0.4375, -0.5,    0.4375,  0.5,    -0.4375 },
	{ -0.4375, -0.5,    -0.5,    0.4375, -0.4375, -0.4375 },
}

