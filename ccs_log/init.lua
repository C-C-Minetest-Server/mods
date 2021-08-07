local old_set_player_privs = minetest.set_player_privs
function minetest.set_player_privs(name,privs)
	local cmod = minetest.get_current_modname()
	minetest.log("action",(cmod and ("Mod " .. cmod) or "Unknown Mod") .. "set player " .. name .. "privs to " .. dump(privs))
	return old_set_player_privs(name,privs)
end
