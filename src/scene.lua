-- Gerenciador de cenas (telas): cada cena e um modulo em src/scenes/
-- com funcoes opcionais enter(params), leave(), update, draw e eventos de entrada.

local scene = {}

local current = nil

function scene.switch(name, params)
  if current and current.leave then
    current.leave()
  end
  current = require("src.scenes." .. name)
  if current.enter then
    current.enter(params or {})
  end
end

-- Repassa um callback do LOVE para a cena atual
local function forward(callback)
  return function(...)
    if current and current[callback] then
      current[callback](...)
    end
  end
end

scene.update = forward("update")
scene.draw = forward("draw")
scene.keypressed = forward("keypressed")
scene.textinput = forward("textinput")
scene.mousepressed = forward("mousepressed")
scene.mousemoved = forward("mousemoved")

return scene
