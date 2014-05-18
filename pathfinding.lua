#!/usr/bin/env lua
---------------
-- ## PathFinding, a Lua module for pathfinding
-- @author Shakil Thakur
-- @copyright 2014
-- @license MIT
-- @script pathfinding

local Peaque = require 'Peaque'
local Heap   = Peaque.Heap

local function constructPath(cameFrom, currentNode)
    local final  = {}
    while cameFrom[currentNode] ~= nil do
        table.insert(final, 1, currentNode)
        currentNode = cameFrom[currentNode]
    end
    -- for i,v in ipairs(final) do print(i, v) end

    return final
end

function PathFinding.aStar(verts, adjMatrix, start, goal, otherAlg)
    local closedList = {}
    local openList = Heap()
    local cameFrom = {}
    local linkCost = {}
    local otherAlg = otherAlg or "aStar"
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
                local tentLinkCost = 0
                if otherAlg == "GBFS" then
                    tentLinkCost = neighbor_edge:length2()
                elseif otherAlg == "uniformCost" then
                    tentLinkCost = linkCost[current.id]
                else
                    tentLinkCost = linkCost[current.id] + neighbor_edge:length2()
                end

                if linkCost[neighbor.id] == math.huge or tentLinkCost < linkCost[neighbor.id] then
                    cameFrom[neighbor] = current
                    linkCost[neighbor.id] = tentLinkCost
                    local totalCost = 0
                    if otherAlg == "GBFS" then
                        totalCost = neighbor:dist2(goal)
                    elseif otherAlg == "uniformCost" then
                        totalCost = linkCost[neighbor.id]
                    else
                        totalCost = linkCost[neighbor.id] + neighbor:dist2(goal)
                    end
                    openList:push(neighbor, totalCost)
                end
                
            end
        end

    end

end

function PathFinding.GBFS(verts, adjMatrix, start, goal)
    return PathFinding.aStar(verts, adjMatrix, start, goal, "GBFS")
end

function PathFinding.uniformCost(verts, adjMatrix, start, goal)
    return PathFinding.aStar(verts, adjMatrix, start, goal, "uniformCost")
end

function PathFinding.BFS(verts, adjMatrix, start, goal)
    local frontier = {}
    local explored = {}

    frontier[ #frontier+1 ] = start  

    while #frontier > 0 do
        local current = frontier[1]
        table.remove(frontier, 1)
        explored[#explored+1] = current

        if current == goal then
            return explored
        end

        for i=1, #verts do
            local e = adjMatrix[current.id][i]
            if e ~= nil then
                local found = false
                local u = e:getConnectedVertex(current)
            
                for j=1, #explored do
                    if explored[j] == u then
                        found = true
                    end
                end

                if found == false then
                    frontier[#frontier+1] = u
                end
            
            end
        end

    end

end

function PathFinding.DFS(verts, adjMatrix, start, goal)
    local frontier = {}
    local explored = {}
    
    frontier[ #frontier+1 ] = start

    while #frontier > 0 do
        local current = frontier[#frontier]
        table.remove(frontier, #frontier)
        explored[#explored+1] = current

        if current == goal then
            return explored
        end

        for i=1, #verts do
            local e = adjMatrix[current.id][i]
            if e ~= nil then
                local found = false
                local u = e:getConnectedVertex(current)
            
                for j=1, #explored do
                    if explored[j] == u then
                        found = true
                    end
                end

                if found == false then
                    frontier[#frontier+1] = u
                end
            
            end
        end

    end
end

local PathFinding = {
    _VERSION = "SUPER-BETA"
}

return PathFinding