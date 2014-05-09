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

function carAI:__init(startPosx, startPosy, car,path)
	self.startPosx = startPosx
	self.startPosy = startPosy
    self.car = car
    self.path = path
end

function carAI:update(dt)
	local throttle = 1
	local steering = 1
   self.car:update(steering,throttle, dt) 
end

local car_ai = {
  carAI    = carAI,
  _VERSION = "ULTRA BEETS"
}

return car_ai