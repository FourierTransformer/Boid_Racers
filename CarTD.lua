#!/usr/bin/env lua
---------------
-- ## Delaunay, Love2D module for top-down cars
-- @author Shakil Thakur and Nate Balas
-- @copyright 2014
-- @license MIT?
-- @script CartD

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

function dotProduct(x1, y1, x2, y2)
    return x1 * x2 + y1 * y2
end

--- `Wheel` class
-- @type Wheel
local Wheel = class()
Wheel.__eq = function(a, b) return (a.p1 == b.p1 and a.p2 == b.p2) end
Wheel.__tostring = function(r) return "" end

function Wheel:__init(x, y, width, diameter)
    self.body = love.physics.newBody(world, x, y, 'dynamic')
    self.shape = love.physics.newRectangleShape(width, diameter)
    self.fixture = love.physics.newFixture(self.body, self.shape)
end

-- lateral with 1,0
-- forward with 0,1
function Wheel:getVelocity(dir_x, dir_y)
    local world_x, world_y = self.body:getWorldVector(dir_x, dir_y)
    local dot = dotProduct(world_x, world_y, self.body:getLinearVelocity())
    return world_x * dot, world_y * dot
end

function Wheel:getForwardVelocity()
    return self:getVelocity(0, 1)
end

function Wheel:getLateralVelocity()
    return self:getVelocity(1, 0)
end

-- 1 for left, -1 for right, 0 for nothing
function Wheel:updateTurn(turnControl)
    local torque = 15 * turnControl
    self.body:applyTorque(torque)
end

-- 1 for up, -1 for brake, 0 for nothing
function Wheel:updateDrive(driveControl)
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
    local forwardNormal_x, forwardNormal_y = self.body:getWorldVector(0, 1)
    local forwardVelocity_x, forwardVelocity_y = self:getForwardVelocity()
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

    self.body:applyForce(force * forwardNormal_x, force * forwardNormal_y, self.body:getWorldCenter())

end

function Wheel:updateFriction()
    -- WOAH
    local maxLateralImpulse = 3

    -- get sideways velocity/impulse
    local lat_x, lat_y = self:getLateralVelocity()
    local imp_x = self.body:getMass() * -lat_x
    local imp_y = self.body:getMass() * -lat_y
    
    -- allow skidding around
    local length = math.sqrt(imp_x^2 + imp_y^2);
    if length > maxLateralImpulse then
        imp_x = imp_x * maxLateralImpulse / length
        imp_y = imp_y * maxLateralImpulse / length
    end

    -- stop the sideways impulse
    local center_x, center_y = self.body:getWorldCenter()
    self.body:applyLinearImpulse(imp_x, imp_y, center_x, center_y)

    -- stop the angular velocity
    self.body:applyAngularImpulse(-.1 * self.body:getInertia() * self.body:getAngularVelocity())

    -- add some drag (so a car can stop on its own)
    local forward_x, forward_y = self:getForwardVelocity()
    -- local forwardSpeed = math.sqrt(forward_x^2 + forward_y^2)
    -- forward_x = forward_x / forwardSpeed
    -- forward_y = forward_y / forwardSpeed
    -- local dragForce = -1 * forwardSpeed
    local dragForce = -.01


    -- self.body:applyForce( dragForce * forward_x, dragForce * forward_y, self.body:getWorldCenter())

end

--- `Car` class
-- @type Car
local Car = class()
Car.__eq = function(a, b) return (a.p1 == b.p1 and a.p2 == b.p2) end
Car.__tostring = function(r) return "" end

function Car:__init(x, y, img, density)
    self.body = love.physics.newBody(world, x, y, 'dynamic')
    self.image = love.graphics.newImage(img)
    self.shape = love.physics.newPolygonShape(0, 0,
                                              self.image:getWidth(), 0,
                                              0, self.image:getHeight(),
                                              self.image:getWidth(), self.image:getHeight())
    self.fixture = love.physics.newFixture(self.body, self.shape, density or .1)
    
    self.wheels = {
        -- these two are front tires
        Wheel:new(x, y + self.image:getHeight() * .75,  5, 12.5),
        Wheel:new(x + self.image:getWidth(), y + self.image:getHeight() * .75, 5, 12.5),
        
        -- first two are back tires
        Wheel:new(x, y,   5, 12.5),
        Wheel:new(x + self.image:getWidth(), y,  5, 12.5)
    }

    -- the car will face "down" to start
    self.joint = {
        love.physics.newRevoluteJoint(self.body, self.wheels[1].body, self.wheels[1].body:getX(), self.wheels[1].body:getY()),
        love.physics.newRevoluteJoint(self.body, self.wheels[2].body, self.wheels[2].body:getX(), self.wheels[2].body:getY()),
        love.physics.newWeldJoint(self.body, self.wheels[3].body, self.wheels[3].body:getX(), self.wheels[3].body:getY()),
        love.physics.newWeldJoint(self.body, self.wheels[4].body, self.wheels[4].body:getX(), self.wheels[4].body:getY())
    }
end

function Car:update(steering, throttle)
    for i, wheel in ipairs(self.wheels) do
        wheel:updateFriction()
        wheel:updateTurn(steering)
        wheel:updateDrive(throttle)
    end
end

function Car:draw(debug)
    love.graphics.draw(tank.image, tank.body:getX(), tank.body:getY(), tank.body:getAngle())
    if debug then
        for i = 1, 4 do
            love.graphics.polygon("line", tank.wheels[i].body:getWorldPoints(tank.wheels[i].shape:getPoints()))
        end
        love.graphics.polygon("line", tank.body:getWorldPoints(tank.shape:getPoints()))
    end
end

CarTD = {
    Car = Car, 
    _VERSION = "SUPER-BETA"
}
return CarTD