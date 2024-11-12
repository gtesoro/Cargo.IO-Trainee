local pd <const> = playdate
local gfx <const> = pd.graphics

local cubeFaces = {
    -- {5, 6, 7, 8},  -- Left
    -- {1, 2, 6, 5},  -- Bottom
    -- {2, 3, 7, 6},  -- Back
    {1, 2, 3, 4},  -- Right
    {3, 4, 8, 7},  -- Top
    {4, 1, 5, 8}   -- Front
}

function drawFilledFace(vertices, color, dither)
    gfx.setColor(color) 
    if dither then
        gfx.setDitherPattern(0.8, dither)
    end
    gfx.fillPolygon(table.unpack(vertices))
end


function createCube(x, y, z, width)
    local halfWidth = width / 2
    return {
        {x - halfWidth, y - halfWidth, z - halfWidth},
        {x + halfWidth, y - halfWidth, z - halfWidth},
        {x + halfWidth, y + halfWidth, z - halfWidth},
        {x - halfWidth, y + halfWidth, z - halfWidth},
        {x - halfWidth, y - halfWidth, z + halfWidth},
        {x + halfWidth, y - halfWidth, z + halfWidth},
        {x + halfWidth, y + halfWidth, z + halfWidth},
        {x - halfWidth, y + halfWidth, z + halfWidth}
    }
end


function drawWireframeCube(x, y, z, width, w, h, _type)
    local vertices = createCube(0, 0, 0, width)
    local totalX, totalY = 0, 0 
    local numVertices = 0
    
    for i, face in ipairs(cubeFaces) do
        local projectedVertices = {}
        
        -- Project vertices for the current face
        for _, vertexIndex in ipairs(face) do
            local vertex = vertices[vertexIndex]
            local projX, projY = projectIsometric(vertex[1], vertex[2], vertex[3], x, y, z, w, h)
            table.insert(projectedVertices, projX)
            table.insert(projectedVertices, projY)

            totalX = totalX + projX
            totalY = totalY + projY
            numVertices = numVertices + 1 
        end

        if _type == 0 then
            drawFilledFace(projectedVertices, gfx.kColorBlack)
        end

        if _type == 1 then
            drawFilledFace(projectedVertices, gfx.kColorWhite, gfx.image.kDitherTypeBayer8x8)
        end

        if _type == 2 then
            drawFilledFace(projectedVertices, gfx.kColorWhite)
        end
        
        -- Optionally, draw the edges of the face
        for j = 1, #face do
            local startIndex = face[j]
            local endIndex = face[(j % #face) + 1]  -- Connect last vertex to the first

            local startVertex = vertices[startIndex]
            local endVertex = vertices[endIndex]

            local x1, y1 = projectIsometric(startVertex[1], startVertex[2], startVertex[3], x, y, z, w, h)
            local x2, y2 = projectIsometric(endVertex[1], endVertex[2], endVertex[3], x, y, z, w, h)


            gfx.setColor(gfx.kColorWhite)

            if _type > 1 then
                gfx.setColor(gfx.kColorBlack)
            end

            gfx.setLineWidth(2)
            gfx.drawLine(x1, y1, x2, y2)
            
        end
    end

    -- Calculate the average center of the cube's projected points
    local centerX = totalX / numVertices
    local centerY = totalY / numVertices

    -- Return the center coordinates
    return centerX, centerY
end


function project3DTo2D(x, y, z)
    local scale = 50 -- Scaling factor to adjust size
    local screenX = 200 + (x / (z + 5)) * scale
    local screenY = 120 + (y / (z + 5)) * scale
    return screenX, screenY
end

function projectIsometric(x, y, z, offsetX, offsetY, offsetZ, width, height)
    -- Apply the isometric projection formula with offsets
    local isoX = (x + offsetX - z - offsetZ) * math.cos(math.rad(30))
    local isoY = (x + offsetX + 2 * (y + offsetY) + z + offsetZ) * math.sin(math.rad(30))
    
    -- Adjust to screen center and scale
    local screenX = width/2 + isoX   -- Center at (200, 120) with a scale of 20
    local screenY = height/2 - isoY 
    return screenX, screenY
end

function drawIsometricFloor(image, x, y, width, depth)
    -- Calculate isometric projection for the four corners of the floor
    local topLeftX, topLeftY = projectIsometric(x, y, 0, 0, 0, 0)
    local topRightX, topRightY = projectIsometric(x + width, y, 0, 0, 0, 0)
    local bottomLeftX, bottomLeftY = projectIsometric(x, y + depth, 0, 0, 0, 0)
    local bottomRightX, bottomRightY = projectIsometric(x + width, y + depth, 0, 0, 0, 0)

    -- Draw the image within the calculated isometric coordinates
    image:draw(topLeftX, topLeftY, playdate.graphics.kImageFlippedY)
end

function getIsometricImage(image, x, y, width, depth)
    -- Create an affine transform object
    local transform = pd.geometry.affineTransform.new()

    -- Translate to the desired position on the screen
    --transform:translate(x, y)

    -- Skew and scale the image to create an isometric projection
    -- 30 degrees (or π/6 radians) is a common angle for isometric projections
    local angle = math.rad(30)
    transform:scale(math.cos(angle), math.sin(angle))

    -- Apply the transform to the image and draw it
    return image:transformedImage(transform)
end