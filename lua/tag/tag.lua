--
-- drawers/lua/tag/tag.lua
--
-- Load support for intllib.
local S, NS = dofile(drawers.modpath .. '/intllib.lua')

-- can be referenced locally as dtk or dtkeys
-- these are 'static' to make code more readable. They are in global table
-- for flexibility reasons which is probably not such a good idea.
-- TODO: make functions that define these locally so other code does not need
-- to know them at all. They are only to keep metadata short.
drawers.tag.meta_keys = {}


-- this only migrates metadata in cabinet node for self
function drawers.tag.migrate_cabinet_meta(self)
	-- for now we have nothing to migrate
	return
	-- all cabinets have at least one drawer, so we can safely test this way.
--	if 0 < self.meta:get_int('item_stack_max1') then return end
--	self.meta:set_int('item_stack_max' .. self.tag_id, self.meta:get_int(''))
end -- migrate_cabinet_meta

-- migrates deserialized static data to newer version
function drawers.tag.migrate_tag_data(data)
	-- backwards compatibility to really old versions
	if 'drawers_empty.png' == data.texture then data.texture = 'blank.png' end
	-- already using new version
	if nil ~= data.x then return data end

	data.c = data.drawerType
	data.i = data.visualId
	data.t = data.texture
	data.x = data.drawer_posx
	data.y = data.drawer_posy
	data.z = data.drawer_posz

	-- clear out old keys (not important as serialized_static_data will make new table)
	-- this is mainly to help us debug code for parts that may still not use new keys
	data.drawerType = nil
	data.visualId = nil
	data.texture = nil
	data.drawer_posx = nil
	data.drawer_posy = nil
	data.drawer_posz = nil

	return data
end -- drawers.tag.migrate

-- this is called when entity is deactivated, it MUST return a string.
-- this string will be passed to on_activate when entity is restored.
function drawers.tag.get_serialized_static_data(self)
	return minetest.serialize({
		-- do we really need to store this here too?
		c = self.drawer_count, -- how many drawers in this cabinet
		-- index in cabinet
		i = self.tag_id,
		-- texture of item stored in drawer
		t = self.texture,
		-- position of cabinet node
		x = self.pos_cabinet.x,
		y = self.pos_cabinet.y,
		z = self.pos_cabinet.z,
	})
end

-- this is called when entity is activated for first time or reactivated.
-- first time static_data_serialized is an empty string
-- delta_seconds is the time that passed since entyty was deactivated, we can ignore that.
function drawers.tag.on_activate(self, static_data_serialized, delta_seconds)
	-- TODO: why are we using object pos here and pos_cabinet later for same
	-- variable?
	-- Now that I moved this block to beginning it makes more sense to use object pos
	local cabinet_node = minetest.get_node(self.object:get_pos())
	if 0 == minetest.get_item_group(cabinet_node.name, 'drawers') then
		self.object:remove()
		return
	end

	-- Restore data
	local data = minetest.deserialize(static_data_serialized)
	if data then
		data = drawers.tag.migrate_tag_data(data)
		self.pos_cabinet = {
			x = data.x,
			y = data.y,
			z = data.z,
		}
		self.drawer_count = data.c or 1
		self.tag_id = data.i or ''
		self.texture = data.t
	else
		-- being created for the first time, we fetch values
		-- from mod cache
		-- TODO: rename and reorganize these
		self.pos_cabinet = drawers.tmp.new_pos_cabinet
		-- TODO: why are we storing this in every tag?
		self.drawer_count = drawers.tmp.new_cabinet_drawer_count
		self.tag_id = drawers.tmp.new_tag_id
		self.texture = drawers.tmp.new_tag_texture or 'blank.png'
	end

	-- add self to public drawer tag cache table
	-- this is needed because there is no other way to get this class
	-- only the underlying LuaEntitySAO
	-- PLEASE contact me, if this is wrong
	local id = self.tag_id
	if '' == id then id = 1 end
	local pos_hash = minetest.hash_node_position(self.pos_cabinet)
	if not drawers.tag.tags[pos_hash] then drawers.tag.tags[pos_hash] = {} end
	drawers.tag.tags.[pos_hash][id] = self

	-- get meta
	self.meta = minetest.get_meta(self.pos_cabinet)
	self:migrate_cabinet_meta()

	-- collisionbox
	cabinet_node = minetest.get_node(self.pos_cabinet)
	local collisionbox
	if 2 == self.drawer_count then
		if 1 == cabinet_node.param2 or 3 == cabinet_node.param2 then
			-- for param2 = 1 or 3
			collisionbox = {0, -0.2187, -0.4374, 0, 0.2187, 0.4374 }
		else
			-- for param2 = 0 or 2
			collisionbox = { -0.4374, -0.2187, 0, 0.4374, 0.2187, 0 }
		end
	else
		if 1 == cabinet_node.param2 or 3 == cabinet_node.param2 then
			-- for param2 = 1 or 3
			collisionbox = { 0, -0.4374, -0.4374, 0, 0.4374, 0.4374 }
		else
			-- for param2 = 0 or 2
			collisionbox = { -0.4374, -0.4374, 0, 0.4374, 0.4374, 0 }
		end
		-- only half the size if it's a small drawer
		if 1 < self.drawer_count then
			for i, j in pairs(collisionbox) do
				collisionbox[i] = j * 0.5
			end
		end
	end -- if for 1x2 or other cabinet

	-- visual size
	local visual_size = { x = 0.6, y = 0.6 }
	if 2 <= self.drawer_count then
		visual_size = { x = 0.3, y = 0.3 }
	end

	-- drawer values
	-- TODO: why do we store this info in cabinet and in tag?
	self.count = self.meta:get_int('count' .. id)
	self.item_name = self.meta:get_string('name' .. id)
	self.max_count = self.meta:get_int('max_count' .. id)
	self.item_stack_max = self.meta:get_int('item_stack_max' .. id)
	self.stack_max_factor = self.meta:get_int('stack_max_factor' .. id)

	-- infotext
	local infotext = self.meta:get_string('entity_infotext' .. id) .. '\n\n\n\n\n'

	self.object:set_properties({
		collisionbox = collisionbox,
		infotext = infotext,
		textures = { self.texture },
		visual_size = visual_size
	})

	-- make entity undestroyable
	self.object:set_armor_groups({ immortal = 1 })
end -- drawers.tag.on_activate

-- called when player right clicks entity with or without something in hand.
-- to put items in
function drawers.tag.handle_use_put(self, player)
	-- check if cabinet still exists
	local cabinet_node = minetest.get_node(self.pos_cabinet)
	if 0 == minetest.get_item_group(cabinet_node.name, 'drawers') then
		self.object:remove()
		return
	end

	local player_name = player:get_player_name()
	if minetest.is_protected(self.pos_cabinet, player_name) then
		minetest.record_protection_violation(self.pos_cabinet, player_name)
		return
	end

	-- used to check if we need to play a sound in the end
	local inventory_changed = false

	local keys = player:get_player_control()
	local wielded_item = player:get_wielded_item()
	-- When the player uses the drawer with their bare hand all
	-- stacks from the inventory will be added to the drawer.
	local leftover
	if '' ~= self.item_name
		and '' == wielded_item:get_name()
		and not keys.sneak
	then
		-- try to insert all items from inventory
		local i = 0
		local inv = player:get_inventory()
		local stack

		while i <= inv:get_size('main') do
			stack = inv:get_stack('main', i)
			-- set current stack to leftover of insertion
			leftover = self:try_insert_stack(stack, true)

			-- check if something was added
			if leftover:get_count() < stack:get_count() then
				inventory_changed = true
			end

			-- set new stack
			inv:set_stack('main', i, leftover)
			i = i + 1
		end
	else
		-- try to insert wielded item/stack only
		leftover = self:try_insert_stack(wielded_item, not keys.sneak)

		-- check if something was added
		if player:get_wielded_item():get_count() > leftover:get_count() then
			inventory_changed = true
		end
		-- set the leftover as new wielded item for the player
		player:set_wielded_item(leftover)
	end

	if inventory_changed then
		self:play_interact_sound()
	end
end -- drawers.tag.handle_use_put

-- called when a player punches the entity to take items
--function drawers.tag.handle_punch_take(self, player, time_from_last_punch,
--										tool_capabilities, dir)
function drawers.tag.handle_punch_take(self, player)
	-- check if cabinet still exists
	local cabinet_node = minetest.get_node(self.pos_cabinet)
	if 0 == minetest.get_item_group(cabinet_node.name, 'drawers') then
		self.object:remove()
		return
	end

	-- protection check
	local player_name = player:get_player_name()
	if minetest.is_protected(self.pos_cabinet, player_name) then
	   minetest.record_protection_violation(self.pos_cabinet, player_name)
	   return
	end

	-- fake player has no inventory, right? TODO: check that
	local inv = player:get_inventory()
	if not inv then return end

	-- if player is holding sneak, only one item
	local stackwize = not player:get_player_control().sneak

	local checker_stack = ItemStack(self.item_name)
	if stackwize then
		checker_stack:set_count(checker_stack:get_stack_max())
	end
	-- what if he has space for half a stack, maybe we should give him that
	-- turns out, that would need a loop through all slots in inventory gathering
	-- all the slots for for same item and get count of each... doable, but worth it?
	if not inv:room_for_item('main', checker_stack) then
		return
	end

	local stack
	if stackwize then
		stack = self:take_stack()
	else
		stack = self:take_items(1)
	end

	if stack then
		-- add removed stack to player's inventory
		inv:add_item('main', stack)

		-- play the interact sound
		self:play_interact_sound()
	end
end -- handle_punch_take

function drawers.tag.take_items(self, take_count)
	if 0 >= self.count then
		return nil
	end

	if take_count > self.count then
		take_count = self.count
	end

	local stack = ItemStack(self.item_name)
	stack:set_count(take_count)

	-- update the drawer count
	self.count = self.count - take_count

	self:update_infotext()
	self:update_texture()
	self:save_metadata()

	-- return the stack that was removed from the drawer
	return stack
end -- drawers.tag.take_items

function drawers.tag.take_stack(self)
	return self:take_items(ItemStack(self.item_name):get_stack_max())
end -- drawers.tag.take_stack

function drawers.tag.how_many_can_insert(self, stack)
print('drawers.tag.how_many_can_insert')
	local stack_count = stack:get_count()
	if '' == stack:get_name() or 0 >= stack_count then
		return 0
	end

	-- don't allow unstackable stacks
	-- TODO: verify that this actually does what it should
	-- 		seems to me, this says: no name and stackable -> add all
	-- 		bc earlier we just checked sam against 0 and negative counts
	if '' == self.item_name and 1 ~= stack:get_stack_max() then
		return stack_count
	end

	-- if attempting to put something else in this drawer
	if self.item_name ~= stack:get_name() then
		return 0
	end

	-- fits easily
	if (self.count + stack_count) <= self.max_count then
		return stack_count
	end

	-- return how many would still have space
	return self.max_count - self.count
end -- drawers.tag.how_many_can_insert

function drawers.tag.try_insert_stack(self, itemstack, insert_all)
	-- make sure count is correct
	if not insert_all then itemstack:set_count(1) end

	local insert_count = self:how_many_can_insert(itemstack)

	-- no space, no action
	if 0 == insert_count then
		return itemstack
	end

	-- only add one, if player holding sneak key
	-- TODO: why is this checked again?
	if not insert_all then
		insert_count = 1
	end

	-- in case the drawer was empty, initialize count, itemName, maxCount
	if '' == self.item_name then
		self.count = 0
		self.item_name = itemstack:get_name()
		self.max_count = itemstack:get_stack_max() * self.stack_max_factor
		self.item_stack_max = itemstack:get_stack_max()
	end

	-- update everything
	self.count = self.count + insert_count
	self:update_infotext()
	self:update_texture()
	self:save_metadata()

	-- return leftover
	itemstack:take_item(insert_count)
	-- TODO: figure out why we can't give back a stack with zero count
	if 0 == itemstack:get_count() then
		return ItemStack('')
	end
	return itemstack
end -- drawers.tag.try_insert_stack

function drawers.tag.update_infotext(self)
	local item_description = ''
	local item_def = minetest.registered_items[self.item_name]
	if item_def then
		item_description = item_def.description
	end

	if 0 >= self.count then
		self.item_name = ''
		self.meta:set_string('name' .. self.tag_id, self.item_name)
		self.texture = 'blank.png'
		item_description = S('Empty')
	end

	-- TODO: point to correct function
	local infotext = drawers.gen_info_text(
		item_description, self.count, self.stack_max_factor, self.item_stack_max)

	self.meta:set_string('entity_infotext' .. self.tag_id, infotext)

	self.object:set_properties({
		infotext = infotext .. '\n\n\n\n\n'
	})
end -- drawers.tag.update_infotext

function drawers.tag.update_texture(self)
	-- TODO: point to correct function
	self.texture = drawers.get_inv_image(self.item_name)
	self.object:set_properties({
		textures = { self.texture }
	})
end -- drawers.tag.update_texture

-- called by drop_overload which is called when upgrades are removed
function drawers.tag.drop_stack(self, itemstack)
	-- TODO: this looks like a debugging entry, see if we can remove it
	-- print warning if dropping higher stack counts than allowed
	if itemstack:get_count() > itemstack:get_stack_max() then
		minetest.log('warning', '[drawers] Dropping item stack with higher count than allowed')
	end
	-- find a position containing air
	local pos_drop = minetest.find_node_near(self.pos_cabinet, 1, { 'air' }, false)
	-- if no pos found then drop on the top of the drawer
	if not pos_drop then
		pos_drop = self.pos_cabinet
		pos_drop.y = pos_drop.y + 1
	end
	-- drop the item stack
	minetest.item_drop(itemstack, nil, pos_drop)
end -- drawers.tag.drop_stack

-- is called when upgrades are removed and drawer no longer has space for them
function drawers.tag.drop_overload(self)
	-- drop stacks until there are no more items than allowed
	while self.count > self.max_count do
		-- remove the overflow
		-- if this is too much for a single stack, only take the
		-- stack limit
		local remove_count = math.min(self.item_stack_max,
										self.count - self.max_count)
		-- remove this amount from the drawer
		self.count = self.count - remove_count
		-- create a new item stack having the size of the remove count
		local stack = ItemStack(self.item_name)
		stack:set_count(remove_count)
print(stack:to_string())
		-- drop the stack
		self:dropStack(stack)
	end
end -- drawers.tag.drop_overload

function drawers.tag.set_stack_max_factor(self, new_stack_max_factor)
	self.stack_max_factor = new_stack_max_factor
	self.max_count = self.stack_max_factor * self.item_stack_max

	-- will drop possible overflowing items
	self:drop_overload()
	self:update_infotext()
	self:save_metadata()
end -- drawers.tag.set_stack_max_factor

function drawers.tag.play_interact_sound(self)
	minetest.sound_play('drawers_interact', {
		pos = self.object:get_pos(),
		max_hear_distance = 6,
		gain = 2.0
	})
end -- drawers.tag.play_interact_sound

function save_metadata(self)
	-- TODO: discuss if it is worth using really short field names
	-- in code we could use discriptive varables like so, but globaly defined so
	-- other code that accesses cabinet node's metadata can use the same ones
	-- would have to be cleaned up in migrate_cabinet_meta()
	local key_count = 'count'
	local key_item_name = 'name'
	local key_max_count = 'max_count'
	local key_item_stack_max = 'item_stack_max'
	local key_stack_max_factor = 'stackMaxFactor'
	local id = self.tag_id
	self.meta:set_int(key_count .. id, self.count)
	self.meta:set_string(key_item_name .. id, self.item_name)
	self.meta:set_int(key_max_count .. id, self.max_count)
	self.meta:set_int(key_item_stack_max .. id, self.item_stack_max)
	self.meta:set_int(key_stack_max_factor .. id, self.stack_max_factor)
end -- drawers.tag.save_metadata

