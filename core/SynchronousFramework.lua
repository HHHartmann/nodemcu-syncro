
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
framework.awaitCB = function(method)
  local co = coroutine.running()
  method(function (...) resumeFromCB(co, unpack(arg)) end )
  coroutine.yield()
end

framework.wait = function(time)
  local timer = tmr.create()
  framework.awaitCB( function (CB)
                      print("timer:alarm")
                      timer:alarm(time, tmr.ALARM_SINGLE, CB)
                    end )
end

-- Start a new coroutine
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
