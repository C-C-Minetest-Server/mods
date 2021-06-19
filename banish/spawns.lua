local world_path = minetest.get_worldpath()
local org_file = world_path .. "/banish_spawns"
local file = world_path .. "/banish_spawns"
local bkwd = false


function banish.read_spawns()
	local spawns = banish.spawn
	local input = io.open(file, "r")
	if input then
		repeat
			local x = input:read("*n")
			if x == nil then
				break
			end
			local y = input:read("*n")
			local z = input:read("*n")
			local name = input:read("*l")
			spawns[name:sub(2)] = {x = x, y = y, z = z}
		until input:read(0) == nil
		io.close(input)
	else
		spawns = {}
	end
end

function banish.save_spawns()
	if not banish.spawn then
		return
	end
	local data = {}
	local output = io.open(org_file, "w")
	for k, v in pairs(banish.spawn) do
		table.insert(data, string.format("%.1f %.1f %.1f %s\n", v.x, v.y, v.z, k))
	end
	output:write(table.concat(data))
	io.close(output)
end

function banish.set_spawns()
	for name,_ in pairs(banish.player) do
		local player = minetest.get_player_by_name(name)
		local p = beds.spawn[name]
		banish.spawn[name] = p
	end
	banish.save_spawns()
end
