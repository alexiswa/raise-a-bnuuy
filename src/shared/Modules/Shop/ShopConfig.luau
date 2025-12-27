local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShopConfig = {
    Items = {
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
        {
            Name = "Carrot",
            Description = "A carrot to feed your bunny!",
            Cost = 5,
            MultipleBuys = true,
            Tool = ReplicatedStorage.Tools.Carrot,
            ImageIcon = "104142069451642",
        },
        {
            Name = "ExampleItem",
            Description = "This is an item",
            Cost = 25,
            MultipleBuys = true,
            OnPurchase = function(self)
                print("You bought this item with a custom onPurchase function for", self.Cost, "!")
            end
        },
        {
            Name = "Second Example",
            Description = "This is another item!",
            Cost = 2,
            Tool = ReplicatedStorage.Tools.ExamplePurchasable
        }, 
        {
            Name = "a third example Example",
            Description = "This wont stay here!",
            Cost = 50,
            Tool = ReplicatedStorage.Tools.ExamplePurchasable
        }
    }
}

return ShopConfig