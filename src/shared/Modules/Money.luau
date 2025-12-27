--[[
	Script to handle everything with money.
	Shop done seperately.

	Note: the only function here usable on the
	client-side is GetCurrentMoney(). Money 
	should only be set on the server
]]

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.src.Globals)
local Bunny = require(ReplicatedStorage.src.Modules.Bunny)
local Money = {}

local moneyEvent: RemoteEvent = ReplicatedStorage.Events.setClientMoneyDisplayThing
local _currentMoney: number = Globals.STARTING_MONEY


-- handle getting and setting money
-- we use getters and setters, because every time money is set,
-- we need to update the client's ui

-- get players money
function Money.GetCurrentMoney(): number
	return _currentMoney
end

function Money.SetCurrentMoney(newValue: number): number
	if RunService:IsClient() then
		error("Cannot drop money from client.", 5)
	end

	_currentMoney = newValue
	moneyEvent:FireAllClients(_currentMoney)
	return _currentMoney
end

function Money.AddMoney(moneyToAdd: number): number
	return Money.SetCurrentMoney(_currentMoney + moneyToAdd)
end

function Money.RemoveMoney(moneyToRemove: number): number
	return Money.AddMoney(-moneyToRemove)
end

-------------------------------------
--vv handle dropping and spawning money vv

local function OnMoneyTouched(droppedMoney)
	task.wait(0.5) -- not necessary, stylistic choice
	-- get variation
	local random = Random.new(os.time())
	local variation = random:NextInteger(-Globals.DROPPED_MONEY_VALUE_RANGE, Globals.DROPPED_MONEY_VALUE_RANGE)

	 -- money is proportional to bunny happiness
	droppedMoney:Destroy()
	Money.AddMoney((Globals.DROPPED_MONEY_DEFAULT_VALUE + variation))
end

local function SpawnMoney(position: Vector3): Part
	-- dont let money work if bunny is sad
	if Bunny.GetHappiness() <= 50 then
		return
	end
	position = position or Globals.BUNNY_MODEL.Parent.MoneySpawnPoint.position
	local spawnedMoney: Part = ServerStorage.money:Clone()
	spawnedMoney.Position = position
	spawnedMoney.Parent = workspace.SpawnedObjects
	Debris:AddItem(spawnedMoney, 60)
	return spawnedMoney
end

-- drop a piece of money to be picked up by a player
function Money.Drop()
	if RunService:IsClient() then
		error("Cannot drop money from client.", 5)
	end
	
	-- drop money
	local droppedMoney = SpawnMoney()
	local debounce = false

	droppedMoney.Touched:Connect(function(otherPart)
		if not Players:GetPlayerFromCharacter(otherPart.Parent) or debounce == true then
			return
		end

		debounce = true
		OnMoneyTouched(droppedMoney)
		debounce = false
	end)
end	

return Money