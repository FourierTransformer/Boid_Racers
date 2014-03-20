#!/usr/bin/env lua
---------------
-- ## Delaunay, Lua module for convex polygon triangulation
-- @author Roland Yonaba
-- @copyright 2013
-- @license MIT
-- @script delaunay

-- ================
-- Private helpers
-- ================

local setmetatable = setmetatable
local tostring     = tostring
local assert       = assert
local unpack       = unpack

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

-- Cross product (p1-p2, p2-p3)
local function crossProduct(a, b)
  return ((a.x*b.y) - (a.y * b.x))
end

-- ================
-- Module classes
-- ================

--- `Vector` class
-- @type Vector
local Vector = class()
Vector.__eq = function(a, b) return (a.p1 == b.p1 and a.p2 == b.p2) end
Vector.__add = function(a, b) return Vector:new(a.x + b.x, a.y + b.y) end
Vector.__mult = function(a, b) return Vector:new(a.x * b.x, a.y * b.y) end
Vector.__sub = function(a, b) return Vector:new(a.x - b.x, a.y - b.y) end
Vector.__div = function(a, b) return Vector:new(a.x / b.x, a.y / b.y) end
Vector.__tostring = function(v)
  return (('Vector :  %d  %d\n'):format(tostring(v.x), tostring(v.y)))
end



--- Creates a new `Vector`
-- @name Vector:new
-- @param x a float
-- @param y a float
-- @return a new `Vector`
-- @usage
-- local Vector = require 'Vector'
-- local v = Vector:new(x,y,width,height)
-- local v = Vector(x,y) -- Alias to Vector:new
-- print(v) -- print the Vector properties
--
function Vector:__init(x, y)
  self.x, self.y = x, y 
end

function Vector:rotate(angle)
  local x = (self.x*math.cos(angle)) - (self.y*math.sin(angle))
  local y = (self.x*math.sin(angle)) + (self.y*math.cos(angle))

  return Vector:new(x,y)
end
function Vector:length()
    return math.sqrt(self.x^2 + self.y^2);
end
function Vector:unit()
    local length = self:length()
    return Vector:new(self.x/length, self.y/length)
end
function Vector:dot(a)
    return self.x * a.x + self.y * a.y
end
function Vector:scalarMult(scalar)
    return Vector:new(self.x*scalar,self.y*scalar)
end
function Vector:projection(b)
    -- local bUnit = b:unit()
    -- local scalar = self:dot(b) / b:length()
    -- return bUnit:scalarMult(scalar)
    local dot = self:dot(b)
    return b:scalarMult(dot), dot
end
--- `Wheel` class
-- @type Wheel
local Wheel = class()
Wheel.__eq = function(a, b) return (a.p1 == b.p1 and a.p2 == b.p2) end
Wheel.__tostring = function(r)
  return (('RigidBody :  %d  %d\n Velocity : %d  %d \nAcceleration : %d  %d\n'):format(tostring(r.x), tostring(r.y),tostring(r.velocity.x), tostring(r.velocity.y),tostring(r.acceleration.x), tostring(r.acceleration.y)))
end
function Wheel:__init(position, radius)
    self.radius = radius
    self.position = position
    self:setSteeringAngle(0)
    self.forwardAxis = Vector:new(0,0)
    self.sideAxis = Vector:new(0,0)
    self.torque,self.speed,self.inertia = 0,0,radius^2
end
function Wheel:addTransmissionTorque(newValue)
  self.torque = self.torque + newValue
end
function Wheel:setSteeringAngle(newAngle)
    self.forwardAxis = Vector:new(0,1)
    self.forwardAxis = self.forwardAxis:rotate(newAngle)
    self.sideAxis = Vector:new(-1,0)
    self.sideAxis = self.forwardAxis:rotate(newAngle)
end
function Wheel:calculateForce(relativeGroundSpeed,dt)
    local patchSpeed = self.forwardAxis:scalarMult(-1 * self.speed * self.radius)
    local velocityDifference = relativeGroundSpeed + patchSpeed
    local forwardMag = 0
    local sideVelocity = velocityDifference:projection(self.sideAxis)
    local forwardVelocity, forwardMag = velocityDifference:projection(self.forwardAxis)
    local responseForce = sideVelocity:scalarMult(-2)
    responseForce = responseForce - forwardVelocity

    self.torque = self.torque + (forwardMag * self.radius)
    self.speed = self.speed + (self.torque / self.inertia * dt)
    self.torque = 0
    return responseForce
end

--- `RigidBody` class
-- @type RigidBody
local RigidBody = class()
RigidBody.__eq = function(a, b) return (a.p1 == b.p1 and a.p2 == b.p2) end
RigidBody.__tostring = function(r)
  return (('RigidBody :  %d  %d\n Velocity : %d  %d \nAcceleration : %d  %d\n'):format(tostring(r.x), tostring(r.y),tostring(r.velocity.x), tostring(r.velocity.y),tostring(r.acceleration.x), tostring(r.acceleration.y)))
end

--- Creates a new `RigidBody`
-- @name RigidBody:new
-- @param x a float
-- @param y a float
-- @param imaage a img_object
-- @return a new `RigidBody`
-- @usage
-- local RigidBody = require 'RigidBody'
-- local r = RigidBody:new(x,y,width,height)
-- local r = RigidBody(x,y,width,height) -- Alias to RigidBody:new
-- print(r) -- print the RigidBody properties
--
function RigidBody:__init(x, y,rotation, image, mass, allWheel)
  self.x, self.y, self.angle = x, y, rotation
  self.image = love.graphics.newImage(image)

  self.velocity = Vector:new(0,0);
  self.acceleration = Vector:new(0,0);
  self.forces = Vector:new(0,0);

  self.mass = mass;
  self.halfsies = Vector:new(self.image:getWidth()/2,self.image:getHeight()/2)
  
  --angular props
  -- self.angle = 0; 
  self.angularVelocity = 0; 
  self.torque = 0; 
  self.inertia  = (1/12) * self.halfsies.x^2 * self.halfsies.y^2 * self.mass;

  --wheels
  self.allWheel = allWheel
  self.wheels = {
    Wheel:new(Vector:new(self.halfsies.x, self.halfsies.y), .5),
    Wheel:new(Vector:new(-self.halfsies.x, self.halfsies.y), .5),
    Wheel:new(Vector:new(self.halfsies.x, -self.halfsies.y), .5),
    Wheel:new(Vector:new(-self.halfsies.x, -self.halfsies.y), .5)
  }
end

function RigidBody:setSteering (steering)
    local steeringLock = 0.75
    self.wheels[1]:setSteeringAngle(-steering * steeringLock);
    self.wheels[2]:setSteeringAngle(-steering * steeringLock);
end

function RigidBody:setThrottle(throttle)
    local torque = 20
    if self.allWheel == true then 
      self.wheels[1]:addTransmissionTorque(throttle * torque)
      self.wheels[2]:addTransmissionTorque(throttle * torque)
    end
    self.wheels[3]:addTransmissionTorque(throttle * torque)
    self.wheels[4]:addTransmissionTorque(throttle * torque)
end

function RigidBody:setBrakes(brakes)
  local brakeTorque = 4
  for i, wheel in ipairs(self.wheels) do
    local wheelVelocity = wheel.speed
    wheel:addTransmissionTorque(-wheelVelocity * brakeTorque * brakes)
  end 
end

function RigidBody:update(dt)
  --print("update") 
  local dt = dt*7
  --wheels
  for i, wheel in ipairs(self.wheels) do
    local worldWheelOffset = self:relativeToWorld(wheel.position)
    print("worldWheelOffset: ", worldWheelOffset)
    local worldGroundVelocity = self:pointVelocity(worldWheelOffset)
    -- print("worldGroundVelocity", worldGroundVelocity)
    local relativeGroundSpeed = self:worldToRelative(worldGroundVelocity)
    -- print("relativeGroundSpeed",relativeGroundSpeed)
    local relativeResponseForce = wheel:calculateForce(relativeGroundSpeed,dt)
    -- print("relativeResponseForce",relativeResponseForce)
    local worldReponseForce = self:relativeToWorld(relativeResponseForce)
    -- print("worldReponseForce", worldReponseForce)
    self:addForce(worldReponseForce,worldWheelOffset)
  end 
  --not wheels
 --  self.acceleration.x = self.forces.x / self.mass
 --  self.acceleration.y = self.forces.y / self.mass
	-- self.velocity.x = self.velocity.x + (self.acceleration.x * dt);
	-- self.velocity.y = self.velocity.y + (self.acceleration.y * dt);
	-- self.x = self.x +  (self.velocity.x * dt);
	-- self.y = self.y + (self.velocity.y * dt);

  local acceleration = self.forces:scalarMult(1/self.mass)
  self.velocity = self.velocity + (acceleration:scalarMult(dt))
  self.x = self.x +  (self.velocity.x * dt);
  self.y = self.y + (self.velocity.y * dt);
  --print(self.forces)
  self.forces = Vector:new(0,0)
  --angular
  print("torque", self.torque)
  local angularAcceleration = self.torque / self.inertia
  self.angularVelocity = self.angularVelocity + (angularAcceleration * dt)
  self.angle = self.angle + (self.angularVelocity * dt)
  self.torque = 0;
end

function RigidBody:updateAcceleration(x,y)
   --print("accel")

	self.acceleration.x = x + self.acceleration.x;
	self.acceleration.y = y + self.acceleration.y;
end

function RigidBody:relativeToWorld(relative)
    local v = Vector:new(relative.x, relative.y) 
    return v:rotate(self.angle)
end

function RigidBody:worldToRelative(world)
    local v = Vector:new(world.x, world.y)
    return v:rotate(-self.angle)
end

function RigidBody:pointVelocity(worldOffset)
  local tangent = Vector:new(-worldOffset.y, worldOffset.x)
  -- print("tangent", tangent)
  -- print("angular", self.angularVelocity)
  -- print("vel",self.velocity)
  return tangent:scalarMult(self.angularVelocity) + self.velocity
end

function RigidBody:addForce(worldForce, worldOffset)
  self.forces = self.forces + worldForce
  self.torque = self.torque + crossProduct(worldOffset,worldForce)
end
car = {
	RigidBody = RigidBody, 
	_VERSION = "superBeta"
}
return car