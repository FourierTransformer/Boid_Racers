#!/usr/bin/env lua
---------------
-- ## Boid, Love2D module for boids
-- @author Shakil Thakur and Nate Balas
-- @copyright 2014
-- @license MIT
-- @script Boid
require 'loveframes'
local BoidModule  = require 'boidmodule'
local Vector      = BoidModule.Vector

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

-- Create GUI class 
local GraphicalUserInterface = class()

local slider1
local slider2
local slider3
local slider4
local checkbox1
local button

function GraphicalUserInterface:__init(ps)
    self.ps             = ps
    self:initVars()
    self.aStarBoids     = slider1
    self.GBFSBoids      = slider2
    self.uniformBoids   = slider3
    self.boidSpeed      = slider4
    self.demoSpeed      = slider5
    self.seperation     = checkbox1
    self.restart        = button 
end

function GraphicalUserInterface:mouseReleased(x, y, button, start, goal)
    loveframes.mousereleased(x, y, button)

    if button == "l" then
        -- create vector with mouse coords
        local mouseLoc = Vector:new(x, y)
        if love.mouse.getCursor() == goalCursor then
            local newGoal = findNearestVertex(mouseLoc)
            if newGoal ~= nil then
                goal = newGoal
                updateGoal()
            end
        
        -- if startCursor is changed
        elseif love.mouse.getCursor() == startCursor then
            local newStart = findNearestVertex(mouseLoc)
            if newStart ~= nil then
                start = newStart
                updateStart()
            end
        end

        -- set cursor back
        love.mouse.setCursor()
    end
end

function GraphicalUserInterface:mousePressed(x, y, button, start, goal)
  -- LOVEFRAMES
  loveframes.mousepressed(x, y, button)

  if button == "l" then
    local mouseVec = Vector:new(x,y)
    
    if distance(start, mouseVec) < 100 then
      love.mouse.setCursor(startCursor)
    end

    if distance(goal, mouseVec) < 100 then
      love.mouse.setCursor(goalCursor)
    end

  end
end 

function GraphicalUserInterface:update(dt)
    loveframes.update(dt)
end 

function GraphicalUserInterface:draw()
    loveframes.draw()
end 

function GraphicalUserInterface:initVars()
    -- Define our locals and create the GUI interface
    local ps = self.ps

    --------------------------------------
    local panelWidth=300*ps
    local panel = loveframes.Create("panel")
    panel:SetSize(panelWidth, love.graphics.getHeight())
    panel:SetPos(love.graphics.getWidth()-panelWidth, 0)


    -- Just text things apparently
    local list1 = loveframes.Create("list", frame)
    list1:SetPos(980*ps, 0)
    list1:SetSize(300*ps, 70*ps)
    list1:SetPadding(20)
    list1:SetSpacing(10)

    -- IT'S US!
    local text1 = loveframes.Create("text")
    text1:SetFont(love.graphics.newFont(12*ps))
    text1:SetText("BOID RACERS\nNate Balas & Shakil Thakur")
    list1:AddItem(text1)

    --------------------------------------
    -- There should be 4 sliders for road frequency
    slider1 = loveframes.Create("slider", frame)
    slider1:SetPos(1000*ps, 110*ps)
    slider1:SetWidth(270*ps)
    slider1:SetMinMax(1, 100)
    slider1:SetValue(60)
    slider1:SetText("A* Boids")
    slider1:SetDecimals(0)

    local s1text1 = loveframes.Create("text", panel)
    s1text1:SetPos(20*ps, 90*ps)
    s1text1:SetFont(love.graphics.newFont(10*ps))
    s1text1:SetText(slider1:GetText())

    local s1text2 = loveframes.Create("text", panel)
    s1text2:SetFont(love.graphics.newFont(10*ps))
    s1text2.Update = function(object, dt)
        object:SetPos((290 - object:GetWidth())*ps, 90*ps)
        object:SetText(slider1:GetValue())
    end

    --------------------------------------

    slider2 = loveframes.Create("slider", frame)
    slider2:SetPos(1000*ps, 160*ps)
    slider2:SetWidth(270*ps)
    slider2:SetMinMax(1, 100)
    slider2:SetValue(60)
    slider2:SetText("GBFS Boids")
    slider2:SetDecimals(0)

    local s2text1 = loveframes.Create("text", panel)
    s2text1:SetPos(20*ps, 150*ps)
    s2text1:SetFont(love.graphics.newFont(10*ps))
    s2text1:SetText(slider2:GetText())

    local s2text2 = loveframes.Create("text", panel)
    s2text2:SetFont(love.graphics.newFont(10*ps))
    s2text2.Update = function(object, dt)
        object:SetPos((290 - object:GetWidth())*ps, 150*ps)
        object:SetText(slider2:GetValue())
    end

    --------------------------------------

    slider3 = loveframes.Create("slider", frame)
    slider3:SetPos(1000*ps, 210*ps)
    slider3:SetWidth(270*ps)
    slider3:SetMinMax(1, 100)
    slider3:SetValue(60)
    slider3:SetText("Uniform Cost Boids")
    slider3:SetDecimals(0)

    local s3text1 = loveframes.Create("text", panel)
    s3text1:SetPos(20*ps, 200*ps)
    s3text1:SetFont(love.graphics.newFont(10*ps))
    s3text1:SetText(slider3:GetText())

    local s3text2 = loveframes.Create("text", panel)
    s3text2:SetFont(love.graphics.newFont(10*ps))
    s3text2.Update = function(object, dt)
        object:SetPos((290 - object:GetWidth())*ps, 200*ps)
        object:SetText(slider3:GetValue())
    end

    --------------------------------------

    slider4 = loveframes.Create("slider", frame)
    slider4:SetPos(1000*ps, 260*ps)
    slider4:SetWidth(270*ps)
    slider4:SetMinMax(0, 30)
    slider4:SetValue(10)
    slider4:SetText("Boid Speed")
    slider4:SetDecimals(0)

    local s4text1 = loveframes.Create("text", panel)
    s4text1:SetPos(20*ps, 250*ps)
    s4text1:SetFont(love.graphics.newFont(10*ps))
    s4text1:SetText(slider4:GetText())

    local s4text2 = loveframes.Create("text", panel)
    s4text2:SetFont(love.graphics.newFont(10*ps))
    s4text2.Update = function(object, dt)
        object:SetPos((290 - object:GetWidth())*ps, 250*ps)
        object:SetText(slider4:GetValue())
    end

    --------------------------------------    

    slider5 = loveframes.Create("slider", frame)
    slider5:SetPos(1000*ps, 310*ps)
    slider5:SetWidth(270*ps)
    slider5:SetMinMax(0, 100)
    slider5:SetValue(25)
    slider5:SetText("Demo Speed")
    slider5:SetDecimals(0)

    local s5text1 = loveframes.Create("text", panel)
    s5text1:SetPos(20*ps, 300*ps)
    s5text1:SetFont(love.graphics.newFont(10*ps))
    s5text1:SetText(slider5:GetText())

    local s5text2 = loveframes.Create("text", panel)
    s5text2:SetFont(love.graphics.newFont(10*ps))
    s5text2.Update = function(object, dt)
        object:SetPos((290 - object:GetWidth())*ps, 300*ps)
        object:SetText(slider5:GetValue())
    end

    --------------------------------------

    -- then a checkbox for Boid Separation
    checkbox1 = loveframes.Create("checkbox", panel)
    checkbox1:SetText("Boid Separation")
    checkbox1:SetPos(20*ps, 390*ps)
    checkbox1:SetFont(love.graphics.newFont(12*ps))
    checkbox1:SetChecked(true)

    --------------------------------------
         
    button = loveframes.Create("button", panel)
    -- button:SetPos(20*ps, 450*ps)
    button:SetWidth(500)
    button:SetHeight(50)
    button:SetText("Generate Map")
    button:Center()
    button.OnClick = function(object, x, y)
        object:SetText("Loading")
    end
    button.OnMouseExit = function(object)
        object:SetText("Generate Map")
    end 
end 

function GraphicalUserInterface:getAStarBoids()
	return self.aStarBoids:GetValue()
end 

function GraphicalUserInterface:getGBFSBoids()
	return self.GBFSBoids:GetValue()
end 

function GraphicalUserInterface:getUniformBoids()
	return self.uniformBoids:GetValue()
end 

function GraphicalUserInterface:getBoidSpeed()
	return self.boidSpeed:GetValue()
end 

function GraphicalUserInterface:getSeperation()
	return self.seperation:GetChecked()
end 

function GraphicalUserInterface:getDemoSpeed()
    return self.demoSpeed:GetValue()
end 

function GraphicalUserInterface:getRestart()
    return self.restart:GetText()
end 
GUI = {
    GraphicalUserInterface = GraphicalUserInterface,
    _VERSION = "SUPER-BETA"
}
return GUI