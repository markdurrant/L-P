-- get Utilities & Point modules.
local utl = require("L-P/utilities")
require("L-P/point")

-- Set up Path class, and set closed to false.
local pathTable = { label = 'Path', closed = false }

-- Return a new path with an optional table of points.
function Path(points)
  local path = {}
        path.points = {}

  setmetatable(path, { __index = pathTable })

  if points then
    path.points = points

    path:setBox()
  end

  return path
end

-- Sets the bounding box for the path. Used internally.
function pathTable:setBox()
  local top    = self.points[1].y
  local bottom = self.points[1].y
  local left   = self.points[1].x 
  local right  = self.points[1].x

  for i, point in ipairs(self.points) do
    if point.y > top then
      top = point.y 
    end
    if point.y < bottom then
      bottom = point.y
    end
    if point.x > right then
      right = point.x
    end
    if point.x < left then
      left = point.x
    end
  end
  
  local hCenter = left + (right - left) / 2
  local vCenter = bottom + (top - bottom) / 2

  self.top          = top
  self.bottom       = bottom
  self.left         = left
  self.right        = right

  self.topLeft      = Point(left, top)
  self.topCenter    = Point(hCenter, top)
  self.topRight     = Point(right, top)  
  self.middleLeft   = Point(left, vCenter)
  self.center       = Point(hCenter, vCenter)
  self.middleRight  = Point(right, vCenter) 
  self.bottomLeft   = Point(left, bottom)
  self.bottomCenter = Point(hCenter, bottom)
  self.bottomRight  = Point(right, bottom)
end

-- close the path
function pathTable:close()
  self.closed = true

  return self
end

-- open the path
function pathTable:open()
  self.closed = false

  return self
end

-- add points to the Path 
-- give an optional index to add points to the middle of a path
function pathTable:addPoints(points, index)
  local i = #self.points + 1
  
  if index then
    i = index + 1
  end

  for _, p in ipairs(points) do
    table.insert(self.points, i, p)
  end

  self:setBox()

  return self
end

-- Remove points from the path using an index and an optional number of points.
function pathTable:removePoints(index, number) 
  local n = number or 1

  for i = 1, n do
    table.remove(self.points, index)
  end
  
  self:setBox()

  return self
end

-- Move the path along the X & Y axes.
function pathTable:move(x, y)
  for _, p in ipairs(self.points) do
    p:move(x, y)
  end
  
  self:setBox()
  
  return self
end

-- Move the path along a vector.
function pathTable:moveVector(direction, length)
  for _, p in ipairs(self.points) do
    p:moveVector(direction, length)
  end
  
  self:setBox()
  
  return self
end

-- Rotate the path clockwise around an optional origin point.
function pathTable:rotate(angle, point)
  local origin = point or self.center
  
  for _, p in ipairs(self.points) do
    p:rotate(angle, origin)
  end

  self:setBox()
  
  return self
end

-- Scale the path by a factor.
function pathTable:scale(factor)
  for _, p in ipairs(self.points) do
    local direction = self.center:angleTo(p)
    local length = self.center:distanceTo(p)

    p:moveVector(direction, length * factor - length)
  end
  
  self:setBox()
  
  return self
end

-- Return the total length of the path.
function pathTable:length()
  local length = 0
  
  for i = 1, #self.points - 1 do
    length = length + self.points[i]:distanceTo(self.points[i + 1])
  end

  if self.closed == true then
    length = length + self.points[#self.points]:distanceTo(self.points[1])
  end

  return length
end

-- Return the point at a specified distance along a path.
-- NEED TO ADD ABILITY TO GET POINT FROM CLOSED PATHS
function pathTable:pointAtDistance(distance)
  local point 

  for i = 1, #self.points - 1 do
    local segmentLength = self.points[i]:distanceTo(self.points[i + 1])

    if distance > segmentLength then
      distance = distance - segmentLength
    elseif distance >= 0 then
      local angle = self.points[i]:angleTo(self.points[i + 1])
      
      point = Point:new(self.points[i].x, self.points[i].y):moveVector(angle, distance)
      distance = distance - segmentLength
    end
  end

  return point
end

-- Return `true` if the path intersects itself. Return false if not.
-- ↓ Not yet imlipmented ↓
function pathTable:intersectsSelf()
  print("not yet implimented")
end

-- Return a table of points containing the intersections with a specified path.
-- ↓ Not yet imlipmented ↓
function pathTable:intersections(path)
  print("not yet implimented")
end

-- Return an identical copy of a path.
function pathTable:clone()
  return utl.clone(self)
end

-- Set the pen to draw the path.
function pathTable:setPen(pen)
  table.insert(pen.paths, self)

  return self
end

-- Return a string of a SVG `<path>` element for the path.
function pathTable:render()
  local pathTag = ""

  for i, p in ipairs(self.points) do
    if i == 1 then
      pathTag = "M "
    else
      pathTag = pathTag .. " L"
    end

    pathTag = pathTag .. p.x .. " " .. p.y
  end

  if self.closed == true then
    pathTag = pathTag .. " Z"
  end

  pathTag = '<path d="' .. pathTag .. '"/>'

  return pathTag
end

-- Return a string with path information including all child points information.
function pathTable:getLog()
  local log = string.format("Path { closed  = %s }", self.closed)
  local pointLog = ""

  for i, p in ipairs(self.points) do
    local pString = string.gsub(p:getLog(), "Point", string.format("\nPoint: %d", i))
    pointLog = pointLog .. pString
  end

  return log .. utl.indent(pointLog)
end

-- print path information including all child points information.
function pathTable:log()
  print(self:getLog())
end

-- Return Path generator
return Path