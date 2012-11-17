return MenuScene.load(
    "resources/main_menu/manifest.lua",
    {
        fontName = "menu",
        title = "Control the game with the gamepad:\nTwo Sticks Up: GO FASTER\nTwo Sticks Down: SLOW DOWN\nOne Stick Up – One Stick Down: TURN\n\nTo hunt fish follow the red arrows\nHover behind a fish to get a lock-on. The fish should be in the\ncenter of the screen.\n\nWhen you have a lock on press L1 and R1 to dive!"
    },
    {{
        message = "NEW GAME",
        action = function()
          StateStack.push(Scene.load("scenes/level.lua"))
        end
    },
    {
        message = "EXIT",
        action = function()
            love.event.push("quit")
        end
    }})