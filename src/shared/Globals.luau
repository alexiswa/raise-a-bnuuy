--!strict

-- A bunch of settings and other (mostly) constants. Basically the settings, but its not called that cause its used for other stuff too
local Globals = {}

------- Constants
-- debug settings
Globals.DEBUG_ENABLED = true :: boolean
Globals.PATHFINDING_VISUALIZATION = true :: boolean
Globals.PATHFINDING_VISUALIZATION_TIME_TO_DISAPPEAR = 15 :: number

-- bunny settings
Globals.BUNNY_SPEED = 16 :: number -- not currently used. TODO: make a getter and setter for this (this would ideally be readonly with a setter function but roblo)
Globals.BUNNY_WANDER_COOLDOWN = 15 :: number -- time, in seconds, between each wander
Globals.BUNNY_WANDER_COOLDOWN_DEVIATION = 5 :: number -- how much variation is in the cooldown
Globals.BUNNY_HUNGER_LOSS_RATE = 2 :: number -- time, in seconds, for the hunger bar to decrease by 1
Globals.BUNNY_HUNGER_EAT_MINIMUM = 75 :: number -- what the hunger needs to be at in order to eat
Globals.BUNNY_HUNGER_MAX_VALUE = 100 :: number -- maximum hunger bunny can have
Globals.BUNNY_HAPPINESS_LOSS_RATE = 2.5 :: number -- time, in seconds, for the happiness bar to decrease by 1
Globals.BUNNY_HAPPINESS_MAX_VALUE = 100 :: number -- the happiest a bunny can be :3

-- other settings
Globals.STARTING_MONEY = 100 :: number -- money player starts with
Globals.DROPPED_MONEY_DEFAULT_VALUE = 1 :: number -- how much money a dropped money gives
Globals.DROPPED_MONEY_VALUE_RANGE = 0 :: number -- how much (+/-) variance each money is given

-- models and references
Globals.BUNNY_MODEL = workspace:WaitForChild("Bunny!!"):WaitForChild("PrimaryPart") :: BasePart -- the model the bunny uses
Globals.BUNNY_MOVEMENT_HUMANOID = workspace:WaitForChild("bunnyMovementRig"):WaitForChild("Humanoid") :: Humanoid -- humanoid welded to bunny which allows movement
Globals.FOOD_BOWL = workspace:WaitForChild("food bowl") :: BasePart -- where the food bowl is
Globals.FOOD_ITEM = workspace:WaitForChild("Carrot") :: Model -- the model used for food
Globals.WANDERING_AREA = workspace:WaitForChild("Wandering Parts"):GetChildren() :: {BasePart} -- a list of parts which the bunny can wander around inside.
Globals.POOP_BOX = workspace:WaitForChild("poop box")

-- misc
Globals.KICK_PLAYER_EXPLOITER_MESSAGE = "Possible exploiter detected. Please contact a developer if you feel this was in error. Error code: " :: string

------- Variables
Globals.FoodAvailable = true :: boolean -- is food available to nom nom?

return Globals