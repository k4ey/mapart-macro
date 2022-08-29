-- this thing is bad and requires a rework. Maybe one day...
Logger = {} 
function Logger:new(name,priority,sound)
    name = name or ""
    priority = priority or 0
    sound = sound or false
  logger = {
      name = name,
      priority = priority,
      sound = sound
  } 
  setmetatable(logger, self)
  self.__index = self
  return logger
end

function Logger:playSound(sound)
    local sound = playSound(sound)
    sound.setVolume(1)
    sound.play()
end

function Logger:setPriority(v)
    self.priority = v
end

function Logger:enableSound(v)
    self.sound= v
end

function Logger:setName(name)
    self.name = name
end

function Logger:log(message,priority,type)
    if self.priority > priority then
        return
    end
    message = message or ""
    type = type or "MESSAGE"
    types = {
        MESSAGE="&3",
        INFO="&b",
        ALERT="&c",
        FATAL="&4"
    }
    message = types[type]..message
    type = types[type]..type

    log(("&e %s &7: %s &7: %s"):format(self.name,type,message))
    if self.sound then
        Logger:playSound("pop.wav")
    end
end

function Logger:info(message,priority)
    priority = priority or 2 
    if self.priority >= priority then 
        return
    end
    log(("&e %s &7: &b INFO  &7: &3%s"):format(self.name,message))
    if self.sound then
        Logger:playSound("pop.wav")
    end
end

function Logger:alert(message)
    if self.priority >= 3 then 
        return
    end
    log(("&e %s &7: &c ALERT &7: &c%s"):format(self.name,message))
    if self.sound then
        Logger:playSound("pop.wav")
    end
end

function Logger:fatal(message)
    if self.priority >= 4 then 
        return
    end
    log(("&e %s &7: &4 FATAL &7: &4%s"):format(self.name,message))
    if self.sound then
        Logger:playSound("pop.wav")
    end
end

function Logger:message(message,priority)
    priority = priority or 1
    if self.priority >= priority then 
        return
    end
    log(("&e %s &7: &8%s"):format(self.name,message))
end

function Logger:toggled_module(name, state)
    if self.priority >= 10 then 
        return
    end

    local message = ""
    if state then message = "&aON" else message="&cOFF" end
        log("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
    log("&8======&4 AM SCRIPT BY K4EY &8=======")
    log(("           &e %s &7 |  &8 %s"):format(name,message))
    log("&8============&ENJOY=============")
    if self.sound then
        Logger:playSound("pop.wav")
    end
end
