require("http")
SynchronousFramework = require("SynchronousFramework")

print ("loading module", moduleName)

local moduleName = ...
local M = {}
_G[moduleName] = M

local syncro = SynchronousFramework

M.get = syncro.CreateSyncFunction(function(cb, url, headers)
                return http.get(url, headers, cb)
              end)

M.put = syncro.CreateSyncFunction(function(cb, url, headers, body)
                return http.put(url, headers, body, cb)
              end)

M.post = syncro.CreateSyncFunction(function(cb, url, headers, body)
                return http.post(url, headers, body, cb)
              end)

M.delete = syncro.CreateSyncFunction(function(cb, url, headers, body)
                return http.delete(url, headers, body, cb)
              end)

M.request = syncro.CreateSyncFunction(function(cb, url, method, headers, body)
                return http.request(url, method, headers, body, cb)
              end)


              
return M
