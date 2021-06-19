-- Definition for juices, an intermediate stage for making popsicles
-- however, they can be consumed raw as well, but the benefit would be less

--[[
    Definition scheme
	internal_name_of_the_juice = {
		proper_name = Human-readable name,
		found_in = mod name where the source object is introduced
		obj_name = name of source object (internal, without "modname:")
		orig_nutritional_value = self-explanatory
	}
	-- image files for items must follow the scheme:
	-- internal_name_of_the_juice.png and
	-- internal_name_of_the_juice_inv.png (for inventory)
	-- internal_name_of_the_juice_popsicle.png for the popsicle form
]]

local juice_table = {
	orange_juice = {
		proper_name = "Orange juice",
		found_in = "ethereal",
		obj_name = "orange",
		orig_nutritional_value = 2
	},
	banana_juice = {
		proper_name = "Banana juice",
		found_in = "ethereal",
		obj_name = "banana",
		orig_nutritional_value = 1
	},
	strawberry_juice = {
		proper_name = "Strawberry juice",
		found_in = "ethereal",
		obj_name = "strawberry",
		orig_nutritional_value = 1
	},
	coconut_milk = {
		proper_name = "Coconut milk",
		found_in = "ethereal",
		obj_name = "coconut_slice",
		orig_nutritional_value = 1
	},
	blueberry_juice = {
		proper_name = "Blueberry juice",
		found_in = "farming",
		obj_name = "blueberries",
		orig_nutritional_value = 1
	},
	raspberry_juice = {
		proper_name = "Raspberry juice",
		found_in = "farming",
		obj_name = "raspberries",
		orig_nutritional_value = 1
	},
	carrot_juice = {
		proper_name = "Carrot juice",
		found_in = "farming",
		obj_name = "carrot",
		orig_nutritional_value = 4
	},
	cucumber_juice = {
		proper_name = "Cucumber juice",
		found_in = "farming",
		obj_name = "cucumber",
		orig_nutritional_value = 4
	},
	grape_juice = {
		proper_name = "Grape juice",
		found_in = "farming",
		obj_name = "grapes",
		orig_nutritional_value = 2
	},
	melon_juice = {
		proper_name = "Melon juice",
		found_in = "farming",
		obj_name = "melon_slice",
		orig_nutritional_value = 2
	},
	pumpkin_juice = {
		proper_name = "Pumpkin juice",
		found_in = "farming",
		obj_name = "pumpkin_slice",
		orig_nutritional_value = 2
	},
	tomato_juice = {
		proper_name = "Tomato juice",
		found_in = "farming",
		obj_name = "tomato",
		orig_nutritional_value = 4
	},

}


-- all juices are created accoriding to a single universal scheme
for juice_name, def in pairs(juice_table) do
	if minetest.get_modpath(def.found_in) then
		
		-- introducing a new item, a bit more nutricious than the source material
		-- that's because one needs a glass, so effort should be rewarded
		minetest.register_craftitem("freezer:" .. juice_name, {
			description = def.proper_name,
			inventory_image = juice_name .. "_inv.png",
			wield_image = juice_name .. ".png",
			groups = { juice = 1 },
			on_use = minetest.item_eat(def.orig_nutritional_value+1, "vessels:drinking_glass"),
		})
		
		-- register corresponding popsicles
		-- lower nutritional value is compensated by leaving a fancy stick behind
		minetest.register_craftitem("freezer:" .. juice_name .. "_popsicle", {
			description = def.proper_name .. " popsicle",
			inventory_image = juice_name .. "_popsicle.png",
			wield_image = juice_name .. "_popsicle.png",
			groups = { popsicle = 1, not_in_creative_inventory = 1 },
			on_use = minetest.item_eat(def.orig_nutritional_value, "default:stick"),
		})
		
		minetest.register_craft({
			type = "shapeless",
			output = "freezer:" .. juice_name,
			recipe = {"vessels:drinking_glass", def.found_in .. ":" .. def.obj_name},
		})
		
	end
end

-- The Moor has done his duty, the Moor can go
juice_table = nil
