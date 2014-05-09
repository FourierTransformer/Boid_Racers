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

local carAI = class();

function carAI:__init( car,path)
	self.index = 1
    self.car = car
    self.path = path
end

function carAI:update(dt)
	local throttle = 1
	local steering = 1
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
  -- Determine which direction to turn
  if math.abs(carOrien - vertexOrien) < .25 then
      steering = 0
  elseif math.abs(carOrien - vertexOrien) >= 2 then
      steering = 1
  else
      steering = -1
  end
  if distance(carX, carY, vertexX, vertexY) < 50 then
      self.index = self.index + 1
  end
  print("abs difference orientation: " .. math.abs(carOrien - vertexOrien))
  print("Distance from vertex: " .. distance(carX, carY, vertexX, vertexY))
  print("Steering: " .. steering)
  self.car:update(steering,throttle, dt) 
end

local car_ai = {
  carAI    = carAI,
  _VERSION = "ULTRA BEETS"
}

return car_ai