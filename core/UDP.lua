local UDP = {}

UDP.hw_UDP = dofile("hw_UDP.lua")

UDP.send = function(port, ip, data)
  UDP.hw_UDP.send(port, ip, data)
end

UDP.init = function(port, framework)
  UDP.hw_UDP.init(port)
  UDP.framework = framework
end

UDP.stop = function()
  UDP.hw_UDP.stop()
  UDP.hw_UDP = nil
  UDP.framework = nil
end

UDP.register = function(cmd, callback)
  UDP.hw_UDP.register(cmd, UDP.framework.wrapCB(callback))
end

return UDP  


