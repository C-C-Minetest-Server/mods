local changes = {
	["streets:bigpole"] = {
		groups = { cracky = 1, level = 2, bigpole = 1, not_blocking_trains = 1,},
	},
}

local func_changes = {}
table.insert(func_changes,{function (nname)
	local ndef = minetest.registered_nodes[nname]
	if not ndef then return false end
	if ndef.mod_origin == "moreblocks" and ndef.drawtype == "mesh" then
		-- HACK! TODO: after slope group appears, use that to seperate those nodes
		return true
	end
end, {
	groups = { not_blocking_trains = 1,},
}})

for k,v in pairs(changes) do
	minetest.override_item(k,v)
end

for k,v in pairs(func_changes) do
	for x,y in pairs(minetest.registered_items) do
		if v[1](x) then
			minetest.override_item(x,v[2])
		end
	end
end

