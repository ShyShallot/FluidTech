--[[
    If you want a unit to be affected by this systme add them to this table, if they are not in here they will not be locked or unlocked accordingly
    ALL ENTRIES MUST BE ALL UPPERCASE even if in XML the unit entry is Star_Destroyer, it MUST BE STAR_DESTROYER in Lua

]]--

---@class Fluid_Tech_Table
Fluid_Tech_Unit_Table = {
    Units = {
        ["STAR_DESTROYER"] = {
            Requirements = {
                ["Industrial"] = 100,
                ["Scientific"] = 50,
            },
            Requirements_Met = false,
        },
        ["R_Ground_Barracks"] = {
            Requirements = {
                ["Industrial"] = 25
            },
            Requirements_Met = false,
        },
    },
    Cateogries = { -- WIP
        ["Frigate"] = {
            Requirements = {
                ["Industrial"] = 25,
            },
            Requirements_Met = false,
        }
    },
    Structures = {
        ["EXAMPLE_INDUSTRIAL_STRUCTURE"] = {
            Type = "Industrial",
            Amount = 25
        },
        ["EXAMPLE_SCIENTIFIC_STRUCTURE"] = {
            Type = "Scientific",
            Amount = 25
        },
        ["EXAMPLE_BAD_INDUSTRIAL_STRUCTURE"] = {
            Type = "Industrial",
            Amount = -50,
        }
    }
    
}

function Fluid_Tech_Unit_Table:Empty(check_string)
    
    if type(check_string) ~= "string" then
        return true
    end

    check_string = string.lower(check_string)

    local table_to_check = nil

    if check_string == "units" then
        table_to_check = self.Units
    elseif check_string == "structure" then
        table_to_check = self.Structures
    end

    if table_to_check == nil then
        return true
    end

    for _ in pairs(table_to_check) do
        return false
    end

    return true
end

function Fluid_Tech_Unit_Table:Resolve_Unit_Data(Unit_Name)
    if type(Unit_Name) ~= "string" then
        return nil
    end

    Unit_Name = string.upper(Unit_Name)

    return self.Units[Unit_Name]
end

function Fluid_Tech_Unit_Table:Resolve_Structure_Data(Structure_Name)
    if type(Structure_Name) ~= "string" then
        return nil
    end

    Structure_Name = string.upper(Structure_Name)

    return self.Structures[Structure_Name]
end

return Fluid_Tech_Unit_Table