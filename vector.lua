local class = require "libs/middleclass/middleclass"

--- `Vector` class
-- @type Vector
local Vector = class("Vector")
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
function Vector:initialize(x, y)
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

function Vector:normalize()
    local mag = self:length();
    return Vector:new(self.x/mag, self.y/mag)
end

function Vector:scalarMult(scalar)
    return Vector:new(self.x*scalar,self.y*scalar)
end

function Vector:scalarSub(scalar)
    return Vector:new(self.x-scalar,self.y-scalar)
end

function Vector:scalarDiv(scalar)
    return Vector:new(self.x/scalar,self.y/scalar)
end

function Vector:upperLimit(limit)
    local x = self.x
    local y = self.y
    if x > limit then
        x = limit
    end
    if y > limit then 
        y = limit
    end
    return Vector:new(x,y)
end

function Vector:projection(b)
    -- local bUnit = b:unit()
    -- local scalar = self:dot(b) / b:length()
    -- return bUnit:scalarMult(scalar), self:dot(b)
    local dot = self:dot(b)
    return b:scalarMult(dot), dot
end
