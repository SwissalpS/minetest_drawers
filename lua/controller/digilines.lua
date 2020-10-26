--
--- drawers/lua/controller/digilines.lua
--

function drawers.controller.on_digiline_receive(pos_controller, _, channel, msg)
	local meta = minetest.get_meta(pos_controller)

	if channel ~= meta:get_string('channel') then
		return
	end

	local item = ItemStack(msg)
	local item_name = item:get_name()
	local drawers_index = drawers.controller.get_drawer_index(
													pos_controller, item_name)

	if not drawers_index[item_name] then
		-- we can't do anything: the requested item doesn't exist
		return
	end

	local taken_stack = drawers.cabinet.take_item(
		drawers_index[item_name]['pos_cabinet'], item)

	-- prevent crash if taken_stack ended up with a nil value
	if not taken_stack then
		return
	end
	local dir = minetest.facedir_to_dir(minetest.get_node(pos_controller).param2)

	pipeworks.tube_inject_item(
				pos_controller, pos_controller, dir, taken_stack:to_string())
end -- drawers.controller.on_digiline_receive

