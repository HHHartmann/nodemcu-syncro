local function method_1(framework)
  local i
  for i = 1, 10 do
    print("method_1 iteration", i)
    framework.wait(1500)
  end
end

local function method_2(framework)
  local i
  for i = 1, 5 do
    print("method_2 iteration", i)
    framework.wait(4000)
  end
end

local framework = dofile("SynchronousFramework.lua")
framework.start(method_1, framework)
framework.start(method_2, framework)
