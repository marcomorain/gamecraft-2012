local MenuSceneState = {
    currentOption = 1,
    wasUpPressed = false,
    wasDownPressed = false
}
MenuSceneState.__index = MenuSceneState
function MenuSceneState:new(res, optionConfig, options)
    local o = {
        resources = res,
        background = background,
        optionConfig = optionConfig,
        options = options
    }
    setmetatable(o, self)
    return o
end

function MenuSceneState:enter()
    Assets.load(self.resources)
end

function MenuSceneState:leave()
    Assets.release(self.resources)
end

function MenuSceneState:update(dt)
    if love.keyboard.isDown("up") then
        if self.wasUpPressed == false then
            self.wasUpPressed = true
            self.currentOption = ((((self.currentOption - 1) + table.maxn(self.options)) - 1) % table.maxn(self.options)) + 1
        end
    else
        self.wasUpPressed = false
    end

    if love.keyboard.isDown("down") then
        if self.wasDownPressed == false then
            self.wasDownPressed = true
            self.currentOption = ((((self.currentOption - 1) + table.maxn(self.options)) + 1) % table.maxn(self.options)) + 1
        end
    else
        self.wasDownPressed = false
    end

    if love.keyboard.isDown("return") then
        self.options[self.currentOption].action()
    end
end

function MenuSceneState:draw()
    love.graphics.setBackgroundColor(0,0,0,255)
    love.graphics.setColor(255,255,255,255)

    local f = Assets.getFont(self.resources, self.optionConfig.fontName)
    love.graphics.setFont(f)

    local h = math.ceil(600 / (table.maxn(self.options) + 2))

    local m = self.optionConfig.title
    local w = f:getWidth(m)
    love.graphics.print(m, 100, 30)

    for i,v in ipairs(self.options) do
        local m = v.message
        if i == self.currentOption then
            m = "* " .. m .." *"
        end
        local w = f:getWidth(m)
        love.graphics.print(m, 400 - (w / 2), (i+1) * h)
    end
end

MenuScene = {}
function MenuScene.load(res, optionConfig, options)
    return MenuSceneState:new(res, optionConfig, options)
end