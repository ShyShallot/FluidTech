require("PGStoryMode")

---@class Fluid_Tech_Main
Fluid_Tech = {
    
    Tech_Values = {
        Scientific = 0,
        Industrial = 0,
    },

    Last_Structure_List_Count = 0,

    ---@type GameObject[]
    Specific_Structure_List = {},

    ---@type Fluid_Tech_Table|nil
    Unit_Tech_Table = nil,

    Setup = false,
    
    Is_Dirty = false, -- When true, allows the Fluid Tech to update

    Are_Structures_Dirty = false,

    Structure_Type_Search = "FluidTechStructure",

    ---@type Notifications|nil
    Notifications = nil,

    ---@type PlayerWrapper|nil
    Human = nil,

    Plot_Location = "FluidTech\\GCOverseerEvents.xml",

    ---@type StoryPlot|nil
    Plot = nil,
}
---@param HumanPlayer PlayerWrapper|nil
function Fluid_Tech:Init(HumanPlayer)
    if self.Unit_Tech_Table == nil then
        self.Unit_Tech_Table = require("FluidTech/Unit_Tech_Table")
        DebugMessage("%s -- FluidTech Found Unit Table", tostring(Script))
    end

    self.Plot = Get_Story_Plot(self.Plot_Location)

    if self.Plot == nil then
        DebugMessage("%s -- FluidTech Failed to Initalize, Failed to find Story Plot", tostring(Script))
        return
    end

    if HumanPlayer ~= nil then
        if HumanPlayer.Get_Faction_Name ~= nil then
            self.Human = HumanPlayer
            DebugMessage("%s -- FluidTech Found Human Player: %s", tostring(Script), tostring(HumanPlayer))
        end
    else
        return
    end

    self.Notifications = require("FluidTech/Notification")

    if self.Notifications == nil then
        DebugMessage("%s -- FluidTech Failed to Initalize, Failed to Grab Notification System", tostring(Script))
        return
    end

    self:Check_Units()

    self.Setup = true

    DebugMessage("%s -- FluidTech Successfuly Initalized", tostring(Script))
end

function Fluid_Tech:Update()
    if not self.Setup then
        DebugMessage("%s -- FluidTech Failed to Update! Not Setup", tostring(Script))
        return
    end

    if not self.Human then
        DebugMessage("%s -- FluidTech Failed to Update! No Player Set", tostring(Script))
        return
    end

    if self.Unit_Tech_Table == nil then
        DebugMessage("%s -- FluidTech Failed to Update! No Unit Table defined", tostring(Script))
        return
    end

    self.Notifications:Process_Events()

    if not self.Is_Dirty then
        DebugMessage("%s -- FluidTech - Canceling Unit Check, Not Dirty", tostring(Script))
        return
    end

    DebugMessage("%s -- FluidTech - Is Dirty, Updating Units", tostring(Script))

    self:Check_Units()

    self.Is_Dirty = false
    
end

---@private
function Fluid_Tech:Check_Units()

    if self.Unit_Tech_Table == nil then
        DebugMessage("%s -- Failed to Check Units! No Unit Table Defined", tostring(Script))
        return
    end

    if self.Unit_Tech_Table.Units == nil then
        DebugMessage("%s -- Failed to Check Units! Unit Table improperly defined", tostring(Script))
        return
    end

    if self:Table_Size(self.Unit_Tech_Table.Units) < 1 then
        DebugMessage("%s -- Failed to Check Units! Unit table is missing entries!", tostring(Script))
        return
    end

    for Unit_Name, Data in pairs(self.Unit_Tech_Table.Units) do

        local all_requirements_met = true

        DebugMessage("%s -- Checking Requirements for Unit: %s", tostring(Script), tostring(Unit_Name))

        if type(Data.Requirements) == "table" then
            for Req_Type, Req_Value in pairs(Data.Requirements) do
                DebugMessage("%s -- Comparing Req Value for Type: %s", tostring(Script), tostring(Req_Type))
                if self.Tech_Values[Req_Type] ~= nil then
                    if self.Tech_Values[Req_Type] < Req_Value then
                        DebugMessage("%s -- Failed Requirement Check for Type %s, Required Value: %s, Current Value: %s", tostring(Script), tostring(Req_Type), tostring(Req_Value), tostring(self.Tech_Values[Req_Type]))
                        all_requirements_met = false
                        break
                    end
                else
                    DebugMessage("%s -- ERROR Requirement Type is missing Definitions in Fluid_Tech Main.lua!", tostring(Script))
                    all_requirements_met = false
                    break
                end
            end
        end

        Data.Requirements_Met = all_requirements_met

        if all_requirements_met then
            self:Lock_Unit_Type(Unit_Name, true)
        else
            self:Lock_Unit_Type(Unit_Name)
        end
    end
end


---@param unit_type_name string
---@param needs_unlock? boolean Default Behaviour is lock, True -- > Unlock, False/Not Provided --> Lock
function Fluid_Tech:Lock_Unit_Type(unit_type_name, needs_unlock)

    if type(unit_type_name) ~= "string" then
        return
    end

    if self.Human == nil then
        return
    end

    if needs_unlock ~= true then
        needs_unlock = false
    end

    local unit_type = Find_Object_Type(unit_type_name)

    if unit_type == nil then
        return
    end

    local Event = self.Plot.Get_Event("Disable_Unit_Construction")

    local Event_Name = "DISABLE_UNIT_CONSTRUCTION"

    if needs_unlock then
        Event = self.Plot.Get_Event("Enable_Unit_Construction")
        Event_Name = "ENABLE_UNIT_CONSTRUCTION"
    end

    Event.Set_Reward_Parameter(0, unit_type)

    Story_Event(Event_Name)
end

---@param unit_type_name string
---@return boolean
function Fluid_Tech:Is_Object_Unlocked(unit_type_name)
    if type(unit_type_name) ~= "string" then
        return false
    end

    local Unit_Data = self.Unit_Tech_Table:Resolve_Unit_Data(unit_type_name)

    if Unit_Data == nil then
        return false
    end

    return Unit_Data.Requirements_Met
end

---@param object_type_name string|nil
---@param is_bad boolean|nil If not true, we assume its a good event, thus add to our values
function Fluid_Tech:Process_Incoming_Event(object_type_name, is_bad)
    if type(object_type_name) ~= "string" then
        return
    end

    if type(is_bad) ~= "boolean" then
        is_bad = false
    end

    DebugMessage("%s -- Processing Incoming Event for Unit: %s, Is Bad: %s", tostring(Script), tostring(object_type_name), tostring(is_bad))

    local Structure_Data = self.Unit_Tech_Table:Resolve_Structure_Data(object_type_name)

    DebugMessage("%s -- Structure Data: %s", tostring(Script), tostring(Structure_Data))

    if Structure_Data == nil then
        DebugMessage("%s -- Unit had no Structure Data, Ignoring", tostring(Script))
        return
    end

    if Structure_Data.Amount == nil then
        return
    end

    if Structure_Data.Type == nil then
        return
    end

    local Structure_Amount = Structure_Data.Amount

    if is_bad then
        Structure_Amount = Structure_Amount * - 1
    end

    self.Is_Dirty = true

    self.Tech_Values:Add_Value(Structure_Amount, Structure_Data.Type)

end

---@param add_value number
---@param value_type string Case Sensitive
function Fluid_Tech.Tech_Values:Add_Value(add_value, value_type)
    if type(add_value) ~= "number" then
       return
    end

    if type(value_type) ~= "string" then
        return
    end

    if self[value_type] == nil then
        return
    end

    local new_value = self[value_type] + add_value

    if type(new_value) == "number" then
        DebugMessage("%s -- Adding %s to Tech Value %s. New Value: %s", tostring(Script), tostring(add_value), tostring(value_type), tostring(new_value))
        self[value_type] = new_value
    end

end

---@param tbl table|nil
function Fluid_Tech:Table_Size(tbl)
    if type(tbl) ~= "table" then
        return 0
    end

    local size = 0

    for _, Item in pairs(tbl) do
        size = size + 1
    end

    return size
end

---@param str1 string
---@param str2 string
function sanatized_string_check(str1, str2)
    if str1 == str2 then
        return true
    end

    if type(str1) ~= "string" or type(str2) ~= "string" then
        return false
    end

    return string.lower(str1) == string.lower(str2)

end

return Fluid_Tech