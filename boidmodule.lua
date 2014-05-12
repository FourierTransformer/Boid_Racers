#!/usr/bin/env lua
---------------
-- ## Boid, Love2D module for boids
-- @author Shakil Thakur and Nate Balas
-- @copyright 2014
-- @license MIT
-- @script Boid

-- Imports
local PathFinding = require 'pathfinding'

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

function distance(v1, v2)
    return math.sqrt((v1.x-v2.x)^2 +(v1.y-v2.y)^2)
end

local colors = {
    ["yellow"] = function() love.graphics.setColor(255, 255, 0) end,
    ["magenta"] = function() love.graphics.setColor(255, 0, 255) end,
    ["cyan"] = function() love.graphics.setColor(0, 255, 255) end
}

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

-- handles changes to paths
local colorToPath = {}
-- keeps track of the amount of boids in each path
local colorToNum = {
    ["yellow"] = 0,
    ["magenta"] = 0,
    ["cyan"] = 0,
}
--- `Boid` class
-- @type Boid
local Boid = class()
Boid.__eq = function(a, b) return (a.id == b.id) end
Boid.__tostring = function(r) return "" end

function Boid:__init(id, x, y, path, color)
    self.id = id

    -- Position Velocity Acceleration
    self.startX = x
    self.startY = y
    self.position = Vector:new(x, y)
    self.velocity = Vector:new(0,0)
    self.acceleration = Vector:new(0,0)
    self.path = path
    self.index = 1
    self.color = color

    self.maxSpeed = 15
    self.maxForce = 5
end

function Boid:setStart(x, y)
    self.startX = x
    self.startY = y
end

function Boid:getVertex(roadRadius)
    if distance(self.position, self.path[self.index]) < roadRadius/1.7 then
        self.index = self.index + 1

        -- reset when they get to the end of the path
        if self.index > #self.path then
            self.index = 1
            self.path = colorToPath[self.color]
            self.position = Vector:new(self.startX, self.startY)
        end

    end
    return self.path[self.index]
end

function Boid:addForce(force)
    self.acceleration = self.acceleration + force
end

function Boid:update(dt, roadRadius)
    local dt = dt * 5
    local vertex = self:getVertex(roadRadius)
    local seek = self:seek(vertex)
    self:addForce(seek)
    self.velocity = self.velocity + self.acceleration:scalarMult(dt)
    self.velocity = self.velocity:upperLimit(self.maxSpeed)
    self.position = self.position + self.velocity:scalarMult(dt)

    if self.index >= 2 then
        local a = self.path[self.index - 1]
        local b = self.path[self.index]
        local n = (Vector:new(b.x, b.y) - Vector:new(a.x, a.y)):normalize()
        local aLessPos = a - self.position
        local distance = (aLessPos - n:scalarMult(aLessPos:dot(n))):length()
        if distance > roadRadius-roadRadius/5 then
            self.velocity = self.velocity:scalarMult(.1)
        end
    end

    self.acceleration = Vector:new(0,0)
end

function Boid:draw(roadRadius)
    colors[self.color]()
    love.graphics.circle( "fill", self.position.x, self.position.y, roadRadius/10)
    love.graphics.setColor(255,255,255)
end

function Boid:seek(target)
    local toTarget = target-self.position
    toTarget = toTarget:normalize()
    toTarget = toTarget:scalarMult(self.maxSpeed)
    local steerForce = toTarget - self.velocity
    steerForce = steerForce:upperLimit(self.maxForce)
    return steerForce
end




--- `Motorcade` class
-- @type Motorcade
local Motorcade = class()

Motorcade.__eq = function(a, b) return false end
Motorcade.__tostring = function(r) return "" end

function Motorcade:__init(roadRadius)
    self.boids = {}
    self.roadRadius = roadRadius
    self.numAStar = 0
    self.numGBFS = 0
    self.numUniform = 0
end

function Motorcade:setStart(v)
    for i, b in ipairs(self.boids) do
        b:setStart(v.x, v.y)
    end
end

function Motorcade:setPath(color, path)
    colorToPath[color] = path
end

function Motorcade:updatePath(vertices, graph, goal)
    for i, b in ipairs(self.boids) do
        if b.color == "yellow" then
            b.path = PathFinding.aStar(vertices, graph, b.path[b.index], goal)
            b.index = 1
        elseif b.color == "magenta" then
            b.path = PathFinding.GBFS(vertices, graph, b.path[b.index], goal)
            b.index = 1
        elseif b.color == "cyan" then
            b.path = PathFinding.uniformCost(vertices, graph, b.path[b.index], goal)
            b.index = 1
        end
    end
end

function Motorcade:separation(boid)
    local c = Vector:new(0, 0)
    for i, v in ipairs(self.boids) do
        if b ~= v then
            if (boid.position-v.position):length() < 15 then
                c = c - (v.position - boid.position)
            end
        end
    end
    return c
end

function Motorcade:update(dt, doSeperation, boidSpeed, aStarNum, GBFSNum, uniformNum, startX, startY)
    -- Do seperation if the box is checked otherwise no.
    if doSeperation then
        for i, b in ipairs(self.boids) do
            -- rules go here
            b.velocity = b.velocity + self:separation(b):scalarMult(dt)
            b:update(dt, self.roadRadius)
        end
    else 
        for i, b in ipairs(self.boids) do
            b:update(dt, self.roadRadius)
        end
    end 
    -- Change the amount of boids on screen according to the sliders
    -- Possible TODO: Make the algorithm colors dynamic in a dictonary
    if aStarNum < colorToNum["yellow"] then 
        self:remove(colorToNum["yellow"] - aStarNum, "yellow" )
    elseif aStarNum > colorToNum["yellow"] then
        self:add(startX, startY, colorToPath["yellow"], aStarNum - colorToNum["yellow"], "yellow") 
    end 
    if GBFSNum < colorToNum["magenta"] then 
        self:remove(colorToNum["magenta"] - GBFSNum, "magenta" )
    elseif GBFSNum > colorToNum["magenta"] then
        self:add(startX, startY, colorToPath["magenta"], GBFSNum - colorToNum["magenta"], "magenta") 
    end 
    if uniformNum < colorToNum["cyan"] then 
        self:remove(colorToNum["cyan"] - uniformNum, "cyan" )
    elseif uniformNum > colorToNum["cyan"] then
        self:add(startX, startY, colorToPath["cyan"], uniformNum - colorToNum["cyan"], "cyan") 
    end 

    -- Change boid speed if needed
    self:changeMaxSpeed(boidSpeed)

    -- Toggle sepereation
end


function Motorcade:draw()
   for i, v in ipairs(self.boids) do
        v:draw(self.roadRadius)
    end 
end
-- TODO: This function runs everytime, could check max speed to not have it run everytime.
function Motorcade:changeMaxSpeed(speed)
    for i = 1, #self.boids do 
        self.boids[i].maxSpeed = speed 
    end 
end 


function Motorcade:add(x, y, path, number, color)
    colorToPath[color] = path
    colorToNum[color] = colorToNum[color] + number
    for i = 1, number do
        local id = #self.boids+1
        -- self.boids[ id ] = Boid:new(id, x, y, path, color)
        table.insert(self.boids, Boid:new(id, x, y, path, color))
    end
end

function Motorcade:remove(number, color)
    local removed = 0
    local index = 1
    colorToNum[color] = colorToNum[color] - number
    while removed < number do
        local currentBoid = self.boids[index]
        if currentBoid.color == color then
            table.remove(self.boids, index)
            removed = removed + 1
        end 
        index = index + 1
        if index >= #self.boids then
            return
        end
    end 
end




BoidModule = {
    Boid = Boid,
    Motorcade = Motorcade,
    Vector = Vector,
    _VERSION = "SUPER-BETA"
}
return BoidModule