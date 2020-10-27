--
--- drawers/lua/controller/register.lua
--
local S, NS = dofile(drawers.modpath .. '/intllib.lua')

local craft_def
if drawers.has_default then
	craft_def = {
		output = 'drawers:controller',
		recipe = {
			{ 'default:steel_ingot', 'default:diamond', 'default:steel_ingot' },
			{ 'default:tin_ingot',    'group:drawer',   'default:copper_ingot' },
			{ 'default:steel_ingot', 'default:diamond', 'default:steel_ingot' },
		}
	}
elseif drawers.has_mcl_core then
	craft_def = {
		output = 'drawers:controller',
		recipe = {
			{ 'mcl_core:iron_ingot', 'mcl_core:diamond', 'mcl_core:iron_ingot' },
			{ 'mcl_core:gold_ingot',   'group:drawer',   'mcl_core:gold_ingot' },
			{ 'mcl_core:iron_ingot', 'mcl_core:diamond', 'mcl_core:iron_ingot' },
		}
	}
else
	-- Because the rest of the drawers mod doesn't have a hard depend on
	-- default, here is an alternative recipe.
	craft_def = {
		output = 'drawers:controller',
		recipe = {
			{ 'group:stone', 'group:stone',  'group:stone' },
			{ 'group:stone', 'group:drawer', 'group:stone' },
			{ 'group:stone', 'group:stone',  'group:stone' },
		}
	}
end

-- actually register craft
minetest.register_craft(craft_def)

-- Set the controller definition using a table to allow for pipeworks and
-- potentially other mod support
local def = {}

-- MCL2 requires a few different groups and parameters that MTG does not
if drawers.has_mcl_core then
	def._mcl_blast_resistance = 30
	def._mcl_hardness = 1.5
	def.groups = {
		pickaxey = 1, stone = 1, building_block = 1, material_stone = 1
	}
else
	def.groups = {
		cracky = 3, level = 2
	}
end

def._digistuff_channelcopier_fieldname = 'channel' -- 'digilineChannel',
def.collision_box = { type = 'regular' }
def.description = S('Drawer Controller')
def.drawtype = 'nodebox'
def.legacy_facedir_simple = true
def.node_box = { type = 'fixed', fixed = drawers.gui.node_box_simple }
def.paramtype = 'light'
def.paramtype2 = 'facedir'
def.selection_box = { type = 'regular' }

-- add pipe connectors, if pipeworks is enabled
if drawers.has_pipeworks then
	def.after_dig_node = pipeworks.after_dig
	def.after_place_node = pipeworks.after_place
	def.groups.tubedevice = 1
	def.groups.tubedevice_receiver = 1
	def.tiles = {
		'drawers_controller_top.png^pipeworks_tube_connection_metallic.png',
		'drawers_controller_top.png^pipeworks_tube_connection_metallic.png',
		'drawers_controller_side.png^pipeworks_tube_connection_metallic.png',
		'drawers_controller_side.png^pipeworks_tube_connection_metallic.png',
		'drawers_controller_top.png^pipeworks_tube_connection_metallic.png',
		'drawers_controller_front.png'
	}
	def.tube = {}
	-- called when attempting to insert from tubes
	-- returns TODO
	def.tube.can_insert = function(pos_controller, node, stack, tubedir)
		return drawers.controller.allow_metadata_inventory_put(
			pos_controller, 'src', nil, stack, nil)
	end
	-- connect from all sides but front
	def.tube.connect_sides = {
		left = 1, right = 1, back = 1, top = 1, bottom = 1
	}
	-- actually insert objec from tubes
	def.tube.insert_object = function(pos_controller, node, stack, tubedir)
		return drawers.controller.insert_to_drawers(pos_controller, stack)
	end

	if drawers.has_digilines then
		def.digiline = {
			receptor = {},
			effector = {
				action = drawers.controller.on_digiline_receive
			},
		}
	end -- if has digilines
else
	def.tiles = {
		'drawers_controller_top.png',
		'drawers_controller_top.png',
		'drawers_controller_side.png',
		'drawers_controller_side.png',
		'drawers_controller_top.png',
		'drawers_controller_front.png'
	}
end -- if has pipeworks or not

def.after_destruct = drawers.controller.net_item_removed
def.allow_metadata_inventory_move = drawers.controller.allow_metadata_inventory_move
def.allow_metadata_inventory_put = drawers.controller.allow_metadata_inventory_put
def.allow_metadata_inventory_take = drawers.controller.allow_metadata_inventory_take

def.can_dig = drawers.controller.can_dig
-- also act as connector
def.groups.drawers_connector = 1
def.on_blast = drawers.controller.on_blast
def.on_construct = drawers.controller.on_construct
def.on_metadata_inventory_put = drawers.controller.on_metadata_inventory_put
def.on_receive_fields = drawers.controller.on_receive_fields

minetest.register_node('drawers:controller', def)

