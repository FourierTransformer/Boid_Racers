-- modules and stuff
local Delaunay = require 'Delaunay'
local Point    = Delaunay.Point
local Voronoi  = require 'Voronoi'
local aStar    = require 'aStar'
local CarTD    = require 'CarTD'
local Car      = CarTD.Car


function love.load()

    -- CONSTANTS BITCHES
    love.window.setTitle("Boid Racers")
    local numberVerts = 10
    scale = 1
    width, height = love.window.getDimensions( )
    local roadRadius = 20

    -- setup the car
   throttle, steering = 0, 0
   love.physics.setMeter(64)
   world = love.physics.newWorld(0, 0, true) -- ZERO-G
   tank = Car:new(100, 200, "95px-Tank-GTA2-2.png")

    -- current camera position.
    x = 0
    y = 0

    -- Create points
    local points = {}
    for i = 1, numberVerts do
        -- random mode
        -- points[i] = Point(math.random() * width * scale, math.random() * height * scale)
        
        -- apparently love's math.random is uniformly distributed?
        -- points[i] = Point(love.math.random() * width * scale, love.math.random() * height * scale)

        -- regular random isn't good enough, so I did a halton
        points[i] = Point(halton(i, 2) * width * scale, halton(i, 3) * height * scale)
    end


    -- keep track of time.
    local tick
    tick = os.clock()


    -- Triangulating the convex polygon made by those points
    triangles = Delaunay.triangulate(unpack(points))
    print("Delaunay Triangulation:", os.clock() - tick)
    tick = os.clock()


    -- calculate voronoi
    vertices, graph = Voronoi.calculate(triangles)
    print("Voronoi Calclation: ", os.clock() - tick)
    tick = os.clock()


    -- run aStar
    start = math.floor((math.random() * #vertices / 4))
    goal = math.floor((math.random() * #vertices))
    -- start = 1
    -- goal = 750
    path = aStar.aStar(vertices, graph, vertices[start], vertices[goal])
    print("A*: ", os.clock() - tick)
    tick = os.clock()


    -- generate the road
    roadCanvas, minimapCanvas = generateRoadMinimapCanvas(roadRadius)
    print("Road/minimap Texture Generation: ", os.clock() - tick)

end

function love.update(dt)
    world:update(dt)
   tank:update(steering, throttle)
end

-- draw ALL THE THINGS
function love.draw()
    -- love.graphics.print("hello world", 400, 300)
    -- Printing the results
    for j, triangle in ipairs(triangles) do
        local vertices = {triangle.p1.x, triangle.p1.y, triangle.p2.x, triangle.p2.y, triangle.p3.x, triangle.p3.y}
        love.graphics.setColor(255, 255, 255)
        -- love.graphics.polygon('line', vertices)
        -- love.graphics.setColor(math.random()*255, math.random()*255, math.random()*255)
        -- love.graphics.line(triangle.p1.x, triangle.p1.y, triangle.p2.x, triangle.p2.y, triangle.p3.x, triangle.p3.y)
    end

    -- draw the roads!
    love.graphics.draw(roadCanvas, 0 - x, 0 - y)

    -- draw the start and end of the path
    love.graphics.setPointSize( 10 )
    love.graphics.setColor(0, 0, 255)
    love.graphics.point(vertices[start].x, vertices[start].y)
    love.graphics.point(vertices[goal].x, vertices[goal].y)

    -- draw the path (THIS IS FOR DEV USE ONLY.)
    love.graphics.setPointSize( 5 )
    love.graphics.setColor(0, 255, 0)
    for i, v in ipairs(path) do
        love.graphics.point(v.x, v.y)
    end

    -- draw the tank!
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(1)
    tank:draw(true)

    -- draw the minimap
    local radius = 100
    local offset = 20
    
    -- bg and outline
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", radius + offset, height - radius - offset, radius + 2)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", radius + offset, height - radius - offset, radius)

    -- and the actual map
    love.graphics.setColor(255, 255, 255)
    love.graphics.setStencil(minimapStencil)
    love.graphics.draw(minimapCanvas, 0 - x/scale + 100, 0 - y/scale + (height-200))
    love.graphics.setStencil()

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

function halton(i, b)
    local result = 0
    local half = 1 / b

    while i > 0 do
        result = result + (i % b) * half
        i = math.floor(i/b)
        half = half / b
    end

    return result
end

function generateRoadMinimapCanvas(roadRadius)
    -- draw the road to an offscreen canvas
    local borderSize = roadRadius / 10 -- for roadRadius 20 this is 2
    local roadCanvas = love.graphics.newCanvas(width*scale, height*scale)
    love.graphics.setCanvas(roadCanvas)

    -- figure out the road coords
    local road = {}
    for i, vertex in ipairs(vertices) do
        -- print(vertex)
        love.graphics.setColor(255, 255, 255)
        love.graphics.circle("fill", vertex.x, vertex.y, (roadRadius/2) * scale)
        -- love.graphics.print(math.floor(vertex:dist(vertices[goal])), vertex.x, vertex.y)
        for j = 1, #vertices do
            if i < j then
                local e = graph[i][j]
                if e ~= nil then
                    road[#road + 1] = {e.p1.x, e.p1.y, e.p2.x, e.p2.y}
                end
            end
        end
    end

    -- the border
    for j = 1, #road do
        love.graphics.setColor(255,255,255)
        love.graphics.setLineWidth(roadRadius * scale)
        love.graphics.line(road[j])
    end

    -- the inside
    for j = 1, #road do
        love.graphics.setColor(90,90,90)
        love.graphics.setLineWidth((roadRadius-borderSize) * scale)
        love.graphics.line(road[j])
    end

    -- the line down the middle
    for j = 1, #road do
        love.graphics.setColor(255, 255, 255)
        love.graphics.setLineWidth(borderSize/2 * scale)
        love.graphics.line(road[j])
    end

    -- handle intersections?
    for i, vertex in ipairs(vertices) do
        love.graphics.setColor(90, 90, 90)
        -- love.graphics.setPointSize((roadRadius-borderSize) * scale)
        love.graphics.circle("fill", vertex.x, vertex.y, ((roadRadius - borderSize)/2) * scale)
        love.graphics.point(vertex.x, vertex.y)
    end

    -- add noise? This is gonna get cray
    -- it got cray. I killed it because slowdown was tremendous. Might revisit later.

    -- draw out the minimap
    local minimapCanvas = love.graphics.newCanvas(width, height)
    love.graphics.setCanvas(minimapCanvas)

    -- roads within the mini
    for j = 1, #road do
        love.graphics.setColor(90,90,90)
        love.graphics.setLineWidth(10)
        love.graphics.line(road[j][1]/scale, road[j][2]/scale, road[j][3]/scale, road[j][4]/scale)
    end

    -- and back to the screen!
    love.graphics.setCanvas()

    return roadCanvas, minimapCanvas
end

function minimapStencil()
    local radius = 100
    local offset = 20
    love.graphics.circle("fill", radius + offset, height - radius - offset, radius)
end