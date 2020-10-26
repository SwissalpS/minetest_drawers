--
-- drawers/lua/cabinet/register.lua
--
local S, NS = dofile(drawers.modpath .. '/intllib.lua')
--local dc = drawers.cabinet -- keep commented if not actually used
--local dcab = drawers.cabinet

-- register trim
minetest.register_node('drawers:trim', drawers.trim.node_def)
minetest.register_craft(drawers.trim.craft_def)

-- cabinet registration function for node and recipe
function drawers.cabinet.register(name, def)
	def.collision_box = { type = 'regular' }
	def.description = def.description or S('Wooden')
	def.drawtype = 'nodebox'
	def.groups = def.groups or {}
	def.legacy_facedir_simple = true
	def.node_box = { type = 'fixed', fixed = drawers.gui.node_box_simple }
	def.paramtype = 'light'
	def.paramtype2 = 'facedir'
	def.selection_box = { type = 'fixed', fixed = drawers.gui.node_box_simple }

	-- events
	def.allow_metadata_inventory_move = function() return 0 end
	def.allow_metadata_inventory_put = drawers.cabinet.allow_upgrade_put
	def.allow_metadata_inventory_take = drawers.cabinet.allow_upgrade_take
	def.on_construct = drawers.cabinet.on_construct
	def.on_destruct = drawers.cabinet.on_destruct
	def.on_dig = drawers.cabinet.on_dig
	def.on_metadata_inventory_put = drawers.cabinet.upgrade_update
	def.on_metadata_inventory_take = drawers.cabinet.upgrade_update

	if drawers.has_screwdriver then
		def.on_rotate = def.on_rotate or screwdriver.disallow
	end

	if drawers.has_pipeworks then
		def.after_dig_node = pipeworks.after_dig
		def.after_place_node = pipeworks.after_place
		def.groups.tubedevice = 1
		def.groups.tubedevice_receiver = 1
		def.tube = def.tube or {}
		def.tube.can_insert = def.tube.can_insert
			or drawers.drawer_can_insert_stack_from_tube

		def.tube.connect_sides = {
			back = 1, bottom = 1,
			left = 1, right = 1, top = 1
		}

		def.tube.insert_object = def.tube.insert_object
			or drawers.cabinet.insert_object_from_tube

	end -- if has pipeworks installed

	local name_full
	if drawers.settings.use_cabinet_1x1 then
		-- normal drawer 1x1 = 1
		local def1 = table.copy(def)
		def1.description = S('@1 1 Drawer Cabinet', def.description)
		def1.groups.drawers = 1
		def1.tiles = def.tiles or def.tiles1
		def1.tiles1 = nil
		def1.tiles2 = nil
		def1.tiles4 = nil

		name_full = name .. '1'
		minetest.register_node(name_full, def1)
		-- 1x1 drawer is the default one
		minetest.register_alias(name, name_full)
		if drawers.has_mesecons_mvps then
			-- don't let drawers be moved by pistons, visual glitches and
			-- possible duplication bugs occur otherwise
			mesecon.register_mvps_stopper(name .. '1')
		end
	end -- if 1x1

	if drawers.settings.use_cabinet_1x2 then
		-- 1x2 = 2
		local def2 = table.copy(def)
		def2.description = S('@1 2 Drawers Cabinet', def.description)
		def2.groups.drawers = 2
		def2.tiles = def.tiles2
		def2.tiles1 = nil
		def2.tiles2 = nil
		def2.tiles4 = nil

		name_full = name .. '2'
		minetest.register_node(name_full, def2)
		if drawers.has_mesecons_mvps then
			mesecon.register_mvps_stopper(name_full)
		end
	end -- if 1x2

	if drawers.settings.use_cabinet_2x2 then
		-- 2x2 = 4
		local def4 = table.copy(def)
		def4.description = S('@1 4 Drawers Cabinet', def.description)
		def4.groups.drawers = 4
		def4.tiles = def.tiles4
		def4.tiles1 = nil
		def4.tiles2 = nil
		def4.tiles4 = nil

		name_full = name .. '4'
		minetest.register_node(name_full, def4)
		if drawers.has_mesecons_mvps then
			mesecon.register_mvps_stopper(name_full)
		end
	end -- if 2x2

	if (not def.no_craft) and def.material then
		local dset = drawers.settings
		if drawers.settings.use_cabinet_1x1 then
			minetest.register_craft({
				output = name .. '1',
				recipe = {
					{ def.material, def.material, def.material },
					{ '', drawers.settings.chest_itemstring, '' },
					{ def.material, def.material, def.material }
				}
			})
		end -- if 1x1
		if drawers.settings.use_cabinet_1x2 then
			minetest.register_craft({
				output = name .. '2 2',
				recipe = {
					{ def.material, dset.chest_itemstring, def.material },
					{ def.material, def.material, def.material },
					{ def.material, dset.chest_itemstring, def.material }
				}
			})
		end -- if 1x2
		if drawers.settings.use_cabinet_2x2 then
			minetest.register_craft({
				output = name .. '4 4',
				recipe = {
					{ dset.chest_itemstring, def.material, dset.chest_itemstring },
					{ def.material, def.material, def.material },
					{ dset.chest_itemstring, def.material, dset.chest_itemstring }
				}
			})
		end -- if 2x2
	end -- no craft and material
end -- drawers.cabinet.register

-- helper function to make tiles
function drawers.cabinet.tiles_front_other(front, other)
	return { other, other, other, other, other, front }
end

if drawers.has_default then
	dofile(drawers.modpath .. '/lua/cabinet/registerDefault.lua')
elseif drawers.has_mcl_core then
	dofile(drawers.modpath .. '/lua/cabinet/registerMCL.lua')
else
	drawers.cabinet.register('drawers:wood', {
		description = S('Wooden'),
		groups = { choppy = 3, oddly_breakable_by_hand = 2 },
		material = drawers.settings.wood_itemstring,
		sounds = drawers.settings.wood_sounds,
		tiles1 = drawers.cabinet.tiles_front_other('drawers_wood_front_1.png',
												'drawers_wood.png'),
		tiles2 = drawers.cabinet.tiles_front_other('drawers_wood_front_2.png',
												'drawers_wood.png'),
		tiles4 = drawers.cabinet.tiles_front_other('drawers_wood_front_4.png',
												'drawers_wood.png'),
	})
end -- switch game type

