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
	local vertexDirX
	local vertexDirY
	local vertexOrien
	local carOrien
   self.car:update(steering,throttle, dt) 
   -- Need to get cars current point and orintation to the next vertex
   vertexDirX = self.car:getX() - self.path[self.index].x
   vertexDirY = self.car:getY() - self.path[self.index].y
   -- take dot product of vector to next vertex and vector in the 0 degree direction
   -- to match the orientation of the car
   vertexOrien = dotProduct(vertexDirX, vertexDirY, 0, -1)
   vertexOrien = vertexOrien / magnitude(vertexDirX,vertexDirY)
   vertexOrien = math.acos(vertexOrien)
   carOrien = self.car:getAngle()
   print(carOrien)
   -- Determine which direction to turn
end

local car_ai = {
  carAI    = carAI,
  _VERSION = "ULTRA BEETS"
}

return car_ai