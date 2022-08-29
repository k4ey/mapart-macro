on = not on or false
if not on then return end
json = require 'json'

run("log4l.lua") -- yes i am to stoopid to use require 
run("schematica_printer.lua")
run("inventory.lua")
run("shulker_restock.lua")


local coordsFile = io.open("coords.json", "r")
local goals = json.decode(coordsFile:read("*all"))
coordsFile:close()

local configFile= io.open("config.json", "r")
local config= json.decode(configFile:read("*all"))
configFile:close()

local logger = Logger:new("printer_log",0,false)
local inventory = Inventory:new()
local restocker = Restocker:new()
local printer = Printer:new(logger,inventory,restocker,goals,config)

printer:start()
