StateStack = {
    states = {}
}

function StateStack.push(newState)
    table.insert(StateStack.states, newState)
    newState:enter()
end

function StateStack.pop()
    local s = StateStack.currentState()
    table.remove(StateStack.states)
    s:leave()
end

function StateStack.currentState()
    local i = table.maxn(StateStack.states)
    return StateStack.states[i]
end

function StateStack.update(dt)
    StateStack.currentState():update(dt)
end

function StateStack.draw()
    StateStack.currentState():draw()
end