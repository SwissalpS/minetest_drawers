--
--- drawers/lua/controller/gui.lua
--
local S, NS = dofile(drawers.modpath .. '/intllib.lua')

drawers.controller.gui = {}

local list_width = '8'
if drawers.has_mcl_core then
	list_width = '9'
end

function drawers.controller.gui.formspec(pos_controller)
	local use_all = core.get_meta(pos_controller):get_int('use_all')
	if 0 >= use_all then use_all = 'false' else use_all = 'true' end
	local formspec = 'size[' .. list_width .. ',8.9]'
		.. drawers.gui.background
		.. drawers.gui.background_image
		.. drawers.gui.slots
		.. 'label[0,0;' .. S('Drawer Controller') .. ']'
		.. 'list[current_name;src;3.5,1.75;1,1;]'
		-- TODO what is the reason for splitting player list, just looks?
		.. 'list[current_player;main;0,4.65;' .. list_width .. ',1;]'
		.. 'list[current_player;main;0,5.9;' .. list_width .. ',3;'
		 .. list_width .. ']'
		.. 'listring[current_player;main]'
		.. 'listring[current_name;src]'
		.. 'listring[current_player;main]'
		.. 'checkbox[0.7,2.6;use_all;' .. S('Use all cabinets') .. ';'
		.. use_all .. ']'

	if drawers.has_digilines and drawers.has_pipeworks then
		formspec = formspec .. 'field[1,3.9;4,1;channel;'
			.. S('Digiline Channel') .. ';${channel}]'
			.. 'button_exit[5,3.6;2,1;save_channel;' .. S('Save') .. ']'
	end

	return formspec
end -- drawers.controller.gui.formspec

