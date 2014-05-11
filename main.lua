-- modules and stuff
local MapModule   = require 'mapmodule'
local Map         = MapModule.Map
local PathFinding = require 'pathfinding'
local BoidModule  = require 'boidmodule'
local Motorcade   = BoidModule.Motorcade

local tank
local car1
local car1_AI

function love.load()
    -- SETTING IT UP!
    love.window.setTitle("Boid Racers")
    love.window.setMode(1280, 720, {highdpi = true})

    -- CONSTANTS BITCHES
    numberVerts = 150
    width, height = love.graphics.getDimensions() --10000, 10000
    width = width - (300 * love.window.getPixelScale())
    local roadRadius = 20 * love.window.getPixelScale()

    -- Generate best path using A*
    local start = math.floor((math.random() * numberVerts / 4))
    local goal = math.floor((math.random() * numberVerts))

    -- Generate the map
    map = Map:new(roadRadius, width, height, start, goal)
    local vertices = map.vertices
    local graph = map.graph
    -- print("Road/minimap Texture Generation: ", os.clock() - tick)

    -- Do some aStar!
    local path = PathFinding.aStar(vertices, graph, vertices[start], vertices[goal])
    map:setPath(path)

    -- Create the motorcade and add 60 cars!
    motorcade = Motorcade:new()
    for i = 1, 60 do
      motorcade:add(vertices[start].x+i*5,vertices[start].y+i*5,path)
    end
end

function love.update(dt)
    motorcade:update(dt)
end

-- draw ALL THE THINGS
function love.draw()
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

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
    -- love.graphics.scale(.075, .075)
    map:draw()
    motorcade:draw()
    -- love.graphics.setColor(255, 255, 255)
    -- love.graphics.setStencil(minimapStencil)
    -- love.graphics.draw(minimapCanvas, 0 - x + 100, 0 - y + (height-200))
    -- love.graphics.setStencil()

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