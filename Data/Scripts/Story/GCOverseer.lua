require("PGStoryMode")

function Definitions()
    ServiceRate = 0.3

    StoryModeEvents = {
        Init_GC = Init_GC,
        Update = Update,
        Flush = Flush,
    }

    ---@type Fluid_Tech_Main|nil
    FluidTech = nil

    Faction_List = {
        "Rebel",
        "Empire",
        "Underworld",
    }

    ---@type PlayerWrapper|nil
    Player = nil
end

function Init_GC(message)
    if message ~= OnEnter then
        return
    end

    Player = Find_Human_Player()

    local Example_Table = require("FluidTech/Example_Table")
    
    FluidTech = require("FluidTech/Main")

    if FluidTech == nil then
        return
    end

    FluidTech:Init(Player, Example_Table)

    if not FluidTech.Setup then
        return
    end

    FluidTech.Notifications:Subscribe(Galactic_Unit_Produced,"GALACTIC_PRODUCTION_EVENT")

    FluidTech.Notifications:Subscribe(Galactic_Unit_Destoryed,"GALACTIC_DESTRUCTION_EVENT")

    Set_Next_State("Flush")
end

function Update(message)
    if message ~= OnUpdate then
        return
    end

    if FluidTech == nil then
        return
    end

    FluidTech:Update()
end

function Flush(message)
    if message == OnEnter then
        Set_Next_State("Update")
    end
end

---@return PlayerWrapper|nil
function Find_Human_Player()
    
    for _, faction_name in pairs(Faction_List) do
        local faction = Find_Player(faction_name)

        if TestValid(faction) then
            if faction.Is_Human() then
                return faction
            end
        end
    end

    return nil
end

---@param object_type_name string
function Galactic_Unit_Produced(object_type_name)
    DebugMessage("%s -- Unit Produced: %s", tostring(Script), tostring(object_type_name))

    FluidTech:Process_Incoming_Event(object_type_name)
end
---@param object_type_name string
function Galactic_Unit_Destoryed(object_type_name)
    DebugMessage("%s -- Unit Destroyed: %s", tostring(Script), tostring(object_type_name))

    FluidTech:Process_Incoming_Event(object_type_name, true)
end