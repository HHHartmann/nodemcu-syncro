local factory = {}

--[[
pins is either  
  { direction = <pin>, speed = <pin> }
or 
  { pin1 = <pin>, pin2 = <pin>}
for direct pulse output

--]]



factory.new = function (pins)

  local DIRECT = 332
  local SPEED_DIRECTION = 7732

  local hw = {}

  local speed = 0.0


  local harmonize = function(value, limit)
    if value > limit then
      return limit
    end
    if value < -limit then
      return -limit
    end
    return value
  end

  local function calcSpeedHeadingValues(speed)
    harmonize(speed, 100)

    local duty,direction = math.abs(speed), gpio.HIGH
    if (speed < 0) then direction = gpio.LOW end
    
    duty = duty / 100 * 1023
  --print(duty, direction)
    return math.min(duty,1023),direction
  end

  local function setMotor()
    local duty,direction = calcSpeedHeadingValues(speed)
    if hw.motorPins.speed then
      pwm.setduty(hw.motorPins.speed,duty)
      gpio.write(hw.motorPins.direction,direction)
    else
      local p1, p2 = hw.motorPins.pin1, hw.motorPins.pin2
      if direction == gpio.LOW then
        p1, p2 = hw.motorPins.pin2, hw.motorPins.pin1
      end

      pwm.close(p1)
      gpio.mode(p1, gpio.OUTPUT)
      gpio.write(p1, gpio.LOW)

      pwm.setup(p2,500,0)
      pwm.start(p2)
      pwm.setduty(p2,duty)
      
    end
  end

  hw.setSpeed = function(speedPercent)
    speed = harmonize(speedPercent, 100)
    setMotor()
  end
    
  hw.getSpeed = function(speedPercent)
    return speed
  end


  --[[
  pins = {speed=3, direction=4}   for DRV8838
  pins = {pin1=3, pin2=4}   for DRV8833
  ]]
  local function setupMotorPins(pins)
    hw.motorPins = pins
    if hw.motorPins.speed then
      pwm.setup(hw.motorPins.speed,500,0)
      pwm.start(hw.motorPins.speed)
      gpio.mode(hw.motorPins.direction,gpio.OUTPUT)

      gpio.mode(6,gpio.OUTPUT) -- set motor driver mode
      gpio.write(6,gpio.HIGH)
    else
      gpio.mode(hw.motorPins.pin1,gpio.OUTPUT)
      gpio.mode(hw.motorPins.pin2,gpio.OUTPUT)
    end
  end

  setupMotorPins(pins)
  hw.setSpeed(0.0)
  return hw  
end

return factory
