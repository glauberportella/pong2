local scene = require("src.scene")
local settings = require("src.settings")
local records = require("src.records")

-- Carregar valores/resources
function love.load()
  love.keyboard.setKeyRepeat(true) -- apagar letras segurando backspace
  settings.load()
  records.load()
  scene.switch("menu")
end

-- Atualizar estado do jogo em cada frame
function love.update(dt)
  scene.update(dt)
end

function love.keypressed(key)
  scene.keypressed(key)
end

function love.textinput(text)
  scene.textinput(text)
end

function love.mousepressed(x, y, button)
  scene.mousepressed(x, y, button)
end

function love.mousemoved(x, y)
  scene.mousemoved(x, y)
end

-- Desenhar na tela em cada frame
function love.draw()
  scene.draw()
end
