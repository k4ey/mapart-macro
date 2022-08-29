local teleport = require 'teleport'
run("inventory.lua")
Restocker = {}
function Restocker:new()
    local restocker = {}
    setmetatable(restocker, self)
    self.__index = self
    return restocker
end

function Restocker:setFocus()
    --praise MajsterTynek for this 
    local Minecraft = luajava.bindClass("net.minecraft.client.Minecraft")
    local mc = Minecraft:func_71410_x() -- minecraft.getMinecraft()
    -- restoring game focus -- this is workaround due bug
    mc.field_71415_G = true -- mc.inGameHasFocus = true
end


function Restocker:checkSafe()
    local playerPos = {getPlayerBlockPos()}
    teleport(playerPos[1]+0.5,playerPos[2]+0.1,playerPos[3]+0.5) 
    local playerPos = {getPlayerBlockPos()}

    local block = getBlock(playerPos[1],playerPos[2],playerPos[3]+1)
    if block.name:find("Carpet") == nil then return false end
    return true
end

function Restocker:confirmPlaced(coords)
    local block = getBlock(coords[1],coords[2],coords[3])
    return block.name ~= "Air"
end

function Restocker:place(block,position)
    local playerPos = {getPlayerBlockPos()}
    Inventory:placeInHotbar(9,block)
    setHotbar(9)

    lookAt(table.unpack(position))

    sleep(500)
    use()
    sleep(100)
end


function Restocker:dig(position)
    Restocker:setFocus()
    while getBlock(table.unpack(position)).name ~= "Air" do 

        setHotbar(8) -- predefined pickaxe pos, make it changable thru config file one day
        sleep(100)

        lookAt(position[1]+0.5,position[2]+0.5,position[3]+0.5)
        sleep(100)
        attack(600)
        sleep(400)
    end
end


function Restocker:getEntity(partialName)
    local entities = getEntityList()

    local entity_id = 0

    for i,v in pairs(entities) do 
        if v.name:find(partialName) ~= nil then  entity_id = v.id break end
    end
    
    return getEntity(entity_id)
end
