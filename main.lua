local car = require 'car'
local RigidBody = car.RigidBody
function love.load()
	box = RigidBody:new(100, 100, 0, "95px-Tank-GTA2.png", 1, false)
   throttle, steering, brakes = 0, 0, 0

end

function love.update(dt)
   box:setSteering(steering)
   box:setThrottle(throttle)
   box:setBrakes(brakes)
   box:update(dt)
end

function love.draw()
   -- dont ever really use % for this. IT kinda sucks and is really hacky. just saying.
   love.graphics.draw(box.image, box.x % love.graphics.getWidth(), (-box.y) % love.graphics.getHeight(), box.angle, 1, 1, box.pivot.x, box.pivot.y)
   -- love.graphics.draw(box.image, box.x % love.graphics.getWidth(), box.y % love.graphics.getHeight())
   love.graphics.print(tostring(box), 0, 0)
   -- love.graphics.print("Steering: " .. steering, 0, 50)
end


function love.keypressed(key)
   if key == "up" then
      throttle = 1;
   end
   if key == "down" then
      brakes = 1;
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
      throttle = 0;
   end
   if key == "down" then
      brakes = 0;
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

function love.quit()
  
end