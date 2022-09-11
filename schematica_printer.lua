Printer = {}
function Printer:new(logger,inventory,restocker,goals,config,resources)
    local config = config or {current=1}
    local distance_to_dest = 0
    local resources = resources or { -- move this thing to config file
        ["Light Gray Carpet"]={ amount=832,shulkerName="Light Gray Shulker Box"},
        ["Black Carpet"]={ amount=384,shulkerName="Black Shulker Box"},
    }
    local printer = {logger=logger,inventory=inventory,goals=goals,config=config,resources=resources,distance_to_dest=distance_to_dest,placingTime=100,forwardTime=100,restocker=restocker}
    setmetatable(printer, self)
    self.__index = self
    return printer
end

function Printer:start()
    self.logger:toggled_module("SCHEMATICA PRINTER",on)

    self.logger:info("starting!")

    self:setSettings() -- enables seppuku's nohunger and timer, not required
    sleep(500)
    self.logger:info("started!")

    for goalIndex=self.config.current ,#self.goals do
        if not on then return end

        for resource,info in pairs(self.resources) do
            self.logger:info(( "Checking amount of %s" ):format(resource),1)
            local resourceCount = self.inventory:calc(resource)
            self.logger:info(("current amount of %s : &c(&b%d&4/&b%d&c)"):format(resource,info.amount,resourceCount))
            if resourceCount < info.amount * 0.20 then  -- check if has enought resources
                self.logger:alert(("not enought %s"):format(resource),2)
                self.logger:info("restocking...")
                if not Inventory:find(info.shulkerName) then self.logger:fatal("no avaiable shulkers!")  break end -- add shulker restock. From premade stash at index 1 of goals? 

                local playerPos = {getPlayerBlockPos()}
                if not Restocker:checkSafe() then self.logger:fatal(" not safe, aborting ") break end
                repeat
                    self.logger:message("shulker is not placed!")
                    Restocker:place(info.shulkerName,{playerPos[1]+0.5,playerPos[2],playerPos[3]+1.5})
                    sleep(500)
                until Restocker:confirmPlaced({playerPos[1],playerPos[2]+1,playerPos[3]+1})
                self.logger:info("placed a shulker",1)
                Inventory:open({playerPos[1],playerPos[2]+1,playerPos[3]+1})
                self.logger:info("opened a shulker",1)

                Inventory:refill(resource,info.amount)
                self.logger:info("took carpets",1)
                Restocker:dig({playerPos[1],playerPos[2]+1,playerPos[3]+1})
                self.logger:info("mined shulker",1)

                while true do -- picks up the shulker
                    sleep(1000)
                    local shulker = Restocker:getEntity("shulkerBox")
                    if not shulker then  break end

                    if Inventory:calcEmptySlots() == 0 then self.logger:alert("NO EMPTY SLOTS! cleaning inv...") Inventory:stackUnstacked() end
                    if Inventory:calcEmptySlots() == 0 then self.logger:alert(" STILL NO EMPTY SLOTS!!, DROPPING UNWANTED ITEMS ") Inventory:dropUnused() end

                    self.logger:alert("Shulker is on the floor! picking it up!")
                    self:gotoCoords(math.floor(shulker["pos"][1]),math.floor(shulker["pos"][3]))
                end
                self.logger:info("shulker is in the Inventory!",1)
            end
        end
        self:setCurrent(goalIndex)
        local goalX = self.goals[self.config.current][1]
        local goalZ = self.goals[self.config.current][2]
        self:gotoCoords(goalX,goalZ)
    end
    self.logger:info("finished...")
    self:finish()
end
function Printer:setCurrent(current)
    self.logger:info(("changing the current goal to : &b%d"):format(current))
    self.config.current = current
end

function Printer:setForwardTime(time)
    self.logger:message(("changing the Forward time to : %d"):format(time))
    self.forwardTime = time
end

function Printer:setPlacingTime(time)
    self.logger:message(("changing the Placing time to : %d"):format(time))
    self.placingTime = time
end

function Printer:setSettings()
    self.logger:info("setting right settings...")
    say(".timer speed 4")
    say(".t timer")
    say(".t nohunger")
end

function Printer:speedSwitcher()
    local goal = self.goals[self.config.current]
    if self.distance_to_dest <=10 then
        sneak(self.placingTime+self.forwardTime+100)
    end
    if self.distance_to_dest == 1 then
        self:setPlacingTime(10)
        self:setForwardTime(50)
    elseif self.distance_to_dest <=3 then
        self:setPlacingTime(200)
        self:setForwardTime(100)
    elseif self.distance_to_dest <=5 then
        lookAt(goal[1]+0.5,1+0.5,goal[2]+0.5)
        self:setPlacingTime(200)
        self:setForwardTime(100)
    else
        lookAt(goal[1]+0.5,1+0.5,goal[2]+0.5)
        self:setForwardTime(100)
        self:setPlacingTime(0)
    end
end

function Printer:gotoCoords(goal_x,goal_z)
    local currentPos = {getPlayerBlockPos()}
    self.distance_to_dest = math.sqrt((currentPos[1] - goal_x)^2 + (currentPos[3] - goal_z)^2) -- calc the distance from current position to the goal

    lookAt(goal_x+0.5,1.5,goal_z+0.5)
    while true do -- always int
        if self.distance_to_dest == 0 then return end
        if on == false then self.logger:fatal("stopped while on the way to goal!!!!") sleep(500) self:stop() return end -- abort if toggled off

        self:speedSwitcher() -- adjust speed to distance from goal

        forward(self.forwardTime)
        sleep(self.forwardTime + self.placingTime) -- delay between each move. To let the printer catch up with the player.

        currentPos = {getPlayerBlockPos()}
        self.distance_to_dest = math.sqrt((currentPos[1] - goal_x)^2 + (currentPos[3] - goal_z)^2)
        self.logger:message(string.format("&4going from: &3 %d %d, &4to: &3 %d %d, distance left: &b %d",currentPos[1],currentPos[3],goal_x,goal_z,self.distance_to_dest))
    end
end

function Printer:finish()
    self:stop()
    self.logger:info("AT THE GOAL!!!!")
end

function Printer:stop()
    self.logger:toggled_module("SCHEMATICA PRINTER",on)
    self.logger:alert("stopping!")

    sneak(1)

    say(".timer speed 4.2")
    say(".t nohunger")
    say(".t timer")

    local configFile= io.open("config.json", "w")
    configFile:write(json.encode(self.config))
    configFile:close()

    on = false
end
