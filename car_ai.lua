#!/usr/bin/env lua
---------------
-- ## Delaunay, Love2D module for top-down cars
-- @author Shakil Thakur and Nate Balas
-- @copyright 2014
-- @license MIT?
-- @script CartD


-- Internal class constructor
local class = function(...)
  local klass = {}
  klass.__index = klass
  klass.__call = function(_,...) return klass:new(...) end
  function klass:new(...)
    local instance = setmetatable({}, klass)
    klass.__init(instance, ...)
    return instance
  end
  return setmetatable(klass,{__call = klass.__call})
end

-- Modules and things

local carAI = class()
local steering = 1
local lastSteering = 1

function carAI:__init( car,path)
	self.index = 1
    self.car = car
    self.path = path
end

function flipSteering()
  print(lastSteering)
  print(steering)
    steering = lastSteering
    steering = -steering
    lastSteering = steering
end
function noSteering()
  if steering ~= 0 then
    lastSteering = -steering
  end
  print(lastSteering)
  steering = 0
end
function restoreSteering()
  steering = lastSteering
end

function carAI:update(dt)
  if self.index < #self.path then
  	local throttle = 1
    local carX = self.car:getX() 
    local carY = self.car:getY() 
    local vertexX = self.path[self.index].x
    local vertexY = self.path[self.index].y
  	local vectorDirX
  	local vectorDirY
  	local vertexOrien
  	local carOrien
     -- Need to get cars current point and orintation to the next vertex
    vectorDirX = carX - vertexX
    vectorDirY = carY - vertexY
    -- take dot product of vector to next vertex and vector in the 0 degree direction
    -- to match the orientation of the car
    vertexOrien = dotProduct(vectorDirX, vectorDirY, 0, -1)
    vertexOrien = vertexOrien / magnitude(vectorDirX,vectorDirY)
    vertexOrien = math.acos(vertexOrien)
    carOrien = self.car:getAngle() % 2*math.pi
    diff = carOrien - vertexOrien
    -- Determine which direction to turn
    if -.1 < diff and diff < .1 then
        noSteering()
    elseif -math.pi > diff and diff > math.pi then
        flipSteering()
    else
        restoreSteering()
    end
    -- If we get close enough to the current vertex then we should move to the next vertex
    if distance(carX, carY, vertexX, vertexY) < 800 then
        self.index = self.index + 1
    end
    -- Slow down if too fast
    if self.car:getForwardSpeed() > 800 then
      throttle = 0
    end
    print ("carOrien: " .. carOrien .. " vertexOrien: " .. vertexOrien)
    print("difference orientation: " .. diff)
    print("Distance from vertex: " .. distance(carX, carY, vertexX, vertexY))
    print("Steering: " .. steering)
    self.car:update(steering,throttle, dt) 
  else 
        throttle = 0
        self.car:update(steering,throttle, dt) 
  end
end

local car_ai = {
  carAI    = carAI,
  _VERSION = "ULTRA BEETS"
}

return car_ai