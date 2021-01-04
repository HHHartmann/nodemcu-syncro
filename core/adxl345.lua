--------------------------------------------------------------------------------
-- asxl345 I2C module for NODEMCU
-- NODEMCU TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Gregor Hartmann (HHHartmann at GitHub)
--------------------------------------------------------------------------------

require("bit")
require("i2c")

local moduleName = ...
print ("loading module", moduleName)

local M = {}
_G[moduleName] = M


local i2c_id = 0
local adxl345_i2c_addr = 0x53
local adxl345_i2c_addr2 = 0x1D

local addr_DEVID          = 0x00
local addr_THRESH_TAP     = 0x1D
local addr_OFSX           = 0x1E
local addr_OFSY           = 0x1F
local addr_OFSZ           = 0x20
local addr_DUR            = 0x21
local addr_Latent         = 0x22
local addr_Window         = 0x23
local addr_THRESH_ACT     = 0x24
local addr_THRESH_INACT   = 0x25
local addr_TIME_INACT     = 0x26
local addr_ACT_INACT_CTL  = 0x27
local addr_THRESH_FF      = 0x28
local addr_TIME_FF        = 0x29
local addr_TAP_AXES       = 0x2A
local addr_ACT_TAP_STATUS = 0x2B
local addr_BW_RATE        = 0x2C
local addr_POWER_CTL      = 0x2D
local addr_INT_ENABLE     = 0x2E
local addr_INT_MAP        = 0x2F
local addr_INT_SOURCE     = 0x30
local addr_DATA_FORMAT    = 0x31
local addr_DATAX0         = 0x32
local addr_DATAX1         = 0x33
local addr_DATAY0         = 0x34
local addr_DATAY1         = 0x35
local addr_DATAZ0         = 0x36
local addr_DATAZ1         = 0x37
local addr_FIFO_CTL       = 0x38
local addr_FIFO_STATUS    = 0x39



local function r8u(reg)
    local ret;

    i2c.start(i2c_id)
    i2c.address(i2c_id, adxl345_i2c_addr, i2c.TRANSMITTER)
    i2c.write(i2c_id, reg)
    i2c.stop(i2c_id)
    i2c.start(i2c_id)
    i2c.address(i2c_id, adxl345_i2c_addr, i2c.RECEIVER)
    ret = i2c.read(i2c_id, 1)
    i2c.stop(i2c_id)
    return string.byte(ret, 1)
end

local function w8u(reg, val)
    i2c.start(i2c_id)
    i2c.address(i2c_id, adxl345_i2c_addr, i2c.TRANSMITTER)
    i2c.write(i2c_id, reg)
    i2c.write(i2c_id, val)
    i2c.stop(i2c_id)
end

function M.setup()
    local  devid

    devid = r8u(0, 0x00)

    if devid ~= 229 then
        print ("device not found: ", devid)
    end

    -- Enable sensor
    w8u(addr_POWER_CTL, 0x1c) -- D5:Link D4:AUTO_SLEEP D3:Measure D2:Sleep D1-D0:Wakeup

    -- reset interrupts
    w8u(addr_INT_ENABLE, 0x00) -- enable activity interrupt
    w8u(addr_ACT_INACT_CTL, 0x00)
    -- w8u(addr_INT_MAP, 0x00)   -- D4 Activity = 0 for int1
    -- w8u(addr_THRESH_ACT, 6)   -- The scale factor is 62.5 mg/LSB

    r8u(addr_INT_SOURCE)  -- read int source to reset interrupt
end


function M.read()

    local x,y,z;

    i2c.start(0);
    i2c.address(0, adxl345_i2c_addr, i2c.TRANSMITTER);
    i2c.write(0, addr_DATAX0);
    i2c.start(0);
    i2c.address(0, adxl345_i2c_addr, i2c.RECEIVER);
    local data
    
    data = i2c.read(0,6)
    i2c.stop(0);

    x = bit.bor(string.byte(data, 2) * 256, string.byte(data, 1))
    y = bit.bor(string.byte(data, 4) * 256, string.byte(data, 3))
    z = bit.bor(string.byte(data, 6) * 256, string.byte(data, 5))

    if x > 0x7fff then x = x - 0x10000 end
    if y > 0x7fff then y = y - 0x10000 end
    if z > 0x7fff then z = z - 0x10000 end

    return x,y,z
end

local function InterruptCallback(when, cb)
  print(when)
  cb(when)
  r8u(addr_INT_SOURCE)  -- read int source to reset interrupt
end
 
local activity_cb

function M.activity(GPIO, cb)
  local ctrl, enable 

  activity_cb = cb
  if cb then
    ctrl = 0xf0   -- ACT ac/dc ACT_X enable ACT_Y enable ACT_Z enable 
    enable = 0x10
    gpio.mode(GPIO,gpio.INT)
    gpio.trig(GPIO, "up", function(level, when, eventcount) InterruptCallback(when, cb) end)
  else
    ctrl = 0x00
    enable = 0x00
    gpio.mode(GPIO,gpio.INT)
    gpio.trig(GPIO)
  end
  
  w8u(addr_THRESH_ACT, 6)   -- The scale factor is 62.5 mg/LSB
  w8u(addr_INT_MAP, 0x00)   -- D4 Activity = 0 for int1
  w8u(addr_ACT_INACT_CTL, ctrl)
  w8u(addr_INT_ENABLE, enable) -- enable activity interrupt
  
end

return M
