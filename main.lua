-- modules and stuff
local CarTD    = require 'CarTD'
local Car      = CarTD.Car
local MapModule   = require 'mapmodule'
local Map      = MapModule.Map
local aStar    = require 'aStar'
local car_ai = require 'car_ai'
local carAI = car_ai.carAI

local tank
local car1
local car1_AI

function love.load()

    -- CONSTANTS BITCHES
    love.window.setTitle("Boid Racers")
    numberVerts = 100
    width, height = 10000, 10000
    local roadRadius = 400

    -- setup the car
    throttle, steering = 0, 0
    love.physics.setMeter(15)
    world = love.physics.newWorld(0, 0, true) -- ZERO-G
    tank = Car:new(0, 0, "95px-Tank-GTA2-2.png")

    -- generate the map
    map = Map:new(roadRadius, width, height)
    -- print("Road/minimap Texture Generation: ", os.clock() - tick)
    -- Generate best path using A*
    local vertices = map.vertices
    local graph = map.graph
    local start = math.floor((math.random() * #vertices / 4))
    local goal = math.floor((math.random() * #vertices))
    -- start = 1
    -- goal = 750
    local path = aStar.aStar(vertices, graph, vertices[start], vertices[goal])

    -- setup the world
    throttle, steering = 0, 0
    love.physics.setMeter(27)
    world = love.physics.newWorld(0, 0, true) -- ZERO-G
    -- set up player car
    tank = Car:new(vertices[start].x, vertices[start].y, "CARS/AMartin-Vanquesh.png")
    -- set up AI cars
    car1 = Car:new(vertices[start].x+50, vertices[start].y+50, "95px-Tank-GTA2-2.png")
    -- add car to map
    map:addCar(tank)
    -- add AI cars to map
    map:addCar(car1)
    car1_AI = carAI:new(car1,path)

end

function love.update(dt)
    world:update(dt)
    -- Player controlled tank
    tank:update(steering, throttle, dt)
    -- AI controlled tanks
    car1_AI:update(dt)
end

-- draw ALL THE THINGS
function love.draw()
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

    -- love.graphics.print("hello world", 400, 300)
    -- Printing the results
    -- for j, triangle in ipairs(triangles) do
    --     local vertices = {triangle.p1.x, triangle.p1.y, triangle.p2.x, triangle.p2.y, triangle.p3.x, triangle.p3.y}
    --     love.graphics.setColor(255, 255, 255)
    --     -- love.graphics.polygon('line', vertices)
    --     -- love.graphics.setColor(math.random()*255, math.random()*255, math.random()*255)
    --     -- love.graphics.line(triangle.p1.x, triangle.p1.y, triangle.p2.x, triangle.p2.y, triangle.p3.x, triangle.p3.y)
    -- end

    -- draw the start and end of the path
    -- love.graphics.setPointSize( 10 )
    -- love.graphics.setColor(0, 0, 255)
    -- love.graphics.point(vertices[start].x, vertices[start].y)
    -- love.graphics.point(vertices[goal].x, vertices[goal].y)

    -- draw the path (THIS IS FOR DEV USE ONLY.)
    -- love.graphics.setPointSize( 5 )
    -- love.graphics.setColor(0, 255, 0)
    -- for i, v in ipairs(path) do
    --     love.graphics.point(v.x, v.y)
    -- end

    -- -- draw the minimap
    -- local radius = 100
    -- local offset = 20
    
    -- -- bg and outline
    -- love.graphics.setColor(255, 255, 255)
    -- love.graphics.circle("fill", radius + offset, height - radius - offset, radius + 2)
    -- love.graphics.setColor(0, 0, 0)
    -- love.graphics.circle("fill", radius + offset, height - radius - offset, radius)

    -- and the actual map
    love.graphics.scale(.5, .5)
    map:draw()
    -- love.graphics.setColor(255, 255, 255)
    -- love.graphics.setStencil(minimapStencil)
    -- love.graphics.draw(minimapCanvas, 0 - x + 100, 0 - y + (height-200))
    -- love.graphics.setStencil()

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

-- anything special on quit?
function love.quit()
    print("Are you happy now Mr Krabs!?")
end

function minimapStencil()
    local radius = 100
    local offset = 20
    love.graphics.circle("fill", radius + offset, height - radius - offset, radius)
end