local UDP = {}
UDP.hooks = {}



local function processUDP(_, data) 
  local cmd, arg = data:match('([A-Za-z0-9]+)=(.*)')
  print("received", cmd, arg)
  if UDP.hooks[cmd] then
    UDP.hooks[cmd](cmd, arg)
  end
end

UDP.send = function(port,ip,data)
  UDP.socket:send(port,ip,data)
end

UDP.init = function(port)
  if UDP.socket then
    UDP.socket:close()
  end
  UDP.socket = net.createUDPSocket()
print("open socket", port)
  UDP.socket:listen(port)
  UDP.socket:on("receive", processUDP)
end

UDP.stop = function()
  UDP.socket:close()
  UDP.socket = nil
end

UDP.register = function(cmd, callback)
  UDP.hooks[cmd] = callback
end

return UDP
