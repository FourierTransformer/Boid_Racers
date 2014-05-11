#!/usr/bin/env lua
---------------
-- ## Delaunay, Love2D module for top-down cars
-- @author Shakil Thakur and Nate Balas
-- @copyright 2014
-- @license MIT?
-- @script CartD

local Delaunay = require 'Delaunay'
local Point    = Delaunay.Point
local Voronoi  = require 'Voronoi'


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

local function halton(i, b)
    local result = 0
    local half = 1 / b

    while i > 0 do
        result = result + (i % b) * half
        i = math.floor(i/b)
        half = half / b
    end

    return result
end

-- stolen from http://stackoverflow.com/questions/9079853/lua-print-integer-as-a-binary
local function bits(num)
    -- returns a table of bits, least significant first.
    local t={} -- will contain the bits
    while num>0 do
        rest=math.fmod(num,2)
        t[#t+1]=rest
        num=(num-rest)/2
    end
    return t
end


local function hammerslay(i, n)
    local s = bits(i)
    local out = 0
    for i, v in ipairs(s) do out = out + 2^(-i) * v end
    return i/n, out
end

local function generateGraph(width, height)

    -- Create points
    local points = {}
    for i = 1, vertDistro[1] do
        -- regular random isn't uniform enough, so I did a halton
        points[#points + 1] = Point(halton(i, 2) * width/2, halton(i, 3) * height/2)
    end

    for i = 1, vertDistro[2] do
        -- apparently love's math.random is uniformly distributed?
        points[#points + 1] = Point(love.math.random(width/2, width), love.math.random(0, height/2))
    end

    for i = 1, vertDistro[4] do
        -- random mode
        points[#points + 1] = Point(math.random(0, width/2), math.random(height/2, height))
    end

    for i = 1, vertDistro[3] do
        -- Hammerslay Set for this one!
        local j, k = hammerslay(i, vertDistro[4])
        points[#points + 1] = Point(j * width/2 + width/2, k * height/2 + height/2)
    end

    -- keep track of time.
    local tick
    tick = os.clock()


    -- Triangulating the convex polygon made by those points
    triangles = Delaunay.triangulate(unpack(points))
    print("Delaunay Triangulation:", os.clock() - tick)
    tick = os.clock()


    -- calculate voronoi
    vertices, graph = Voronoi.calculate(triangles)
    print("Voronoi Calclation: ", os.clock() - tick)
    tick = os.clock()

    for i = 1, #graph do
        for j = 1, #graph[i] do
            if i > j then
                local e = graph[i][j]
            end
        end
    end    

    return vertices, graph

end

local function drawEdges(edges)
    for j = 1, #edges do
        love.graphics.line(edges[j])
    end
end

local Map = class()

function Map:__init(roadRadius, width, height, start, finish)
    self.roadRadius = roadRadius
    self.width = width
    self.height = height
    self.canvas = love.graphics.newCanvas(width, height)

    -- generate vertices and graph
    self.vertices, self.graph = generateGraph(self.width, self.height)

    -- generate edges
    self.edges = {}

    for i = 1, #self.graph do
        for j = 1, #self.graph do
            local e = self.graph[i][j]
            if e ~= nil then
                self.edges[ #self.edges+1 ] = {e.p1.x, e.p1.y, e.p2.x, e.p2.y}
            end
        end
    end

    -- start/end
    self.start = start
    self.finish = finish

    -- populate the canvas
    self:populateCanvas()

    -- car handler
    self.cars = {}

end

function Map:draw()
    -- local window_w, window_h = love.graphics.getDimensions()
    -- local x = -self.cars[1]:getX() -- + window_w/2
    -- local y = - -- + window_h/2
    -- local x, y = self.cars[1].body:getWorldCenter()

    -- love.graphics.setCanvas()

    -- love.graphics.push()
    -- love.graphics.translate(window_w/6000, window_h/6000)

    -- love.graphics.push()
    --love.graphics.translate(-x, -y)
    love.graphics.draw(self.canvas, 0, 0)
    
    --self.cars[1]:draw(true)
    -- for _, car in ipairs(self.cars) do
    --     car:draw(true)
    -- end

    -- love.graphics.pop()
    -- love.graphics.pop()

end

function Map:addCar(car)
    self.cars[ #self.cars+1 ] = car
end

local MiniMap = class()
function MiniMap__init(width, height)
    self.width = width
    self.height = height
    self.canvas = love.graphics.newCanvas(width, height)
end

function Map:populateCanvas()
    -- draw the road to an offscreen canvas
    local borderSize = self.roadRadius / 10 -- for roadRadius 20 this is 2
    love.graphics.setCanvas(self.canvas)

    -- handle border on outside of intersections
    love.graphics.setColor(255, 255, 255)
    for i, vertex in ipairs(self.vertices) do
        love.graphics.circle("fill", vertex.x, vertex.y, self.roadRadius/2)
    end

    -- the border of roads
    love.graphics.setColor(255,255,255)
    love.graphics.setLineWidth(self.roadRadius)
    drawEdges(self.edges)

    -- the inside of roads
    love.graphics.setColor(90,90,90)
    love.graphics.setLineWidth((self.roadRadius-borderSize))
    drawEdges(self.edges)

    -- the line down the middle
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(borderSize/2 )
    drawEdges(self.edges)

    -- handle intersections, inside
    love.graphics.setColor(90, 90, 90)
    for i, vertex in ipairs(self.vertices) do
        love.graphics.circle("fill", vertex.x, vertex.y, ((self.roadRadius - borderSize)/2))
    end

    -- draw the start/goal
    love.graphics.setColor(0, 255, 0)
    love.graphics.circle("fill", self.vertices[self.start].x, self.vertices[self.start].y, ((self.roadRadius - borderSize)/2))

    love.graphics.setColor(255, 0, 0)
    love.graphics.circle("fill", self.vertices[self.finish].x, self.vertices[self.finish].y, ((self.roadRadius - borderSize)/2))

    love.graphics.setCanvas()

    -- add noise? This is gonna get cray
    -- it got cray. I killed it because slowdown was tremendous. Might revisit later.
end


function Map:setPath(path)
    self.path = path

    love.graphics.setCanvas(self.canvas)
    local index = 1
    for i, v in ipairs(self.path) do
        love.graphics.setColor(200, 200, 0)
        love.graphics.setPointSize(self.roadRadius/4)
        love.graphics.point(v.x, v.y)
        index = index + 1
    end
    love.graphics.setColor(255, 255, 255)
    love.graphics.setCanvas()
end

MapModule = {
    Map = Map,
    Minimap = Map, 
    _VERSION = "SUPER-BETA"
}
return MapModule