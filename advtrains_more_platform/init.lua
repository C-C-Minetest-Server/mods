-- License: LGPLv2.1

if not minetest.global_exists("advtrains_platform") then advtrains_platform = {} end
function advtrains_platform.register_platform(on,preset)
	local ndef=minetest.registered_nodes[preset]
	if not ndef then 
		minetest.log("warning", " register_platform couldn't find preset node "..preset)
		return
	end
	local btex=ndef.tiles
	if type(btex)=="table" then
		btex=btex[1]
	end
	local desc=ndef.description or ""
	local nodename=string.match(preset, ":(.+)$")
	minetest.register_node(on..":platform_low_"..nodename, {
		description = attrans("@1 Platform (low)", desc),
		tiles = {btex.."^advtrains_platform.png", btex, btex, btex, btex, btex},
		groups = {cracky = 1, not_blocking_trains = 1, platform=1},
		sounds = default.node_sound_stone_defaults(),
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.1, -0.1, 0.5,  0  , 0.5},
				{-0.5, -0.5,  0  , 0.5, -0.1, 0.5}
			},
		},
		paramtype2="facedir",
		paramtype = "light",
		sunlight_propagates = true,
	})
	minetest.register_node(on..":platform_high_"..nodename, {
		description = attrans("@1 Platform (high)", desc),
		tiles = {btex.."^advtrains_platform.png", btex, btex, btex, btex, btex},
		groups = {cracky = 1, not_blocking_trains = 1, platform=2},
		sounds = default.node_sound_stone_defaults(),
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5,  0.3, -0.1, 0.5,  0.5, 0.5},
				{-0.5, -0.5,  0  , 0.5,  0.3, 0.5}
			},
		},
		paramtype2="facedir",
		paramtype = "light",
		sunlight_propagates = true,
	})
	minetest.register_craft({
		type="shapeless",
		output = on..":platform_high_"..nodename.." 4",
		recipe = {
			"dye:yellow", preset, preset
		},
	})
	minetest.register_craft({
		type="shapeless",
		output = on..":platform_low_"..nodename.." 4",
		recipe = {
			"dye:yellow", preset
		},
	})
end


advtrains_platform.register_platform(":bakedclay","bakedclay:white")
advtrains_platform.register_platform(":bakedclay","bakedclay:magenta")
advtrains_platform.register_platform(":bakedclay","bakedclay:black")
