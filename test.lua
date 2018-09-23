
local path = './desktop/mezzabot/data/8BallData.json'

local json = require('json.lua')

function loadData(fileName)
	local jsonlines = {}
	for line in io.lines(fileName) do --print(line) print(json.decode(line)) 
		print(line)
		table.insert(jsonlines, line)
	end
	local filestr = table.concat(jsonlines, "\n")
	print(filestr)
	local dec = json.decode(filestr)
	for _,v in pairs(dec) do
		print(v)
	end

	return dec
end

local data = loadData(path)
for _,v in pairs(data) do
	print(v)
end

