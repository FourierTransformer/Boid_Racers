

-- modules and stuff
local Delaunay = require 'Delaunay'
local Point    = Delaunay.Point
local Voronoi  = require 'Voronoi'
local aStar    = require 'aStar'

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


-- Load up any thing we might need.
function love.load()
    love.window.setTitle("Boid Racer")

    local width, height = love.window.getDimensions( )

    -- Create random points
    local points = {}

    local numberVerts = 1000

    for i = 1, numberVerts do
        -- regular random isn't good enough
        -- points[i] = Point(math.random() * width, math.random() * height)
        points[i] = Point(halton(i, 2) * width, halton(i, 3) * height)
    end

    local tick

    tick = os.clock()

    -- Triangulating the convex polygon made by those points
    triangles = Delaunay.triangulate(unpack(points))
    print("Delaunay Triangulation:", os.clock() - tick)
    tick = os.clock()

    vertices, graph = Voronoi.calculate(triangles)
    print("Voronoi Calclation: ", os.clock() - tick)
    tick = os.clock()

    -- start = math.floor((math.random() * #vertices / 4))
    -- goal = math.floor((math.random() * #vertices))
    start = 1
    goal = 750

    something = aStar.aStar(vertices, graph, vertices[start], vertices[goal])
    print("A*: ", os.clock() - tick)

    -- for i, triangle in ipairs(triangles) do
    --   print(triangle)
    -- end

end

-- update the maths
function love.update()

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

    love.graphics.setColor(255, 0, 0)
    for i, vertex in ipairs(vertices) do
        -- print(vertex)
        -- love.graphics.setColor(255, 255, 255)
        love.graphics.point(vertex.x, vertex.y)
        -- love.graphics.print(math.floor(vertex:dist(vertices[goal])), vertex.x, vertex.y)
        for j = 1, #vertices do
            if i < j then
                local e = graph[i][j]
                if e ~= nil then
                    love.graphics.line(e.p1.x, e.p1.y, e.p2.x, e.p2.y)
                    -- love.graphics.print(math.floor(e:length()), e:getMidPoint())
                end
            end
        end
    end

    love.graphics.setPointSize( 10 )
    love.graphics.setColor(0, 0, 255)
    love.graphics.point(vertices[start].x, vertices[start].y)
    love.graphics.point(vertices[goal].x, vertices[goal].y)

    love.graphics.setPointSize( 5 )
    love.graphics.setColor(0, 255, 0)
    for i, v in ipairs(something) do
        love.graphics.point(v.x, v.y)
    end

end

-- anything special on quit?
function love.quit()
    print("Are you happy now Mr Krabs!?")
end
