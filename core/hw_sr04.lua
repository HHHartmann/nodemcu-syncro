local moduleName = ...

print ("loading module", moduleName)

local M = {}
_G[moduleName] = M

local trig, echo
local callback
local echo_start = 0

local function deregister_echo_cb()
  gpio.trig(echo)
end

local function trigger()
  print("triggering")
  gpio.serout(trig, gpio.HIGH, {120000, 120000}, 1 , function() end) -- actually 10 us would be enough, but we want to be safe
  print("after trigger")
end

local echo_cb = function(level, timestamp, count)

--  print("trigger CB", level, timestamp, count)
  if level == gpio.HIGH then
    -- rising edge
    --print("rising edge")
    echo_start = timestamp
  else
    -- falling edge
    print("falling edge")
    print(timestamp-echo_start)
    local echo_time = timestamp-echo_start
    if echo_time <= 0 then
      print("Trigger_time <= 0. Retrying.")
      trigger()
    else
      deregister_echo_cb()
      cb = nil
      callback((timestamp-echo_start)/58)
    end
  end
end

local function register_echo_cb()
  gpio.trig(echo, "both", echo_cb)
end

M.init = function(triggerPin, measurePin)
  trig = triggerPin
  echo = measurePin

  gpio.mode(trig, gpio.OUTPUT)
	gpio.mode(echo, gpio.INT)
  deregister_echo_cb()
end


-- cb is called with distance in cm
M.measure = function(cb)
  callback = cb
  register_echo_cb()
  trigger()
end


return M