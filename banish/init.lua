
--Banish command
--Copyright 2016,2018 Gabriel Pérez-Cerezo
--AGPLv3

local spawn_spawnpos = minetest.setting_get_pos("static_spawnpoint")
local banish_pos = {x=-300,y=7,z=-48}
banish = {}
banish.spawn = {}
local modpath = minetest.get_modpath("banish")

function banish.xbanish(name, param)
   -- banish player in param.
   local plname, reason = param:match("(%S+)%s+(.+)")
   if not plname or not reason then
      minetest.chat_send_player(name, "banish: invalid syntax")
      return 
   end
   local player = minetest.get_player_by_name(plname)
   if player == nil then
      minetest.chat_send_player(name,"Player "..plname.." not found.")
      return false
   end
   local record = {
      source = name,
      time = os.time(),
      expires = nil,
      reason = reason,
      type = "jail",
   }
   xban.add_record(plname, record)
   xban.add_property(plname, "jailed", true)
   if beds.spawn[plname] then
      banish.spawn[plname] = beds.spawn[plname]
   else
      banish.spawn[plname] = spawn_spawnpos
   end
   banish.save_spawns()
   beds.spawn[plname] = banish_pos
   beds.save_spawns()
   player:setpos(banish_pos)
   local privs = minetest.get_player_privs(plname)
   privs.teleport = false
   privs.home = false
   minetest.set_player_privs(plname, {interact=true, shout=true})
   minetest.chat_send_player(name, "Player "..plname.." has been jailed")
end

function banish.xunbanish(name, param)
   local plname, reason = param:match("(%S+)%s+(.+)")
   if not plname or not reason then
      minetest.chat_send_player(name, "banish: invalid syntax")
      return 
   end
   if not banish.spawn[plname] then
      minetest.chat_send_player(name,"Player "..plname.." was never jailed")
      return
   end
   local record = {
      source = name,
      time = os.time(),
      expires = nil,
      reason = reason,
      type = "unjail",
   }
   xban.add_record(plname, record)
   xban.add_property(plname, "jailed", nil)
   beds.spawn[plname] = banish.spawn[plname]
   beds.save_spawns()
   minetest.set_player_privs(plname, {interact=true, shout=true, home=true})
   minetest.chat_send_player(name, "Player "..plname.." has been unjailed")
end

minetest.register_chatcommand("jail", {
   description = "Jails Players",
   privs = {kick=true},
   params = "<player> <reason>",
   func = function(name, param)
      banish.xbanish(name, param) 
   end,
})

minetest.register_chatcommand("unjail", {
   description = "Unjails players",
   privs = {kick=true},
   params = "<player> <reason>",
   func = function(name, param)
      banish.xunbanish(name, param) 
   end,
})

minetest.register_on_joinplayer(function(player)
	banish.read_spawns()
end)

dofile(modpath .. "/spawns.lua")
