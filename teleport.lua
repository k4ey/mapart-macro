local baseClass = "com.theincgi.advancedMacros.AdvancedMacros"
local minecraft = luajava.bindClass(baseClass):getMinecraft()

local teleport = function( x, y, z )
    -- minecraft.player.setPosition( x, y, z )
    minecraft.field_71439_g:func_70107_b( x, y, z )
end

return teleport
