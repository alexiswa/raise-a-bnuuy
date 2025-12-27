-- This module contains the ShopItem type and relevant oop functions
-- **to add items to the shop, use ShopConfig**

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Money = require(ReplicatedStorage.src.Modules.Money)
--[[
    `Name: string`,
    The name of the item. 

    `Description: string`,
    A description of the item.

    `Cost: number`,
   How much money the item costs.

    `MultipleBuys: boolean`,
    Can the item be bought multiple times? Defaults to no, optional.

   `Tool: Tool`,
    a reference to the tool purchased. Optional (see `OnPurchase` field).
            
    `ImageIcon: string`, 
    An Icon to display for the items image in the shop.
    Not necessary if a viewport is set up for the tool.

    `OnPurchase: (self: ShopItem, plr: Player?) -> ()`, 
    An optional function to run when purchased. Optional input parameter of `self`. 
    Will override the default "clone tool to players backpack" function
]]
export type ShopItem = {
    Name: string, 
    Description: string,
    Cost: number,
    MultipleBuys: boolean,
    Tool: Tool,
    ImageIcon: string,
    OnPurchase: (self: ShopItem, plr: Player?, ...any?) -> (),
    _GuiReference: ImageButton, -- For internal use only, do not add in definitions.
    _Purchased: boolean, -- For internal use only, do not add in definitions.
    _Index: number, -- For internal use only, do not add in definitions.
}

local ShopItem = {}
ShopItem.__index = ShopItem

function ShopItem.new(item: {}): ShopItem
    local newItem: ShopItem = {}
    setmetatable(newItem, ShopItem)

    newItem.Name = item.Name or ""
    newItem.Cost = item.Cost or 0
    newItem.Description = item.Description or ""
    newItem.MultipleBuys = item.MultipleBuys or false
    newItem.ImageIcon = item.ImageIcon or ""
    newItem.Tool = item.Tool or nil :: Tool

    newItem._GuiReference = nil :: ImageButton
    newItem._Purchased = false

    newItem.OnPurchase = ShopItem.OnPurchase

    return newItem
end

ShopItem.IsPurchasable = function(self: ShopItem): boolean
    if Money.GetCurrentMoney() < self.Cost then
        return false
    end
    if self._Purchased and not self.MultipleBuys then
        return false
    end
    return true
end

ShopItem.OnPurchase = function(self: ShopItem, plr: Player)
    print(`bought {self.Name} for ${self.Cost}!`)
    if self.Tool then
        self.Tool:Clone().Parent = plr.Backpack
    end
end

return ShopItem  