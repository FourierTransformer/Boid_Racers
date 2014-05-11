local ps = love.window.getPixelScale()

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
local slider1 = loveframes.Create("slider", frame)
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

local slider2 = loveframes.Create("slider", frame)
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

local slider3 = loveframes.Create("slider", frame)
slider3:SetPos(1000*ps, 210*ps)
slider3:SetWidth(270*ps)
slider3:SetMinMax(1, 100)
slider3:SetValue(60)
slider3:SetText("GBFS Boids")
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

-- then a checkbox for Boid Separation
local checkbox1 = loveframes.Create("checkbox", panel)
checkbox1:SetText("Boid Separation")
checkbox1:SetPos(20*ps, 250*ps)
checkbox1:SetFont(love.graphics.newFont(12*ps))
checkbox1:SetChecked(true)

