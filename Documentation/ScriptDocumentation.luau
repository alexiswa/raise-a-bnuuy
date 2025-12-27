--[[
         ____   ___   ____ _   _ __  __ _____ _   _ _____  _  _____ ___ ___  _   _
        |  _ \ / _ \ / ___| | | |  \/  | ____| \ | |_   _|/ \|_   _|_ _/ _ \| \ | |
        | | | | | | | |   | | | | |\/| |  _| |  \| | | | / _ \ | |  | | | | |  \| |
        | |_| | |_| | |___| |_| | |  | | |___| |\  | | |/ ___ \| |  | | |_| | |\  |
        |____/ \___/ \____|\___/|_|  |_|_____|_| \_| |_/_/   \_|_| |___\___/|_| \_|

    - All server-scripts should go in `serverscriptstorage/server/core`.
    - Most scripts are calling functions from modules, in `serverscriptstorage/server/modules`.

    Script overview:
        [ServerScriptStorage/Server]
        `Core/Core`:
            hosts the core gameplay loop. It handles much of the games logic
	        and routines. Primary content as of writing is mostly for the heartbeat function
            Which runs every physics frame.
        `Core/DebugServer`:
            Hosts debug tools. Handles the server-side parts of Iris (debug UI used)
        `Core/Events`:
            Recieves most events. Currently handles remoteEvents, proximity prompts, and
            some other stuff.
        `Core/ServerInit`:
            Script that runs on server startup. Can be used for just about anything, such as
            generating folders used during runtime that should stay empty or initializing
            positions for certain objects
        -----
        `Modules/Bunny`:
            Module containing functions for happiness and hunger. All thats done there currently
        `Modules/Pathfinding`:
            Contains all the pathfinding logic (for the bunny). Very busy file.
        ------------------
        [ReplicatedStorage/Shared]
        `Globals`:
            Contains a bunch of commonly accessed settings and constants. Kept all in one place
            for ease of use.
        `Debug`:
            Not much going on here. Contains reused debug tools.
        -----
        `Modules/Money`:
            Module containing functions which handle money. Used for any transactions.
        `Modules/Shop/ShopConfig`
            Contains definitions for every purchasable item in the shop. If you want to
            add a purchasable, add it here
        `Modules/Shop/ShopUi`
            Actually handles the shop. Manages UI and purchasables
        ------------------
        [StarterPlayer/StarterPlayerScripts/Client]
        `core`: does most client side stuff
        `iris`: debug UI
]]
