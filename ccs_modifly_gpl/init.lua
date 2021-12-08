local changes = {
	["apartment:build_chest"] = { -- Copyright (C) 2014 Sokomine
		groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1},
		can_dig = function(pos,player)	
			if( not( player and player:is_player() )) then
				return false;
			end
			local pname = player:get_player_name();
			local meta  = minetest.get_meta( pos );
			local old_placer = meta:get_string('placed_by');
			if( not( minetest.check_player_privs(pname, {apartment_unrent=true}) or (pname == old_placer))) then
				minetest.chat_send_player( pname, 'You do not have the apartment_unrent priv which is necessary to dig this node, or you are not the apartment owner.');
				return false;
			end
			return true;
		end,
		on_place = function(itemstack, placer, pointed_thing)
			itemstack:set_count(0)
			if placer:is_player() then
				minetest.chat_send_player(placer:get_player_name(),"Apartment Spawning Chest is disabled.")
			end
			return itemstack
		end,
		node_placement_prediction = "air",
		inventory_overlay = "barrier_inv.png",
		description = "Apartment spawner (Disabled)",
	},
}

local func_changes = {}
local for_item = {}

for k,v in pairs(changes) do
	minetest.override_item(k,v)
end

for k,v in pairs(for_item) do
	for x,y in pairs(minetest.registered_items) do
		v(x)
	end
end

for k,v in pairs(func_changes) do
	for x,y in pairs(minetest.registered_items) do
		if v[1](x) then
			minetest.override_item(x,v[2])
		end
	end
end

-- Additional code starts
