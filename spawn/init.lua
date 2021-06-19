function teleport_to_spawn(name)
    local player = minetest.get_player_by_name(name)
    if player == nil then
        -- just a check to prevent the server crashing
        return false
    end
    local spawn_pos = pos_marker.get("\\SERVER\\","spawn")
    if not spawn_pos then
        return false, "Admins not yet set the spawn point!"
    end
    local pos = player:getpos()
    if _G['cursed_world'] ~= nil and    --check global table for cursed_world mod
        cursed_world.location_y and cursed_world.dimension_y and
        pos.y < (cursed_world.location_y + cursed_world.dimension_y) and    --if player is in cursed world, stay in cursed world
        pos.y > (cursed_world.location_y - cursed_world.dimension_y)
    then   --check global table for cursed_world mod
        --minetest.chat_send_player(name, "T"..(cursed_world.location_y + cursed_world.dimension_y).." "..(cursed_world.location_y - cursed_world.dimension_y))
        -- local spawn_pos = vector.round(spawn_command.pos);
        spawn_pos.y = spawn_pos.y + cursed_world.location_y;
    end
    player:set_pos(spawn_pos)
    return true, "Teleported to spawn!"
end

minetest.register_chatcommand("spawn", {
    description = "Teleport you to spawn point set by admins",
    privs = {home=true},
    func = teleport_to_spawn,
})

