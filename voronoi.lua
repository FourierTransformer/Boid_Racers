#!/usr/bin/env lua
---------------
-- ## Voronoi, Lua module for convex polygon triangulation
-- @author Shakil Thakur
-- @copyright 2014
-- @license MIT
-- @script voronoi

-- modules and stuff
local Delaunay = require 'delaunay'
local Triangle = Delaunay.Triangle
local Point    = Delaunay.Point
local Edge     = Delaunay.Edge

local Voronoi = {
    _VERSION = "SUPER-BETA"
}

function Voronoi.calculate(t)
    local triangles = t
    local ntriangles = #t
    assert(ntriangles > 0, "Need to have at least 1 triangle")
    if ntriangles == 1 then
        return {t[ntriangles]:getCircumCenter()}
    end

    local vertices = {}

    local graph = {}
    for i=1, ntriangles do
        graph[i] = {}
        for j=1, ntriangles do
            graph[i][j] = nil
        end
    end

    for i, triangle in ipairs(triangles) do
        local x, y = triangle:getCircumCenter()
        vertices[i] = Point(x, y)
        vertices[i].id = i
    end
    
    for i, triangle in ipairs(triangles) do
        for l, currentEdge in ipairs(triangle.e) do
            for j = i+1, ntriangles do
                
                local newEdge = Edge(vertices[i], vertices[j])
                for k, edge in ipairs(triangles[j].e) do
                    if currentEdge:same(edge) then
                        graph[i][j] = newEdge
                        graph[j][i] = newEdge
                        break
                    end
                end

            end
        end
    end

    return vertices, graph

end

return Voronoi