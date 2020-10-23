--
-- drawers/lua/cabinet/handler.lua
--
local S, NS = dofile(drawers.modpath .. '/intllib.lua')
local Base_Object = dofile(drawers.modpath .. '/lua/baseObject.lua')
local Handler = Base_Object:extend()

-- TODO: discuss if it is worth using really short field names
-- in code we could use discriptive varables like so, but globaly defined so
-- other code that accesses cabinet node's metadata can use the same ones
-- would have to be cleaned up in migrate_cabinet_meta()
local key_count = 'count'
local key_infotext = 'infotext'
local key_item_name = 'name'
local key_item_stack_max = 'item_stack_max'
local key_locked = 'locked'
local key_max_count = 'max_count'
local key_stack_max_factor = 'stackMaxFactor'
local key_texture = 'texture'

-- use this way:
--	local handler = Handler(pos_cabinet)
function Handler:new(pos_cabinet)
	self.is_valid = false

	-- check if there is a node at all there
	self.cabinet_node = minetest.get_node_or_nil(pos_cabinet)
	if not self.cabinet_node then
		return nil
	end

	-- check that it is a drawers compatible node
	-- TODO: we may need to do better check here
	local node_def = minetest.registered_nodes[self.cabinet_node.name]
	self.drawer_count = node_def.groups.drawers
	if not (0 < self.drawer_count) then
		return nil
	end

	-- get meta
	self.meta = minetest.get_meta(pos_cabinet)
	self.pos_cabinet = table.copy(pos_cabinet)
	self.is_valid = true
	self:read_meta()
end -- new

function Handler:count_for(tag_id)
	return self.count[tonumber(tag_id)] or ''
end

function Handler:how_many_can_insert(tag_id, stack)
	local stack_count = stack:get_count()
	if '' == stack:get_name() or 0 >= stack_count then
		return 0
	end

	local id = tonumber(tag_id)
	-- don't allow unstackable stacks
	-- if drawer is empty and item's max stack size is not 1
	if '' == self.name[id] and 1 ~= stack:get_stack_max() then
		-- TODO: limit this to valid stack size and also check if we have that
		--	much space. Just because we are empty does not guarantee we can take
		--	any amount.
		return stack_count
	end

	-- if attempting to put something else in this drawer
	if stack:get_name() ~= self.name[id] then
		return 0
	end

	-- fits easily
	if (self.count[id] + stack_count) <= self.max_count[id] then
		return stack_count
	end

	-- return how many would still have space
	return self.max_count[id] - self.count[id]
end -- how_many_can_insert

function Handler:infotext_for(tag_id)
	return self.infotext[tonumber(tag_id)] or ''
end

function Handler:is_cabinet_missing()
	-- check if there is a node at all there
	self.cabinet_node = minetest.get_node_or_nil(self.pos_cabinet)
	if not self.cabinet_node then
		return true
	end

	-- check that it is a drawers compatible node
	-- TODO: we may need to do better check here
	local node_def = minetest.registered_nodes[self.cabinet_node.name]
	self.drawer_count = node_def.groups.drawers
	if not (0 < self.drawer_count) then
		return true
	end

	return false
end -- is_cabinet_missing

function Handler:item_name_for(tag_id)
	return self.name[tonumber(tag_id)] or ''
end

function Handler:item_stack_max_for(tag_id)
	return self.item_stack_max[tonumber(tag_id)] or 0
end

function Handler:locked_for(tag_id)
	return self.locked[tonumber(tag_id)] or 0
end

function Handler:max_count_for(tag_id)
	return self.max_count[tonumber(tag_id)] or 0
end

-- called when player right clicks tag with or without something in hand,
-- to put items in
function Handler:player_put(tag_id, player)
	-- check permissions first
	local player_name = player:get_player_name()
	if minetest.is_protected(self.pos_cabinet, player_name) then
		minetest.record_protection_violation(self.pos_cabinet, player_name)
		return nil
	end

	-- used to check if we need to play a sound in the end
	local inventory_changed = false
	local item_name = self:item_name_for(tag_id)
	local keys = player:get_player_control()
	local wielded_item = player:get_wielded_item()
	-- When the player uses the drawer with their bare hand all
	-- stacks from the inventory will be added to the drawer.
	local leftover
	if '' ~= item_name
		and '' == wielded_item:get_name()
		and not keys.sneak
	then
		-- try to insert all items from inventory
		local stack
		local inv = player:get_inventory()
		local i = inv:get_size('main')
		repeat
			stack = inv:get_stack('main', i)
			-- set current stack to leftover of insertion
			leftover = self:try_insert_stack(tag_id, stack, true)

			-- check if something was added
			if leftover:get_count() < stack:get_count() then
				inventory_changed = true
			end

			-- set new stack
			inv:set_stack('main', i, leftover)
			i = i - 1
		until 0 == i
	else
		-- try to insert wielded item/stack only
		leftover = self:try_insert_stack(tag_id, wielded_item, not keys.sneak)

		-- check if something was added
		if leftover:get_count() < wielded_item:get_count() then
			inventory_changed = true
			item_name = wielded_item:get_name()
		end
		-- set the leftover as new wielded item for the player
		player:set_wielded_item(leftover)
	end
	if keys.aux1 then
		-- TODO: move this to a generalized method so later it can be done using
		-- digiline or some other tool
		-- lock the drawer to it's item
		if 0 == self.locked[id] then
			-- don't lock drawers that don't have an item assigned yet
			if 0 < #item_name then
				self.locked[id] = 1
				self:write_meta()
				minetest.chat_send_player(player_name,
					S('Drawer assigned to @1', item_name))
			end
		end -- if not locked
	end -- if keys.aux1
	return inventory_changed
end -- player_put

-- called when a player punches the entity to take items
--function drawers.tag.handle_punch_take(self, player, time_from_last_punch,
--										tool_capabilities, dir)
function Handler:player_take(tag_id, player)
	-- check permissions first
	local player_name = player:get_player_name()
	if minetest.is_protected(self.pos_cabinet, player_name) then
		minetest.record_protection_violation(self.pos_cabinet, player_name)
		return nil
	end

	local keys = player:get_player_control()
	local id = tonumber(tag_id)
	local item_name = self.name[id]
	-- unlock if special key is held
	if keys.aux1 then
		if 1 == self.locked[id] then
			self.locked[id] = 0
			minetest.chat_send_player(player_name, S('Drawer unlocked'))
			if 0 >= self.count[id] then
				self.name[id] = ''
				-- nothing to take, so
				self:write_meta()
				return false
			end
			self:write_meta()
		end -- if locked at all
	end -- if special pressed

	-- fake player has no inventory, right? TODO: check that
	local inv = player:get_inventory()
	if not inv then return false end

	-- if player is holding sneak, only one item
	local stackwize = not keys.sneak

	local checker_stack = ItemStack(item_name)
	if stackwize then
		checker_stack:set_count(checker_stack:get_stack_max())
	end
	-- what if he has space for half a stack, maybe we should give him that
	-- turns out, that would need a loop through all slots in inventory gathering
	-- all the slots for same item and get count of each... doable, but worth it?
	if not inv:room_for_item('main', checker_stack) then
		return false
	end

	local stack
	if stackwize then
		stack = self:take_stack(tag_id)
	else
		stack = self:take_items(tag_id, 1)
	end

	if stack then
		-- add removed stack to player's inventory
		inv:add_item('main', stack)
		-- play the interact sound
		return true
	end
end -- player_take

function Handler:read_meta()
	if not self.is_valid then
		--return nil
	end
	self.locked = {}
	self.count = {}
	self.name = {}
	self.max_count = {}
	self.item_stack_max = {}
	self.stack_max_factor = {}
	-- TODO: see if we can do without caching these two and maybe more
	self.texture = {}
	self.infotext = {}
	local index = self.drawer_count
	local tag_id
	repeat
		tag_id = tostring(index)
		self.locked[index] = self.meta:get_int(key_locked .. tag_id)
		self.count[index] = self.meta:get_int(key_count .. tag_id)
		self.name[index] = self.meta:get_string(key_item_name .. tag_id)
		self.max_count[index] = self.meta:get_int(key_max_count .. tag_id)
		self.item_stack_max[index] = self.meta:get_int(key_item_stack_max .. tag_id)
		self.texture[index] = self.meta:get_string(key_texture .. tag_id)
		if '' == self.texture[index] then
			self.texture[index] = 'blank.png'
		end
		self.infotext[index] = self.meta:get_string(key_infotext .. tag_id)
		index = index - 1
	until 0 == index -- loop all drawers of this cabinet into object fields
	self.stack_max_factor = self.meta:get_int(key_stack_max_factor)

	return true
end -- read_meta

function Handler:set_stack_max_factor(stack_max_factor)

	self.stack_max_factor = stack_max_factor

	-- TODO: test if we need to copy this or if this is implicitly a copy
	local id = self.drawer_count
	repeat
		self.max_count[id] = self.stack_max_factor * self.item_stack_max[id]
		self:update_infotext(id)
		id = id - 1
	until 0 == id
	self:write_meta()

end -- set_stack_max_factor

function Handler:stack_max_factor_for(tag_id)
	return self.stack_max_factor or 0
end

function Handler:take_items(tag_id, take_count)
	local id = tonumber(tag_id)
	if 0 >= self.count[id] then
		return nil
	end

	if take_count > self.count[id] then
		take_count = self.count[id]
	end

	local item_name = self.name[id]
	local stack = ItemStack(item_name)
	stack:set_count(take_count)

	-- update everything
	self.count[id] = self.count[id] - take_count
	self:update_infotext(tag_id)
	self.texture[id] = drawers.tag.gui.get_image(item_name)
	self:write_meta()

	-- return the stack that was removed from the drawer
	return stack
end -- take_items

function Handler:take_stack(tag_id)
	return self:take_items(ItemStack(self:item_name_for(tag_id)):get_stack_max())
end -- take_stack

function Handler:texture_for(tag_id)
	return self.texture[tonumber(tag_id)] or 'blank.png'
end

-- return what did not fit
function Handler:try_insert_stack(tag_id, stack, insert_all)
	-- make sure count is correct
	local itemstack = ItemStack(stack)
	if not insert_all then
		itemstack:set_count(1)
	end

	local insert_count = self:how_many_can_insert(tag_id, itemstack)

	-- no space, no action
	if 0 == insert_count then
		return stack
	end

	local id = tonumber(tag_id)

	-- in case the drawer was empty, initialize count, itemName, maxCount
	if '' == self.item_name_for(tag_id) then
		self.count[id] = 0
		self.name[id] = itemstack:get_name()
		self.max_count[id] = itemstack:get_stack_max() * self.stack_max_factor
		self.item_stack_max[id] = itemstack:get_stack_max()
	end

	-- update everything
	self.count[id] = self.count[id] + insert_count
	self:update_infotext(tag_id)
	self.texture[id] = drawers.tag.gui.get_image(self.name[id])
	self:write_meta()

	-- return leftover
	itemstack:take_item(insert_count)
	-- TODO: figure out why we can't give back a stack with zero count
	if 0 == itemstack:get_count() then
		return ItemStack('')
	end
	return itemstack
end -- try_insert_stack

function Handler:update_infotext(tag_id)
	local id = tonumber(tag_id)
	local item_description = ''
	local item_def = minetest.registered_items[self.name[id]]
	if item_def and item_def.description then
		item_description = item_def.description
	end

	if 0 >= self.count[id] then
		self.count[id] = 0
		item_description = S('Empty')
		if 0 == self.locked[id] then
			self.name[id] = ''
			self.texture[id] = 'blank.png'
		end
	end -- if empty

	self.infotext[id] = drawers.tag.gui.generate_info_text(
		item_description,
		self.count[id],
		self.stack_max_factor,
		self.item_stack_max[id])
end -- update_infotext

function Handler:write_meta()
	if not self.is_valid then
		return nil
	end
	local index = self.drawer_count
	local tag_id
	repeat
		tag_id = tostring(index)
		self.meta:set_int(key_locked .. tag_id, self.locked[index])
		self.meta:set_int(key_count .. tag_id, self.count[index])
		self.meta:set_string(key_item_name .. tag_id, self.name[index])
		-- TODO: can we please not store this one, we already have the other
		--		two factors that produce this value
		self.meta:set_int(key_max_count .. tag_id, self.max_count[index])
		self.meta:set_int(key_item_stack_max .. tag_id, self.item_stack_max[index])
		self.meta:set_string(key_texture .. tag_id, self.texture[index])
		self.meta:set_string(key_infotext .. tag_id, self.infotext[index])
		index = index - 1
	until 0 == index
	self.meta:set_int(key_stack_max_factor, self.stack_max_factor)

	return true
end -- write_meta

-- ====================================================================
-- ====================================================================
-- ====================================================================
-- ====================================================================

drawers.cabinet.Handler = Handler
-- runtime cache of handler object references
drawers.cabinet.handlers = {}

-- ====================================================================
-- ====================================================================
-- ====================================================================
-- ====================================================================

function drawers.cabinet.handler_for(pos_cabinet, skip_cabinet_check)
	-- TODO: performance checks to see if it is worth caching at all
	--		especially if we need to check for existance of drawer on each
	--		call. Maybe we don't need to do that though.
	local pos_hash = minetest.hash_node_position(pos_cabinet)
	local handler = drawers.cabinet.handlers[pos_hash]
	local remove_tags = false
	if not handler then
		-- none yet, let's try to create one
		handler = drawers.cabinet.Handler(pos_cabinet)
		if not handler.is_valid then
			remove_tags = true
		end
		drawers.cabinet.handlers[pos_hash] = handler
	end
	if not skip_cabinet_check then
		remove_tags = handler:is_cabinet_missing()
	end
	if remove_tags then
		drawers.tag.map.remove_for(pos_cabinet)
		drawers.cabinet.handlers[pos_hash] = nil
		return nil
	end
	return handler
end -- drawers.cabinet.handler_for

function drawers.cabinet.remove_handler_for(pos_cabinet)
	local pos_hash = minetest.hash_node_position(pos_cabinet)
	drawers.cabinet.handlers[pos_hash] = nil
end -- drawers.cabinet.remove_handler_for

-- ====================================================================
-- ====================================================================
-- ====================================================================
-- ====================================================================

