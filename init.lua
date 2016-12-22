--
-- Nekrowebmod
--

-- Add this mod to trusted_mods
-- Open : minetest.confg
-- Add : secure.trusted_mods = requesthttpapi

local load_time_start = os.clock()

local http_api = minetest.request_http_api and minetest.request_http_api()


if http_api then
	local feed_url = "https://queryfeed.net/tw?q=Minetest"
	local receive_interval = 10

	local old_tweet
	local function pcall_function(data)
		local contents = data.responseData.feed.entries[1]
		local text = "<"..contents.author.."> "..contents.contentSnippet
		if old_tweet ~= text then
			old_tweet = text
			minetest.chat_send_all(text)
		end
	end

	local function fetch_callback(result)
		if not result.completed then
			return
		end

		pcall(pcall_function, minetest.parse_json(result.data))
	end

	local function get_latest_tweet()
		local json_url = "https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q="..feed_url.."&num=1"

		http_api.fetch({url = json_url, timeout = receive_interval}, fetch_callback)

		minetest.after(receive_interval, get_latest_tweet)
	end

	minetest.after(1, get_latest_tweet)
end


minetest.register_chatcommand("locatePlayer", {
	params = "<player name>",
	description = "Tell the location of <player>",
	func = function(user, args)
		if args == "" then
			return false, "Player name required."
		end
		local player = minetest.get_player_by_name(args)
		if not player then
			return false, "There is no player named '"..args.."'"
		end
		local fmt = "Player %s is at (%.2f,%.2f,%.2f)"
		
		local pos = player:getpos()
		return true, fmt:format(args, pos.x, pos.y, pos.z)
	end
})




local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "[Request Http API Tweeter] Loaded after ca. " .. time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end
