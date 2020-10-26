--
-- drawers/lua/cabinet/gui.lua
--
-- formspec for the cabinet and node bounds definition

drawers.cabinet.gui = {}

function drawers.cabinet.gui.upgrade_slots_background(x, y)
	local out = ''
	for i = 0, 4, 1 do
		out = out .. 'image['
			.. tostring(x + i) .. ',' .. tostring(y)
			.. ';1,1;drawers_upgrade_slot_bg.png]'
	end
	return out
end -- drawers.cabinet.gui.upgrade_slots_background

local list_width = '8'
if drawers.has_mcl_core then list_width = '9' end

drawers.cabinet.gui.formspec = 'size[' .. list_width .. ',7]'
	.. 'list[context;upgrades;2,0.5;5,1;]'
	.. 'list[current_player;main;0,3;' .. list_width .. ',4;]'
	.. 'listring[]'
	.. drawers.gui.background
	.. drawers.gui.background_image
	.. drawers.gui.slots
	.. drawers.cabinet.gui.upgrade_slots_background(2, 0.5)

