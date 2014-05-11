-- modules and stuff
local MapModule   = require 'mapmodule'
local Map         = MapModule.Map
local PathFinding = require 'pathfinding'
local BoidModule  = require 'boidmodule'
local Motorcade   = BoidModule.Motorcade

function love.load()
    -- SETTING IT UP!
    love.window.setTitle("Boid Racers")
    love.window.setMode(1280, 720, {highdpi = true})

    -- CONSTANTS BITCHES
    math.randomseed( os.time() )
    vertDistro = {math.random(10, 50), math.random(10, 50), math.random(10, 50), math.random(10, 50)} --for each quadrant
    numberVerts = 0
    for i, v in ipairs(vertDistro) do numberVerts = numberVerts + v end
    local width, height = love.graphics.getDimensions() --10000, 10000
    width = width - (300 * love.window.getPixelScale())
    local roadRadius = 20 * love.window.getPixelScale()

    -- Generate best path using A*
    local start = math.floor((math.random() * numberVerts/4))
    local goal = math.floor((math.random(2*numberVerts/4, numberVerts)))

    -- Generate the map
    map = Map:new(roadRadius, width, height, start, goal)
    local vertices = map.vertices
    local graph = map.graph
    -- print("Road/minimap Texture Generation: ", os.clock() - tick)

    -- Create the motorcade and add 60 cars to each Algo!
    motorcade = Motorcade:new(roadRadius)

    -- Do some aStar!
    local path = PathFinding.aStar(vertices, graph, vertices[start], vertices[goal])
    map:setPath(path, "yellow")
    for i = 1, 60 do
      motorcade:add(vertices[start].x, vertices[start].y, path, "yellow")
    end

    -- GBFS
    local path2 = PathFinding.GBFS(vertices, graph, vertices[start], vertices[goal])
    map:setPath(path2, "magenta")
    for i = 1, 60 do
      motorcade:add(vertices[start].x, vertices[start].y, path2, "magenta")
    end

    -- and uniform cost!
    local path3 = PathFinding.uniformCost(vertices, graph, vertices[start], vertices[goal])
    map:setPath(path3, "cyan")
    for i = 1, 60 do
      motorcade:add(vertices[start].x, vertices[start].y, path3, "cyan")
    end
end

function love.update(dt)
    motorcade:update(dt)
end

-- draw ALL THE THINGS
function love.draw()
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    -- and the actual map and motorcade!
    map:draw()
    motorcade:draw()
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