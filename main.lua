local car = require 'car'
local RigidBody = car.RigidBody
function love.load()
	box = RigidBody:new(200,400,0,"95px-Tank-GTA2.png",1,false)
   throttle,steering,brakes = 0,0,0

end

function love.update(dt)
   box:setSteering(steering)
   box:setThrottle(throttle)
   box:setBrakes(brakes)
   box:update(dt)
end

function love.draw()
   love.graphics.draw(box.image,box.x,box.y,box.angle)
   love.graphics.print(tostring(box),0,0)
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
      steering = 0;
   end
   if key == "right" then
      steering = 0;
   end
end

function love.quit()
  
end