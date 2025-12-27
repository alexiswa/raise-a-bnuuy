--[[
    Handles pathfinding for the bunny
]]

-- imports
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Globals = require(ReplicatedStorage.src.Globals)
local Debug = require(ReplicatedStorage.src.Debug)
local Bunny = require(ReplicatedStorage.src.Modules.Bunny)
-- local settings (pathfinding & tween info, etc)
---TODO: optimize pathfinding settings
local bunnyPath = PathfindingService:CreatePath({
    AgentRadius = 4.3, -- minimum horizontal distance needed to traverse
    AgentHeight = 4.3, -- minimum height needed to traverse
    AgentCanJump = true, -- self-explanatory. keep it to true or it breaks.
    AgentCanClimb = false, -- can it climb trusses and similar?
    WaypointSpacing = 5, -- distance between intermediate waypoints
    Costs = {} -- costs for traversing certain materials or regions. Not needed yet but im keeping it here anyways
})

--------------------
local Pathfinding = {}

-- holds the settings for bunny pathfinding

-- gets a random point located inside a BasePart
---@param part BasePart The part to select a random point from
---@return Vector3
local function GetRandomPointInsidePart(part: BasePart): Vector3
    local x = part.Position.X + math.random(-part.Size.X /2, part.Size.X /2)
    local y = part.Position.Y + math.random(-part.Size.Y /2, part.Size.Y /2)
    local z = part.Position.Z + math.random(-part.Size.Z /2, part.Size.Z /2)

    return Vector3.new(x, y, z)
end

-- flawed approach since it assumes all parts in list are the same size
local function GetRandomPointInsideListOfParts(listOfParts: {BasePart}): Vector3
    local results: {Vector3} = {}
    -- for each part in our list of parts, get a random point inside it
    -- and add that to our results array
    for index, item in listOfParts do
        results[index] = GetRandomPointInsidePart(item)
    end
    -- pick a random number between 1 and the length of the results array
    -- and select that as our index
    local random: Random = Random.new(os.time())
    local randomIndex = random:NextInteger(1, #results)
    -- return a random point for a random part
    return results[randomIndex]
end

---TODO: if the game ever takes off, this function will probably need to be redone because it is not good

-- move the bunny to the given point
---@param waypoint Vector3 where the bunny will move from
---@param debugPlotColor Color3
local function MoveToWaypoint(waypoint: Vector3, debugPlotColor: BrickColor?)
    debugPlotColor = debugPlotColor or BrickColor.new("Magenta").Color

    if Globals.BUNNY_MODEL.Position == Vector3.new(waypoint.X, Globals.BUNNY_MODEL.Position.Y, waypoint.Z) then
        return
    end

    -- keep the y value constant so it doesent clip into the floor
    local levelWaypoint = Vector3.new(waypoint.X, Globals.BUNNY_MOVEMENT_HUMANOID.Parent.PrimaryPart.Position.Y, waypoint.Z)

    -- if in debug mode, plot out the waypoints to visualize
    if Globals.DEBUG_ENABLED and Globals.PATHFINDING_VISUALIZATION then
        Debug.PlotPoint(waypoint, Globals.PATHFINDING_VISUALIZATION_TIME_TO_DISAPPEAR, debugPlotColor)
    end

    Globals.BUNNY_MOVEMENT_HUMANOID:MoveTo(levelWaypoint)
    Globals.BUNNY_MOVEMENT_HUMANOID.MoveToFinished:Wait()
end

---make a path between the bunny and a given point
---@param pointToGetTo Vector3 The point the bunny will pathfind to
---@param callback function function to call when not successful
---@return Enum.PathStatus
local function MakePath(
    pointToGetTo: Vector3, 
    waypointDebugColor: BrickColor?, 
    callback: (Enum.PathStatus?, string?, ...any) -> ()?, 
    ...: any
): (Enum.PathStatus, string?)
	
	local succ, err = pcall(function()
        bunnyPath:ComputeAsync(Globals.BUNNY_MODEL.Position, pointToGetTo)
    end)

    if not succ or bunnyPath.Status ~= Enum.PathStatus.Success then
        err = err or "No error message recieved"
        warn(`Unable to feed the bunny. path status: {bunnyPath.Status}; error message: {err}\nTrying again..`)
        callback(bunnyPath.Status, err, ...)
        return bunnyPath.Status, err
    end

    for _, waypoint in bunnyPath:GetWaypoints() do
        MoveToWaypoint(waypoint.Position, waypointDebugColor)
    end
    return Enum.PathStatus.Success
end

-- moves the bunny to the food bowl and eats
local function HungryPath()
    -- dont do the rest of this if its already at the food
    if Globals.BUNNY_MODEL.Position.X == Globals.FOOD_BOWL.Position.X
    and Globals.BUNNY_MODEL.Position.Z == Globals.FOOD_BOWL.Position.Z then
        return
    end

    MakePath(Globals.FOOD_BOWL.Position, Debug.DefaultColor, function()  
        MoveToWaypoint(Globals.FOOD_BOWL.Position, BrickColor.Red())
    end)

    Bunny.Eat(Globals.FOOD_ITEM, 50, true, function()
        -- move the carrot down to give visual clue that theres no food. This doesent need to be a callback but its cleaner.
        Globals.FOOD_ITEM:PivotTo(CFrame.new(Globals.FOOD_ITEM.WorldPivot.Position.X, -4, Globals.FOOD_ITEM.WorldPivot.Position.Z))
    end)

    MakePath(Globals.POOP_BOX.Position)
    task.wait(0.5)
    Globals.POOP_BOX.Decal.Transparency = 0
end

-- Makes the bunny wander in the wander area
---@param r number The number of times this has recursively ran. Limit of 256.
function Pathfinding.BunnyWander(r: number?)
    r = r or 0

    while Bunny.GetHappiness() < 75 do
        repeat 
            -- do nothing
        until MakePath((Players:GetChildren()[1] :: Player).Character:GetPivot().Position) == Enum.PathStatus.Success
    end

    if Bunny.GetHunger() <= Globals.BUNNY_HUNGER_EAT_MINIMUM then
        HungryPath()
    end
    -- stop stupid amounts of recursion
    if r >= 256 then
        warn("Pathfinding recursion limit reached.")
        -- attempt to pathfind to center of wandering area
        -- if successful, pathfind normally
        -- if not succesful, well, i guess we walking through walls
        MakePath(Globals.WANDERING_AREA[1].Position, BrickColor.Red(), function()
            MoveToWaypoint(Globals.WANDERING_AREA[1].Position, BrickColor.Red().Color)
        end)
        return
    end

    local nextPathfindingPoint = GetRandomPointInsideListOfParts(Globals.WANDERING_AREA)

    -- if the distance between the current position and the next position is low, recursively run it again so the distance is more visible
    local distanceBetweenBunnyAndEndPoint = (Globals.BUNNY_MODEL.Position - nextPathfindingPoint).Magnitude
    if distanceBetweenBunnyAndEndPoint <= 6 then
        print(distanceBetweenBunnyAndEndPoint)
        r += 1
        Pathfinding.BunnyWander(r)
        return
    end

    if Globals.DEBUG_ENABLED and Globals.PATHFINDING_VISUALIZATION then
        Debug.PlotPoint(nextPathfindingPoint, Globals.PATHFINDING_VISUALIZATION_TIME_TO_DISAPPEAR, nil, "endPoint")
    end

    -- generates the path
    -- if it didnt give an error, but couldn't make a path, try again recursively
    -- otherwise if it wasnt succesful or the path status isnt success then warn and return
    MakePath(nextPathfindingPoint, nil, function(status)
        if status == Enum.PathStatus.NoPath then
            r += 1
            Pathfinding.BunnyWander(r)
        end
    end)
end

return Pathfinding