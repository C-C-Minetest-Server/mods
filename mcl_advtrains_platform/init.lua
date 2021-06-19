local function register_platform(on,preset)
	local ndef=minetest.registered_nodes[preset]
	if not ndef then 
		minetest.log("error", " register_platform couldn't find preset node "..preset)
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
		sounds = mcl_sounds.node_sound_stone_defaults(),
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
		sounds = mcl_sounds.node_sound_stone_defaults(),
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
			"mcl_dye:yellow", preset, preset
		},
	})
	minetest.register_craft({
		type="shapeless",
		output = on..":platform_low_"..nodename.." 4",
		recipe = {
			"mcl_dye:yellow", preset
		},
	})
end

local node_list = {
	-- mcl_core
	"mcl_core:stone",
	"mcl_core:stonebrick",
	"mcl_core:stone_smooth",
	"mcl_core:granite",
	"mcl_core:granite_smooth",
	"mcl_core:andesite",
	"mcl_core:andesite_smooth",
	"mcl_core:diorite",
	"mcl_core:diorite_smooth",
	"mcl_core:sandstone",
	"mcl_core:sandstonesmooth",
	"mcl_core:redsandstone",
	"mcl_core:redsandstonesmooth",
	"mcl_core:brick_block",
	"mcl_core:cobble",
	-- mcl_nether
	"mcl_nether:netherrack",
	"mcl_nether:nether_brick",
	"mcl_nether:red_nether_brick",
	"mcl_nether:quartz_block",
	-- mcl_end
	"mcl_end:end_stone",
	"mcl_end:end_bricks",
	"mcl_end:purpur_block",
}

for k, v in pairs(node_list) do
	register_platform("mcl_advtrains_platform",v)
end
