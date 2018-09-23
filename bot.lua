local discordia = require('discordia')
local storage = discordia.storage
local client = discordia.Client()

-- local cache = require('cache')
local json = require('json.lua')
local dir = './onedrive/mezzabot/'

local spam = {}

--local Cache = require('class')('Cache', Iterable)

local dicemin = 0
local dicemax = 6

local bet = {

	{["Player"] = nil, ["Bid"] = 0, ["Num"] = 0, ["Channel"] = nil},
	{["Player"] = nil, ["Bid"] = 0, ["Num"] = 0}

}

local prefs = {

	'!';
	';';
	',';
	'.';
	'?';
	'&';
	'$';
	'~';
	'-';
	'+';
	'/';
	':';
	'"';
	"'";

}

local mezzaBotData = dir .. 'data/mezzaBotData.json'
local mezzaBotPrefixes = dir .. 'data/mezzaBotPrefixes.json'
local mezzaBotSettings = dir .. 'data/mezzaBotSettings.json'
local levelData = dir .. 'data/levelData.json'
local plrData = dir .. 'data/plrData.json'
local EightBallData = dir .. 'data/8BallData.json'

local options = {"Yes","No","Maybe","Absolutely!","Absolutely Not!","Nope","You","Nope","Yep.","I really dunno..","What are you talking about"}

local sets = {

	["onlineNotify"] = false

}

local chatOptions = {

	["cmds"] = "Just run `-help` to get a list of commands!";
	["help"] = "You can run `-help` to get a list of commands!";
	["job"] = "Im a `moderation`, `economy` and `utility` bot!";
	["library"] = "I was made in the `Discordia` library in `Lua`! A few `JSON` files here and there.";
	["dev"] = "I was developed by `MezzaDev#5400`! I stole the name from him :3";
	["howami"] = "I mean, thanks for asking but there is not much to say. Im `programmed`. But i suppose im doing `OK`.";
	['mean'] = "Hey! Dont you think that's a bit mean?";
	['yourgood'] = "Well, im glad to hear so!";
	['level'] = "By `chatting`, you recieve a random ammount of `EXP`. To check your level and EXP, just do `-level`.";
	['coins'] = "Chat to get a few coins here and there. `-bal` will show your coins. \nYou can `bet` with the against a slot machine or against others. \njust do `-help` to check all economy commands."

}

client:on('ready', function()
	print('Logged in as '.. client.user.username)
	client:setGame(string.format('-help | %s Servers',#client.guilds))
	
	for _,v in pairs(client.guilds) do
		if v.name ~= "Discord Bots" then
			local writable = v.textChannels:toArray('position', function(c)
				return v.me:hasPermission(c, 'sendMessages')
			end)[1]
			
			print(v.name)
			
			if loadData(mezzaBotSettings)[v.id] ~= nil then
				if loadData(mezzaBotSettings)[v.id] ~= nil then
					writable = v:getChannel(loadData(mezzaBotSettings)[v.id]["outchannel"])
				end
			end
			
			if sets["onlineNotify"] == true then
				writable:send {
					embed = {
						title = "**Now Running**",
						author = {
							name = client.user.username,
							icon_url = client.user.avatarURL
						},
						description = "\n \n Guess what? MezzaBOT Is back online and has completed the startup sequence!",
						color = 0x00ff00 -- hex color code
					}
				}
			end
		end
	end
end)

client:on('guildCreate', function(guild)

	local pres = loadData(tostring(mezzaBotPrefixes))
	if pres[guild.name] == nil then
		pres[guild.name] = "-"
		local enc = json.encode(pres)
		local file = io.open(mezzaBotPrefixes,"w+")
		file:write(enc)
		file:close()
	end
	
	client:setGame(string.format('-help | %s Servers',#client.guilds))

	print(string.format('###NEW GUILD JOINED### GUILD = %s', guild.name))
	
	local writable = guild.textChannels:toArray('position', function(c)
		return guild.me:hasPermission(c, 'sendMessages')
	end)[1]
	
	if loadData(mezzaBotSettings)[guild.id] ~= nil then
		writable = guild:getChannel(loadData(mezzaBotSettings)[guild.id]["outchannel"])
	end
	
	writable:send{
		embed = {
			title = "***Thank You For Adding MezzaBOT***",
			author = {
						name = 'MezzaBOT',
						icon_url = client.user.avatarURL
					},
			description = string.format("\n \n Run ***-help*** for a list of commands. \nPrefix:  **%s**", prefix),
			color = 0x0e600 -- hex color code
		}
	}
	
	writable:send('-help')
end)

client:on('userBan', function(user, guild)

	local writable = guild.textChannels:toArray('position', function(c)
		return guild.me:hasPermission(c, 'sendMessages')
	end)[1]
	
	if loadData(mezzaBotSettings)[guild.id] ~= nil then
		writable = guild:getChannel(loadData(mezzaBotSettings)[guild.id]["outchannel"])
	end
	
	writable:send{
		embed = {
			title = string.format('***%s*** was **Banned** from %s!', user.name, guild.name),
			author = {
						name = user.name,
						icon_url = user.avatarURL
					},
			description = string.format("\n \n You will not be seeing them *around.*"),
			color = 0xff0000 -- hex color code
		}
	}
	
	user:send{
		embed = {
			title = string.format('***%s*** was **Banned** from %s!', user.name, guild.name),
			author = {
						name = user.name,
						icon_url = user.avatarURL
					},
			description = string.format("\n \n You will not be seeing them *around.*"),
			color = 0xff0000 -- hex color code
		}
	}

end)

function loadData(fileName)
	--print(fileName)
	local jsonlines = {}
	for line in io.lines(fileName) do --print(line) print(json.decode(line)) 
		table.insert(jsonlines, line)
		--print(line)
	end
	local filestr = table.concat(jsonlines, "\n")
	--print(filestr)
	local dec = json.decode(filestr)
	for i,v in pairs(dec) do
		--print(i,v)
	end
	return dec
end

client:on('messageCreate', function(message)

	client:setGame(string.format('-help | %s Servers',#client.guilds))
	
	if message.guild ~= nil then --  and message.guild.name ~= "Discord Bots" 
	
		if spam[message.author] ~= nil then
			if spam[message.author] > os.time() then
				return true
			elseif spam[message.author] <= os.time() then
				spam[message.author] = os.time() + 2
			end
		else
			spam[message.author] = os.time() + 2
		end
		
		local pres = loadData(tostring(mezzaBotPrefixes))
		if pres[message.guild.name] == nil then
			pres[message.guild.name] = "-"
			local enc = json.encode(pres)
			local file = io.open(mezzaBotPrefixes,"w+")
			file:write(enc)
			file:close()
		end
		local prefix = loadData(tostring(mezzaBotPrefixes))[message.guild.name]

		local coinNum = math.random(1,15)
		local baseNum = math.random(1,15)
		local coinAmt = math.random(math.random(1,3),math.random(3,4))
		
		------------------- LEVELING ---------------------
		if string.sub(message.content,1,string.len(prefix)) ~= prefix then
		
			local lData = loadData(levelData)
			for _,v in pairs(lData) do
				--print(v,v["Level"],v["EXP"])
			end
			
			--print(message.member.user.id)
			
			if message.member == nil then
				return true
			end
			
			if lData[message.member.user.id] == nil then
				lData[message.member.user.id] = {}
				lData[message.member.user.id]["Level"] = 1
				lData[message.member.user.id]["EXP"] = 0
			end
			
			local gainedEXP = math.random(math.random(1,2),math.random(6,10))
			local lvlData = lData[message.member.user.id]
			
			--print(gainedEXP)
			lvlData["EXP"] = lvlData["EXP"] + gainedEXP
			--print(lvlData["EXP"])
			
			if lvlData["EXP"] >= (lvlData["Level"] * 10) * lvlData["Level"] then
				lvlData["EXP"] = lvlData["EXP"] - ((lvlData["Level"] * 10) * lvlData["Level"])
				lvlData["Level"] = lvlData["Level"] + 1
				local loadedBal = loadData(mezzaBotData)
				if loadedBal[message.member.user.fullname] ~= nil then
					loadedBal[message.member.user.fullname] = loadedBal[message.member.user.fullname] + lvlData["Level"] * 5
					local encBal = json.encode(loadedBal)
					local file = io.open(mezzaBotData, 'w+')
					file:write(encBal)
					file:close()
				end
			end
			
			local encData = json.encode(lData)
			--print(encData)
			
			--local file = io.open(levelData,'w+')
			--file:write(encData)
			--file:close()
		
		end
		-----------------------------------------------------------
		
		--print(coinNum, baseNum, coinAmt)
		
		if message.member ~= nil then
		
			if message.member.user.bot == false then
			
				if message.member.user.bot == false then
					if coinAmt == baseNum then
						print(string.format('Giving %s Coins to user %s!',coinAmt,message.member.name))
						local file = io.open(mezzaBotData, 'r')
						local jsonlines = {}
						for line in io.lines(mezzaBotData) do --print(line) print(json.decode(line)) 
							table.insert(jsonlines, line)
						end
						local filestr = table.concat(jsonlines, "\n")
						local dec = json.decode(filestr)
						--for _,v in pairs(dec) do
							--print(_,v)
						--end
						if dec[message.member.user.fullname] == nil then
							dec[message.member.user.fullname] = 0
						end
						dec[message.member.user.fullname] = dec[message.member.user.fullname] + coinAmt
						local enc = json.encode(dec)
						--print(enc)

						file:close()
						local file = io.open(mezzaBotData, 'w+')
						file:write(enc)
						file:close()
						
						if #message.guild.members < 30 then
							if message.guild.name ~= "Discord Bots" then
								print('ChName '..message.guild.name)
								message.channel:send {
									embed = {
										title = string.format("@%s, You just recieved **%s** Coins!", message.member.user.fullname, coinAmt),
										color = 0x00ff00 -- hex color code
									}
								}
							end
						end
					end
				end
				
				if message.guild ~= nil then
					print(string.format('Log from guild %s - %s: %s', message.guild.name, message.member.user.fullname,message.content))
					file = io.open('log.txt', 'a')
					file:write(string.format('\n Log from guild %s - %s: %s \n ', message.guild.name, message.member.user.fullname,message.content), " \n ")
					file:write('\n')
					file:close()
				else
					print(string.format('Log from user dm - %s: %s',message.author,message.content))
				end
				
				local args = {}
		
				for arg in string.gmatch(message.content,"[^%s]+") do
					table.insert(args,arg)
				end
				
				--print(string.format('%s Arguments Found',#args))
				
				--print('parsingArgs')
			
				for _,v in pairs(args) do
					--print(v)
				end
				
				if string.sub(message.content,1,string.len(prefix)) == prefix then
					local cmd = string.sub(message.content,(string.len(prefix)+1))
					
					local writable = message.guild.textChannels:toArray('position', function(c)
						return message.guild.me:hasPermission(c, 'sendMessages')
					end)[1]
					
					if loadData(mezzaBotSettings)[message.guild.id] ~= nil then
						writable = message.guild:getChannel(loadData(mezzaBotSettings)[message.guild.id]["outchannel"])
					end
					
					if cmd == 'sinfo' or cmd == 'serverinfo' then
						if message.guild ~= nil then
							message:reply {
								embed = {
									title = "***Server Info***",
									description = string.format("\n \n **Server Name: ** %s \n**Owner: ** %s \n**Region: ** %s \n \n**Member Count: ** %s \n**Role Count: ** %s", message.guild.name, message.guild.owner.name, message.guild.region, #message.guild.members, #message.guild.roles),
									color = 0x00ff00 -- hex color code
								}
							}
						end
						--message.channel:send(string.format('```css\n ---  Server Info  --- \n \nName: %s```', message.guild.name))
					elseif cmd == 'ping' then
						message.channel:send('Pong!')
					elseif cmd == 'help' or cmd == 'cmds' then

						--local text = ' '
					
						--for _,v in pairs(message.guild.roles) do
						
							--message.channel:send(v.Name)
						
						--end
						
						message.member.user:send {
							embed = {
								title = "***MezzaBOT Help Menu***",
								description = string.format("\n \n**%shelp** Opens this menu. \n \n**%sflipcion** Heads or Tails?\n**%sdiceroll** Random number from 1 to 6 \n \n**%ssinfo** Information about this server/guild \n**%slink** Add bot to a server \n**%secho <message>** Bot repeats message \n**%sroles** Lists all guild roles \n**%sclrchannel <ammount>** Clear <100 messages from the channel \n**%sprefix <prefix>** Set a custom prefix for the server \n**mB-prefix <prefix>** Set your prefix if you forgot it \n**%skick <@user> <reason>** Kick a user with a reason. \n**%sban <@user> <reason>** Bans a user with a reason. \n \n**%sbal** Shows your current coin balance \n**%sbaltop** Shows the highest balance(s) \n**%spay <@user> <ammount>** Pay a user coins \n**%sbet <amount>** Bet coins on every server with MezzaBOT \n**%sbetting** Display the current bet in MezzaBOT \n**%sjackpot <amount>** chance to double coins **HIGH LOSS RATE** \n**%sdaily** Claim your daily reward every 12 Hours! \n \n**-level** Checks your current Level and EXP Points. \n \n**%soutchannel [#channel]** Select the channel that recieves Notifications \n**%sticketchannel [#channel]** Select the channel that recieves Tickets \n \n**-gitsearch <search>** Search for results on `GitHub`. \n**-google <search>** Search for results on `Google`. \n \n**%sping** Pings the bot!", prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix,prefix),
								author = {
									name = client.user.username,
									icon_url = client.user.avatarURL
								},
								--[[fields = { -- array of fields
									{
										name = "Field 1",
										value = "**-help** Opens this menu.",
										inline = true
									},
									{
										name = "Field 2",
										value = "This is some more information",
										inline = false
									}
								},
								footer = {
									text = "Created with Discordia"
								},]]
								color = 0x00ff00 -- hex color code
							}
							
						}
					message:reply('A list of commands were sent to your **DMS**')
					elseif cmd == 'diceroll' or cmd == 'dr' then
						
						message.channel:send(string.format(':game_die:  I rolled a ***%s!***',math.random(dicemin, dicemax)))
						
					--[[elseif string.sub(cmd,1,9) == 'dice min ' then
						
						print('dicemin')
						local num = string.sub(cmd,10)
						
						dicemin = num
						message.channel:send(string.format('Dice **MINIMUM** Now Set To ***%s!***', dicemin))
						
					elseif string.sub(cmd,1,9) == 'dice max ' then
						
						print('dicemax')
						local num = string.sub(cmd,10)
						
						dicemax = num
						message.channel:send(string.format('Dice **MAXIMUM** Now Set To ***%s!***', dicemax))
						]]
						
					elseif cmd == 'flipcoin' or cmd == 'fc' then
						local num = math.random(1,2)
						if num == 1 then
							message.channel:send(':dvd:  I flipped a **Coin** and it landed on ***Heads!***')
						else
							message.channel:send(':dvd:  I flipped a **Coin** and it landed on ***Tails!***')
						end
					elseif cmd == 'link' then
						message:reply {
							embed = {
								title = "***Add Bot To A Server***",
								author = {
									name = 'MezzaBOT',
									icon_url = client.user.avatarURL
								},
								description = "\n \n **Use This Link To Add MezzaBOT To A Server**\n \n **Link:** https://discordapp.com/oauth2/authorize?client_id=469362732534071297&scope=bot&permissions=2146958591",
								color = 0x00ff00 -- hex color code
							}
						}
					elseif string.sub(cmd,1,5) == 'echo ' then
						if message.member:hasPermission("administrator") then
							message:delete()
							message.channel:send(string.sub(cmd,6))
						else
							message.channel:send('No Permissions for that command, '..message.member.name)
						end
					elseif cmd == 'roles' then
						if message.guild ~= nil then
							local str = '\n'
							for _,v in pairs(message.guild.roles) do
								--print(v)
								--print(message.guild:getRole(v).name)
								if message.guild:getRole(v).name ~= '@everyone' then
									str = str .. '**' .. message.guild:getRole(v).name .. '**' .. '\n'
								else
									str = str .. 'everyone\n'
								end
								--message.channel:send(message.guild:getRole(v).name)
							end
							message:reply {
								embed = {
									title = "***Server Role List***",
									description = str,
									color = 0x00ff00 -- hex color code
								}
							}
						end
					elseif string.sub(cmd,1,11) == 'clrchannel ' or string.sub(cmd,1,4) == 'clc ' then
						if #args == 2 then
							if message.member:hasPermission("manageMessages") then
								message:delete()
								for _,v in pairs(message.channel:getMessages(args[2])) do
									v:delete()
								end
							else
								message.channel:send('No Permissions for that command, '..message.member.name)
							end
						end
					elseif string.sub(cmd,1,9) == 'downtime ' then
						if message.member.name == 'MezzaDev' then
							for _,v in pairs(client.guilds) do
								local writable = v.textChannels:toArray('position', function(c)
									return v.me:hasPermission(c, 'sendMessages')
								end)[1]
								
								if loadData(mezzaBotSettings)[message.guild.id] ~= nil then
									writable = message.guild:getChannel(loadData(mezzaBotSettings)[message.guild.id]["outchannel"])
								end
								
								writable:send {
									embed = {
										title = "***Sceduled Downtime***",
										author = {
											name = message.member.name,
											icon_url = message.member.avatarURL
										},
										description = string.format("\n \n There Will Be ***Downtime*** As Sceduled. Details *Below* \n \n **Details: %s**", string.sub(cmd,10)),
										color = 0xff0000 -- hex color code
									}
								}
							end
						else
							message.channel:send('No Permissions for that command, '..message.member.name)
						end
					elseif string.sub(cmd,1,11) == 'gbroadcast ' then
						if message.member.name == 'MezzaDev' then
							for _,v in pairs(client.guilds) do
								local writable = v.textChannels:toArray('position', function(c)
									return v.me:hasPermission(c, 'sendMessages')
								end)[1]
								
								if loadData(mezzaBotSettings)[message.guild.id] ~= nil then
									writable = message.guild:getChannel(loadData(mezzaBotSettings)[message.guild.id]["outchannel"])
								else
									print('Nope, you havent set an out channel '..message.guild.name)
								end
								
								if #message.guild.members < 30 then
									if v.name ~= "Discord Bots" then
										writable:send {
											embed = {
												title = "**Global Broadcast**",
												author = {
													name = message.member.name,
													icon_url = message.member.user.avatarURL
												},
												description = string.format("\n \n **Message: ** \n \n %s",string.sub(cmd,12)),
												color = 0x00ff00 -- hex color code
											}
										}
									end
								end
							end
						else
							message.channel:send('No Permissions for that command, '..message.member.name)
						end
					elseif string.sub(cmd,1,7) == "prefix " or string.sub(cmd,1,10) == 'mB/prefix ' then
						if message.member:hasPermission("administrator") then
							local setPre = args[2]
							if string.len(setPre) > 0 and setPre ~= " " and setPre ~= nil then
								local file = io.open(mezzaBotPrefixes, 'r')
								local jsonlines = {}
								for line in io.lines(mezzaBotPrefixes) do --print(line) print(json.decode(line)) 
									table.insert(jsonlines, line)
								end
								local filestr = table.concat(jsonlines, "\n")
								local dec = json.decode(filestr)
								dec[message.guild.name] = tostring(setPre)
								local enc = json.encode(dec)
								--print(enc)
								file:close()	
								local file = io.open(mezzaBotPrefixes, 'w+')
								file:write(enc)
								file:close()	
								message.channel:send {
									embed = {
										title = "**Prefix Updated.**",
										author = {
											name = client.user.name,
											icon_url = client.user.avatarURL
										},
										description = string.format("\n \n Your prefix has now been set to `%s`. \n Run `%shelp` for a list of commands.", setPre, setPre),
										color = 0x00ff00 -- hex color code
									}
								}
							end					
						end
					elseif cmd == "baltop" or cmd == "balancetop" then
						topPlrs = {{["Bal"]=0,["Plr"]=nil},{["Bal"]=0,["Plr"]=nil},{["Bal"]=0,["Plr"]=nil},{["Bal"]=0,["Plr"]=nil},{["Bal"]=0,["Plr"]=nil},{["Bal"]=0,["Plr"]=nil},{["Bal"]=0,["Plr"]=nil},{["Bal"]=0,["Plr"]=nil},{["Bal"]=0,["Plr"]=nil},{["Bal"]=0,["Plr"]=nil}}
						for u,v in pairs(loadData(mezzaBotData)) do
							for j,k in pairs(topPlrs) do
								if v > k["Bal"] then
									k["Bal"] = v
									k["Plr"] = u
									if j-1 > 0 then
										topPlrs[j-1]["Bal"] = 0
										topPlrs[j-1]["Plr"] = "No One"
									end
								end
							end
						end
						message.channel:send(string.format("**%s,** The Top player balances at the current time are: \n \n  ` %s ` at ` %s Coins ` \n  ` %s ` at ` %s Coins `\n  ` %s ` at ` %s Coins `\n  ` %s ` at ` %s Coins `\n  ` %s ` at ` %s Coins `\n  ` %s ` at ` %s Coins `\n  ` %s ` at ` %s Coins `\n  ` %s ` at ` %s Coins `\n  ` %s ` at ` %s Coins `\n  ` %s ` at ` %s Coins `", message.member.user.fullname, topPlrs[10]["Plr"], topPlrs[10]["Bal"], topPlrs[9]["Plr"], topPlrs[9]["Bal"], topPlrs[8]["Plr"], topPlrs[8]["Bal"], topPlrs[7]["Plr"], topPlrs[7]["Bal"], topPlrs[6]["Plr"], topPlrs[6]["Bal"], topPlrs[5]["Plr"], topPlrs[5]["Bal"], topPlrs[4]["Plr"], topPlrs[4]["Bal"], topPlrs[3]["Plr"], topPlrs[3]["Bal"], topPlrs[2]["Plr"], topPlrs[2]["Bal"], topPlrs[1]["Plr"], topPlrs[1]["Bal"]))
					elseif string.sub(cmd,1,3) == "bal" or string.sub(cmd,1,9) == "balance" then
						if #args == 1 then
							print('Balance Called')
							local file = io.open(mezzaBotData, 'r')
							local jsonlines = {}
							for line in io.lines(mezzaBotData) do --print(line) print(json.decode(line)) 
								table.insert(jsonlines, line)
							end
							local filestr = table.concat(jsonlines, "\n")
							local dec = json.decode(filestr)
							if dec[message.member.user.fullname] == nil then
								dec[message.member.user.fullname] = 0
							end
							message.channel:send(string.format('You Have ***%s***   **Coins!**', dec[message.member.user.fullname]))
							file:close()
						elseif #args == 2 then
							local user = message.mentionedUsers
							if user ~= nil then
								for _,v in pairs(user) do
									print('Balance of '..v.fullname)
									local data = loadData(mezzaBotData)[v.fullname]
									if data == nil then
										data = 0
									end
									message.channel:send(string.format('%s Has ***%s***   **Coins!**', v.fullname, data))
								end
							end
						end
					elseif string.sub(cmd,1,4) == "pay " then
						local pUsers = args[2]
						local pAmt = args[3]
						
						if tonumber(pAmt) >= 5 then
							local loadedData = loadData(mezzaBotData)
							if pUsers and pAmt then
								if loadedData[message.member.user.fullname] == nil then
									return false
								end
								if loadedData[message.member.user.fullname] >= tonumber(pAmt) then
									local pUsrs = message.mentionedUsers
									if #pUsrs == 1 and #args == 3 then
										for _,v in pairs(pUsrs) do
											--print(v)
											for _,j in pairs(v.mutualGuilds) do
												--print('Iter')
												--print(type(j))
												--print(j)
												if j.name == message.guild.name then
													--print(j.name..' Is the guild kicked from')
													for _,k in pairs(j.members) do
														print(k.name)
														print(v.name)
														if k.name == v.name then
															print('Paying' .. k.name)
															if loadedData[k.user.fullname] == nil then
																loadedData[k.user.fullname] = 0
															end
															loadedData[message.member.user.fullname] = loadedData[message.member.user.fullname] - pAmt
															loadedData[k.user.fullname] = loadedData[k.user.fullname] + pAmt
															local enc = json.encode(loadedData)
															file = io.open(mezzaBotData,'w+')
															file:write(enc)
															file:close()
															k.user:send(string.format('**%s** Just sent you ***%s***  **Coins!**',message.member.name,pAmt))
															message.member.user:send(string.format('You just sent **%s** ***%s***  **Coins!**',k.name,pAmt))
														end
													end
												end
											end
										end
									end
								end
							end
						else
							message.channel:send('Sorry, You must pay more than `5 Coins`.')
						end
					elseif string.sub(cmd,1,5) == "kick " then
						if message.member:hasPermission("kickMembers") then
						
							local kUsrs = args[2]
							local kRsn = string.sub(cmd,string.len(kUsrs)+6)
							
							print(string.format('***%s***',kRsn))
						
							local kUsers = message.mentionedUsers
							for _,v in pairs(kUsers) do
								--print(v)
								for _,j in pairs(v.mutualGuilds) do
									--print('Iter')
									--print(type(j))
									--print(j)
									if j.name == message.guild.name then
										--print(j.name..' Is the guild kicked from')
										for _,k in pairs(j.members) do
											print(k.name)
											print(v.name)
											if k.name == v.name then
												print(k.name)
												k:kick(string.format('Kicked from server '..message.guild.name..' by '..message.member.name..'. \n**Reason: ** \n%s',kRsn))
												message.member.user:send(string.format('Successfully kicked **%s** from the server.',k.name))
											end
										end
									end
								end
							end
						end
					
					elseif string.sub(cmd,1,4) == "ban " then
						if message.member:hasPermission("banMembers") then
						
							local bUsrs = args[2]
							local bRsn = string.sub(cmd,string.len(bUsrs)+5)
							
							print(string.format('***%s***',bRsn))
						
							local bUsers = message.mentionedUsers
							for _,v in pairs(bUsers) do
								--print(v)
								for _,j in pairs(v.mutualGuilds) do
									--print('Iter')
									--print(type(j))
									--print(j)
									if j.name == message.guild.name then
										--print(j.name..' Is the guild kicked from')
										for _,k in pairs(j.members) do
											print(k.name)
											print(v.name)
											if k.name == v.name then
												print(k.name)
												k:ban(string.format('Banned from server '..message.guild.name..' by '..message.member.name..'. \n**Reason: ** \n%s',bRsn))
												message.member.user:send(string.format('Successfully banned **%s** from the server.',k.name))
											end
										end
									end
								end
							end
						end
					elseif string.sub(cmd,1,4) == "bet " then
						if #args == 2 then
							local betAmt = args[2]
							print(string.format('***%s Is betting %s Coins globally.***',message.member.name,betAmt))
							
							local bNum = math.random(1,10)
							
							print(type(loadData(mezzaBotData)[message.member.user.fullname]))
							print(type(betAmt))
							
							if tonumber(betAmt) ~= nil then
							
								if tonumber(betAmt) >= 5 then
								
									if loadData(mezzaBotData)[message.member.user.fullname] ~= nil then
									
										if tonumber(betAmt) ~= nil then
									
											if loadData(mezzaBotData)[message.member.user.fullname] >= tonumber(betAmt) then
											
												if bet[1]["Player"] ~= message.member.user.fullname then
												
													message.channel:send {
														embed = {
															--title = string.format("**You have now bet `%s` **Coins** globally. `Finding Match`  :white_circle: :white_circle: :white_circle:**",betAmt),
															author = {
																name = message.member.name,
																icon_url = message.member.user.avatarURL
															},
															description = string.format("**You have now bet `%s` **Coins** globally. `Finding Match`  :white_circle: :white_circle: :white_circle:** \nYour `Number` has been chosen.",betAmt),
															color = 0x00ff00 -- hex color code
														}
													}
												
												end
												
												if bet[1]["Player"] == nil then
													bet[1]["Player"] = message.member.user.fullname
													bet[1]["Bet"] = tonumber(betAmt)
													bet[1]["Num"] = bNum
													bet[1]["Channel"] = message.channel
													print("You Are Player 1")
												elseif bet[2]["Player"] == nil and bet[1]["Player"] ~= message.member.user.fullname then
													bet[2]["Player"] = message.member.user.fullname
													bet[2]["Bet"] = tonumber(betAmt)
													bet[2]["Num"] = bNum
													print("You Are Player 2")
													
													local data = loadData(mezzaBotData)
													
													if data[bet[1]["Player"]] == nil then
														data[bet[1]["Player"]] = 0
													end
													if data[bet[2]["Player"]] == nil then
														data[bet[2]["Player"]] = 0
													end
													
													if loadData(mezzaBotData)[message.member.user.fullname] >= tonumber(betAmt) and loadData(mezzaBotData)[bet[1]["Player"]] >= tonumber(bet[1]["Bet"]) then
													
														print(bet[1]["Bet"])
														if bet[1]["Num"] <= bet[2]["Num"] then
															print("Winner Is Player 2")
															message.channel:send(string.format("`%s` Won the Bet! \n**%s's Number:  **`%s`        *%s's Number:  **`%s` \n`%s` Won %s **Coins**        `%s` Lost %s **Coins**", message.member.user.fullname, bet[1]["Player"], bet[1]["Num"], message.member.user.fullname, bNum, message.member.user.fullname, betAmt, bet[1]["Player"], tostring(bet[1]["Bet"])))
															if bet[1]["Channel"] ~= message.channel then
																bet[1]["Channel"]:send(string.format("`%s` Won the Bet! \n**%s's Number:  **`%s`        *%s's Number:  **`%s` \n`%s` Won %s **Coins**        `%s` Lost %s **Coins**", message.member.user.fullname, bet[1]["Player"], bet[1]["Num"], message.member.user.fullname, bNum, message.member.user.fullname, betAmt, bet[1]["Player"], tostring(bet[1]["Bet"])))
															end
															data[bet[1]["Player"]] = data[bet[1]["Player"]] - bet[1]["Bet"]
															data[bet[2]["Player"]] = data[bet[2]["Player"]] + bet[2]["Bet"]
														elseif bet[1]["Num"] >= bet[2]["Num"] then
															print("Winner Is Player 1")
															message.channel:send(string.format("`%s` Won the Bet! \n**%s's Number:  **`%s`        **%s's Number:  **`%s` \n`%s` Lost %s **Coins**        `%s` Won %s **Coins**", bet[1]["Player"], bet[1]["Player"], bet[1]["Num"], message.member.user.fullname, bNum, message.member.user.fullname, betAmt, bet[1]["Player"], tostring(bet[1]["Bet"])))
															if bet[1]["Channel"] ~= message.channel then
																bet[1]["Channel"]:send(string.format("`%s` Won the Bet! \n**%s's Number:  **`%s`        **%s's Number:  **`%s` \n`%s` Lost %s **Coins**        `%s` Won %s **Coins**", bet[1]["Player"], bet[1]["Player"], bet[1]["Num"], message.member.user.fullname, bNum, message.member.user.fullname, betAmt, bet[1]["Player"], tostring(bet[1]["Bet"])))
															end
															data[bet[1]["Player"]] = data[bet[1]["Player"]] + bet[1]["Bet"]
															data[bet[2]["Player"]] = data[bet[2]["Player"]] - bet[2]["Bet"]
														elseif bet[1]["Num"] == bet[2]["Num"] then
															print("Draw Of Bets")
															message.channel:send('**DRAW!** NoOne Won the Bet!')
															if bet[1]["Channel"] ~= message.channel then
																bet[1]["Channel"]:send('**DRAW!** NoOne Won the Bet!')
															end
														end
													end
													
													bet[1]["Player"] = nil
													bet[1]["Num"] = 0
													bet[1]["Bet"] = 0
													bet[1]["Channel"] = nil
													
													bet[2]["Player"] = nil
													bet[2]["Num"] = 0
													bet[2]["Bet"] = 0
													
													local enc = json.encode(data)
													file = io.open(mezzaBotData,'w+')
													file:write(enc)
													file:close()
												else
													print('ERRRR')
												end
											end
										end
									end
								else
									message.channel:send('Sorry, Bet must be more than `5 Coins`.')
								end
							else
								message.channel:send('Invalid bet Amount. Bet must be more than `5 Coins`.')
							end
						else
							message.channel:send('Invalid number of ***Arguments***, %s. Try %sbet <ammount>', message.member.name, prefix)
						end
					elseif string.sub(cmd,1,7) == "betting" then
						if bet[1]["Player"] ~= nil then
							message.channel:send {
								embed = {
									title = "**Current bet**",
									author = {
										name = bet[1]["Player"],
										icon_url = client.user.avatarURL
									},
									description = string.format('Currently, `%s` is betting ***%s***  **Coins!**', bet[1]["Player"], bet[1]["Bet"]),
									color = 0x00ff00 -- hex color code
								}
							}
						else
							message.channel:send(string.format('*Sorry,* `%s`. Currently, **No-one** has a bet up.', message.member.name))
						end
					elseif string.sub(cmd,1,10) == "outchannel" or string.sub(cmd,1,5) == "outch" then
						if message.member:hasPermission('manageChannels') then
							if tonumber(#args) == 2 then
								print('Args Are 2')
								local channel = message.mentionedChannels
								
								print(#channel)
								if #channel > 0 then
									for _,v in pairs(channel) do
										print(v.name)
										v:send(string.format('`#%s` Is now recieving all `Staff Notifications` and `Outputs`.', v.name))
										if v ~= message.channel then
											message.channel:send(string.format('`#%s` Is now recieving all `Staff Notifications` and `Outputs`.', v.name))
										end
										local loadedData = loadData(mezzaBotSettings)
										loadedData[message.guild.id] = {} -- make this define message.guild.id first knowing that how will i define it if its just a number refer to MezzaBotSettings
										loadedData[message.guild.id]["outchannel"] = v.id
										local enc = json.encode(loadedData)
										file = io.open(mezzaBotSettings,'w+')
										file:write(enc)
										file:close()
										--print('Written!')
									end
								else
									message.channel:send('Invalid `channel`. try `-outchannel <#channel-name>`')
								end
							elseif #args == 1 then
								message.channel:send(string.format('`#%s` Is now recieving all `Staff Notifications` and `Outputs`.', message.channel.name))
								local loadedData = loadData(mezzaBotSettings)
								loadedData[message.guild.id] = {}
								loadedData[message.guild.id]["outchannel"] = message.channel.id
								local enc = json.encode(loadedData)
								file = io.open(mezzaBotSettings,'w+')
								file:write(enc)
								file:close()
							elseif #args > 2 then
								message.channel:send('Invalid number of `Arguments`. try `-outchannel <#channel-name>`')
							end
						else
							message.channel:send('Invalid permissions. You need `MANAGE_CHANNELS` to run this command.')
						end
					elseif string.sub(cmd,1,8) == "jackpot " or string.sub(cmd,1,3) == "jp " then
						if #args == 2 then
							local jAmt = args[2]
							if tonumber(jAmt) ~= nil then
								jAmt = tonumber(jAmt)
								if jAmt >= 5 then
									if loadData(mezzaBotData)[message.member.user.fullname] ~= nil then
										if loadData(mezzaBotData)[message.member.user.fullname] >= jAmt then
											-- Passed all tests
											local slot = {0, 0, 0}
											local reward = 0
											
											for i = 1,3,1 do
												slot[i] = math.random(1,6)
												if slot[i] == 1 then
													slot[i] = ':apple:'
												elseif slot[i] == 2 then
													slot[i] = ':pear:'
												elseif slot[i] == 3 then
													slot[i] = ':green_apple:'
												elseif slot[i] == 4 then
													slot[i] = ':peach:'
												elseif slot[i] == 5 then
													slot[i] = ':cherries:'
												else
													slot[i] = ':watermelon:'
												end
											end
											
											if slot[1] == slot[2] and slot[2] == slot[3] and slot[3] == slot[1] then
												reward = 2.5
												--print('3 In A Row')
											elseif slot[1] == slot[2] then
												reward = 1.5
												--print('1 and 2 In A Row')
											elseif slot[2] == slot[3] then
												reward = 1.5
												--print('2 and 3 In A Row')
											elseif slot[3] == slot[1] then
												reward = 1.5
												--print('1 and 3 In A Row')
											else
												reward = -1
												--print('No Commons.')
											end
											
											print(reward)
											
											local loadedData = loadData(mezzaBotData)
											loadedData[message.member.user.fullname] = loadedData[message.member.user.fullname] + math.ceil(jAmt * reward)
											local enc = json.encode(loadedData)
											local file = io.open(mezzaBotData,'w+')
											file:write(enc)
											file:close()
											
											message.channel:send {
												embed = {
													title = "**Jackpot Results!**",
													author = {
														name = message.member.name,
														icon_url = message.member.user.avatarURL
													},
													description = string.format('`%s` bet ***%s***  **Coins** \n          **Results**          \n    %s  %s  %s\n \n***%s***  **Coins**', message.member.name, jAmt, slot[1],slot[2],slot[3], math.ceil(jAmt * reward)),
													color = 0x00ff00 -- hex color code
												}
											}
										end
									end
								end
							else
								message.channel:send("Invalid `Jackpot Ammount`. Try -jackpot <ammount>")
							end
						elseif #args > 2 then
							message.channel:send("Invalid number of `Arguments`. Try -jackpot <ammount>")
						elseif #args < 2 then
							message.channel:send("Invalid `Jackpot Ammount`. Try -jackpot <ammount>")
						end
					elseif string.sub(cmd,1,5) == "level" or string.sub(cmd,1,3) == "lvl" then
						message.channel:send(string.format('`%s`, Your current level is ` %s ` and EXP is ` %s / %s `.',message.member.user.fullname,loadData(levelData)[message.author.id]["Level"],loadData(levelData)[message.author.id]["EXP"],(loadData(levelData)[message.author.id]["Level"] * 10) * loadData(levelData)[message.author.id]["Level"]))
					elseif cmd == "daily" then
						local loadedData = loadData(plrData)
						local loadedBal = loadData(mezzaBotData)
						
						if loadedData[message.author.id] == nil then
							loadedData[message.author.id] = {}
							loadedData[message.author.id]["Daily"] = os.time() - 1
							loadedData[message.author.id]["Collected"] = 1
						end
						if loadedBal[message.member.user.fullname] == nil then
							loadedBal[message.member.user.fullname] = 0
						end
						local coinRwd = 250 + (loadedData[message.author.id]["Collected"] * 10)
						if os.time() >= loadedData[message.author.id]["Daily"] then
							loadedData[message.author.id]["Daily"] = os.time() + 43200
							message.channel:send(string.format("Congrats, ` %s `! You just recieved `%s Coins` as your Daily Reward!", message.member.user.fullname, coinRwd))
							loadedBal[message.member.user.fullname] = loadedBal[message.member.user.fullname] + coinRwd
							loadedData[message.author.id]["Collected"] = loadedData[message.author.id]["Collected"] + 1
						else
							local timeLeft = math.ceil((loadedData[message.author.id]["Daily"] - os.time()) / 3600)
							local minsLeft = tonumber(string.sub(tostring(100 * math.ceil((loadedData[message.author.id]["Daily"] - os.time()) / 3600)),3)) / 60
							message.channel:send(string.format("Sorry, ` %s `! You are not yet able to claim your `%s Coins` Daily Reward! \nCome back in ` %s ` Hours!", message.member.user.fullname, coinRwd, timeLeft))
						end
						local encPlr = json.encode(loadedData)
						local encData = json.encode(loadedBal)
						
						local file = io.open(plrData, 'w+')
						file:write(encPlr)
						file:close()
						
						local file = io.open(mezzaBotData, 'w+')
						file:write(encData)
						file:close()
					elseif string.sub(cmd,1,5) == "8ball" then
						if #args >= 2 then
							local option = options[math.random(1,#options)]
							message.channel:send(string.format(' :8ball:  **%s**, The 8Ball says `%s`',message.member.user.fullname,option))
						else
							message.channel:send(' :8ball:  Say something to the 8Ball! `-8ball <question>`')
						end
					elseif string.sub(cmd,1,13) == "ticketchannel" or string.sub(cmd,1,7) == "tcktchl" then
						if message.member:hasPermission('manageChannels') then
							if tonumber(#args) == 2 then
								print('Args Are 2')
								local channel = message.mentionedChannels
								
								print(#channel)
								if #channel > 0 then
									for _,v in pairs(channel) do
										print(v.name)
										v:send(string.format('`#%s` Is now recieving all `New Tickets` and `Ticket Edits`.', v.name))
										if v ~= message.channel then
											message.channel:send(string.format('`#%s` Is now recieving all `New Tickets` and `Ticket Edits`.', v.name))
										end
										local loadedData = loadData(mezzaBotSettings)
										loadedData[message.guild.id] = {} -- make this define message.guild.id first knowing that how will i define it if its just a number refer to MezzaBotSettings
										loadedData[message.guild.id]["ticketchannel"] = v.id
										local enc = json.encode(loadedData)
										file = io.open(mezzaBotSettings,'w+')
										file:write(enc)
										file:close()
										--print('Written!')
									end
								else
									message.channel:send('Invalid `channel`. try `-ticketchannel <#channel-name>`')
								end
							elseif #args == 1 then
								message.channel:send(string.format('`#%s` Is now recieving all `Staff Notifications` and `Outputs`.', message.channel.name))
								local loadedData = loadData(mezzaBotSettings)
								loadedData[message.guild.id] = {}
								loadedData[message.guild.id]["ticketchannel"] = message.channel.id
								local enc = json.encode(loadedData)
								file = io.open(mezzaBotSettings,'w+')
								file:write(enc)
								file:close()
							elseif #args > 2 then
								message.channel:send('Invalid number of `Arguments`. try `-ticketchannel <#channel-name>`')
							end
						else
							message.channel:send('Invalid permissions. You need `MANAGE_CHANNELS` to run this command.')
						end
					elseif string.sub(cmd,1,10) == "gitsearch " or string.sub(cmd,1,5) == "gits " then
						if #args >= 2 then
							local searchTags = string.sub(cmd,11)
							local searchUrl = "https://github.com/search?q="
							for i,v in pairs(args) do
								if i > 1 then
									if i >= #args then
										searchUrl = searchUrl .. v
									else
										searchUrl = searchUrl .. v .. "+"
									end
								end
							end
							message.channel:send(':mag_right:   I have searched **GitHub** And heres the link: \n \n' .. searchUrl)
						end
					elseif string.sub(cmd,1,7) == "google " then
						if #args >= 2 then
							local searchTags = string.sub(cmd,8)
							local searchUrl = "https://google.com/search?q="
							for i,v in pairs(args) do
								if i > 1 then
									if i >= #args then
										searchUrl = searchUrl .. v
									else
										searchUrl = searchUrl .. v .. "+"
									end
								end
							end
							message.channel:send(':mag_right:   I have searched **Google** And heres the link: \n \n' .. searchUrl)
						end
					--[[elseif string.sub(cmd,1,6) == "ticket" then
						if #args > 1 then
							if args[2] == "new" then
								if args[3] ~= nil then
									--local lChannels = loadData(MezzaBotSettings)
									--message.channel:send(string.format('%s, A new ticket was created! \n  **Ticket ID:**   `%s` \n  **Ticket Creator:**  `%s` \n  **Ticket Subject:** \n`%s`',message.member.user.fullname,1,message.member.user.fullname, string.sub(cmd,1,12)))
									--local loadedTChannels = loadData(MezzaBotSettings)
									--print(loadedTChannels[message.guild.id]["ticketchannel"])
									--if loadedTChannels[message.guild.id]["ticketchannel"] == nil then
										--message.channel:send(string.format('Sorry, A ticket channel is not set. Ask a member with `MANAGE_CHANNELS` can set one with `%sticketchannel <#channel>`',prefix))
										--return true
									--end	
									message.channel:send {
										embed = {
											title = "**New Ticket Created**",
											author = {
												name = client.user.name,
												icon_url = client.user.avatarURL
											},
											description = string.format('%s, A new ticket was created! \n  **Ticket ID:**   `%s` \n  **Ticket Creator:**  `%s` \n  **Ticket Subject:** \n`%s`',message.member.user.fullname,1,message.member.user.fullname, string.sub(cmd,12)),
											color = 0xffc300 -- hex color code
										}
									}
									message.guild:getChannel(loadedTChannels[message.guild.id]["ticketchannel"]):send {
										embed = {
											title = "**"..message.member.user.fullname.."'s Ticket**",
											author = {
												name = client.user.name,
												icon_url = client.user.avatarURL
											},
											description = string.format('**Ticket ID:**   `%s` \n  **Ticket Creator:**  `%s` \n  **Ticket Subject:** \n  `%s` \n \n  **Added Info:** \n  `%s`',1,message.member.user.fullname, string.sub(cmd,12),"None"),
											color = 0xffc300 -- hex color code
										}
									}
								end
							end
						end]]
					end
				elseif string.sub(message.content,1,10) == "mB-prefix " then
					if message.member:hasPermission("administrator") or message.member.user.fullname == "MezzaDev#5400" then
						local setPre = args[2]
						if string.len(setPre) > 0 and setPre ~= " " and setPre ~= nil then
							local file = io.open(mezzaBotPrefixes, 'r')
							local jsonlines = {}
							for line in io.lines(mezzaBotPrefixes) do --print(line) print(json.decode(line)) 
								table.insert(jsonlines, line)
							end
							local filestr = table.concat(jsonlines, "\n")
							local dec = json.decode(filestr)
							dec[message.guild.name] = tostring(setPre)
							local enc = json.encode(dec)
							--print(enc)
							file:close()	
							local file = io.open(mezzaBotPrefixes, 'w+')
							file:write(enc)
							file:close()	
							message.channel:send {
								embed = {
									title = "**Prefix Updated.**",
									author = {
										name = client.user.name,
										icon_url = client.user.avatarURL
									},
									description = string.format("\n \n Your prefix has now been set to `%s`. \n Run `%shelp` for a list of commands.", setPre, setPre),
										color = 0x00ff00 -- hex color code
								}
							}
						end					
					end
				elseif message.mentionedUsers ~= nil then
					local msg = string.lower(message.content)
					for i,v in pairs(message.mentionedUsers) do
						if v.name == client.user.name then
							print("Mentioned MezzaBot")
							local words = {}
							for i,v in pairs(args) do
								words[string.lower(v)] = true
							end
							for _,v in pairs(prefs) do
								if string.sub(msg,1,1) == v or string.sub(msg,2,2) == v or string.sub(msg,1,3) == "pls" then
									return true
								end
							end
							if words["how"] == true and words["level"] == true then
								message.channel:send(chatOptions['level'])
							elseif words["how"] == true and words["coins"] == true then
								message.channel:send(chatOptions['coins'])
							elseif words["help"] == true or words["how"] == true and words["i"] or words["how"] and words['do'] or words["what"] == true and words["commands"] == true then
								message.channel:send(chatOptions['help'])
							elseif words["who"] == true and words["developed"] or words["who"] == true and words["developed"] == true and words["mezzabot"] == true or words["created"] == true and words["who"] == true or words["made"] and words["who"] then
								message.channel:send(chatOptions['dev'])
							elseif words["your"] == true and words["job"] or words["you"] == true and words["what"] == true and words["do"] == true or words["whats"] and words["job"] or words["what's"] and words["job"] then
								message.channel:send(chatOptions['job'])
							elseif words["what"] == true and words["library"] then
								message.channel:send(chatOptions['library'])
							elseif words["how"] == true and words["doing"] or words["how"] == true and words["are"] and words["you"] then
								message.channel:send(chatOptions['howami'])
							elseif words["bad"] == true or words["suck"] == true or words["sucks"] == true or words["worst"] == true or words["annoying"] or words["stinks"] == true or words["horrible"] == true or words["spam"] == true and words["lot"] == true or words["spam"] == true and words["alot"] == true or words["spam"] then
								message.channel:send(chatOptions['mean'])
							elseif words["im"] == true and words['ok'] == true or words["im"] == true and words["good"] == true or words["i"] == true and words["am"] == true and words["good"] == true or words["i"] == true and words["am"] == true and words["ok"] == true then
								message.channel:send(chatOptions['yourgood'])
							else
								message.channel:send("Sorry, I didn't get what you were saying. Let `MezzaDev#5400` know if you think I *really* should know this.")
							end
							return true
						end
					end
				end
			end
		end
	end
end)

client:run('Bot NDY5MzYyNzMyNTM0MDcxMjk3.DjGnvA.2gW3EJuFIhqTatTD542OrIYBr20')