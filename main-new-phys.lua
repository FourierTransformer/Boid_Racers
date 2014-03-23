function love.load()
    throttle, steering = 0, 0

    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true) -- ZERO-G

    objects = {}
    objects.tire = {}
    for i = 1, 4 do
        objects.tire[i] = {}
        objects.tire[i].body = love.physics.newBody(world, 10, 105, 'dynamic')
        objects.tire[i].shape = love.physics.newRectangleShape(5, 12.5)
        objects.tire[i].fixture = love.physics.newFixture(objects.tire[i].body, objects.tire[i].shape)
    end

    objects.tire[2].body:setPosition(50, 105)
    objects.tire[3].body:setPosition(0, 0)
    objects.tire[4].body:setPosition(55, 0)

    objects.car = {}
    objects.car.body = love.physics.newBody(world, 30, 0, 'dynamic')
    objects.car.shape = love.physics.newPolygonShape(
     15,   0,
       30, 25,
     28, 55,
       10,  100,
      -10,  100,
    -28, 55,
      -30, 25,
    -15,   0)
    objects.car.fixture = love.physics.newFixture(objects.car.body, objects.car.shape, .1)

    love.physics.newRevoluteJoint(objects.car.body, objects.tire[1].body, 10, 105)
    love.physics.newRevoluteJoint(objects.car.body, objects.tire[2].body, 50, 105)
    love.physics.newWeldJoint(objects.car.body, objects.tire[3].body, 0, 0)
    love.physics.newWeldJoint(objects.car.body, objects.tire[4].body, 55, 0)

end

function love.update(dt)
    world:update(dt)
    for i = 1, 4 do
    updateFriction(objects.tire[i].body)
    updateDrive(objects.tire[i].body, throttle)
    updateTurn(objects.tire[i].body, steering)
    end
end

function love.draw()
    love.graphics.setColor(250, 250, 250) -- set the drawing color to grey for the blocks
    for i = 1, 4 do
        love.graphics.polygon("fill", objects.tire[i].body:getWorldPoints(objects.tire[i].shape:getPoints()))
    end
    love.graphics.polygon("fill", objects.car.body:getWorldPoints(objects.car.shape:getPoints()))
    -- love.graphics.rectangle(object.tire.body:getX(), object.tire.body:getY(),)
end


-- lateral with 1,0
-- forward with 0,1
function getVelocity(body, dir_x, dir_y)
    local world_x, world_y = body:getWorldVector(dir_x, dir_y)
    local dot = dotProduct(world_x, world_y, body:getLinearVelocity())
    return world_x * dot, world_y * dot
end

function updateFriction(body)
    -- WOAH
    local maxLateralImpulse = 3

    -- get sideways velocity/impulse
    local lat_x, lat_y = getVelocity(body, 1, 0)
    local imp_x = body:getMass() * -lat_x
    local imp_y = body:getMass() * -lat_y
    
    -- allow skidding around
    local length = math.sqrt(imp_x^2 + imp_y^2);
    if length > maxLateralImpulse then
        imp_x = imp_x * maxLateralImpulse / length
        imp_y = imp_y * maxLateralImpulse / length
    end

    -- stop the sideways impulse
    local center_x, center_y = body:getWorldCenter()
    body:applyLinearImpulse(imp_x, imp_y, center_x, center_y)

    -- stop the angular velocity
    body:applyAngularImpulse(-.1 * body:getInertia() * body:getAngularVelocity())

    -- add some drag (so a car can stop on its own)
    local forward_x, forward_y = getVelocity(body, 0, 1)
    -- local forwardSpeed = math.sqrt(forward_x^2 + forward_y^2)
    -- forward_x = forward_x / forwardSpeed
    -- forward_y = forward_y / forwardSpeed
    -- local dragForce = -1 * forwardSpeed
    local dragForce = -.01


    body:applyForce( dragForce * forward_x, dragForce * forward_y, body:getWorldCenter())

end

function dotProduct(x1, y1, x2, y2)
    return x1 * x2 + y1 * y2
end

-- 1 for up, -1 for brake, 0 for nothing
function updateDrive(body, driveControl)
    local maxForward = 250
    local maxBackward = -40
    local maxForce = 300

    -- determine new speed
    local newSpeed = 0
    if (driveControl == 1) then
        newSpeed = maxForward
    elseif (driveControl == -1) then
        newSpeed = maxBackward
    else
        return
    end

    -- get current (forward) speed
    local forwardNormal_x, forwardNormal_y = body:getWorldVector(0, 1)
    local forwardVelocity_x, forwardVelocity_y = getVelocity(body, 0, 1)
    local currentSpeed = forwardNormal_x * forwardVelocity_x + forwardNormal_y * forwardVelocity_y

    -- print("newspeed", newSpeed)
    -- print("currentSpeed", currentSpeed)

    -- apply force
    local force = 0
    -- if currentSpeed >= maxForward then -- added
        -- force = 0                       -- added
    if newSpeed > currentSpeed then
        force = maxForce
    elseif newSpeed < currentSpeed then
        force = -maxForce
    else
        return
    end

    body:applyForce(force * forwardNormal_x, force * forwardNormal_y, body:getWorldCenter())

end

-- 1 for left, -1 for right, 0 for nothing
function updateTurn(body, turnControl)
    local torque = 15 * turnControl
    body:applyTorque(torque)
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