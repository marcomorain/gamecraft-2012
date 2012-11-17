

local Level = {}

local rain = {}
local rain_curve = 0.02

local w = love.graphics.getWidth()
local h = love.graphics.getHeight()

local rain_x = 50
local rain_y = 500
local wing_l = 0
local wing_r = 0
local rotation = 0
local bird_x = w/2
local bird_y = h/4 + h/2

local fish_x = w/2
local fish_y = h/2
local fish_angle = 0
local fish_dx   = 0
local fish_dy   = 0
local fish_x_speed = 40
local fish_y_speed = 40

local breath = 0

local bird_forward = 20
local bird_accel   = 0


local fish_body =
{
  0,0,
  1,1,
  2,4,
  1,9,
  0,11
}

local fish_tail =
{
  0,11,
  1,12,
  0,12,
}

local wing_out =
{
  {
    0,  0,
    3, -2,
    3,  1,
    0,  3
  },
  {
    3, -2,
    10,  4,
    3,  1
  }
}

local wing_in = 
{
  {
    0,  0,
    3, -3,
    2,  0,
    0,  3
  },
  {
    3, -3,
    5,  8,
    2,  0,
  }
}

local bird_body = 
{
  {
    0, -3,
    0.5, -3,
    1, -2,
    0.5, -1,
    0, -1
  },
  {
    0,-1,
    0.5, -1,
    1,2,
    0.5,5,
    0,5
  }
}

local tail_out =
{
  {
    0,  5,
    0.5,  5,
    1.5,  8,
    0.5,  8,
    0,  6
  },
  {
    1.5,  8,
    0.5, 12,
    0.5,  8
  }
}

local tail_in =
{
  {
    0, 5,
    0.5, 5,
    0.5, 6,
    0, 6,
    0, 6
  },
  {
    0.5, 6,
    0.5, 13,
    0, 6,
  }
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

function update_rain(dt)
  for i, r in pairs(rain) do

    local dx = math.sin(rotation)
    local dy = math.cos(rotation)
    r.lx = r.x
    r.ly = r.y
    r.x = r.x
    r.y = r.y + bird_forward



    r.x, r.y = rotate_point(r.x, r.y, rotation * rain_curve, bird_x, bird_y)

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

function Level:update(dt)


  breath = (breath + dt) % (2*math.pi)

  if math.random() < 0.01 then
    fish_angle = math.random() * 2 * math.pi
  end

  fish_x = fish_x + dt * math.sin(fish_angle) * fish_x_speed
  fish_y = fish_y + dt * math.cos(fish_angle) * fish_y_speed

  fish_dx = (fish_x - bird_x)
  fish_dy = (fish_x - bird_y)

  fish_x = fish_x + (rotation * 0.5)
  fish_y = fish_y - (bird_accel)

  local function read_wing(axis)
    local result = love.joystick.getAxis(2,  axis)
    if math.abs(result) < 0.1 then
      result = 0
    end
    return result
  end

  wing_l     = read_wing(2)
  wing_r     = read_wing(4)
  rotation   = (wing_l - wing_r) / 2
  bird_accel = (wing_l + wing_r) / 2

  update_rain()

end


function Level:draw()

  local function angle(x1,y1,x2,y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.atan2(dy, dx) + (math.pi/2)
  end

  local function distance(x1,y1,x2,y2)
    local a = x1-x2
    local b = y1-y2
    return math.sqrt(a*a+b*b)
  end


  local function draw_arrow()
    local distance = math.min(w, distance(
    bird_x, bird_y,
    fish_x, fish_y))

    local alpha = distance/w * 255

    local r = angle(bird_x, bird_y, fish_x, fish_y)

    love.graphics.setColor(200,50,50,alpha)
    
    love.graphics.translate(w/2, h/2)
    love.graphics.rotate(r)

    love.graphics.scale(10, 10)
    
    love.graphics.polygon('line',
      0,-3,
      3,4,
      -3,4)

  end

  local wing_style = 'fill' -- 'line'


  love.graphics.push()
    
    draw_arrow()
  love.graphics.pop()

  love.graphics.push()
    love.graphics.setColor(200,170,100)
    love.graphics.translate(fish_x, fish_y)
    love.graphics.scale(5, 5)
    love.graphics.polygon(wing_style, fish_body)
    love.graphics.polygon(wing_style, fish_tail)
    love.graphics.scale(-1, 1)
    love.graphics.polygon(wing_style, fish_body)
    love.graphics.polygon(wing_style, fish_tail)
  love.graphics.pop()

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
    for i, g in ipairs(a) do
      result[i] = {}
      for j, _ in ipairs(g) do
        result[i][j] = lerp(a[i][j], b[i][j], speed)
      end
    end
    return result
  end

  local function wing_position(wing_speed)
    return geom_position(wing_in, wing_out, wing_speed)
  end

  local function tail_position(wing_speed)
    return geom_position(tail_in, tail_out, wing_speed)
  end

  local function find_max(...)
    local xmax = 0
    local ymax = 0
    for _, geom in pairs({...}) do
      for i,g in ipairs(geom) do
        for j,p in ipairs(g) do
          if j % 2 == 1 then
            xmax = math.max(xmax, p)
          else
            ymax = math.max(ymax, p)
          end
        end
      end
    end
    return xmax, ymax
  end


  local function render_geom(wing_speed)
    
    local wing_geom  = wing_position(wing_speed)
    local tail_geom  = tail_position(wing_speed)
    local xmax, ymax = find_max(wing_geom)

    -- love.graphics.setColor(255,255,255, 50)
    -- love.graphics.polygon('fill',
    --   0, 0,
    --   xmax, ymax,
    --   xmax, 20,
    --   0, 20)

    love.graphics.setColor(0,0,0)
    for _,g in ipairs(wing_geom) do
      love.graphics.polygon(wing_style, g)
    end
    for _,g in ipairs(tail_geom) do
      love.graphics.polygon(wing_style, g)
    end
    for _,g in ipairs(bird_body) do
      love.graphics.polygon(wing_style, g)
    end
  end

  love.graphics.setLine(1, 'rough')
  love.graphics.push()    
    love.graphics.translate(bird_x, bird_y)



      local scale = 10 + math.sin(breath)

      love.graphics.scale(scale, scale)



    render_geom(wing_r)
    love.graphics.scale(-1, 1)
    render_geom(wing_l)
  love.graphics.pop()

  love.graphics.setColor(255,255,255)
  love.graphics.printf(string.format("Wings: %g %g\nTurn %g\nAccel: %g\nFish DX: %g\nFish DY: %g",
    wing_l, wing_r, rotation, bird_accel, fish_dx, fish_dy),
    25, 25, 400, "left")
end

return Level