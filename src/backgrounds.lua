-- Planos de fundo da quadra

local config = require("src.config")

local backgrounds = {
  { name = "Clássico" }, -- fundo preto original
  { name = "Cidade", file = "assets/bg/fundo_cidade.png" },
  { name = "Digital", file = "assets/bg/fundo_digital.png" },
  { name = "Espaço", file = "assets/bg/fundo_espaco.png" },
  { name = "Floresta", file = "assets/bg/fundo_floresta.png" },
  { name = "Ruínas", file = "assets/bg/fundo_ruinas.png" },
}

local TITLE_FILE = "assets/bg/tela_inicial_pong2.png"

local images = {}
local title_image = nil

local function image(index)
  local bg = backgrounds[index]
  if bg and bg.file and not images[index] then
    images[index] = love.graphics.newImage(bg.file)
  end
  return images[index]
end

function backgrounds.count()
  return #backgrounds
end

function backgrounds.name(index)
  return backgrounds[index] and backgrounds[index].name or backgrounds[1].name
end

-- Garante um indice valido (ex.: vindo de um save antigo)
function backgrounds.clamp(index)
  if type(index) ~= "number" or index < 1 or index > #backgrounds then
    return 1
  end
  return math.floor(index)
end

-- Desenha o fundo no retangulo dado (tela inteira por padrao).
-- dim: escurecimento de 0 a 1 para os elementos do jogo aparecerem bem.
function backgrounds.draw(index, dim, x, y, w, h)
  x, y = x or 0, y or 0
  w, h = w or config.WINDOW_W, h or config.WINDOW_H
  local img = image(index)
  if img then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(img, x, y, 0, w / img:getWidth(), h / img:getHeight())
  else
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", x, y, w, h)
  end
  if dim and dim > 0 then
    love.graphics.setColor(0, 0, 0, dim)
    love.graphics.rectangle("fill", x, y, w, h)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

-- Arte da tela inicial, usada como fundo dos menus
function backgrounds.draw_title(dim)
  title_image = title_image or love.graphics.newImage(TITLE_FILE)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(title_image, 0, 0, 0, config.WINDOW_W / title_image:getWidth(), config.WINDOW_H / title_image:getHeight())
  if dim and dim > 0 then
    love.graphics.setColor(0, 0, 0, dim)
    love.graphics.rectangle("fill", 0, 0, config.WINDOW_W, config.WINDOW_H)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

return backgrounds
