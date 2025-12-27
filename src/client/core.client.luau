local startTime = os.clock()
print("Client loading")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.src.Globals)
local Shop = require(ReplicatedStorage.src.Modules.Shop.Shop)

local moneyUi: TextLabel = Players.LocalPlayer.PlayerGui:WaitForChild("MoneyGui").TextLabel
local clickToDrop: ClickDetector = Globals.BUNNY_MODEL.makeMoney

local moneyEvent: RemoteEvent = ReplicatedStorage.Events.setClientMoneyDisplayThing
local dropMoneyEvent: RemoteEvent = ReplicatedStorage.Events.dropMoney
local uiLoadedEvent: RemoteEvent = ReplicatedStorage.Events.clientUiLoaded
local shopPrompt: ProximityPrompt = workspace:WaitForChild("shop").ProximityPrompt


uiLoadedEvent:FireServer()
print("Client loaded in", os.clock() - startTime, "seconds")

-------------------------------------------------------------------------------
shopPrompt.Triggered:Connect(function()
    Players.LocalPlayer.PlayerGui.ShopGui.Enabled = not Players.LocalPlayer.PlayerGui.ShopGui.Enabled
end)

moneyEvent.OnClientEvent:Connect(function(money)
    moneyUi.Text = `$ {money}`
end)

clickToDrop.MouseClick:Connect(function(plr)
    dropMoneyEvent:FireServer(plr, "066fd78f-a7ee-471f-98d0-2e06be474274")
end)

ReplicatedStorage.Events.ShopUiReady.OnClientEvent:Once(function(items)
    Shop._items = items
    Shop.RunClient()
end)