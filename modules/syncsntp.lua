require("sntp")
SynchronousFramework = require("SynchronousFramework")

print ("loading module", moduleName)

local moduleName = ...
local M = {}
_G[moduleName] = M

local syncro = SynchronousFramework

-- only support server, not autorepeat as it would generate multiple callbacks
M.sync = syncro.CreateSyncFunctionMultipleCB(function(cbs, server)
                return sntp.sync(server, cbs.success, cbs.error)
              end)
              
return M
