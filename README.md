# nodemcu-syncro
add synchronous execution of commands which originally have a callback to indicate execution.

Be able to write code like

```lua
for i = 1 to 10
  tcp.send("Hello World")
end
```


Also have preemptive multitasking:
Start several coroutines which run synchronous code.
Make sure to call wait or some other synchronous function which uses callbacks to allow other coroutines and the system to run.

```lua
function blinkLed(pin, interval)
  gpio.write(pin, gpio.HIGH)
  fw.wait(interval)
  gpio.write(pin, gpio.LOW)
  fw.wait(interval)
end

fw = dofile("SynchronousFramework.lua")
fw.start(blinkLed, 2, 20)    -- will call blinkLed(2, 20) in a separate coroutine
fw.start(blinkLed, 3, 17)
```

which will blink the leds in given intervals. See Examples for another example.
