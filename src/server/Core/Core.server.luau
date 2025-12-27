--[[
	Core script which handles much of the games logic
	and routines. Primary content as of writing is mostly
	for heartbeats. 
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Modules = game:GetService("ServerScriptService").Server.Modules

local Bunny = require(ReplicatedStorage.src.Modules.Bunny)
local Debug = require(ReplicatedStorage.src.Debug)
local Globals = require(ReplicatedStorage.src.Globals)
local Pathfinding = require(Modules.Pathfinding)

local bunnyWanderTick = 0 -- counts the time since the bunny last wandered
local bunnyHungerTick = 0
local bunnyHappinessTick = 0
local currentDeviation = 0
local deviationNotSelected = true

---Heartbeat stuff-------------------------------------------------------------------------

local function CheckWanderTick(_bunnyWanderTick): number
    if _bunnyWanderTick < Globals.BUNNY_WANDER_COOLDOWN - Globals.BUNNY_WANDER_COOLDOWN_DEVIATION then
        return _bunnyWanderTick
    end

	-- only select the deviation once per wander-tick; 
	--selecting deviation every heartbeat makes deviations 
	-- on the lower-end significantly more likely
    if deviationNotSelected then
        -- generate a random number within the cooldown deviation
        local random = Random.new(os.time())
        currentDeviation = random:NextNumber(-Globals.BUNNY_WANDER_COOLDOWN_DEVIATION, Globals.BUNNY_WANDER_COOLDOWN_DEVIATION)
        deviationNotSelected = false
    end

    -- if bunny hasnt wandered for the cooldown +/- deviation, it shall wander
    if _bunnyWanderTick >= Globals.BUNNY_WANDER_COOLDOWN + currentDeviation then
        bunnyWanderTick  = 0
        _bunnyWanderTick = 0

        Pathfinding.BunnyWander()
        deviationNotSelected = true
    end
    return _bunnyWanderTick
end

local function CheckHungerTick(_bunnyHungerTick): number
    if _bunnyHungerTick >= Globals.BUNNY_HUNGER_LOSS_RATE then
        _bunnyHungerTick = 0
        bunnyHungerTick  = 0

        Bunny.Starve(1)
    end

    if Bunny.GetHunger() <= 0 then
        Players:FindFirstChildWhichIsA("Player"):Kick("Your bunny starved :(")
    end
    return _bunnyHungerTick
end

local function CheckHappinessTick(_bunnyHappinessTick): number
    if _bunnyHappinessTick >= Globals.BUNNY_HAPPINESS_LOSS_RATE then
        _bunnyHappinessTick = 0
        bunnyHappinessTick  = 0

        Bunny.Sad(1)
    end
    return _bunnyHappinessTick
end

-- send debug info to client so iris can show it and stuff
local function SendDebugInformation(deltaTime)
	ReplicatedStorage.Events.sendCoreInformation:FireAllClients(
		bunnyWanderTick, bunnyHungerTick, bunnyHappinessTick, deltaTime, currentDeviation)
end

local function Heartbeat(deltaTime)
    SendDebugInformation(deltaTime)
    -- skip doing this if its paused
    if Debug.Pause then
        return
    end

	-- Check each tick after adding deltaTime,
	-- then set each tick to the new tick (each function returns the input value)
    bunnyWanderTick     = CheckWanderTick(bunnyWanderTick + deltaTime)
    bunnyHungerTick     = CheckHungerTick(bunnyHungerTick + deltaTime)
    bunnyHappinessTick  = CheckHappinessTick(bunnyHappinessTick + deltaTime)
end

-- this runs every physics frame
RunService.Heartbeat:Connect(Heartbeat)
