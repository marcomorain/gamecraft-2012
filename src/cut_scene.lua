require 'src.assets'

local CutSceneState = {
    bgColor = {0x00, 0x00, 0x00},
    letterBox = nil,               -- How big vertically is the letterbox. nil to disable.
    maxLayers = 10,
    caption = nil
}
CutSceneState.__index = CutSceneState
function CutSceneState:new(resources, cr, termAction)
    local o = {
        cr = coroutine.create(function (css)
            cr(css)
            return "END"
        end),
        layers = {},
        resources = resources,
        termAction = (termAction or (function () end))
    }
    setmetatable(o, self)
    return o
end

function CutSceneState:enter()
    Assets.load(self.resources)
end

function CutSceneState:leave()
    Assets.release(self.resources)
end

function CutSceneState:update(dt)
    local s,e = coroutine.resume(self.cr, self, dt)
    if not s then
        print(e)
        print('an_unknown_function_call()')
    elseif e == "END" then
        StateStack.pop()
        self.termAction()
    end
end

function CutSceneState:draw()
    love.graphics.setBackgroundColor(self.bgColor)
    love.graphics.clear()

    local h, w = love.graphics.getHeight(), love.graphics.getWidth()
    local offY = 0

    for li=1,self.maxLayers do
        local layer = self.layers[li]
        if layer then
            love.graphics.draw(layer.sprite, layer.x, layer.y)
        end
    end

    if self.letterBox then
        offY = (h - self.letterBox) / 2
        h = h - (2 * offY)
        love.graphics.setColor(0,0,0,255)
        love.graphics.rectangle("fill", 0, 0, w, offY)
        love.graphics.rectangle("fill", 0, h + offY, w, offY)
        love.graphics.setColor(255,255,255,255)
    end

    if self.caption then
        local text = self.caption.text
        local font = self.caption.font
        local tw, th = font:getWidth(text), font:getHeight()
        love.graphics.setFont(font)
        love.graphics.setColor(255,255,255,255)
        love.graphics.print(text, (w / 2) - (tw / 2), offY + h + th)
    end
end

function CutSceneState:setBackgroundColor(bgColor)
    self.bgColor = bgColor
end

function CutSceneState:setLetterBoxSize(size)
    self.letterBox = size
end

function CutSceneState:setLayer(li, sprite, x, y)
    if not x then
        x = (love.graphics.getWidth() / 2) - (sprite:getWidth() / 2)
    end

    if not y then
        y = (love.graphics.getHeight() / 2) - (sprite:getHeight() / 2)
    end

    self.layers[li] = {sprite = sprite, x = x, y = y}
end

function CutSceneState:wait(seconds)
    local timePassed = 0
    while timePassed < seconds do
        local _, dt = coroutine.yield()
        timePassed = timePassed + dt
    end
end

function CutSceneState:setCaption(caption, font)
    self.caption = {text = caption, font = font}
end

CutScene = {}
function CutScene.load(res, cr, termAction)
    return CutSceneState:new(res, cr, termAction)
end