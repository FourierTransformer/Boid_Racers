#!/usr/bin/env lua
---------------
-- ## Boid, Love2D module for boids
-- @author Shakil Thakur and Nate Balas
-- @copyright 2014
-- @license MIT
-- @script Boid

-- ================
-- Private helpers
-- ================

local setmetatable = setmetatable
local tostring     = tostring
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

function dotProduct(x1, y1, x2, y2)
    return x1 * x2 + y1 * y2
end

function magnitude(x1,y2)
    return math.sqrt(x1^2 + y2^2)
end

function distance(x1,y1,x2,y2)
    return math.sqrt((x1-x2)^2 +(y1-y2)^2)
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
return (('Vector :  %f  %f'):format(tostring(v.x), tostring(v.y)))
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
    return Vector:new(x, y)
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
    -- return bUnit:scalarMult(scalar), self:dot(b)
    local dot = self:dot(b)
    return b:scalarMult(dot), dot
end

--- `Car` class
-- @type Car
local Car = class()
Car.__eq = function(a, b) return (a.p1 == b.p1 and a.p2 == b.p2) end
Car.__tostring = function(r) return "" end

function Car:__init(x, y, img, density)
end

BoidModule = {
    Boid = Boid, 
    _VERSION = "SUPER-BETA"
}
return BoidModule