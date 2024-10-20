function getRandomDistinctPair(min, max)
    -- Get the first random number
    local first = math.random(min, max)
    
    -- Keep generating a second number until it's different from the first
    local second
    repeat
        second = math.random(min, max)
    until second ~= first
    
    return first, second
end

function drawDottedCircle(centerX, centerY, radius, dotCount, dotRadius, rotationAngle)
    -- Iterate through the number of dots you want to place on the circle
    for i = 1, dotCount do
        -- Calculate the angle for each dot (evenly spaced)
        local angle = (i / dotCount) * (2 * math.pi)
        
        -- Apply the rotation offset to create the spinning effect
        local rotatedAngle = angle + rotationAngle
        
        -- Calculate the x and y positions for each dot using the rotated angle
        local x = centerX + radius * math.cos(rotatedAngle)
        local y = centerY + radius * math.sin(rotatedAngle)
        
        -- Draw a small circle (dot) at the calculated position
        playdate.graphics.fillCircleAtPoint(x, y, dotRadius)
    end
end

function drawDottedEllipse(centerX, centerY, a, b, dotCount, dotRadius, rotationAngle)
    -- Iterate through the number of dots you want to place on the ellipse
    for i = 1, dotCount do
        -- Calculate the angle for each dot (evenly spaced)
        local angle = (i / dotCount) * (2 * math.pi)
        
        -- Calculate the x and y positions for each dot using ellipse parametric equations
        local rotatedAngle = angle + rotationAngle

        local x = centerX + a * math.cos(rotatedAngle)
        local y = centerY + b * math.sin(rotatedAngle)
        
        -- Draw a small circle (dot) at the calculated position
        playdate.graphics.fillCircleAtPoint(x, y, dotRadius)
    end
end

function drawDottedLine(x1, y1, x2, y2, dotSpacing, dotRadius)
    -- Calculate the total length of the line
    local dx = x2 - x1
    local dy = y2 - y1
    local lineLength = math.sqrt(dx * dx + dy * dy)
    
    -- Calculate the unit direction vector of the line
    local unitX = dx / lineLength
    local unitY = dy / lineLength
    
    -- Calculate the number of dots that will fit along the line
    local dotCount = math.floor(lineLength / dotSpacing)
    
    -- Draw dots along the line
    for i = 0, dotCount do
        -- Calculate the position of each dot with animation offset
        local dotPosition = (i * dotSpacing) % lineLength
        
        -- Calculate the x and y coordinates of the dot
        local x = x1 + dotPosition * unitX
        local y = y1 + dotPosition * unitY
        
        -- Draw a small circle (dot) at the calculated position
        playdate.graphics.fillCircleAtPoint(x, y, dotRadius)
    end
end

function clamp(v, l, m)

    if v > m then
        return m
    end

    if v < l then
        return l
    end

    return v

end

function rotatePoint(x, y, cx, cy, angle)
    -- Step 1: Translate the point to be relative to the center
    local px = x - cx
    local py = y - cy

    -- Step 2: Convert the angle to radians
    local angle_in_radians = math.rad(angle)

    -- Step 3: Apply the rotation matrix
    local new_px = px * math.cos(angle_in_radians) - py * math.sin(angle_in_radians)
    local new_py = px * math.sin(angle_in_radians) + py * math.cos(angle_in_radians)

    -- Step 4: Translate the point back to global coordinates
    local new_x = new_px + cx
    local new_y = new_py + cy

    return new_x, new_y
end