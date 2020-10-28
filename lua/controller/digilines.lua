--
--- drawers/lua/controller/digilines.lua
--

-- TODO
-- add digiline command: has_item; only give bool back, SwissalpS is tending to
-- say no to this request. It would mean parsing digiline message in more
-- complicated way and would also mean that users expect to be able to do other
-- things like set use_all and inquire about space for something instead of
-- building systems themselves that fullfill these functions.
-- test how orientation of controller to orientation of cabinets affects output

function drawers.controller.on_digiline_receive(pos_controller, _, channel, msg)
	local meta = minetest.get_meta(pos_controller)
	if channel ~= meta:get_string('channel') then
		return
	end
	local message = {}
	local msg_type = type(msg)
	if 'string' == msg_type
		or ('table' == msg_type and (not msg.command))
	then
		message = { command = 'take', stack = msg }
	elseif 'table' == msg_type and msg.command then
		message = msg
	else
		return
	end
	local command = message.command
	if 'take' == command then
		if not message.stack then
			return
		end
		-- message.stack can be string 'default:cobble 34'
		-- or table { name = 'default:cobble', count = 34 }
		local stack = ItemStack(message.stack)
		local taken_stack = drawers.controller.take(pos_controller, stack)
print('digiline, got stack: ', taken_stack:to_string())
		if 0 >= taken_stack:get_count() then
			return
		end

		local dir = minetest.facedir_to_dir(minetest.get_node(pos_controller).param2)
		local stack_string = taken_stack:to_string()
		pipeworks.tube_inject_item(pos_controller, pos_controller, dir, stack_string)
		return
	end
--[[
	if 'has' == command then
		if not message.name then
			return
		end
		local meta = minetest.get_meta(pos_controller)
		local net_index = minetest.deserialize(meta:get_string('net_index'))
		local item_index = net_index[message.name]
		if not item_index then
			return false -- actually send digiline message
		end
		-- check if it really does have some in that drawer
	end
--]]
end -- drawers.controller.on_digiline_receive

