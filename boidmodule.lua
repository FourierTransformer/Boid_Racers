#!/usr/bin/env lua
---------------
-- ## Boid, Love2D module for boids
-- @author Shakil Thakur and Nate Balas
-- @copyright 2014
-- @license MIT
-- @script Boid

-- Imports
local class       = require 'libs/middleclass/middleclass'
local PathFinding = require 'pathfinding'
local Vector      = require 'vector'

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
-- handles changes to paths
local colorToPath = {}
-- keeps track of the amount of boids in each path
local colorToNum
-- looks up the color for a certain algorithm
local algoToColor = {
    ["aStar"]   = "yellow",
    ["GBFS"]    = "magenta",
    ["uniform"] = "cyan",
}
--- `Boid` class
-- @type Boid
local Boid = class("Boid")
Boid.__eq = function(a, b) return (a.id == b.id) end
Boid.__tostring = function(r) return "" end

function Boid:initialize(id, x, y, path, color)
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

    self.size = 2

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
    love.graphics.circle( "fill", self.position.x, self.position.y, self.size)
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

function Boid:setSize(size)
    self.size = size
end


--- `Motorcade` class
-- @type Motorcade
local Motorcade = class("Motorcade")

Motorcade.__eq = function(a, b) return false end
Motorcade.__tostring = function(r) return "" end

function Motorcade:initialize(roadRadius)
    self.boids = {}
    self.roadRadius = roadRadius
    self.numAStar = 0
    self.numGBFS = 0
    self.numUniform = 0
    self.neighborDist = 20
    self.pixelScale = love.window.getPixelScale()
    self.boidSize = roadRadius/20

    colorToNum = {
    ["yellow"] = 0,
    ["magenta"] = 0,
    ["cyan"] = 0,
    }
end

function Motorcade:setStart(v)
    for i, b in ipairs(self.boids) do
        b:setStart(v.x, v.y)
    end
end

function Motorcade:setBoidSize(v)
    self.boidSize = v*self.pixelScale
    for i, b in ipairs(self.boids) do
        b:setSize(self.boidSize)
    end
end

function Motorcade:setNeighborDistance(v)
    self.neighborDist = v * self.pixelScale
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
    local neighborDist = self.neighborDist * .75
    local c = Vector:new(0, 0)
    for i, v in ipairs(self.boids) do
        if boid ~= v then
            if (boid.position-v.position):length() < neighborDist then
                c = c - (v.position - boid.position)
            end
        end
    end
    return c
end

function Motorcade:cohesion(boid)
    local neighborDist = self.neighborDist
    local averageSum = Vector:new(0,0)
    local neighbors = 0

    for i, v in ipairs(self.boids) do 
        if boid ~= v then 
            local distance = distance(boid.position,v.position)
            if distance < neighborDist and distance > 0 then 
                averageSum = averageSum + v.position
                neighbors = neighbors + 1
            end 
        end
    end 
    if neighbors > 0 then 
        avarageSum  = averageSum:scalarDiv(neighbors)
        return boid:seek(averageSum)
    else
        return Vector:new(0,0)
    end 
end

function Motorcade:alignment(boid)
    local neighborDist = self.neighborDist
    local averageSum = Vector:new(0,0)
    local neighbors = 0

    for i, v in ipairs(self.boids) do 
        if boid ~= v then 
            local distance = distance(boid.position,v.position)
            if distance < neighborDist and distance > 0 then 
                averageSum = averageSum + v.velocity
                neighbors = neighbors + 1
            end 
        end
    end 
    if neighbors > 0 then 
        avarageSum  = averageSum:scalarDiv(neighbors)
        averageSum = averageSum:normalize()
        averageSum = averageSum:scalarMult(self.maxSpeed)
        steer =  averageSum - self.velocity
        steer:upperLimit(self.maxForce)
        return steer
    else
        return Vector:new(0,0)
    end    
end  

function Motorcade:update(dt, alignment, cohesion, doSeperation, boidSpeed, aStarNum, GBFSNum, uniformNum, startX, startY)
    -- Do seperation if the box is checked otherwise no.
        for i, b in ipairs(self.boids) do
            -- rules go here
            local seperationMult = dt * (doSeperation/25)
            local cohesionMult = dt * (cohesion/25)
            local alignmentMult = dt * (alignment/25)
            b.velocity = b.velocity + self:separation(b):scalarMult(seperationMult)  
            b.velocity = b.velocity + self:cohesion(b):scalarMult(cohesionMult)
            b.velocity = b.velocity + self:cohesion(b):scalarMult(alignmentMult)
            b:update(dt, self.roadRadius)
        end
    -- Change the amount of boids on screen according to the sliders
    local aStarColor  = algoToColor["aStar"]
    local GBFSColor   = algoToColor["GBFS"]
    local uniform     = algoToColor["uniform"]
    self:adjustNumBoids(startX, startY, aStarNum, colorToNum[aStarColor], aStarColor, colorToPath[aStarColor] )
    self:adjustNumBoids(startX, startY, GBFSNum, colorToNum[GBFSColor], GBFSColor, colorToPath[GBFSColor] )
    self:adjustNumBoids(startX, startY, uniformNum, colorToNum[uniform], uniform, colorToPath[uniform] )

    -- Change boid speed if needed
    self:changeMaxSpeed(boidSpeed)
end

function Motorcade:adjustNumBoids(startX, startY, newNum, oldNum, color, path)
    if newNum < oldNum then 
        self:remove(oldNum - newNum, color )
    elseif newNum > oldNum then
        self:add(startX, startY, path, newNum - oldNum, color) 
    end     
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

-- TODO: Crashes when I change the number of boids with sliders. Should probably fix.
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
            index = 1
        end
    end 
end

BoidModule = {
    Boid = Boid,
    Motorcade = Motorcade,
    _VERSION = "SUPER-BETA"
}
return BoidModule