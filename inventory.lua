Inventory = {}
local inv = openInventory()
function Inventory:new()
    local inventory = {}
    setmetatable(inventory, self)
    self.__index = self
    return inventory
end


function Inventory:open(chest)
    chest = chest or getPlayer().lookingAt
    for i=1,3 do chest[i] = chest[i]+0.5 end
    repeat 
        lookAt(table.unpack(chest))
        sleep(25)
        use()
        sleep(100)
    until inv.getTotalSlots() >= 63
    sleep(200)
end

function Inventory:calc(material)
    local totalSlots = inv.getTotalSlots()
    local inventoryAt = self:inventoryPositions(totalSlots)["ends"]
    local items = 0
    for i=inventoryAt+1,totalSlots do 
        local item = inv.getSlot(i)
        if item and item.name == material then
            items = items + item.amount
        end
    end
    return items
end
function Inventory:inventoryPositions(numOfSlots)
    local possible_inventories = {
        [63]={ ends=27, starts=1 },
        [90]={ ends=56, starts=1},
        [46]={ ends=9, starts=9}
    }
    return possible_inventories[numOfSlots]
end


function Inventory:refill(itemName,amount)
    local totalSlots = inv.getTotalSlots()

    if totalSlots == 46 then return end

    local chestEnds = self:inventoryPositions(totalSlots)["ends"]

    local item
    for i=1,chestEnds do 
        
        if self:calc(itemName) >= amount then inv.close() sleep(250) return true end
    

        item = inv.getSlot(i)
        if item and item.name == itemName then inv.quick(i) sleep(10) end
    end
    inv.close()
    return "NOT ENOUGH ITEMS IN CHEST" 
end

function Inventory:calcEmptySlots()
    local totalSlots = inv.getTotalSlots()
    local inventoryAt = Inventory:inventoryPositions(totalSlots)["ends"]
    
    local emptySlots = 0 
    for i=inventoryAt+1,totalSlots-1 do 
        local item = inv.getSlot(i)
        if not item then
            emptySlots = emptySlots + 1
        end
    end
    return emptySlots
end

function Inventory:stackUnstacked()
    local totalSlots = inv.getTotalSlots()
    local inventoryAt = Inventory:inventoryPositions(totalSlots)["ends"]
    local stackableItems= {
        ["minecraft:carpet"]=true -- move this to config file
    }
    
    local item
    for i=totalSlots-1,inventoryAt+1,-1 do 
        item = inv.getSlot(i)
        if item and stackableItems[item.id] then
            inv.quick(i)
            sleep(150)
        end
    end
end

function Inventory:dropUnused()
    local totalSlots = inv.getTotalSlots()
    local inventoryAt = Inventory:inventoryPositions(totalSlots)["ends"]
    local usedItems = { -- move this to config file
        ["minecraft:carpet"]=true, 
        ["minecraft:diamond_pickaxe"]=true,
        ["minecraft:lime_shulker_box"]=true,
        ["minecraft:pink_shulker_box"]=true,
        ["minecraft:gray_shulker_box"]=true,
        ["minecraft:silver_shulker_box"]=true,
        ["minecraft:cyan_shulker_box"]=true,
        ["minecraft:purple_shulker_box"]=true,
        ["minecraft:blue_shulker_box"]=true,
        ["minecraft:brown_shulker_box"]=true,
        ["minecraft:green_shulker_box"]=true,
        ["minecraft:red_shulker_box"]=true,
        ["minecraft:black_shulker_box"]=true,
    }
    
    local item
    for i=inventoryAt+1,totalSlots-1 do 
        item = inv.getSlot(i)
        if item and not usedItems[item.id] then
            inv.drop(i)
        end
    end
end

function Inventory:find(material)
    local totalSlots = inv.getTotalSlots()
    local inventoryAt = Inventory:inventoryPositions(totalSlots)["ends"]
    
    for i=inventoryAt+1,totalSlots do 
        local item = inv.getSlot(i)
        if item and item.name == material then
            local contents = item.nbt.tag.BlockEntityTag.Items
            if contents then return i end
        end
    end
    return false
end

function Inventory:placeInHotbar(pos,item)
    local itemPos = Inventory:find(item)
    pos = pos + 36
    if itemPos == pos then return end


    inv.click(itemPos) -- take the item
    sleep(250)
    inv.click(pos) -- swap it with desired slot
    sleep(250)
    inv.click(itemPos) -- put the swapped item in the pos of previous item.
end
