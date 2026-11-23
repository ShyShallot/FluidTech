---@class Notifications
Notification_System = {
    Events = {
        ["GALACTIC_PRODUCTION_EVENT"] = {
            Subscribers = {},
        },
        ["GALACTIC_DESTRUCTION_EVENT"] = {
            Subscribers = {},
        }
    },

}

---@param func function
---@param event_name string
function Notification_System:Subscribe(func, event_name)

    if type(event_name) ~= "string" then
        DebugMessage("%s -- Failed to Subscribe to Event, Invalid Event Name Paramater", tostring(Script))
    end

    if type(func) ~= "function" then
        DebugMessage("%s -- Failed to Subscribe to Event %s, Invalid Function Paramater", tostring(Script), tostring(event_name))
        return
    end

    local Event_Entry = self.Events[string.upper(event_name)]

    if Event_Entry == nil then
        DebugMessage("%s -- Failed to Subscribe to Event %s, Unknown Event", tostring(Script), tostring(event_name))
    end

    if Event_Entry.Subscribers == nil then
        DebugMessage("%s -- Failed to Subscribe to Event %s, Event Improperly Defined", tostring(Script), tostring(event_name))
        return
    end
    
    table.insert(Event_Entry.Subscribers, func)

    DebugMessage("%s -- Successfuly Subsribed to Event %s, with function %s", tostring(Script), tostring(event_name), tostring(func))
end

function Notification_System:Process_Events()
    for Event, Data in pairs(self.Events) do
        if type(Event) == "string" then
            
            local Event_Value = GlobalValue.Get(Event)
            if type(Event_Value) == "string" then
                for _, sub_func in pairs(Data.Subscribers) do
                    pcall(sub_func, Event_Value)
                end

                GlobalValue.Set(Event, 0)
            end
        end
    end
end

return Notification_System

