--
-- drawers/lua/cabinet/gui.lua
--
-- formspec for the cabinet

drawers.cabinet.gui = {}

drawers.cabinet.gui.node_box_simple = {
	{ -0.5,    -0.5,    -0.4375, 0.5,     0.5,     0.5 },
	{ -0.5,    -0.5,    -0.5,   -0.4375,  0.5,    -0.4375 },
	{  0.4375, -0.5,    -0.5,    0.5,     0.5,    -0.4375 },
	{ -0.4375,  0.4375, -0.5,    0.4375,  0.5,    -0.4375 },
	{ -0.4375, -0.5,    -0.5,    0.4375, -0.4375, -0.4375 },
}

drawers.cabinet.gui.formspec = 'size[9,7]'
	.. 'list[context;upgrades;2,0.5;5,1;]'
	.. 'list[current_player;main;0,3;9,4;]'
	.. 'listring[]'
	.. drawers.gui.background
	.. drawers.gui.background_image
	.. drawers.gui.slots
	.. drawers.cabinet.gui.upgrade_slots_background(2, 0.5)

function drawers.cabinet.gui.upgrade_slots_background(x, y)
	local out = ''
	for i = 0, 4, 1 do
		out = out .. 'image['
			.. tostring(x + i) .. ',' .. tostring(y)
			.. ';1,1;drawers_upgrade_slot_bg.png]'
	end
	return out
end -- drawers.cabinet.gui.upgrade_slots_background

