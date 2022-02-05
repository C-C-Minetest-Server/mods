local formspec_version = 5
local suggested_client_version = "5.5.0"
-- minetest.get_player_information(player_name).formspec_version
minetest.register_on_joinplayer(function(OR, last_login)
	if not OR:is_player() then return end
	local pname = OR:get_player_name()
	local info = minetest.get_player_information(pname)
	if info.formspec_version < formspec_version then
		minetest.chat_send_player(pname,minetest.colorize("#F33","Outdated clients are not supported. Please use clients newer then " .. suggested_client_version .. "!"))
		OR:hud_add({
			name          = "ccs_kick_outdate:warning",
			hud_elem_type = "text",
			position      = {x = 0.5, y = 0.5},
			scale         = {x = 0, y = 70},
			text          = "Outdated clients are not supported. Please use clients newer then " .. suggested_client_version .. "!",
			number        = 0xFF3333,
			offset        = {x = -20, y = 20},
			alignment     = {x = 0.2, y = 0}
		})
		-- minetest.after(3,minetest.kick_player,pname,"Outdated clients are not supported. Please use clients newer then " .. suggested_client_version .. "!")
		-- TODO: solve all mod's error then re-add this line
	end
end)
