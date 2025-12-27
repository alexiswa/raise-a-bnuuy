local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local Globals = require(script.Parent.Globals)
local Debug = {}

Debug.DefaultColor = BrickColor.new("Institutional white")

Debug.Location = nil-- :: Folder

Debug.Pause = false

-- this only runs once upon server initialization. this will be expanded as needed
function Debug.InitializeDebugTools()
    if Globals.DEBUG_ENABLED ~= true then
        print("Debug tools disabled")
        return
    end

    local debugFolder = Instance.new("Folder")
    debugFolder.Parent = workspace
    debugFolder.Name = "Debug"
    Debug.Location = debugFolder
end

function Debug.PlotPoint(pointPosition: Vector3, disappearanceTime: number, color: BrickColor?, name: string?)
    if Globals.PATHFINDING_VISUALIZATION == false then return end

    if typeof(color) == "Color3" then
        color = BrickColor.new(color)
    end

    local debugPart = Instance.new("Part", workspace)
    debugPart.Anchored = true
    debugPart.Shape = Enum.PartType.Ball
    debugPart.Size = Vector3.new(4, 4, 4)
    debugPart.Parent = Workspace.Debug
    debugPart.CanCollide = false
    debugPart.BrickColor = color or Debug.DefaultColor
    debugPart.Transparency = 0.6
    debugPart.Position = pointPosition
    debugPart.Rotation = Vector3.new(0, 0, 0)
    debugPart.Name = name or "DebugPart"
    debugPart.Material = Enum.Material.SmoothPlastic
    Debris:AddItem(debugPart, Globals.PATHFINDING_VISUALIZATION_TIME_TO_DISAPPEAR)
end

return Debug