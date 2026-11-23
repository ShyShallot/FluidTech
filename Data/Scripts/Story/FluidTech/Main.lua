require("PGStoryMode")

---@class Fluid_Tech_Main
Fluid_Tech = {
    
    Industrial = {
        Global_Value = 0,
        Last = 0,
    },

    Scientific = {
        Global_Value = 0,
        Last = 0,
    },

    Last_Structure_List_Count = 0,

    ---@type GameObject[]
    Specific_Structure_List = {},

    ---@type Fluid_Tech_Table|nil
    Unit_Tech_Table = nil,

    Setup = false,
    
    Is_Dirty = false, -- When true, allows the Fluid Tech to update

    Are_Structures_Dirty = false,

    Local_Unit_Table = {
        Locked = {},
        Unlocked = {},
    },

    Structure_Type_Search = "FluidTechStructure",

    ---@type Notifications|nil
    Notifications = nil,

    Human = nil,
}
---@param HumanPlayer PlayerWrapper|nil
function Fluid_Tech:Init(HumanPlayer)
    if self.Unit_Tech_Table == nil then
        self.Unit_Tech_Table = require("FluidTech/Unit_Tech_Table")
        DebugMessage("%s -- FluidTech Found Unit Table", tostring(Script))
    end

    for Unit_Name, _ in pairs(self.Unit_Tech_Table.Units) do
        table.insert(self.Local_Unit_Table.Locked, Unit_Name)
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

    self.Setup = true

    DebugMessage("%s -- FluidTech Successfuly Initalized", tostring(Script))
end

function Fluid_Tech:Update()
    if not self.Setup then
        return
    end

    if not self.Human then
        return
    end

    if self.Unit_Tech_Table == nil then
        return
    end

    DebugMessage("%s -- Current Industrial Value: %s, Current Scientific Value: %s", tostring(Script), tostring(self.Industrial.Global_Value), tostring(self.Scientific.Global_Value))

    self.Notifications:Process_Events()

    if not self.Is_Dirty then
        return
    end

    DebugMessage("%s -- Is Dirty, Updating Units", tostring(Script))

    --self:Check_Units()

    self.Is_Dirty = false
    
end

---@private
function Fluid_Tech:Check_Units()

    for i = table.getn(self.Local_Unit_Table.Locked), 1, -1 do
        local Unit_Name = self.Local_Unit_Table.Locked[i]

        if type(Unit_Name) == "string" then
            local Data = self.Unit_Tech_Table:Resolve_Unit_Data(Unit_Name)

            if type(Data) == "table" then
                if self.Industrial.Global_Value >= Data.Industrial and self.Scientific.Global_Value >= Data.Scientific then
                    Data.Requirements_Met = true
                    table.insert(self.Local_Unit_Table.Unlocked, Unit_Name)
                    table.remove(self.Local_Unit_Table.Locked, i)
                end
            end
        end
    end

    for i = table.getn(self.Local_Unit_Table.Unlocked), 1, -1 do
        local Unit_Name = self.Local_Unit_Table.Unlocked[i]

        if type(Unit_Name) == "string" then
            local Data = self.Unit_Tech_Table:Resolve_Unit_Data(Unit_Name)

            if type(Data) == "table" then
                if self.Industrial.Global_Value < Data.Industrial or self.Scientific.Global_Value < Data.Scientific then
                    Data.Requirements_Met = false
                    table.insert(self.Local_Unit_Table.Locked, Unit_Name)
                    table.remove(self.Local_Unit_Table.Unlocked, i)
                end
            end
        end
    end
end

---@param object_type_name string|nil
---@param is_bad boolean|nil If not true, we assume its a good event, thus add to our values
function Fluid_Tech:Process_Incoming_Event(object_type_name, is_bad)
    if type(object_type_name) ~= "string" then
        return
    end

    if not is_bad then
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

    if sanatized_string_check(Structure_Data.Type, "Industrial") then
        DebugMessage("%s -- Adding/Subtracting %s to Industrial Value", tostring(Script), tostring(Structure_Amount))
        self.Industrial:Add_Value(Structure_Amount)
    elseif sanatized_string_check(Structure_Data.Type, "Scientific") then
        DebugMessage("%s -- Adding/Subtracting %s to Scientific Value", tostring(Script), tostring(Structure_Amount))
        self.Scientific:Add_Value(Structure_Amount)
    end
        
end

---@param new_value number
function Fluid_Tech.Industrial:Add_Value(new_value)
    if type(new_value) ~= "number" then
       return
    end

    local new_global_value = self.Global_Value + new_value

    if type(new_global_value) ~= "number" then
        return
    end

    self.Global_Value = new_global_value

    Fluid_Tech.Is_Dirty = true
end
---@param new_value number
function Fluid_Tech.Industrial:Set_Value(new_value)
    if type(new_value) ~= "number" then
       return
    end

    self.Global_Value = new_value

    Fluid_Tech.Is_Dirty = true
end
---@param new_value number
function Fluid_Tech.Scientific:Add_Value(new_value)
    if type(new_value) ~= "number" then
       return
    end

    local new_global_value = self.Global_Value + new_value

    if type(new_global_value) ~= "number" then
        return
    end

    self.Global_Value = new_global_value

    Fluid_Tech.Is_Dirty = true
end
---@param new_value number
function Fluid_Tech.Scientific:Set_Value(new_value)
    if type(new_value) ~= "number" then
       return
    end

    self.Global_Value = new_value

    Fluid_Tech.Is_Dirty = true
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