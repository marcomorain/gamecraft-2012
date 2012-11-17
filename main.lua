require 'third_party.all'
require 'src.scene'
require 'src.state_stack'
require 'third_party.strict'

function love.load()
  

  local function num_things(f, i, name)
    print(string.format("Joystick %d %s %d", i, name, f(i)))
  end

  for i=1,2,1 do
    local open = love.joystick.open(i)
    print(string.format("Joystick %d open %s", i, tostring(open)))
    num_things(love.joystick.getNumBalls,     i, 'ball')
    num_things(love.joystick.getNumAxes,      i, 'axes')
    num_things(love.joystick.getNumButtons,   i, 'buttons')
    num_things(love.joystick.getNumHats,      i, 'hats')
    num_things(love.joystick.getNumJoysticks, i, 'joysticks')
  end

  

  local splash = Scene.load("scenes/splash.lua")
  StateStack.push(splash)
end

local paused = false
local limit  = 0

function love.keypressed(key)
  if key == 'd' then
    StateStack.debug = not StateStack.debug
  elseif key == "p" then
    paused = not paused
  elseif key == " " and paused then
    limit = limit + 1
  end
end

function love.update(dt)
  if paused then
    if limit > 0 then
      limit = limit - 1
      StateStack.update(dt)
    end
  else
    StateStack.update(dt)
  end
end

function love.draw()
    StateStack.draw()
end

-- Ellipse in general parametric form 
-- (See http://en.wikipedia.org/wiki/Ellipse#General_parametric_form)
-- (Hat tip to IdahoEv: https://love2d.org/forums/viewtopic.php?f=4&t=2687)
--
-- The center of the ellipse is (x,y)
-- a and b are semi-major and semi-minor axes respectively
-- phi is the angle in radians between the x-axis and the major axis

function love.graphics.ellipse(mode, x, y, a, b, phi, points)
  phi = phi or 0
  points = points or 10
  if points <= 0 then points = 1 end

  local two_pi = math.pi*2
  local angle_shift = two_pi/points
  local theta = 0
  local sin_phi = math.sin(phi)
  local cos_phi = math.cos(phi)

  local coords = {}
  for i = 1, points do
    theta = theta + angle_shift
    coords[2*i-1] = x + a * math.cos(theta) * cos_phi 
                      - b * math.sin(theta) * sin_phi
    coords[2*i] = y + a * math.cos(theta) * sin_phi 
                    + b * math.sin(theta) * cos_phi
  end

  coords[2*points+1] = coords[1]
  coords[2*points+2] = coords[2]

  love.graphics.polygon(mode, coords)
end
