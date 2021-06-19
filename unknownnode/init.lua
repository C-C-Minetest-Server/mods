--unknownnode - adds a node looking like unknown  nodes
--only use: the unknown node texture looks so nice.
minetest.register_node("unknownnode:un", {
	groups={cracky=1},
	tiles={"unknown_node.png"},
	description="Fake Unknown Node",
	drawtype = "normal",
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_craft({
	output = 'unknownnode:un 4',
	recipe = {
		{'default:cobble', '',               'default:cobble'},
		{'default:cobble', ''              , 'default:cobble'},
		{'default:cobble', 'default:cobble', 'default:cobble'}, -- Also groups; e.g. 'group:crumbly'
	},
})
if minetest.get_modpath("moreblocks") then
	
	stairsplus:register_all(
		"unknownnode",
		"un",
		"unknownnode:un",
		{
			description = "Unknown Node",
			tiles = {"unknown_node.png"},
			groups = {cracky=1},
			sounds = default.node_sound_stone_defaults(),
		}
	)
end