-- modules and stuff
local MapModule   = require 'mapmodule'
local Map         = MapModule.Map
local PathFinding = require 'pathfinding'
local BoidModule  = require 'boidmodule'
local Motorcade   = BoidModule.Motorcade
local Vector      = BoidModule.Vector

-- variables for this file
local start
local goal
local vertices
local graph
local map
local motorcade
local roadRadius
local borderSize

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
    roadRadius = 20 * love.window.getPixelScale()
    borderSize = roadRadius/10

    -- Cursors
    handCursor = love.mouse.getSystemCursor("hand")

    -- create startCursor
    local startCursorCanvas = love.graphics.newCanvas( 100, 100 )
    love.graphics.setCanvas(startCursorCanvas)
    love.graphics.setColor(0, 255, 0, 128)
    love.graphics.circle("fill", 50, 50, ((roadRadius - borderSize)/2))
    love.graphics.setCanvas()
    startCursor = love.mouse.newCursor(startCursorCanvas:getImageData(), 50, 50)

    -- create goalCursor
    local goalCursorCanvas = love.graphics.newCanvas( 100, 100 )
    love.graphics.setCanvas(startCursorCanvas)
    love.graphics.setColor(255, 0, 0, 128)
    love.graphics.circle("fill", 50, 50, ((roadRadius - borderSize)/2))
    love.graphics.setCanvas()
    goalCursor = love.mouse.newCursor(startCursorCanvas:getImageData(), 50, 50)

    -- Generate the map
    map = Map:new(roadRadius, width, height)
    vertices = map.vertices
    graph = map.graph
    -- print("Road/minimap Texture Generation: ", os.clock() - tick)

    -- figure out the start/end nodes
    start = vertices[math.floor((math.random() * #vertices/4))]
    goal = vertices[math.floor((math.random(2*#vertices/4, #vertices)))]

    -- Create the motorcade and add 60 cars to each Algo!
    motorcade = Motorcade:new(roadRadius)

    -- Do some aStar!
    local path = PathFinding.aStar(vertices, graph, start, goal)
    map:setPath(path, "yellow")
    motorcade:add(start.x, start.y, path, 60, "yellow")

    -- GBFS
    local path2 = PathFinding.GBFS(vertices, graph, start, goal)
    map:setPath(path2, "magenta")
    motorcade:add(start.x, start.y, path2, 60, "magenta")

    -- and uniform cost!
    local path3 = PathFinding.uniformCost(vertices, graph, start, goal)
    map:setPath(path3, "cyan")
    motorcade:add(start.x, start.y, path3, 60, "cyan")
end

function love.update(dt)
    motorcade:update(dt)
end

-- draw ALL THE THINGS
function love.draw()
    -- and the actual map and motorcade!
    map:draw()

    -- draw the start point
    love.graphics.setColor(0, 255, 0)
    love.graphics.circle("fill", start.x, start.y, ((roadRadius - borderSize)/2))

    -- draw the goal
    love.graphics.setColor(255, 0, 0)
    love.graphics.circle("fill", goal.x, goal.y, ((roadRadius - borderSize)/2))
    love.graphics.setColor(255, 255, 255)

    -- motorcade
    motorcade:draw()

    -- texty stuff
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10, 0, love.window.getPixelScale(), love.window.getPixelScale())
end

function love.mousepressed(x, y, button)
  if button == "l" then
    local mouseVec = Vector:new(x,y)
    
    if distance(start, mouseVec) < 100 then
      love.mouse.setCursor(startCursor)
    end

    if distance(goal, mouseVec) < 100 then
      love.mouse.setCursor(goalCursor)
    end

  end
end

local function findNearestVertex(vert)
  local shortestDistance = math.huge
  local shortestNode = nil
  for i, v in ipairs(vertices) do
    local currentDistance = distance(v, vert)
    if currentDistance < shortestDistance then
      shortestDistance = currentDistance
      shortestNode = v
    end
  end
  if shortestDistance < 100 then
    return shortestNode
  else
    return nil
  end
end

local function updateStart()
    -- clear the Path canvas
    map:clearPathCanvas()

    -- Do some aStar!
    local path = PathFinding.aStar(vertices, graph, start, goal)
    motorcade:setPath("yellow", path)
    map:setPath(path, "yellow")

    -- GBFS
    local path2 = PathFinding.GBFS(vertices, graph, start, goal)
    motorcade:setPath("magenta", path2)
    map:setPath(path2,"magenta")

    -- and uniform cost!
    local path3 = PathFinding.uniformCost(vertices, graph, start, goal)
    motorcade:setPath("cyan", path3)
    map:setPath(path3,"cyan")

    -- and start popping up in the right location
    motorcade:setStart(start)
end

local function updateGoal()
    motorcade:updatePath(vertices, graph, goal)
    updateStart()
end

function love.mousereleased(x, y, button)
    if button == "l" then
        -- create vector with mouse coords
        local mouseLoc = Vector:new(x, y)
        if love.mouse.getCursor() == goalCursor then
            local newGoal = findNearestVertex(mouseLoc)
            if newGoal ~= nil then
                goal = newGoal
                updateGoal()
            end
        
        -- if startCursor is changed
        elseif love.mouse.getCursor() == startCursor then
            local newStart = findNearestVertex(mouseLoc)
            if newStart ~= nil then
                start = newStart
                updateStart()
            end
        end

        -- set cursor back
        love.mouse.setCursor()
    end
end

-- anything special on quit?
function love.quit()
    print("Are you happy now Mr Krabs!?")
end
