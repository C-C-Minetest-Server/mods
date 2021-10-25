local function air(pos)
	minetest.set_node(pos,{name="air"})
end
minetest.register_node("ccs_temp_blocks:temp_block_water", {
	description = "Moderation Temp Block (Liquid Pointable)",
	drawtype = "airlike",
	on_construct = air,
	on_punch = air,
	on_rightclick = air,
	groups = {cracky = 1, handly = 1},
	liquids_pointable = true,
	paramtype = "light",
	sunlight_propagates = true,
})

minetest.register_node("ccs_temp_blocks:temp_block_water", {
	description = "Moderation Temp Block",
	drawtype = "airlike",
	on_construct = air,
	on_punch = air,
	on_rightclick = air,
	groups = {cracky = 1, handly = 1},
	paramtype = "light",
	sunlight_propagates = true,
})
