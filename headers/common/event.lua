---@class EventListener
---@field id integer
---@field callback function
EventListener = {}

---@class Event
---@field counter number
---@field listeners EventListener[]
---@field subscribe fun(self, callback: function): integer
---@field unsubscribe fun(self, id: integer): boolean
---@field flush fun(self)
---@field invoke fun(self, ...)
Event = {}
