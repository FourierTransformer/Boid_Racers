#!/usr/bin/env lua
---------------
-- ## Delaunay, Love2D module for top-down cars
-- @author Shakil Thakur and Nate Balas
-- @copyright 2014
-- @license MIT?
-- @script CartD

-- Modules and things


-- This creates the car AI class
carAI = class(function(ai,startPos,car)
              ai.startPos = startPos
              ai.car = car
           end)

function carAI:update()
   
end