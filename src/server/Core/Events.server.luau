--[[
	This script handles most events, whether its remote events,
	proximity prompts, etc. Might split this up later if we end
	up having a lot of events.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Modules = ReplicatedStorage.src.Modules

local Money = require(ReplicatedStorage.src.Modules.Money)
local Globals = require(ReplicatedStorage.src.Globals)
local Bunny = require(Modules.Bunny)
local Shop = require(Modules.Shop.Shop)

-- money dropped function
local dropMoneyRemoteFunc: RemoteEvent = ReplicatedStorage.Events.dropMoney
dropMoneyRemoteFunc.OnServerEvent:Connect(Money.Drop)

-- handle proximity prompts ---------------------------------------------------------------
local function FillBowl(plr: Player)
	if Globals.FoodAvailable == true then
		return
	end

	local foodTool: Tool
	for _, tool in plr.Backpack:GetChildren() do
		if CollectionService:HasTag(tool, "FoodItem") then
			foodTool = tool
			break
		end
	end
	if not foodTool then return end
	foodTool:Destroy()
	Globals.FoodAvailable = true
	Globals.FOOD_ITEM:PivotTo(CFrame.new(Globals.FOOD_ITEM.WorldPivot.Position.X, 0.65, Globals.FOOD_ITEM.WorldPivot.Position.Z))
end

Globals.FOOD_BOWL.fillBowlPrompt.giveFood.Triggered:Connect(function(plr)
	FillBowl(plr)
end)

Globals.BUNNY_MODEL.petBunny.Triggered:Connect(function()
	Bunny.Happy(25)
end)

Globals.POOP_BOX.poopboxprompt.cleanPoop.Triggered:Connect(function()  
	if Globals.POOP_BOX.Decal.Transparency == 1 then
		return
	end

	Globals.POOP_BOX.Decal.Transparency = 1
	Money.AddMoney(15)
end)

-- shop
ReplicatedStorage.Events.ItemPurchased.OnServerEvent:Connect(function(plr, item)
	Shop.ItemPurchasedServer(item, plr)
end)
