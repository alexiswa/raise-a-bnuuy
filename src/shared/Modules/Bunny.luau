--[[
    Module to handle happiness and hunger for the bunny
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Bunny = {}
-- imports
local Globals = require(ReplicatedStorage.src.Globals)

local hungerUi: TextLabel = Globals.BUNNY_MODEL.BillboardGui.HungerLabel
local happinessUi: TextLabel = Globals.BUNNY_MODEL.BillboardGui.HappinessLabel

do
    local _hunger = Globals.BUNNY_HUNGER_MAX_VALUE

    -- raise food bar
    ---@param change number how much you want to give the bunny
    ---@return number hunger the new hunger of the bunny
    function Bunny.Feed(change: number): number
        Bunny.SetHunger(_hunger + change)
        return _hunger
    end

    -- lower food bar
    ---@param change number how much you want to take away from the bunny
    ---@return number hunger the new hunger of the bunny
	function Bunny.Starve(change: number): number
        return Bunny.Feed(-change)
    end

	function Bunny.SetHunger(newHunger: number): number
        if RunService:IsClient() then
            error("Cannot change hunger from client", 5)
        end
        _hunger = math.clamp(newHunger, 0, Globals.BUNNY_HUNGER_MAX_VALUE)
        hungerUi.Text = `Hunger: {_hunger}`
        return _hunger
    end

    -- get the hunger of bunny
    ---@return number hunger the hunger of the bunny
	function Bunny.GetHunger(): number
        return _hunger
    end

    -- makes bunny eat the instance given in `thingtoeat`
-- which allows different things to happen if different foods are given.
-- For now, this is actually kinda useless, but it might be useful later
---@param thingToEat any a thing the bunny eats
---@param hungerToGive number how much food the function gives
---@param avoidDestruction boolean disables the destruction function so the item ate isnt destroyed
---@param callback function an optional callback allowing custom behavior
---@return any
    function Bunny.Eat(thingToEat, hungerToGive: number, avoidDestruction: boolean, callback: () -> ())
        if RunService:IsClient() then
            error("Cannot eat from client", 5)
        end

        if Globals.FoodAvailable == false then
            return
        end
        task.wait(2.5)
        thingToEat = thingToEat or Globals.FOOD_ITEM
        Bunny.Feed(hungerToGive)
        Globals.FoodAvailable = false
        if not avoidDestruction then
            thingToEat:Destroy()
        end
        callback()
    end
end

do
    local _happiness = Globals.BUNNY_HAPPINESS_MAX_VALUE

	function Bunny.GetHappiness(): number
        return _happiness
    end

	function Bunny.SetHappiness(newHappiness: number): number
        if RunService:IsClient() then
            error("Cannot change happiness from client", 5)
        end

        _happiness = math.clamp(newHappiness, 0, Globals.BUNNY_HAPPINESS_MAX_VALUE)
        happinessUi.Text = `Happiness: {_happiness}`
        return _happiness
    end

	function Bunny.Happy(change: number): number
        return Bunny.SetHappiness(_happiness + change)
    end

	function Bunny.Sad(change: number): number
        return Bunny.Happy(-change)
    end
end

return Bunny