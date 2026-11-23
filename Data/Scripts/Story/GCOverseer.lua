require("PGStoryMode")

function Definitions()
    ServiceRate = 0.3

    StoryModeEvents = {
        Init_GC = Init_GC,
        Update = Update,
        Flush = Flush,
    }

    FluidTech = nil
end

function Init_GC(message)
    if message ~= OnEnter then
        return
    end

    ---@type Fluid_Tech_Main|nil
    FluidTech = require("FluidTech/Main")

    if FluidTech == nil then
        return
    end
    
    FluidTech:Init()

    FluidTech.Notifications:Subscribe(Galactic_Unit_Produced,"GALACTIC_PRODUCTION_EVENT")

    FluidTech.Notifications:Subscribe(Galactic_Unit_Destoryed,"GALACTIC_DESTRUCTION_EVENT")
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
---@param object_type_name string
function Galactic_Unit_Produced(object_type_name)
    DebugMessage("%s -- Unit Produced: %s", tostring(Script), tostring(object_type_name))
end
---@param object_type_name string
function Galactic_Unit_Destoryed(object_type_name)
    DebugMessage("%s -- Unit Destroyed: %s", tostring(Script), tostring(object_type_name))
end