-- Default tracks for advtrains
-- (c) orwell96 and contributors

--flat

local function suitable_substrate(upos)
	return minetest.registered_nodes[minetest.get_node(upos).name] and (minetest.registered_nodes[minetest.get_node(upos).name].liquidtype == "source" or minetest.registered_nodes[minetest.get_node(upos).name].liquidtype == "flowing")
end

advtrains.register_tracks("groundline", {
	nodename_prefix="groundline:groundline",
	texture_prefix="advtrains_ltrack",
	models_prefix="advtrains_ltrack",
	models_suffix=".obj",
	shared_texture="linetrack_line.png",
	description=attrans("Ground Line Track"),
	formats={},
	liquids_pointable=false,

	get_additional_definiton = function(def, preset, suffix, rotation)
		return {
			groups = {
				advtrains_track=1,
				advtrains_track_groundline=1,
				save_in_at_nodedb=1,
				dig_immediate=2,
				not_in_creative_inventory=1,
				not_blocking_trains=1,
			},
			use_texture_alpha = true,
		}
	end
}, advtrains.ap.t_30deg_flat)
--slopes
advtrains.register_tracks("groundline", {
	nodename_prefix="groundline:groundline",
	texture_prefix="advtrains_ltrack",
	models_prefix="advtrains_ltrack",
	models_suffix=".obj",
	shared_texture="linetrack_line.png",
	description=attrans("GLine Track"),
	formats={vst1={true, false, true}, vst2={true, false, true}, vst31={true}, vst32={true}, vst33={true}},
	liquids_pointable=false,

	get_additional_definiton = function(def, preset, suffix, rotation)
		return {
			groups = {
				advtrains_track=1,
				advtrains_track_groundline=1,
				save_in_at_nodedb=1,
				dig_immediate=2,
				not_in_creative_inventory=1,
				not_blocking_trains=1,
			},
			use_texture_alpha = true,
		}
	end
}, advtrains.ap.t_30deg_slope)

if atlatc ~= nil then
	advtrains.register_tracks("groundline", {
		nodename_prefix="groundline:groundline_lua",
		texture_prefix="advtrains_ltrack_lua",
		models_prefix="advtrains_ltrack",
		models_suffix=".obj",
		shared_texture="linetrack_lua.png",
		description=atltrans("LuaAutomation ATC Ground Line"),
		formats={},
		liquids_pointable=false,
	
		get_additional_definiton = function(def, preset, suffix, rotation)
			return {
				after_place_node = atlatc.active.after_place_node,
				after_dig_node = atlatc.active.after_dig_node,

				on_receive_fields = function(pos, ...)
					atlatc.active.on_receive_fields(pos, ...)
					
					--set arrowconn (for ATC)
					local ph=minetest.pos_to_string(pos)
					local _, conns=advtrains.get_rail_info_at(pos, advtrains.all_tracktypes)
					atlatc.active.nodes[ph].arrowconn=conns[1].c
				end,

				advtrains = {
					on_train_enter = function(pos, train_id)
						--do async. Event is fired in train steps
						atlatc.interrupt.add(0, pos, {type="train", train=true, id=train_id})
					end,
				},
				luaautomation = {
					fire_event=atlatc.rail.fire_event
				},
				digiline = {
					receptor = {},
					effector = {
						action = atlatc.active.on_digiline_receive
					},
				},
				groups = {
					advtrains_track=1,
					advtrains_track_groundline=1,
					save_in_at_nodedb=1,
					dig_immediate=2,
					not_in_creative_inventory=1,
					not_blocking_trains=1,
				},
				use_texture_alpha = true,
			}
		end,
	}, advtrains.trackpresets.t_30deg_straightonly)
end

if minetest.get_modpath("advtrains_line_automation") ~= nil then
	local adef = minetest.registered_nodes["advtrains_line_automation:dtrack_stop_st"]
	
	advtrains.register_tracks("groundline", {
		nodename_prefix="groundline:groundline_stn",
		texture_prefix="advtrains_ltrack_stn",
		models_prefix="advtrains_ltrack",
		models_suffix=".obj",
		shared_texture="linetrack_stn.png",
		description="Station/Stop Ground Line",
		formats={},
		liquids_pointable=false,
	
		get_additional_definiton = function(def, preset, suffix, rotation)
			return {
				after_place_node = adef.after_place_node,
				after_dig_node = adef.after_dig_node,
				on_rightclick = adef.on_rightclick,
				advtrains = adef.advtrains,
				groups = {
					advtrains_track=1,
					advtrains_track_groundline=1,
					save_in_at_nodedb=1,
					dig_immediate=2,
					not_in_creative_inventory=1,
					not_blocking_trains=1,
				},
				use_texture_alpha = true,
			}
		end,
	}, advtrains.trackpresets.t_30deg_straightonly)
end

if minetest.get_modpath("advtrains_interlocking") ~= nil then
	dofile(minetest.get_modpath("groundline") .. "/interlocking.lua")
end

advtrains.register_wagon("advbus", {
	mesh="advtrains_subway_wagon.b3d",
	textures = {"advtrains_subway_wagon.png"},
	drives_on={groundline=true},
	max_speed=15,
	seats = {
		{
			name="Driver stand",
			attach_offset={x=0, y=0, z=0},
			view_offset={x=0, y=0, z=0},
			group="dstand",
		},
		{
			name="1",
			attach_offset={x=-4, y=-2, z=8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=4, y=-2, z=8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-4, y=-2, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=4, y=-2, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
	},
	seat_groups = {
		dstand={
			name = "Driver Stand",
			access_to = {"pass"},
			require_doors_open=true,
			driving_ctrl_access=true,
		},
		pass={
			name = "Passenger area",
			access_to = {"dstand"},
			require_doors_open=true,
		},
	},
	assign_to_seat_group = {"pass", "dstand"},
	doors={
		open={
			[-1]={frames={x=0, y=20}, time=1},
			[1]={frames={x=40, y=60}, time=1},
			sound = "advtrains_subway_dopen",
		},
		close={
			[-1]={frames={x=20, y=40}, time=1},
			[1]={frames={x=60, y=80}, time=1},
			sound = "advtrains_subway_dclose",
		}
	},
	door_entry={-1, 1},
	visual_size = {x=1, y=1},
	wagon_span=2,
	--collisionbox = {-1.0,-0.5,-1.8, 1.0,2.5,1.8},
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	is_locomotive=true,
	drops={"default:steelblock 4"},
	horn_sound = "advtrains_subway_horn",
	custom_on_velocity_change = function(self, velocity, old_velocity, dtime)
		if not velocity or not old_velocity then return end
		if old_velocity == 0 and velocity > 0 then
			minetest.sound_play("advtrains_subway_depart", {object = self.object})
		end
		if velocity < 2 and (old_velocity >= 2 or old_velocity == velocity) and not self.sound_arrive_handle then
			self.sound_arrive_handle = minetest.sound_play("advtrains_subway_arrive", {object = self.object})
		elseif (velocity > old_velocity) and self.sound_arrive_handle then
			minetest.sound_stop(self.sound_arrive_handle)
			self.sound_arrive_handle = nil
		end
		if velocity > 0 and (self.sound_loop_tmr or 0)<=0 then
			self.sound_loop_handle = minetest.sound_play({name="advtrains_subway_loop", gain=0.3}, {object = self.object})
			self.sound_loop_tmr=3
		elseif velocity>0 then
			self.sound_loop_tmr = self.sound_loop_tmr - dtime
		elseif velocity==0 then
			if self.sound_loop_handle then
				minetest.sound_stop(self.sound_loop_handle)
				self.sound_loop_handle = nil
			end
			self.sound_loop_tmr=0
		end
	end,
	custom_on_step = function(self, dtime, data, train)
		--set line number
		local line = nil
		if train.line then
			local lint = string.sub(train.line, 1, 1)
			line = tonumber(lint)
			if lint=="X" then line="X" end
		end
		if line and line~=self.line_cache then
			local new_line_tex="advtrains_subway_wagon.png^advtrains_subway_wagon_line"..line..".png"
			self.object:set_properties({
				textures={new_line_tex},
		 	})
			self.line_cache=line
		elseif self.line_cache~=nil and line==nil then
			self.object:set_properties({
				textures=self.textures,
		 	})
			self.line_cache=nil
		end
	end,
}, "advBus", "advtrains_subway_wagon_inv.png")


minetest.register_node("groundline:invisible_platform", {
	description = "Invisible Platform",
	groups = {cracky = 1, not_blocking_trains = 1, platform=1},
	drawtype = "airlike",
	inventory_image = "linetrack_invisible_platform.png",
	wield_image = "linetrack_invisible_platform.png",
	walkable = false,
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
	
