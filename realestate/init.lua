-- Real Estate mod for minetest
-- Sell your areas!

-- Copyright (c) 2018 Gabriel Pérez-Cerezo <gabriel@gpcf.eu>

-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU General Public License as
-- published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.

-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see
-- <http://www.gnu.org/licenses/>.


realestate = {}
realestate.area = function (area_id)
   area = areas.areas[area_id]
   local size = (math.abs( area.pos1.x - area.pos2.x )+1)
       * (math.abs( area.pos1.z - area.pos2.z )+1);
   return size
end

local function after_place_node(pos, player)
   local meta = minetest.get_meta(pos)
   local owner = player:get_player_name()
   meta:set_string("owner", owner)
   meta:set_string("infotext", "Land for sale by "..owner)
end
local playerpos = {}

local function get_formspec(pos,player)
   local meta = minetest.get_meta(pos)
   local owner = meta:get_string("owner")
   local name = player:get_player_name()
   local id = meta:get_int("id")
   local price = meta:get_int("price")
   atm.ensure_init(name) -- ensure the player already has an atm account
   playerpos[name] = pos
   local formspec = ""
   if player:get_player_name() == owner then
      if not id then
	 id = ""
      end
      if not price then
	 price = ""
      end
      formspec =
      "size[8,6]"..
      default.gui_bg..
      default.gui_bg_img..
      default.gui_slots..
      "label[2.5,0;Real estate for sale]" ..
	 "field[1,2;2,1;name;Area Number;"..id.."]"..
	 "field[4,2;2,1;price;Price;"..price.."]"..
      "label[2,0.5;Your account balance: $".. atm.balance[player:get_player_name()].. "]" ..
      "button_exit[0.2,5;1,1;Quit;Quit]" ..
	 "button[4.7,5;3,1;sell;Sell]"
      minetest.after((0.1), function(gui)
	    return minetest.show_formspec(player:get_player_name(), "realestate.setup", gui)
			    end, formspec)
      return
   end

   if not id or not price then
      minetest.chat_send_player(name, "This sale point is unconfigured")
      return
   end
   if not areas.areas[id] then
      minetest.chat_send_player(name, "The area no longer exists")
      return
   end
   local formspec =
      "size[8,6]"..
      default.gui_bg..
      default.gui_bg_img..
      default.gui_slots..
      "label[2.5,0;Real estate for sale]" ..
	 "label[0.5,0.5;Your account balance: $".. atm.balance[player:get_player_name()].. "]" ..
	 "label[0.5,1.5;Area Number: "..id.."]" ..
	 "label[0.5,2;Area Name: "..minetest.formspec_escape(areas.areas[id].name).."]" ..
	 "label[0.5,2.5;Area Price: "..price.."]" ..
	 "label[0.5,3;Surface Area: "..realestate.area(id).." m²]" ..
      "button_exit[0.2,5;1,1;Quit;Quit]" ..
	 "button[4.7,5;3,1;buy;Buy]"   
   minetest.after((0.1), function(gui)
	 return minetest.show_formspec(player:get_player_name(), "realestate.sell", gui)
			 end, formspec)
end
realestate.transfer = function (transfer)
   -- callback called from atm mod after transfer arrives. 
   areas.areas[transfer.id].owner = transfer.from
   minetest.set_node(transfer.pos,{name="air"})
   minetest.chat_send_player(transfer.from,"The area has been transfered to you")
end
minetest.register_on_player_receive_fields(function(player, form, pressed)
      if form == "realestate.sell" then
	 if not pressed.buy then
	    return
	 end
	 local name = player:get_player_name()
	 if not playerpos[name] then
	    return
	 end
	 local meta = minetest.get_meta(playerpos[name])
	 local id = meta:get_int("id")
	 local price = meta:get_int("price")

	 local owner = meta:get_string("owner")
	 atm.pending_transfers[name] = {from=name, to = owner, sum = price, desc = "Payment for area "..id, callback=realestate.transfer, extern=true, id=id, pos=playerpos[name]}
	 atm.showform_wtconf (player, owner, price, "Payment for area "..id)
	 return
      end
      if form == "realestate.setup" then
	 local name = player:get_player_name()
	 if not playerpos[name] then
	    return
	 end
	 local meta = minetest.get_meta(playerpos[name])
	 if pressed.name then
	    local id = tonumber(pressed.name)
	    if not id then
	       minetest.chat_send_player(name, "Invalid area number: \""..pressed.name.."\"")
	       return
	    elseif not areas.areas[tonumber(pressed.name)] then
	       minetest.chat_send_player(name, "No such area with id "..pressed.name)
	       return
	    elseif areas.areas[id].owner ~= name then
	       minetest.chat_send_player(name, "You don't own area "..id)
	       return
	    else
	       minetest.chat_send_player(name, "Selling area ".. areas.areas[id].name)
	       meta:set_int("id",id)
	    end
	 end
	 if pressed.price then
	    local price = tonumber(pressed.price) or 15
	    meta:set_int("price", price)
	 end
	 minetest.close_formspec(name, "realestate.setup")
      end
end)

minetest.register_node("realestate:sign", {
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"realestate_sign_back.png",
		"realestate_sign.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	description = "For sale sign",
	node_box = {
		type = "fixed",
		fixed = {
			{0.4375, -0.5, 0, 0.5, 0.4375, 0.0625}, -- NodeBox1
			{-0.5, 0.375, 0, 0.5, 0.4375, 0.0625}, -- NodeBox2
			{-0.465, -0.2, 0, 0.4, 0.3125, 0.0625}, -- NodeBox3
			{-0.375, 0.3125, 0, -0.3125, 0.375, 0.0625}, -- NodeBox4
			{0.25, 0.3125, 0, 0.3125, 0.4375, 0.0625}, -- NodeBox5
		}
	},
	after_place_node=after_place_node,
	paramtype2="facedir",
	groups = {snappy = 3},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	   get_formspec(pos,player)
	end,
})

minetest.register_craft({
	output = "realestate:sign",
	recipe = {
		{"default:stick", "default:stick", "default:stick"},
		{"default:stick", "", "default:sign_wall_wood"},
		{"default:stick", "", ""}
	}
})
