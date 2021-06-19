minetest.register_node("visable_air:visable_air", {
	description = "Visable Air (beta)",
	tiles = {"air.png"},
	inventory_image = "air.png",
	wield_image = "air.png",
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	floodable = true,
	air_equivalent = true,
	drop = "",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		}
	}
})
minetest.register_craft{
	type = "shapeless",
	output = "visable_air:visable_air 8",
	recipe = {"bucket:bucket_empty"},
}
