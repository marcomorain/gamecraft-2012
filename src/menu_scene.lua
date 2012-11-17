local MenuSceneState = {
    currentOption = 1
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

end

function MenuSceneState:draw()

end

MenuScene = {}
function MenuScene.load(res, optionConfig, options)
    return MenuSceneState:new(res, optionConfig, options)
end