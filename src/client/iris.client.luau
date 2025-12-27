---@diagnostic disable: unused-local
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Iris = require(ReplicatedStorage.Packages:WaitForChild("iris"))
local Globals = require(ReplicatedStorage.src.Globals)
local debugEvent = ReplicatedStorage.Events["debug_1181e04d-5d1b-44fb-8a8b-793b0282e205"]

Iris.Init()

local wanderTick, hungerTick, happinessTick, deltaTime, lastSelectedDeviation
local deltaTimeCache = {}

local cameraFollowsBunny: boolean = false

local getCoreInfo: RemoteEvent = ReplicatedStorage.Events.sendCoreInformation
getCoreInfo.OnClientEvent:Connect(function(...)
    local args = {...}
    wanderTick = math.floor(args[1] * 100) / 100
    hungerTick = math.floor(args[2] * 100) / 100
    happinessTick = math.floor(args[3] * 100) / 100
    deltaTime = args[4]
    lastSelectedDeviation = args[5]
    -- add select data to the cache so it can be graphed
    table.insert(deltaTimeCache, deltaTime)
    -- if cache gets too big, remove the first element
    if #deltaTimeCache >= 600 then
        table.remove(deltaTimeCache, 1)
    end
end)

Iris:Connect(function()
    Iris.Window({"Debug Tools"})
    -- bunny
    do
        Iris.CollapsingHeader({"Bunny and other Variables"})
            -- change the hunger
            do
            Iris.SameLine()
                local setHunger = Iris.Button({"Set"})
                local hungerInputNumber = Iris.State(50)
                local _setHungerInput = Iris.InputNum({[1]="Set Hunger", [3]=0, [4]=100}, {number = hungerInputNumber})
                if setHunger.clicked() then
                    debugEvent:FireServer("setHunger", hungerInputNumber:get())
                end
            Iris.End()
            end
            -- change the happiness
            do
                Iris.SameLine()
                    local setHappy = Iris.Button({"Set"})
                    local happyInputNumber = Iris.State(50)
                    local _setHappyInput = Iris.InputNum({[1]="Set Happiness", [3]=0, [4]=100}, {number = happyInputNumber})
                    if setHappy.clicked() then
                        debugEvent:FireServer("setHappy", happyInputNumber:get())
                    end
                Iris.End()
            end
            -- change animation speed
            do
                Iris.SameLine()
                    local setAnimSpeed = Iris.Button({"Set"})
                    local animSpeedInputNumber = Iris.State(Globals.BUNNY_SPEED)
                    local _setAnimSpeedInput = Iris.InputNum({[1]="Set Animation Speed", [3]=0, [4]=100}, {number = animSpeedInputNumber})
                    if setAnimSpeed.clicked() then
                        debugEvent:FireServer("setAnimSpeed", animSpeedInputNumber:get())
                    end
                Iris.End()
            end
            -- change money $$$$$
            do
                Iris.SameLine()
                    local setNewMoney = Iris.Button({"Set"})
                    local newMoneyInputNumber = Iris.State(Globals.STARTING_MONEY)
                    local _setNewMoneyInput = Iris.InputNum({[1]="Set Money", [3]=0, [4]=999999}, {number = newMoneyInputNumber})
                    if setNewMoney.clicked() then
                        debugEvent:FireServer("setNewMoney", newMoneyInputNumber:get())
                    end
                Iris.End()
            end
            -- force wander
            if Iris.Button({"Force bunny to Wander"}).clicked() then
                debugEvent:FireServer("forceWander")
            end
            -- camera follow
            if Iris.Button({"Set Camera to Follow Bunny"}).clicked() then
                cameraFollowsBunny = not cameraFollowsBunny
                if cameraFollowsBunny == true then
                    workspace.CurrentCamera.CameraSubject = Globals.BUNNY_MODEL
                else
                    workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character.Humanoid
                end
            end
        Iris.End()
    end
    -- core information
    do
        Iris.CollapsingHeader({"Core Information"})
            Iris.Text({`Delta Time: {deltaTime}`})
            Iris.Separator()
            Iris.Text({`Wander Tick: {wanderTick}`})
            Iris.Text({`Hunger Tick: {hungerTick}`})
            Iris.Text({`Happiness Tick: {happinessTick}`})
            Iris.Text({`Deviation: {lastSelectedDeviation}`})

            Iris.Separator()

            local deltaPlotState = Iris.State(deltaTimeCache)
            deltaPlotState:set(deltaTimeCache, true)
            Iris.PlotLines({"Delta Time",100, 0, 0.03}, {values = deltaPlotState})
        Iris.End()
    end
    -- debug settings
    do
        Iris.CollapsingHeader({"Debug Settings"})
            -- pause time
            if Iris.Button({"Pause sim"}).clicked() then
                debugEvent:FireServer("pause")
            end
            -- toggle debug mode
            if Iris.Button({"Toggle Debug"}).clicked() then
                debugEvent:FireServer("toggleDebug")
            end
            -- toggle pathfinding visualization
            if Iris.Button({"Pathfinding Visualization"}).clicked() then
                debugEvent:FireServer("togglePathfinding")
            end
            -- clear debug folder
            if Iris.Button({"Clear Debug Folder"}).clicked() then
                debugEvent:FireServer("clearDebugFolder")
            end
            -- set time it takes for visualization parts to disappear
            Iris.SeparatorText({"Set Pathfinding Visualization Time"})
            Iris.SameLine()
                local setPathVisTime = Iris.Button({"Set"})
                local pathVisInputNumber = Iris.State(5)
                local _inputPathVisTime = Iris.InputNum({[3]=0, [4]=5000}, {number = pathVisInputNumber})
                if setPathVisTime.clicked() then
                    debugEvent:FireServer("setPathVisTime", pathVisInputNumber:get())
                end
            Iris.End()
        Iris.End()
    end
    Iris.End()
end)
