

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
local init_bird_x = w/2
local init_bird_y = h/4 + h/2
local bird_x = init_bird_x
local bird_y = init_bird_y
local health = w
local health_decay = 0.5
local eaten  = 0
local time_in_tone = 0

local fish_x = w/2
local fish_y = h/2
local fish_angle = 0
local fish_dx   = 0
local fish_dy   = 0
local fish_x_speed = 40
local fish_y_speed = 40
local fish_target_d = 10000

local game_time = 0
local fish_alpha = 0

local game_state = 'waiting'

local breath = 0
local dive_scale = 1
local dive_distance = 100

local bird_forward = 20
local bird_accel   = 0

local beep = love.audio.newSource("resources/beep.wav", "static")
local tone = love.audio.newSource("resources/tone.wav", "static")
local collect = love.audio.newSource("resources/collect.wav", "static")
local beep_last_time = 0


local font_eaten = love.graphics.newFont("resources/Krungthep.ttf", 15)
local font_title = love.graphics.newFont("resources/Krungthep.ttf", 36)

local water = love.graphics.newParticleSystem(love.graphics.newImage('resources/water.png'), 80)
water:setParticleLife(0.5, 4)
water:setPosition(w/2, h/2)
water:setEmissionRate(200)
water:setSizeVariation(0.8)
water:setSpeed(20,50)
water:setRadialAcceleration(10,50)
water:setSpread(2 * math.pi )
water:setTangentialAcceleration(3, 20)
water:setColors(255,255,255,255,
  255,255,255,0)
water:stop()
--water:start()

local fish_body =
{
  0,-6,
  1,-5,
  2,-2,
  1,3,
  0,5
}

local fish_tail =
{
  0,5,
  1,6,
  0,6,
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

local function distance(x1,y1,x2,y2)
    local a = x1-x2
    local b = y1-y2
    return math.sqrt(a*a+b*b)
  end

function Level:update(dt)

  game_time = game_time + dt

  breath = (breath + dt*2) % (2*math.pi)

  water:update(dt)

  if game_state == 'waiting' then

    if game_time > 3 then
      health = w
      game_state = 'fish_in_water'
      fish_alpha = 1
      fish_x = math.random(w)
      fish_y = math.random(h)
    end

  elseif game_state == 'climbing' then

    --water:update(dt)

    if (distance(bird_x, bird_y, init_bird_x, init_bird_y) > 2) then
      bird_x = bird_x + (init_bird_x - bird_x) * dt
      bird_y = bird_y + (init_bird_y - bird_y) * dt
    else
      bird_x = init_bird_x
      bird_y = init_bird_y
    end

    if dive_scale < 1 then
      dive_scale = dive_scale + dt


    else
      game_time = 0
      bird_x = init_bird_x
      bird_y = init_bird_y
      game_state = 'waiting'
      water:stop()
      
    end
  elseif game_state == 'diving' then
    fish_x = w/2
    fish_y = h/2

    local db = distance(fish_x, fish_y, bird_x, bird_y)
    if db < 50 then
      eaten = eaten + 1       
      health_decay = health_decay + 0.1
      game_state = 'climbing'
      love.audio.play(collect)
      game_time = 0
      water:setPosition(w/2-100, h/2-100)
      water:start()
    else
      bird_x = bird_x + ((fish_x - bird_x) * dt)
      bird_y = bird_y + ((fish_y - bird_y) * dt)
      dive_scale = math.max(0.3, db/dive_distance)
    end

    -- move bird to fish
  elseif game_state == 'fish_in_water' then

    health = health - health_decay

    if health <= 0 then
      StateStack.pop()
    end

    fish_alpha = math.min(255, fish_alpha + 1)

    beep_last_time = beep_last_time + dt

    fish_target_d = distance(fish_x, fish_y, w/2, h/2)

    local sound_range = 100
    local tone_range  = 15


    if (fish_target_d < tone_range) then
      --love.audio.rewind()
      tone:setVolume(1)
      love.audio.play(tone)
      love.audio.stop(beep)
      time_in_tone = time_in_tone + dt

      if time_in_tone > 0.3 then

        if  love.joystick.isDown(2, 11) and 
            love.joystick.isDown(2, 12) then
          dive_distance = distance(fish_x, fish_y, bird_x, bird_y)
          print('dive start ' .. tostring(dive_distance))
          game_state = 'diving'
          tone:stop()
          game_time = 0
        end
      end

    else
      time_in_tone = 0
      tone:stop()

      if (fish_target_d < sound_range) and (beep_last_time > 1) then
        beep_last_time = 0
        love.audio.rewind()
        beep:setVolume((sound_range-fish_target_d)/sound_range)
        love.audio.play(beep)
      end
    end

    if math.random() < 0.005 then
      fish_angle = math.random() * 2 * math.pi
    end

    fish_x = fish_x + dt * math.sin(fish_angle) * fish_x_speed
    fish_y = fish_y + dt * math.cos(fish_angle) * fish_y_speed

    local function clamp1000(value)
      if value < -1000 then
        return -1000
      elseif value > 1000 then
        return 1000
      else
        return value
      end
    end

    fish_x = clamp1000(fish_x)
    fish_y = clamp1000(fish_y)

    fish_dx = (fish_x - bird_x)
    fish_dy = (fish_x - bird_y)

    fish_x = fish_x + (rotation*2)
    fish_y = fish_y - (bird_accel * 2)
  end

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


  love.graphics.draw(water, 100, 100)



  local function angle(x1,y1,x2,y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.atan2(dy, dx) + (math.pi/2)
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


  if game_state == 'fish_in_water'  or game_state == 'diving' then
    love.graphics.push()
    draw_arrow()
    love.graphics.pop()


    love.graphics.push()
    love.graphics.setColor(200,170,100, fish_alpha)
    love.graphics.translate(fish_x, fish_y)
    love.graphics.scale(5, 5)
    love.graphics.polygon(wing_style, fish_body)
    love.graphics.polygon(wing_style, fish_tail)
    love.graphics.scale(-1, 1)
    love.graphics.polygon(wing_style, fish_body)
    love.graphics.polygon(wing_style, fish_tail)
    love.graphics.pop()
  end

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

  local scale = dive_scale * (20 + (1 * math.sin(breath)))

  love.graphics.scale(scale, scale)

  render_geom(wing_r)
  love.graphics.scale(-1, 1)
  render_geom(wing_l)
  love.graphics.pop()

  love.graphics.setColor(255,255,255)
  love.graphics.setFont(font_eaten)
  love.graphics.printf(string.format("Fish Eaten: %d", eaten), 25, 25, 200, "left")

  if game_time < 3 then
    
    love.graphics.setFont(font_title)
    love.graphics.printf(string.format('%d',4-game_time), w/2-25, h/2, 100, "center")
  elseif game_time < 4 then
    love.graphics.setFont(font_title)
    love.graphics.printf('Fish!', w/2-50, h/2, 100, "center")
  end


  if StateStack.debug then   

    love.graphics.setFont(font_eaten) 
    love.graphics.printf(string.format("State: %s\nWings: %g %g\nTurn %g\nAccel: %g\nFish DX: %g\nFish DY: %g\nTarget: %g\nButtons: %s",
      game_state, wing_l, wing_r, rotation, bird_accel, fish_dx, fish_dy, fish_target_d, buttons),
      25, 75, 400, "left")

    
  end


  if game_state == 'fish_in_water' then

    love.graphics.push()
    love.graphics.translate(w/2, h/2)

    local size_sq = math.max(2, fish_target_d/10)

    local sq_alpha = math.max(255 - fish_target_d * 3, 0)

    love.graphics.setColor(0,255,0,sq_alpha)
    love.graphics.scale(size_sq, size_sq)
    love.graphics.polygon('line',
      -15, -15,
      -15,  15,
      15,  15,
      15, -15)
    love.graphics.pop()

    love.graphics.setColor(255,255,255, fish_alpha)
    love.graphics.quad("fill",
      0, h-20,
      0, h,
      health, h,
      health, h-20)
  end

end

return Level