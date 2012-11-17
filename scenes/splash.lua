local res = "resources/splash/manifest.lua"
local delay = 1

return CutScene.load(res,
  -- The animation itself
  function (c, dt)
    c:setBackgroundColor({0xFF, 0xFF, 0xFF})
    c:setLetterBoxSize(400)
    c:setLayer(1, Assets.getSprite(res, "splash"))
    c:setCaption("GameJam II Entry", Assets.getFont(res, "caption"))
    c:wait(delay)

    c:setCaption("Programming: Marc O'Morain", Assets.getFont(res, "caption"))
    c:wait(delay)
  end,

  -- What to do after termination
  function ()
    StateStack.push(Scene.load("scenes/main_menu.lua"))
    
  end)