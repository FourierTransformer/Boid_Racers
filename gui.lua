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
local slider5
local slider6
local slider7
local slider8
local button

function GraphicalUserInterface:__init(ps)
    self.ps             = ps
    self:initVars()
    self.aStarBoids     = slider1
    self.GBFSBoids      = slider2
    self.uniformBoids   = slider3
    self.boidSpeed      = slider4
    self.demoSpeed      = slider5
    self.seperation     = slider6
    self.cohesion       = slider7
    self.alginment      = slider8
    self.restart        = button 
end

function GraphicalUserInterface:mouseReleased(x, y, button, start, goal)
    loveframes.mousereleased(x, y, button)
end

function GraphicalUserInterface:mousePressed(x, y, button, start, goal)
  -- LOVEFRAMES
  loveframes.mousepressed(x, y, button)
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
    loveframes.SetState("boids")

    local panelWidth=300*ps
    local panel = loveframes.Create("panel")
    panel:SetSize(panelWidth, love.graphics.getHeight())
    panel:SetPos(love.graphics.getWidth()-panelWidth, 0)
    panel:SetState("boids")

             
    local form = loveframes.Create("form", frame)
    form:SetPos(love.graphics.getWidth()-panelWidth, 650*ps)
    form:SetSize(panelWidth, 65*ps)
    form:SetLayoutType("horizontal")
    form:SetName("Settings")
    form:SetState("boids")
         
    local settings1 = loveframes.Create("button")
    settings1:SetText("Boids")
    settings1:SetWidth((300/2-5)*ps)
    settings1.OnClick = function (object)
        loveframes.SetState("boids")
    end
    form:AddItem(settings1)


    local settings2 = loveframes.Create("button")
    settings2:SetText("Paths")
    settings2:SetWidth((300/2-5)*ps)
    settings2.OnClick = function (object)
        loveframes.SetState("paths")
    end
    form:AddItem(settings2)

    -- Just text things apparently
    local list1 = loveframes.Create("list", frame)
    list1:SetPos(980*ps, 0)
    list1:SetSize(300*ps, 70*ps)
    list1:SetPadding(20)
    list1:SetSpacing(10)
    list1:SetState("boids")

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
    slider1:SetState("boids")

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
    slider2:SetState("boids")

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
    slider3:SetState("boids")

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
    slider4:SetState("boids")

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
    slider5:SetText("Simulation Speed")
    slider5:SetDecimals(0)
    slider5:SetState("boids")

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

    slider6 = loveframes.Create("slider", frame)
    slider6:SetPos(1000*ps, 360*ps)
    slider6:SetWidth(270*ps)
    slider6:SetMinMax(0, 100)
    slider6:SetValue(25)
    slider6:SetText("Boid Seperation")
    slider6:SetDecimals(0)
    slider6:SetState("boids")

    local s6text1 = loveframes.Create("text", panel)
    s6text1:SetPos(20*ps, 350*ps)
    s6text1:SetFont(love.graphics.newFont(10*ps))
    s6text1:SetText(slider6:GetText())

    local s6text2 = loveframes.Create("text", panel)
    s6text2:SetFont(love.graphics.newFont(10*ps))
    s6text2.Update = function(object, dt)
        object:SetPos((290 - object:GetWidth())*ps, 350*ps)
        object:SetText(slider6:GetValue())
    end

    --------------------------------------

    slider7 = loveframes.Create("slider", frame)
    slider7:SetPos(1000*ps, 410*ps)
    slider7:SetWidth(270*ps)
    slider7:SetMinMax(0, 100)
    slider7:SetValue(25)
    slider7:SetText("Boid Cohesion")
    slider7:SetDecimals(0)
    slider7:SetState("boids")

    local s7text1 = loveframes.Create("text", panel)
    s7text1:SetPos(20*ps, 400*ps)
    s7text1:SetFont(love.graphics.newFont(10*ps))
    s7text1:SetText(slider7:GetText())

    local s7text2 = loveframes.Create("text", panel)
    s7text2:SetFont(love.graphics.newFont(10*ps))
    s7text2.Update = function(object, dt)
        object:SetPos((290 - object:GetWidth())*ps, 400*ps)
        object:SetText(slider7:GetValue())
    end

    --------------------------------------

    slider8 = loveframes.Create("slider", frame)
    slider8:SetPos(1000*ps, 460*ps)
    slider8:SetWidth(270*ps)
    slider8:SetMinMax(0, 100)
    slider8:SetValue(25)
    slider8:SetText("Boid Alignment")
    slider8:SetDecimals(0)
    slider8:SetState("boids")

    local s8text1 = loveframes.Create("text", panel)
    s8text1:SetPos(20*ps, 450*ps)
    s8text1:SetFont(love.graphics.newFont(10*ps))
    s8text1:SetText(slider8:GetText())

    local s8text2 = loveframes.Create("text", panel)
    s8text2:SetFont(love.graphics.newFont(10*ps))
    s8text2.Update = function(object, dt)
        object:SetPos((290 - object:GetWidth())*ps, 450*ps)
        object:SetText(slider8:GetValue())
    end
    
    --------------------------------------

    local panelWidth=300*ps
    local panel2 = loveframes.Create("panel")
    panel2:SetSize(panelWidth, 50)
    panel2:SetPos(love.graphics.getWidth()-panelWidth, 1000)
    panel2:SetState("boids")

    button = loveframes.Create("button", panel2)
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


    --------------------------------------
    --------------------------------------
    --------------------------------------
    --AND NOW FOR THE PATH SETTINGS-------
    --------------------------------------
    --------------------------------------
    --------------------------------------
    local ppanel = loveframes.Create("panel")
    ppanel:SetSize(panelWidth, love.graphics.getHeight())
    ppanel:SetPos(love.graphics.getWidth()-panelWidth, 0)
    ppanel:SetState("paths")

             
    local pform = loveframes.Create("form", frame)
    pform:SetPos(love.graphics.getWidth()-panelWidth, 650*ps)
    pform:SetSize(panelWidth, 65*ps)
    pform:SetLayoutType("horizontal")
    pform:SetName("Settings")
    pform:SetState("paths")
         
    local psettings1 = loveframes.Create("button")
    psettings1:SetText("Boids")
    psettings1:SetWidth((300/2-5)*ps)
    psettings1.OnClick = function (object)
        loveframes.SetState("boids")
    end
    pform:AddItem(psettings1)


    local psettings2 = loveframes.Create("button")
    psettings2:SetText("Paths")
    psettings2:SetWidth((300/2-5)*ps)
    psettings2.OnClick = function (object)
        loveframes.SetState("paths")
    end
    pform:AddItem(psettings2)

    -- Just text things apparently
    local plist1 = loveframes.Create("list", frame)
    plist1:SetPos(980*ps, 0)
    plist1:SetSize(300*ps, 70*ps)
    plist1:SetPadding(20)
    plist1:SetSpacing(10)
    plist1:SetState("paths")

    -- IT'S US!
    local ptext1 = loveframes.Create("text")
    ptext1:SetFont(love.graphics.newFont(12*ps))
    ptext1:SetText("BOID RACERS\nNate Balas & Shakil Thakur")
    plist1:AddItem(ptext1)

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
	return self.seperation:GetValue()
end 

function GraphicalUserInterface:getDemoSpeed()
    return self.demoSpeed:GetValue()
end 

function GraphicalUserInterface:getRestart()
    return self.restart:GetText()
end 

function GraphicalUserInterface:getCohesion()
    return self.cohesion:GetValue()
end 

function GraphicalUserInterface:getAlignment()
    return self.alginment:GetValue()
end 
GUI = {
    GraphicalUserInterface = GraphicalUserInterface,
    _VERSION = "SUPER-BETA"
}
return GUI