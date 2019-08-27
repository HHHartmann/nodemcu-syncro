require("hw_sr04")
SynchronousFramework = require("SynchronousFramework")

local moduleName = ...

print ("loading module", moduleName)

_G[moduleName] = M
local M = {}

local syncro = SynchronousFramework

M.measure = syncro.CreateSyncFunction(function(cb)
                return hw_sr04.measure(cb)
              end)

M.init = function(triggerPin, measurePin)
  hw_sr04.init(triggerPin, measurePin)
end


return M  


