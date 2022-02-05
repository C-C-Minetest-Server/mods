local changes = {
	["streets:bigpole"] = {
		groups = { cracky = 1, level = 2, bigpole = 1, not_blocking_trains = 1,},
	},
	["currency:minegeld_100"] = {
		inventory_image = "minegeld_100_mod.png",
	},
}

local func_changes = {}
--[[table.insert(func_changes,{function (nname)
	local ndef = minetest.registered_nodes[nname]
	if not ndef then return false end
	if ndef.mod_origin == "moreblocks" and ndef.drawtype == "mesh" then
		-- HACK! TODO: after slope group appears, use that to seperate those nodes
		return true
	end
end, {
	groups = { not_blocking_trains = 1,},
}})]]
local for_item = {
	function(nname)
		local ndef = table.copy(minetest.registered_items[nname])
		if not ndef then return end
		ndef.name = nil
		ndef.type = nil
		if ndef.mod_origin == "moreblocks" and ndef.drawtype == "mesh" then
			-- HACK! TODO: after slope group appears, use that to seperate those nodes
			if not ndef.groups then ndef.groups = {} end
			ndef.groups.not_blocking_trains = 1
			minetest.override_item(nname,ndef)
		end
	end,
	function(nname)
		local ndef = table.copy(minetest.registered_items[nname])
		if not ndef then return end
		ndef.name = nil
		ndef.type = nil
		if ndef.mod_origin == "trainblocks" then
			if not ndef.groups then ndef.groups = {} end
			ndef.groups.not_blocking_trains = 1
			minetest.override_item(nname,ndef)
		end
	end,
	function(nname)
		if not(nname == "homedecor:fence_barbed_wire" or nname == "homedecor:gate_barbed_wire_open" or nname == "homedecor:gate_barbed_wire_closed") then return end
		local ndef = table.copy(minetest.registered_items[nname])
		if not ndef then return end
		ndef.name = nil
		ndef.type = nil
		if not ndef.groups then ndef.groups = {} end
		ndef.groups.not_blocking_trains = 1
		minetest.override_item(nname,ndef)
	end,
}

for k,v in pairs(changes) do
	minetest.override_item(k,v)
end

for k,v in pairs(for_item) do
	for x,y in pairs(minetest.registered_items) do
		v(x)
	end
end

for k,v in pairs(func_changes) do
	for x,y in pairs(minetest.registered_items) do
		if v[1](x) then
			minetest.override_item(x,v[2])
		end
	end
end

-- Additional code starts
beacon.unregister_effect("fly")
morelights_dim.register_light_level_tool("morelights:bulb")
if unified_inventory then
local ui_mail_btn = nil
for x,y in pairs(unified_inventory.buttons) do 
	if y.name == "mail" then
		ui_mail_btn = x
	end
end
unified_inventory.buttons[ui_mail_btn] = nil
end
digiline_nodes.register_digiline_node("bakedclay","white")
digiline_nodes.register_digiline_node("bakedclay","black")

local function register_stairsplus(origmod,nodename)
	local ndef = table.copy(minetest.registered_nodes[origmod .. ":" .. nodename])
	ndef.sunlight_propagates = true
	local mod = "ccs_modifly"
	local name = origmod .. ":" .. nodename 
	stairsplus:register_all(origmod, nodename, name, ndef)
	minetest.register_alias_force("stairs:stair_" .. nodename, mod .. ":stair_" .. nodename)
	minetest.register_alias_force("stairs:stair_outer_" .. nodename, mod .. ":stair_" .. nodename .. "_outer")
	minetest.register_alias_force("stairs:stair_inner_" .. nodename, mod .. ":stair_" .. nodename .. "_inner")
	minetest.register_alias_force("stairs:slab_"  .. nodename, mod .. ":slab_"  .. nodename)
end

for _,y in pairs({
	{"ehlphabet","block"},
}) do
	register_stairsplus(y[1],y[2])
end

minetest.registered_chatcommands.admin.func = function (name,param)
	return true, "" ..
		"The admins of C&C Servers are Cato and Cyrus.\n" ..
		"Use /mail command to send a mail to Cato\n" ..
		"or give a written book to Cato in the\n" ..
		"post office to give feedbacks, or to report griefs." 
end


--[[
function default.register_craft_metadata_copy(ingredient, result)
	minetest.register_craft({
		type = "shapeless",
		output = result,
		recipe = {ingredient, result}
	})

	minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
		if (itemstack.get_name and itemstack:get_name()) ~= result then
			return
		end

		local original
		local index
		for i = 1, #old_craft_grid do
			if old_craft_grid[i]:get_name() == result then
				original = old_craft_grid[i]
				index = i
			end
		end
		if not original then
			return
		end
		local copymeta = original:get_meta():to_table()
		itemstack:get_meta():from_table(copymeta)
		-- put the book with metadata back in the craft grid
		craft_inv:set_stack("craft", index, original)
	end)
end
]]
--[[
minetest.register_on_mods_loaded(function()
	for x,y in pairs(minetest.registered_on_craft) do
		minetest.registered_on_craft[x] = function(is,...)
			minetest.log("info","OnCraft ItemStack: " .. dump(is))
			if not is.get_name then 
				minetest.log("OnCraft Failed: invalid ItemStack!")
				return nil
			end
			return y(is,...)
		end
	end
end)
]]

minetest.register_on_craft(function(...)
	minetset.log("info","ItemStack: " .. dump(...)) 
end)
