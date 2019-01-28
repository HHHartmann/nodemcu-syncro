
local timer

local framework = {}

framework.this = framework

local function resumeFromCB(co, ...)
  local success, msg =
    coroutine.resume(co, unpack(arg))
  if not success then print("error: coroutine terminated with: ", msg) end
end

-- Wrap the CB inside a command like wait or when getting async
-- calls a function with a callback and handles coroutine context switch 
framework.awaitCB = function(method, ...)
  local co = coroutine.running()
  method(function (...) resumeFromCB(co, unpack(arg)) end, ... )
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


framework.wait = framework.CreateSyncFunction(function(cb, time)
                local timer = tmr.create()
                print("timer:alarm new")
                timer:alarm(time, tmr.ALARM_SINGLE, cb)
              end)


-- Start a new coroutine
-- func   the function to run
-- additional params are handed to func
framework.start = function(func, ...)
  resumeFromCB(coroutine.create(func), unpack(arg))
end

-- define new routine to be called on CB. Starting a new coroutine every time
framework.wrapCB = function(callback)
  return function (...) 
            framework.start(callback, unpack(arg))
         end 
end

print("started Framework")

return framework
