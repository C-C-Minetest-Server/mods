--
-- Freezer for mintest: a device which turns water (in buckets) into ice
-- And does a couple of other tricks, discovering which is left as a pleasant
-- surprise for the player.
--

-- enable extra popsicle types provided there are both vessels and fruits/veggies available
-- fruit + glass -> juice; juice @ freezer -> popsicle + empty glass

if minetest.get_modpath("vessels") then
	dofile(minetest.get_modpath("freezer") .. "/juices.lua")
end

--
-- Formspecs
--

local function active_formspec(fuel_percent, item_percent)
	local formspec = 
		"size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[current_name;src;2.5,1;1,1;]"..
		"image[3.75,1.5;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
		(item_percent)..":gui_furnace_arrow_fg.png^[transformR270]"..
		"list[current_name;dst;4.75,0.96;3,2;]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[current_name;dst]"..
		"listring[current_player;main]"..
		"listring[current_name;src]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
	return formspec
end

local inactive_formspec =
	"size[8,8.5]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[current_name;src;2.5,1.5;1,1;]"..
	"image[3.75,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
	"list[current_name;dst;4.75,0.96;3,2;]"..
	"list[current_player;main;0,4.25;8,1;]"..
	"list[current_player;main;0,5.5;8,3;8]"..
	"listring[current_name;dst]"..
	"listring[current_player;main]"..
	"listring[current_name;src]"..
	"listring[current_player;main]"..
	default.get_hotbar_bg(0, 4.25)

--
-- Node callback functions that are the same for active and inactive freezer
--

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("dst") and inv:is_empty("src")
end

	      
local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "src" then
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	end
end

	      
local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

	      
local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

	      
local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

	      
local function freezer_node_timer(pos, elapsed)
	--
	-- Inizialize metadata
	--
	local meta = minetest.get_meta(pos)

	local src_time = meta:get_float("src_time") or 0


	local inv = meta:get_inventory()
	local srclist = inv:get_list("src")

	local dstlist = inv:get_list("dst")

	--
	-- Cooking
	--

	-- takes both regular and river water
	if inv:contains_item("src", "bucket:bucket_water") or 
	      inv:contains_item("src", "bucket:bucket_river_water") then
		if inv:room_for_item("dst", "default:ice") then
			inv:remove_item("src", "bucket:bucket_water")
			inv:remove_item("src", "bucket:bucket_river_water")
			inv:add_item("dst", "default:ice")
			inv:add_item("dst", "bucket:bucket_empty")
	      end
	end
	   
	-- an extra recipe involving liquid in a bucket, for good measure
	-- a cactus pulp bucket gives 2 hp, but freezing it gives 3 popsicles, each
	-- of them giving 1 hp, achieving 50% increase in efficiency through processing
	if minetest.get_modpath("ethereal") then
		if inv:contains_item("src", "ethereal:bucket_cactus") then
			if inv:room_for_item("dst", "freezer:cactus_popsicle 3") then
				inv:remove_item("src", "ethereal:bucket_cactus")
				inv:add_item("dst", "freezer:cactus_popsicle 3")
				inv:add_item("dst", "bucket:bucket_empty")
			end
		end 
	end
	
	-- and yet another liquid in a bucket, this time with no extravagance though
	if minetest.get_modpath("mobs") and mobs and mobs.mod == "redo" then
		if inv:contains_item("src", "mobs:bucket_milk") then
			if inv:room_for_item("dst", "freezer:milk_popsicle 3") then
				inv:remove_item("src", "mobs:bucket_milk")
				inv:add_item("dst", "freezer:milk_popsicle 3")
				inv:add_item("dst", "bucket:bucket_empty")
			end
		end 
	end
	      
	-- and of course what is hot can be cooled down
	if minetest.get_modpath("farming") then
		if inv:contains_item("src", "farming:coffee_cup_hot") then
			while inv:room_for_item("dst", "farming:coffee_cup") do
				local removed = inv:remove_item("src", "farming:coffee_cup_hot")
				if removed:get_count() > 0 then
					inv:add_item("dst", "farming:coffee_cup")
				else
					break
				end
			end
		end 
	end
	      
	-- juices -> popsicles
	-- since we're dealing with 1 glass and not 1 bucket, the output is 1 item
	if minetest.get_modpath("vessels") then
		local input_stack = inv:get_stack("src", 1);
		local input_name = input_stack:get_name();
		if minetest.get_item_group(input_name, "juice") > 0 then
			local output_name = input_name .. "_popsicle"
			while inv:room_for_item("dst", output_name) do
				local removed = inv:remove_item("src", input_name)
				if removed:get_count() > 0 then
					inv:add_item("dst", output_name)
					inv:add_item("dst", "vessels:drinking_glass")
				else
					break
				end
			end
		end
	end

	      
	-- pelmeni
	-- while freezing is a crucial step in preparation, the full chain involves extra steps:
	-- raw pelmeni -> pack of frozen pelmeni -> actual cooked pelmeni
	if minetest.get_modpath("mobs") and mobs and mobs.mod == "redo" and minetest.get_modpath("farming") then
		if inv:contains_item("src", "freezer:pelmeni_raw") then
			if inv:room_for_item("dst", "freezer:pelmeni_pack 3") then
				inv:remove_item("src", "freezer:pelmeni_raw")
				inv:add_item("dst", "freezer:pelmeni_pack 3")
			end
		end 
	end

	-- aspic
	if minetest.get_modpath("mobs") and mobs and mobs.mod == "redo" and minetest.get_modpath("ethereal") then
	      if inv:contains_item("src", "freezer:meat_broth") then
			if inv:room_for_item("dst", "freezer:aspic 5") then
				inv:remove_item("src", "freezer:meat_broth")
				inv:add_item("dst", "freezer:aspic 5")
				inv:add_item("dst", "bucket:bucket_empty")
			end
		end 
	end
	      
	-- Check if we have cookable content
	return true
end

	      
--
-- Node definitions
--

minetest.register_node("freezer:freezer", {
	description = "Freezer",
	tiles = {
		"freezer_top.png", "freezer_top.png",
		"freezer_side.png", "freezer_side.png",
		"freezer_side.png", "freezer_front.png"
	},
	paramtype2 = "facedir",
	groups = {cracky = 2, tubedevice = 1, tubedevice_receiver = 1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

	tube = (function() if minetest.get_modpath("pipeworks") then return {
		-- using a different stack from defaut when inserting
		insert_object = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local timer = minetest.get_node_timer(pos)
			if not timer:is_started() then
				timer:start(1.0)
			end
			return inv:add_item("src", stack)
		end,
		can_insert = function(pos,node,stack,direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:room_for_item("src", stack)
		end,
		-- the default stack, from which objects will be taken
		input_inventory = "dst",
		connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1}
	} end end)(),
	                                     
	can_dig = can_dig,

	on_timer = freezer_node_timer,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", inactive_formspec)
		local inv = meta:get_inventory()
		inv:set_size('src', 1)
		inv:set_size('dst', 6)
	end,

	on_metadata_inventory_move = function(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(1.0)
	end,
	on_metadata_inventory_put = function(pos)
		-- start timer function, it will sort out whether freezer will work or not.
		local timer = minetest.get_node_timer(pos)
		timer:start(1.0)
	end,
	on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "src", drops)
		default.get_inventory_drops(pos, "dst", drops)
		drops[#drops+1] = "freezer:freezer"
		minetest.remove_node(pos)
		return drops
	end,

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
})

	      
if minetest.get_modpath("ethereal") then
	minetest.register_craftitem("freezer:cactus_popsicle", {
		description = "Cactus Pulp Popsicle",
		inventory_image = "cactus_popsicle.png",
		wield_image = "cactus_popsicle.png",
		stack_max = 99,
		groups = { not_in_creative_inventory = 1 },
		on_use = minetest.item_eat(1, "default:stick"),
	})
end
	      
	      
if minetest.get_modpath("mobs") and mobs and mobs.mod == "redo" then
	minetest.register_craftitem("freezer:milk_popsicle", {
		description = "Eskimo icecream",
		inventory_image = "milk_popsicle.png",
		wield_image = "milk_popsicle.png",
		stack_max = 99,
		groups = { not_in_creative_inventory = 1 },
		on_use = minetest.item_eat(1, "default:stick"),
	})
end	

-- aspic
-- bones + bucket of water + meat = broth -> freezer -> portions of aspic

if minetest.get_modpath("mobs") and mobs and mobs.mod == "redo" and minetest.get_modpath("ethereal") then
	minetest.register_craftitem("freezer:meat_broth", {
		description = "Meat broth",
		inventory_image = "meat_broth.png",
		wield_image = "meat_broth.png",
		stack_max = 99,
		groups = { },
		on_use = minetest.item_eat(3, "bucket:bucket_empty"),
	})
	      
	minetest.register_craft({
		type = "shapeless",
		output = "freezer:meat_broth",
		recipe = {"mobs:meat_raw", "ethereal:bone", "bucket:bucket_river_water"},
	})
	      
	minetest.register_craft({
		type = "shapeless",
		output = "freezer:meat_broth",
		recipe = {"mobs:meat_raw", "ethereal:bone", "bucket:bucket_water"},
	})   
	      
	minetest.register_craftitem("freezer:aspic", {
		description = "A portion of aspic",
		inventory_image = "aspic.png",
		wield_image = "aspic.png",
		stack_max = 99,
		groups = { not_in_creative_inventory = 1 },
		on_use = minetest.item_eat(6),
	})
end
	      
-- pelmeni (dumplings with meat filling)
if minetest.get_modpath("mobs") and mobs and mobs.mod == "redo" and minetest.get_modpath("farming") then
	
	-- both the dough and the frozen pelmeni are nigh inedible
	-- only the cooked product should reveal the benefits of preparing this food
	      
	minetest.register_craftitem("freezer:pelmeni_raw", {
		description = "Raw pelmeni",
		inventory_image = "pelmeni_raw.png",
		wield_image = "pelmeni_raw.png",
		stack_max = 99,
		groups = {  },
		on_use = minetest.item_eat(1),
	})
     
	minetest.register_craftitem("freezer:pelmeni_pack", {
		description = "A pack of frozen pelmeni",
		inventory_image = "pelmeni_pack.png",
		wield_image = "pelmeni_pack.png",
		stack_max = 99,
		groups = { not_in_creative_inventory = 1 },
		on_use = minetest.item_eat(1),
	})
	      
	minetest.register_craftitem("freezer:pelmeni", {
		description = "Cooked pelmeni",
		inventory_image = "pelmeni.png",
		wield_image = "pelmeni.png",
		stack_max = 99,
		groups = { not_in_creative_inventory = 1 },
		on_use = minetest.item_eat(10),
	})
	    
	minetest.register_craft({
		type = "shapeless",
		output = "freezer:pelmeni_raw",
		recipe = {"mobs:meat_raw", "farming:flour", "farming:flour", "farming:flour"},
	})      
	      
	minetest.register_craft({
		type = "cooking",
		cooktime = 10,
		output = "freezer:pelmeni",
		recipe = "freezer:pelmeni_pack"
	})

	
end
	  
	      
minetest.register_craft({
	output = "freezer:freezer",
	recipe = {
		{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"},
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"}
	}
})
	      
	      
minetest.register_craft({
      output = "default:snowblock 3",
      type = "shapeless",
      recipe = {
	 "default:ice"
      }
})
