local CarTD = require 'CarTD'
local Car = CarTD.Car

function love.load()
   throttle, steering = 0, 0

   love.physics.setMeter(64)
   world = love.physics.newWorld(0, 0, true) -- ZERO-G

   tank = Car:new(100, 200, "95px-Tank-GTA2-2.png")
end

function love.update(dt)
   world:update(dt)
   tank:update(steering, throttle)
end

function love.draw()
   love.graphics.setColor(255, 255, 255)
   tank:draw()
end


function love.keypressed(key)
   if key == "up" then
      throttle = 1;
   end
   if key == "down" then
      throttle = -1;
   end
   if key == "left" then
      steering = -1;
   end
   if key == "right" then
      steering = 1;
   end
end
function love.keyreleased(key)
   if key == "up" then
        if love.keyboard.isDown("down") then
            throttle = -1
        else
            throttle = 0;
        end
   end
   if key == "down" then
        if love.keyboard.isDown("up") then
            throttle = 1
        else
            throttle = -1;
        end
   end
   if key == "left" then
      if love.keyboard.isDown("right") then
         steering = 1
      else
         steering = 0
      end
   end
   if key == "right" then
      if love.keyboard.isDown("left") then
         steering = -1
      else
         steering = 0
      end
   end
end