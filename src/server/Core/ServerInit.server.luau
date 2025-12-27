--[[
	Runs any initialization events that might need to be implemented.
	This will probably get larger over time.
]]
local startTime = os.clock()

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Debug = require(ReplicatedStorage.src.Debug)
local Globals = require(ReplicatedStorage.src.Globals)
local ShopUi = require(ReplicatedStorage.src.Modules.Shop.Shop)
local Money = require(ReplicatedStorage.src.Modules.Money)

print("Loading debug..")
Debug.InitializeDebugTools()
print("Debug loaded")

print("Adding server objects..")
Globals.BUNNY_MODEL.CanCollide = false
Globals.BUNNY_MOVEMENT_HUMANOID.WalkSpeed = Globals.BUNNY_SPEED

local SpawnedObjects = Instance.new("Folder")
SpawnedObjects.Name = "SpawnedObjects"
SpawnedObjects.Parent = game.Workspace
print("Objects added")

print("Waiting for client UI..")
ReplicatedStorage.Events.clientUiLoaded.OnServerEvent:Wait()
Money.SetCurrentMoney(Globals.STARTING_MONEY)
print("Client UI loaded")

print("Loading shop..")
ShopUi.init()

print("Server initialization complete in", os.clock() - startTime, "seconds")