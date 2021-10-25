minetest.register_node("ccs_temp_blocks:temp_block_water", {
	destription = "Moderation Temp Block (Liquid Pointable)",
	drawtype = "airlike",
	on_construct = function (pos)
		minetest.set_node({name="air"})
	end,
	liquids_pointable = true,
})

minetest.register_node("ccs_temp_blocks:temp_block_water", {
	destription = "Moderation Temp Block",
	drawtype = "airlike",
	on_construct = function (pos)
		minetest.set_node({name="air"})
	end,
})
