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
---@param HumanPlayer PlayerWrapper
function Fluid_Tech:Init(HumanPlayer)
    if self.Unit_Tech_Table == nil then
        self.Unit_Tech_Table = require("FluidTech/Unit_Tech_Table")
    end

    for Unit_Name, _ in pairs(self.Unit_Tech_Table.Units) do
        table.insert(self.Local_Unit_Table.Locked, Unit_Name)
    end

    if HumanPlayer ~= nil then
        if HumanPlayer.Get_Faction_Name ~= nil then
            self.Human = HumanPlayer
        end
    end

    self.Notifications = require("FluidTech/Notification")

    self.Setup = true
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

    self.Notification_System:Process_Events()

    if not self.Is_Dirty then
        return
    end

    self:Check_Units()

    self.Is_Dirty = false
    
end
---@private
function Fluid_Tech:Structure_Search()

    local Structure_List = Find_All_Objects_Of_Type(self.Human, self.Structure_Type_Search)

    if table.getn(Structure_List) < 1 then
        return
    end

    for _, Structure in pairs(Structure_List) do
        if TestValid(Structure) then
            if self.Specific_Structure_List[Structure] == nil then

                local Structure_Data = self.Unit_Tech_Table:Resolve_Structure_Data()

                if Structure_Data ~= nil then

                    local Structure_Name = Structure.Get_Type().Get_Name()

                    self.Specific_Structure_List[Structure] = {
                        Data = Structure_Data,
                        Name = Structure_Name
                    }
                end
            end
        end
    end
end

---@private
function Fluid_Tech:Structure_Update()
    if table.getn(self.Specific_Structure_List) < 1 then
        return
    end

    local New_Industrial_Value = 0

    local New_Scientific_Value = 0

    for Structure, Structure_Data in pairs(self.Specific_Structure_List) do
        if type(Structure_Data.Data) == "table" then
            if type(Structure_Data.Data.Industrial) == "number" then
                New_Industrial_Value = New_Industrial_Value + Structure_Data.Data.Industrial
            end
            
            if type(Structure_Data.Data.Scientific) == "number" then
                New_Scientific_Value = New_Scientific_Value + Structure_Data.Data.Scientific
            end
        end
    end

    if type(New_Industrial_Value) == "number" then

        self.Industrial.Global_Value = New_Industrial_Value
    
    end

    if type(New_Scientific_Value) == "number" then

        self.Scientific.Global_Value = New_Scientific_Value
    
    end
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
