

local Level = {}

local rain = {}

local w = love.graphics.getWidth()
local h = love.graphics.getHeight()

local rain_x = 50
local rain_y = 500
local wing_l = 0
local wing_r = 0
local rotation = 0
local bird_x = w/2
local bird_y = h/4 + h/2

local bird_forward = 20
local bird_accel   = 0

local wing_out =
{
   0,  0,
   3, -2,
  10,  4,
   3,  1,
   0,  3
}

local wing_in = 
{
  0,  0,
  3, -3,
  5,  8,
  2,  0,
  0,  3
}

local tail_out =
{
  0,  5,
  1,  5,
  2,  8,
  1, 12,
  1,  8,
  0,  6
}

local tail_in =
{
  0, 5,
  1, 5,
  1, 6,
  1, 13,
  0, 6,
  0, 6
}

local function rotate_point(x, y, angle, cx, cy)
  local s = math.sin(angle);
  local c = math.cos(angle);

  -- translate point back to origin:
  local rx = x - cx;
  local ry = y - cy;

  -- rotate point
  local xnew = rx * c - ry * s;
  local ynew = rx * s + ry * c;

  -- translate point back:
  rx = xnew + cx;
  ry = ynew + cy;

  return rx, ry
end

function Level:enter()

  for i = 1,100 do
    local x = math.random(w)
    local y = math.random(h)
    table.insert(rain, {
      x  = x,
      y  = y,
      lx = x,
      ly = y
    })
  end

  print('level-enter')
  love.graphics.setBackgroundColor(15,13,190)

end

function Level:leave()
  print('level-leave')
end

function Level:update(dt)

  local function read_wing(axis)
    local result = love.joystick.getAxis(2,  axis)
    if math.abs(result) < 0.1 then
      result = 0
    end
    return -result
  end

  wing_l     = read_wing(2)
  wing_r     = read_wing(4)
  rotation   = (wing_l - wing_r) / 2
  bird_accel = (wing_l + wing_r) / 2

  for i, r in pairs(rain) do

    local dx = math.sin(rotation)
    local dy = math.cos(rotation)
    r.lx = r.x
    r.ly = r.y
    r.x = r.x
    r.y = r.y + bird_forward

    r.x, r.y = rotate_point(r.x, r.y, rotation * 0.05, bird_x, bird_y)

    if r.y > h then
      r.y  = 0
      r.x = math.random(w)
      r.lx = r.x
      r.ly = r.y
    end

    if r.x > w then
      r.x  = 0
      r.y = math.random(h)
      r.lx = r.x
      r.ly = r.y
    end

    if r.x < 0 then
      r.x = w
      r.y = math.random(h)
      r.lx = r.x
      r.ly = r.y
    end

  end
end

function Level:draw()

  love.graphics.setColor(0, 0, 255)

  -- love.graphics.setLine(2, "smooth")
  for _, r in pairs(rain) do
    love.graphics.line(r.x, r.y, r.lx, r.ly)
  end

  local function lerp(a, b, s)
    return a + (s * (b - a))
  end

  local function geom_position(a, b, wing_speed)
    local speed = (wing_speed + 1) / 2.0
    local result = {}
    for i, _ in ipairs(a) do
      result[i] = lerp(a[i], b[i], speed)
    end
    return result
  end

  local function wing_position(wing_speed)
    return geom_position(wing_in, wing_out, wing_speed)
  end

  local function tail_position(wing_speed)
    return geom_position(tail_in, tail_out, wing_speed)
  end

  --wing = wing_out

  local wing_style = 'fill' -- 'line'

love.graphics.setLine(1, 'rough')
  love.graphics.push()
    love.graphics.setColor(0,0,0)
    love.graphics.translate(bird_x, bird_y)
    love.graphics.scale(10, 10)
    love.graphics.polygon(wing_style, wing_position(wing_r))
    love.graphics.polygon(wing_style, tail_position(wing_r))
    love.graphics.scale(-1, 1)
    love.graphics.polygon(wing_style, wing_position(wing_l))
    love.graphics.polygon(wing_style, tail_position(wing_l))
  love.graphics.pop()


  love.graphics.printf(string.format("Wings: %g %g\nTurn %g\nAccel: %g",
    wing_l, wing_r, rotation, bird_accel),
    25, 25, 400, "left")
end

return Level