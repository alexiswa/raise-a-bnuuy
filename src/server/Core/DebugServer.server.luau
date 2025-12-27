--[[
	Script to handle debug utilities
]]


local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = game:GetService("ServerScriptService").Server.Modules

local Bunny = require(ReplicatedStorage.src.Modules.Bunny)
local Debug = require(ReplicatedStorage.src.Debug)
local Globals = require(ReplicatedStorage.src.Globals)
local Money = require(ReplicatedStorage.src.Modules.Money)
local pathfinding = require(Modules.Pathfinding)

-- i hate this function
local function CheckTrigger(plr, trigger, ...)
	local args = ...
	if trigger == "pause" then
		Debug.Pause = not Debug.Pause
	elseif trigger == "setHunger" then
		Bunny.SetHunger(args[1])
	elseif trigger == "setHappy" then
		Bunny.SetHappiness(args[1])
	elseif trigger == "forceWander" then
		pathfinding.BunnyWander()
	elseif trigger == "toggleDebug" then
		Globals.DEBUG_ENABLED = not Globals.DEBUG_ENABLED
	elseif trigger == "togglePathfinding" then
		Globals.PATHFINDING_VISUALIZATION = not Globals.PATHFINDING_VISUALIZATION
	elseif trigger == "setPathVisTime" then
		Globals.PATHFINDING_VISUALIZATION_TIME_TO_DISAPPEAR = args[1]
	elseif trigger == "setAnimSpeed" then
		Globals.BUNNY_SPEED = args[1]
	elseif trigger == "setNewMoney" then
		Money.SetCurrentMoney(args[1])
	elseif trigger == "clearDebugFolder" then
		for _, instance in Debug.Location:GetChildren() do
			instance:Destroy()
		end
	else
		plr:Kick(Globals.KICK_PLAYER_EXPLOITER_MESSAGE.."dbe.t.c") -- debug event type content
	end
end

local debugEvent: RemoteEvent = ReplicatedStorage.Events["debug_1181e04d-5d1b-44fb-8a8b-793b0282e205"]
debugEvent.OnServerEvent:Connect(function(plr, trigger, ...)
	local args = {...}
	if args[1] ~= nil then
		if type(args[1]) ~= "number" then
			plr:Kick(Globals.KICK_PLAYER_EXPLOITER_MESSAGE.."dbe.a.1.t") -- debug event args 1 type
		end
	end
	if type(trigger) ~= "string" then
		plr:Kick(Globals.KICK_PLAYER_EXPLOITER_MESSAGE.."dbe.t.ns") -- debug event type not string
	end

	CheckTrigger(plr, trigger, args)
end)