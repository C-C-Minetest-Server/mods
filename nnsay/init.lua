minetest.register_chatcommand("nnsay", {
	params = "<text>",
	description = "Say <text> but nobody knows who say that.",
	privs = {server=true},
	func = function(name, param)
		minetest.chat_send_all(param)
		minetest.log("action", name.."Used nnsay: "..param)
	end
})
