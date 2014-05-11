#!/usr/bin/env lua
---------------
-- ## PathFinding, a Lua module for pathfinding
-- @author Shakil Thakur
-- @copyright 2014
-- @license MIT
-- @script pathfinding

local Peaque = require 'Peaque'
local Heap   = Peaque.Heap

local PathFinding = {
    _VERSION = "SUPER-BETA"
}

local function constructPath(cameFrom, currentNode)
    local final  = {}
    while cameFrom[currentNode] ~= nil do
        table.insert(final, 1, currentNode)
        currentNode = cameFrom[currentNode]
    end
    -- for i,v in ipairs(final) do print(i, v) end

    return final
end

function PathFinding.aStar(verts, adjMatrix, start, goal)
    local closedList = {}
    local openList = Heap()
    local cameFrom = {}
    local linkCost = {}

    for i = 1, #verts do
        linkCost[i] = math.huge
    end
    
    openList:push(start, start:dist2(goal))
    linkCost[start.id] = 0

    while openList:isEmpty() == false do
        
        local current = openList:pop()
        if current == goal then
            return constructPath(cameFrom, goal)
        end

        closedList[current.id] = true

        for i=1, #verts do
            local neighbor_edge = adjMatrix[current.id][i]
            if neighbor_edge ~= nil and closedList[i] == nil then

                local neighbor = verts[i]

                local tentLinkCost = linkCost[current.id] + neighbor_edge:length2()

                if linkCost[neighbor.id] == math.huge or tentLinkCost < linkCost[neighbor.id] then
                    cameFrom[neighbor] = current
                    linkCost[neighbor.id] = tentLinkCost
                    local totalCost = linkCost[neighbor.id] + neighbor:dist2(goal)
                    openList:push(neighbor, totalCost)
                end
                
            end
        end


    end

end

return PathFinding