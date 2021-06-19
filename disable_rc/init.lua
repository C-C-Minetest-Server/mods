minetest.register_craftitem("disable_rc:fake_rc", {
	description = "Rc (Disabled)",
	inventory_image = "vehicles_rc.png",
	wield_scale = {x = 1.5, y = 1.5, z = 1},
})

minetest.unregister_item("vehicles:rc")

minetest.register_alias("vehicles:rc", "disable_rc:fake_rc")