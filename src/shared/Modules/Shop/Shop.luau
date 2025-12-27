--[[
    Script for initializing the Shop UI,
    as well as handling interactions.
    To add new items to the shop, use ShopConfig
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Money = require(ReplicatedStorage.src.Modules.Money)
local ShopConfig = require(script.Parent.ShopConfig)
local ShopItem = require(script.Parent.ShopItem)
type ShopItem = ShopItem.ShopItem

local Shop = {}

Shop._items = {} :: {ShopItem}

function Shop.init()
    local startTime = os.clock()
    -- sort items by cost
    table.sort(ShopConfig.Items, function(a, b)
        return a.Cost < b.Cost
    end)

    local storeGui = StarterGui.ShopGui.Main

    for i, item in ShopConfig.Items do
        local newItem: ShopItem = ShopItem.new(item)
        
        if typeof(item.OnPurchase) == "function" then  
            newItem.OnPurchase = item.OnPurchase
        end
        newItem._Index = i

        local newIcon: ImageButton = storeGui.Template:Clone()
        newIcon.ItemName.Text = item.Name
        newIcon.Cost.Text = `${item.Cost}`
        newIcon.Name = newItem.Name
        newIcon.Visible = true
        newIcon.Interactable = true
        newIcon.Active = true

        -- if `item.Tool` is defined and `item.Tool` has some descendant which
        -- is a viewport, then clone the viewport and set its parent to the UI
        -- button. Then, clone the parent of the original viewport and make it
        -- a child of the new viewport
        if newItem.ImageIcon ~= "" then
            local imageLabel: ImageLabel = newIcon.ImageLabel
            imageLabel.Image = "rbxassetid://" .. newItem.ImageIcon
            imageLabel.Visible = true
            imageLabel.ImageTransparency = 0
        elseif newItem.Tool and newItem.Tool:FindFirstChildWhichIsA("ViewportFrame", true) then
            local vp: ViewportFrame = newItem.Tool:FindFirstChildWhichIsA("ViewportFrame", true)

            local viewport = vp:Clone()
            viewport.Parent = newIcon

            local part = vp.Parent:Clone()
            part.Parent = viewport
        else
            warn(`Shop item {newItem.Name} does not have an icon or viewport. Item may not display properly in shop.`)
        end

        newIcon.Parent = storeGui
        newItem._GuiReference = newIcon

        Shop._items[i] = newItem
    end
    storeGui.Template:Destroy()

    ReplicatedStorage.Events.ShopUiReady:FireAllClients(Shop._items) -- make sure shop._items is ready on the client side

    for _, player in Players:GetChildren() do
        player.PlayerGui.ShopGui:Destroy()
        StarterGui.ShopGui:Clone().Parent = player.PlayerGui
    end

    print("Store GUI initialized in", os.clock() - startTime, "seconds.")
end

function Shop.RunClient()
    for _, item in Shop._items do
        item._GuiReference = Players.LocalPlayer.PlayerGui.ShopGui.Main:FindFirstChild(item.Name)
        
        item._GuiReference.MouseButton1Click:Connect(function(...: any)  
            ReplicatedStorage.Events.ItemPurchased:FireServer(item)
        end)
    end
end

function Shop.ItemPurchasedServer(item: ShopItem, plr: Player)
    item = Shop._items[item._Index]

    if not item:IsPurchasable() then
        return
    end

    item:OnPurchase(plr)
    Money.RemoveMoney(item.Cost)

    item._Purchased = true
end

return Shop