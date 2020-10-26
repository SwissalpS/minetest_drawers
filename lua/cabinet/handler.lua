--
-- drawers/lua/cabinet/handler.lua
--
local Base_Object = dofile(drawers.modpath .. '/lua/baseObject.lua')
local Handler = Base_Object:extend()

-- TODO: discuss if it is worth using really short field names
-- in code we could use discriptive varables like so, but globaly defined so
-- other code that accesses cabinet node's metadata can use the same ones
-- would have to be cleaned up in migrate_cabinet_meta()
local key_count = 'count'
local key_item_name = 'name'
local key_locked = 'locked'
local key_slots_per_drawer = 'slots_per_drawer'

--- Handler object initializer
-- use this way:
--	local handler = Handler(pos_cabinet)
-- called by handler_for() when area is first loaded or some other mod cleared
-- out some cached objects.
function Handler:new(pos_cabinet)
print('Handler:new')
	self.is_valid = false
	self.pos_cabinet = table.copy(pos_cabinet)
	-- so all we check is that this instance was instantiated via handler_for
	-- without skipping node check
	if self:is_cabinet_missing() then
print('Handler:new:no cabinet_node')
		return nil
	end
	-- get meta
	self.meta = minetest.get_meta(pos_cabinet)
	self.pos_cabinet = table.copy(pos_cabinet)
	self.is_valid = true
	-- read meta and initialize cached values to defaults if need be
	self:read_meta()
end -- new

--- table of 3 most important values of a drawer
-- returns table with count, name and max_count fields
function Handler:contents_for(tag_id)
	return {
		count = tonumber(self:count_for(tag_id)),
		name = self:item_name_for(tag_id),
		max_count = tonumber(self:max_count_for(tag_id)),
	}
end -- contents_for

--- amount of items in drawer
-- returns a string
function Handler:count_for(tag_id)
	return self.count[tonumber(tag_id)] or ''
end --

--- amount of space in drawer
function Handler:free_space_for(tag_id)
	return tonumber(self:max_count_for(tag_id)) - tonumber(self:count_for(tag_id))
end --

--- Inquire how much of stack fits in drawer.
-- returns int >= 0
-- called by pipeworks compatible nodes
function Handler:how_many_can_insert(tag_id, stack)
	local stack_count = stack:get_count()
	local stack_name = stack:get_name()
	-- no empty stacks or unknown items
	if '' == stack_name
		or 0 >= stack_count
		or not minetest.registered_items[stack_name]
	then
		return 0
	end
	-- don't allow unstackable stacks
	if 1 == stack:get_stack_max() then
		return 0
	end
	local id = tonumber(tag_id)
	-- if attempting to put something else in this drawer
	if '' ~= self.name[id] and stack_name ~= self.name[id] then
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

--- Checks if the cabinet node actually exists
-- returns boolean
function Handler:is_cabinet_missing()
print('Handler:is_cabinet_missing')
	-- check if there is a node at all there
	self.cabinet_node = minetest.get_node_or_nil(self.pos_cabinet)
	if not self.cabinet_node then
		return true
	end
	-- check that it is a drawers compatible node
	-- TODO: we may need to do better check here
	local node_def = minetest.registered_nodes[self.cabinet_node.name]
	if not node_def then
		return false
	end -- if unknown item
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

--- Handle player right-clicking tag entity to put items in drawer.
-- with or without something in hand,
function Handler:player_put(tag_id, player)
	if player.is_fake_player then
		return nil
	end
	-- check permissions first
	local player_name = player:get_player_name()
	if minetest.is_protected(self.pos_cabinet, player_name) then
		minetest.record_protection_violation(self.pos_cabinet, player_name)
		return nil
	end
	-- used to check if we need to play a sound in the end
	local changed = false
	local id = tonumber(tag_id)
	local item_name = self:item_name_for(id)
	local keys = player:get_player_control()
	local wielded_item = player:get_wielded_item()
	local wielded_count = wielded_item:get_count()
	local wielded_name = wielded_item:get_name()
	-- When the player uses the drawer with their bare hand all
	-- stacks from the inventory will be added to the drawer.
	local leftover
	-- if drawer is not empty or empty but locked
	if '' ~= item_name
		-- and player is holding nothing
		and '' == wielded_name
		-- and not holding sneak
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
				changed = true
			end

			-- set new stack
			inv:set_stack('main', i, leftover)
			i = i - 1
		until 0 == i
	else
		-- try to insert wielded item/stack only
		leftover = self:try_insert_stack(tag_id, wielded_item, not keys.sneak)
		-- check if something was added


		if leftover:get_count() < wielded_count then
			changed = true
			-- keep track of the name we may need if being locked
			item_name = wielded_name
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
				self.name[id] = item_name
				self:write_meta()
				changed = true
			end
		end -- if not locked
	end -- if keys.aux1
	if changed then
		self:update_visibles(id)
	end
	return changed
end -- player_put

--- Handle player punching tag entity to take items out.
--function drawers.tag.handle_punch_take(self, player, time_from_last_punch,
--										tool_capabilities, dir)
function Handler:player_take(tag_id, player)
	if player.is_fake_player then
		return nil
	end
	-- check permissions first
	local player_name = player:get_player_name()
	if minetest.is_protected(self.pos_cabinet, player_name) then
		minetest.record_protection_violation(self.pos_cabinet, player_name)
		return nil
	end

	local keys = player:get_player_control()
	local id = tonumber(tag_id)
	local item_name = self.name[id]
	local changed = false
	-- unlock if special key is held
	if keys.aux1 then
		if 1 == self.locked[id] then
			self.locked[id] = 0
			if 0 >= self.count[id] then
				self.name[id] = ''
				self.texture[id] = 'blank.png'
				-- nothing to take, so
				self:write_meta()
				return true
			end
			changed = true
			self:write_meta()
		end -- if locked at all
	end -- if special pressed

	-- if there is nothing to take, nothing to do
	if 0 >= self.count[id] then
		return changed
	end

	-- fake player has no inventory, right? TODO: check that
	local inv = player:get_inventory()
	if not inv then return changed end

	-- if player is holding sneak, only one item
	local stackwize = not keys.sneak

	local checker_stack = ItemStack(item_name)
	if stackwize then
		checker_stack:set_count(self.item_stack_max[id])
	end
	-- what if he has space for half a stack, maybe we should give him that
	-- turns out, that would need a loop through all slots in inventory gathering
	-- all the slots for same item and get count of each... doable, but worth it?
	if not inv:room_for_item('main', checker_stack) then
		return changed
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
	return changed
end -- player_take

--- reads meta from cabinet node and populates Handler object tables
-- called by Handler:new()
-- If another mod wants to manipulate meta, theis is what to call to refresh it.
-- updates visuals
function Handler:read_meta()
print('handler read_meta')
	if not self.is_valid then
print('Handler:read_meta:KO:not valid handler object')
		-- TODO: do we need this check anymore?
		--return nil
	end
	-- reset all cache tables
	self.count = {}
	self.item_stack_max = {}
	self.locked = {}
	self.max_count = {}
	self.name = {}
	self.slots_per_drawer = self.meta:get_int(key_slots_per_drawer)
	-- TODO: see if we can do without caching these two and maybe more
	self.infotext = {}
	self.texture = {}
	local needs_init = 0 == self.slots_per_drawer
	local index = self.drawer_count
	local tag_id, name, stack_max, max_count
	if needs_init then
		-- must be initialized, probably drawer has only just been placed
print('Handler:read_meta:new drawer was just placed')
		self.slots_per_drawer = math.floor(
			drawers.settings.base_slot_count / self.drawer_count)
		stack_max = minetest.nodedef_default.stack_max or 99
		max_count = stack_max * self.slots_per_drawer
		repeat
			self.count[index] = 0
			self.item_stack_max[index] = stack_max
			self.locked[index] = 0
			self.max_count[index] = max_count
			self.name[index] = ''
			self:update_visibles(index)
			index = index - 1
		until 0 == index
		-- probably good idea to save meta at this point
		self:write_meta()
	else
		-- just read
		repeat
			tag_id = tostring(index)
			name = self.meta:get_string(key_item_name .. tag_id)
			self.count[index] = self.meta:get_int(key_count .. tag_id)
			if minetest.registered_items[name] then
				stack_max = minetest.registered_items[name].stack_max
			else
				stack_max = 65535
				-- log a warning to admins
				local warning = '[drawers] ALERT: You have unknown items of type "'
					.. name .. '" in a drawer at: '
					.. minetest.pos_to_string(self.pos_cabinet)
					.. ' drawer with tag id ' .. tag_id .. ' has '
					.. tostring(self.count[index]) .. ' items. '
					.. 'Setting max stack to 65535. Players can remove but '
					.. 'not put more in.'
				minetest.log('warning', warning)
				print(warning)
			end
			self.infotext[index] = ''
			self.item_stack_max[index] = stack_max
			self.name[index] = name
			self.locked[index] = self.meta:get_int(key_locked .. tag_id)
			self.max_count[index] = stack_max * self.slots_per_drawer

			self:update_visibles(index)

			index = index - 1
		until 0 == index -- loop all drawers of this cabinet into object fields
	end -- if needs init or just read
	return true
end -- read_meta

--- update upgrade changes
-- updates visuals and writes to meta
-- called when cabinet formspec is manipulated and maybe soon also by controller
function Handler:set_slots_per_drawer(slots_per_drawer)
	-- did anything actually change?
	if slots_per_drawer == self.slots_per_drawer then
		return
	end
	-- assign new value
	self.slots_per_drawer = slots_per_drawer
	-- update max_count for all drwaers and update visuals
	local id = self.drawer_count
	repeat
		self.max_count[id] = self.slots_per_drawer * self.item_stack_max[id]
		self:update_visibles(id)
		id = id - 1
	until 0 == id
	-- finalize changes
	self:write_meta()
end -- set_slots_per_drawer

--- take requested amount out of drawer with id tag_id or as much as is in there
-- returns stack of taken items
-- updates visuals
-- see also Handler:take_stack(tag_id)
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
	take_count = math.min(take_count, stack:get_stack_max())
	stack:set_count(take_count)

	-- update everything
	-- TODO: optimize, we are taking out, only need to update infotext mostly
	self.count[id] = self.count[id] - take_count
	self:update_visibles(tag_id)
	self:write_meta()

	-- return the stack that was removed from the drawer
	return stack
end -- take_items

--- proxy to Handler:take_items(tag_id, take_count)
-- returns the stack that was removed from the drawer
function Handler:take_stack(tag_id)
	local id = tonumber(tag_id)
	return self:take_items(id, self.item_stack_max[id])
end -- take_stack

--- get texture string for tag with id tag_id.
-- returns a string
function Handler:texture_for(tag_id)
	return self.texture[tonumber(tag_id)] or 'blank.png'
end

--- insert as much as fits, even in neighboring drawers of the same cabinet.
-- return what did not fit
-- please use this route to insert items into drawers
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
	if '' == self:item_name_for(tag_id) then
		self.count[id] = 0
		local name = stack:get_name()
		local stack_max = minetest.registered_items[name].stack_max
		self.name[id] = name
		self.max_count[id] = stack_max * self.slots_per_drawer
		self.item_stack_max[id] = stack_max
	end

	-- update everything
	self.count[id] = self.count[id] + insert_count
	self:update_visibles(tag_id)
	self:write_meta()

	-- return leftover
	stack:take_item(insert_count)
	-- TODO: figure out why we can't give back a stack with zero count
	if 0 == stack:get_count() then
		return ItemStack('')
	end
	return stack
end -- try_insert_stack

--- update user visible indicators
-- infotext and texture
-- called whenever transaction happens and also at init of Handler object
-- it does not write to meta, only to handler object tables.
function Handler:update_visibles(tag_id)
	local id = tonumber(tag_id)
	local item_description = ''
	local item_def = minetest.registered_items[self.name[id]]
	if item_def and item_def.description then
		item_description = item_def.description
	end

	-- string or nil to send to infotext generator
	local locked_to = nil
	if 0 < self.locked[id] then
		-- drawer is locked to an item type
		if '' == item_description then
			locked_to = self.name[id]
		else
			locked_to = item_description
		end
	end -- if is locked

	if 0 >= self.count[id] then
		-- no items
		self.count[id] = 0
		item_description = ''
		if 0 == self.locked[id] then
			-- not locked
			self.name[id] = ''
			self.texture[id] = 'blank.png'
		end
	elseif 'blank.png' == self:texture_for(id) then
		-- contents changed to have a texture
		self.texture[id] = drawers.tag.gui.get_image(self.name[id])
	end -- if empty or not

	self.infotext[id] = drawers.tag.gui.generate_infotext(
		item_description,
		self.count[id],
		self.max_count[id],
		locked_to)

	-- last but not least, tell the tag to refresh
	local tag = drawers.tag.map.tag_for(self.pos_cabinet, id)
	if not tag then
		-- this does happen when area is loading
print('Handler:update_visibles:failed to get tag')
		return
	end
	tag:update(self.infotext[id], self.texture[id])
end -- update_visibles

--- dump current state to cabinet's meta
-- called whenever a change happens
-- returns nil if not a valid handler object or true on success
function Handler:write_meta()
print('Handler:write_meta')
	if not self.is_valid then
print('KO:Handler:write_meta:not a valid handler object')
		return nil
	end
	local index = self.drawer_count
	local tag_id
	repeat
		tag_id = tostring(index)
		self.meta:set_int(key_count .. tag_id, self.count[index])
		self.meta:set_string(key_item_name .. tag_id, self.name[index])
		self.meta:set_int(key_locked .. tag_id, self.locked[index])
		index = index - 1
	until 0 == index
	self.meta:set_int(key_slots_per_drawer, self.slots_per_drawer)

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
		-- we can skip check, as this is done when instantiating new instance.
		skip_cabinet_check = true
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

