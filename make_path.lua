-- creates a list of goals the bot will go to 
json = require 'json' 
hud3D.clearAll()
local x,y,z = getPlayerBlockPos()
local goals = {}

for relative_z=z, z+127,8 do 
    local good = {}
    for relative_x=x,x+127,4 do 
        good[#good+1] = {relative_x,relative_z}
    end

    local inverted = {}
    for relative_x=x,x+127,4 do 
        inverted[#inverted+1] = {relative_x,relative_z+4}
    end

    for i=1, #good do
        goals[#goals+1] = good[i]
    end
    for i=1,#inverted do 
        goals[#goals+1] = inverted[#inverted+1-i]
    end
end


for i=1,#goals do 
    local block = hud3D.newBlock(goals[i][1],y,goals[i][2])
    block.enableDraw()
end

file = io.open("coords.json", "w")
file:write(json.encode(goals))
file:close()
