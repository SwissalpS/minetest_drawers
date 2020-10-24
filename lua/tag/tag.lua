--
-- drawers/lua/tag/tag.lua
--
--[[
-- this only migrates metadata in cabinet node for self
function drawers.tag:migrate_cabinet_meta()
	-- for now we have nothing to migrate
	return
	-- all cabinets have at least one drawer, so we can safely test this way.
--	if 0 < self.meta:get_int('item_stack_max1') then return end
--	self.meta:set_int('item_stack_max' .. self.tag_id, self.meta:get_int(''))
-- problem may arrise with existing 1x1s that don't have a number :/
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
--]]

-- this is called when entity is deactivated, it MUST return a string.
-- this string will be passed to on_activate when entity is restored.
function drawers.tag:get_serialized_static_data()
	return self.tag_id
end

-- called when a player punches the entity to take items
--function drawers.tag.handle_punch_take(player, time_from_last_punch,
--										tool_capabilities, dir)
function drawers.tag:handle_punch_take(player)
	-- get handler. Will also check if cabinet node exists and remove tags if not.
	local handler = drawers.cabinet.handler_for(self.pos_cabinet)
	if not handler then
		return
	end
	local changed = handler:player_take(self.tag_id, player)

	if changed then
		-- we keep this as part of object for sound direction and possibly later
		-- adding sounds per kind of item -- in years when sounds are not so expensive
		self:play_interact_sound()
	end
end -- handle_punch_take

-- called when player right clicks entity with or without something in hand.
-- to put items in
function drawers.tag:handle_use_put(player)
print('tag:handle_use_put')
	-- get handler. Will also check if cabinet node exists and remove tags if not.
	local handler = drawers.cabinet.handler_for(self.pos_cabinet)
	if not handler then
		return
	end
	local changed, leftover = handler:player_put(self.tag_id, player)
	if changed then
		-- we keep this as part of object for sound direction and possibly later
		-- adding sounds per kind of item -- in years when sounds are not so expensive
		self:play_interact_sound()
	end
	return leftover
end -- drawers.tag.handle_use_put

-- this is called when entity is activated for first time or reactivated.
-- first time static_data_serialized is an empty string
-- delta_seconds is the time that passed since entyty was deactivated, we can ignore that.
function drawers.tag:on_activate(static_data_serialized, delta_seconds)
	self.pos_cabinet = vector.round(self.object:get_pos())
	local handler = drawers.cabinet.handler_for(self.pos_cabinet)
	if not handler then
		-- no need to clean up as drawers.cabinet.handler_for() does that
		return
	end

	-- Restore data
--	local data = minetest.deserialize(static_data_serialized)
--	if data then
	if '' == static_data_serialized then
		self.tag_id = drawers.tmp.new_tag_id
	else
		self.tag_id = static_data_serialized
	end

	-- collisionbox
	local collisionbox
	local param2 = handler.cabinet_node.param2
	local drawer_count = handler.drawer_count
	if 2 == drawer_count then
		if 1 == param2 or 3 == param2 then
			-- for param2 = 1 or 3
			collisionbox = {0, -0.2187, -0.4374, 0, 0.2187, 0.4374 }
		else
			-- for param2 = 0 or 2
			collisionbox = { -0.4374, -0.2187, 0, 0.4374, 0.2187, 0 }
		end
	else
		if 1 == param2 or 3 == param2 then
			-- for param2 = 1 or 3
			collisionbox = { 0, -0.4374, -0.4374, 0, 0.4374, 0.4374 }
		else
			-- for param2 = 0 or 2
			collisionbox = { -0.4374, -0.4374, 0, 0.4374, 0.4374, 0 }
		end
		-- only half the size if it's a small drawer
		if 1 < drawer_count then
			for i, j in ipairs(collisionbox) do
				collisionbox[i] = j * 0.5
			end
		end
	end -- if for 1x2 or other cabinet

	-- visual size
	local visual_size = { x = 0.6, y = 0.6 }
	if 2 <= drawer_count then
		visual_size = { x = 0.3, y = 0.3 }
	end

	-- infotext
	local infotext = handler:infotext_for(self.tag_id) .. '\n\n\n\n\n'
	local texture = handler:texture_for(self.tag_id)
	self.object:set_properties({
		collisionbox = collisionbox,
		infotext = infotext,
		textures = { texture },
		visual_size = visual_size
	})

	-- make entity undestroyable
	self.object:set_armor_groups({ immortal = 1 })

	-- register in cache
	drawers.tag.map.cache_tag(self)
end -- drawers.tag.on_activate

function drawers.tag:play_interact_sound()
	minetest.sound_play('drawers_interact', {
		pos = self.object:get_pos(),
		max_hear_distance = 6,
		gain = 2.0
	})
end -- drawers.tag:play_interact_sound

-- used in general to update infotext and texture
function drawers.tag:update(new_infotext, new_texture)
	self.object:set_properties({
		infotext = new_infotext,-- .. '\n\n\n\n\n',
		textures = { new_texture },
	})
end -- drawers.tag:update

-- used by cabinet when upgrades changed
function drawers.tag:update_infotext(new_infotext)
	self.object:set_properties({
		infotext = new_infotext-- .. '\n\n\n\n\n',
	})
end -- drawers.tag:update_infotext

