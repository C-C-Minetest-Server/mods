minetest.register_lbm({
	name="get_rid_unknown_nodes:get_rid_unknown_nodes",
	run_at_every_load=true,
	action=function(pos,node)
		if not minetest.registered_nodes[node.name] then
			minetest.remove_node(pos)
		end
	end
})

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	if not minetest.registered_nodes[node.name] then
		minetest.remove_node(pos)
	end
end)
