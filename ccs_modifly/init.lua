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
