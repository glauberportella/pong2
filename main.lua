local game = require("src.game")

-- Carregar valores/resources
function love.load()
  game.load()
end

-- Atualizar estado do jogo em cada frame
function love.update(dt)
  game.update(dt)
end

-- Desenhar na tela em cada frame
function love.draw()
  game.draw()
end
