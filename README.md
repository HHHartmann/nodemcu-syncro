# nodemcu-syncro
add synchronous execution of commands which originally have a callback to indicate execution.

Be able to white code like

```lua
for i = 1 to 10
  tcp.send("Hello World")
end
```


Also have preemptive multitasking:
Start several coroutines which run synchronous code.


```lua
function blinkLed(pin, interval)
  gpio.write(pin, gpio.HIGH)
  fw.wait(interval)
  gpio.write(pin, gpio.LOW)
  fw.wait(interval)
end

fw.start(blinkLed(2, 20))
fw.start(blinkLed(3, 17))
```

which will blink the leds in given intervals.
