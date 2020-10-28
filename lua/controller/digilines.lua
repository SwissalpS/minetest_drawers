--
--- drawers/lua/controller/digilines.lua
--

function drawers.controller.on_digiline_receive(pos_controller, _, channel, msg)
	local meta = minetest.get_meta(pos_controller)
	if channel ~= meta:get_string('channel') then
		return
	end
	-- msg can be string 'default:cobble 34'
	-- or table { name = 'default:cobble', count = 34 }
	local stack = ItemStack(msg)
	local taken_stack = drawers.controller.take(pos_controller, stack)
	if 0 >= taken_stack:get_count() then
		return
	end

	local dir = minetest.facedir_to_dir(minetest.get_node(pos_controller).param2)
	local stack_string = taken_stack:to_string()
	pipeworks.tube_inject_item(pos_controller, pos_controller, dir, stack_string)
end -- drawers.controller.on_digiline_receive

