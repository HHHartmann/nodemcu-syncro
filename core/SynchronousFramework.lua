
local timer

local framework = {}

local function resumeFromCB(co, ...)
  local success, msg =
    coroutine.resume(co, ...)
  if not success then print("error: coroutine terminated with: ", msg) end
end

-- Wrap the CB inside a command like wait or when getting async
-- calls a function with a callback and handles coroutine context switch 
framework.awaitCB = function(method, ...)
  local co = coroutine.running()
  local cb = function (...) resumeFromCB(co, ...) end 
  method(cb , ... )
  return coroutine.yield()
end


-- creates a method which can be called with params and returns the params of the callback.
-- func is a function which is called with a callback function as first param followed by the params given to the function
--      it has to call the desired function
-- the return values are the values given to the callback function
framework.CreateSyncFunction = function(func)
  return function (...)
    return framework.awaitCB( func, ... )
  end
end


-- Wrap the CB inside a command like wait or when getting async
-- calls a function with multiple callbacks and handles coroutine context switch 
framework.awaitCBMulti = function(method, ...)
  local co = coroutine.running()
  local cbs = {}
  local mt = {}
  setmetatable(cbs, mt)
  -- cbs.cbName muss ein wrapper sein, der einfach den name vor die Params klemmt
  mt.__index =  function(table, key)
                  return   function (...) resumeFromCB(co, key, ...) end 
                end
  method(cbs , ... )
  return coroutine.yield()
end

-- create a sync function just as above but for callbacks the passed array which dynamically creates as many CBs as you need.
-- func is a function which is called with a an array of callback functions as first param followed by the params given to the function.
--      exactly one callback is to be called once!!
-- returns as first value the name of the executed callback followed by the params passed to the callback of the called functionality
-- Can be used e.g. for http module which has a succes and a failed callback.
framework.CreateSyncFunctionMultipleCB = function(func)
  return function (...)
    return framework.awaitCBMulti( func, ... )
  end
end


framework.wait = framework.CreateSyncFunction(function(cb, time)
                local timer = tmr.create()
                print("timer:alarm")
                timer:alarm(time, tmr.ALARM_SINGLE, cb)
              end)

              
framework.wait2 = framework.CreateSyncFunctionMultipleCB(function(cbs, time)
                local timer = tmr.create()
                print("timer:alarm")
                timer:alarm(time, tmr.ALARM_SINGLE, cbs.timeout)
              end)

              

-- Start a new coroutine
-- func   the function to run
-- additional params are handed to func
framework.start = function(func, ...)
  resumeFromCB(coroutine.create(func), ...)
end

-- define new routine to be called on CB. Starting a new coroutine every time
framework.wrapCB = function(callback)
  return function (...) 
            framework.start(callback, ...)
         end 
end

print("started Framework")

return framework
