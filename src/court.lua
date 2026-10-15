-- Quadra: rede e placar

local config = require("src.config")

local court = {}

local score_texts = {}
local name_font = nil
local names = { "", "" }

function court.load()
  local font = love.graphics.newFont(config.FONT_PATH, config.SCORE_FONT_SIZE)
  score_texts.player1 = love.graphics.newText(font, "0")
  score_texts.player2 = love.graphics.newText(font, "0")
  name_font = love.graphics.newFont(config.FONT_PATH, config.NAME_FONT_SIZE)
end

function court.set_names(player_names)
  names = player_names
end

function court.set_score(score)
  score_texts.player1:set(string.format("%d", score.player1))
  score_texts.player2:set(string.format("%d", score.player2))
end

function court.draw_score()
  love.graphics.draw(score_texts.player1, config.SCORE_LEFT_X, config.SCORE_LEFT_Y)
  love.graphics.draw(score_texts.player2, config.SCORE_RIGHT_X, config.SCORE_RIGHT_Y)

  -- nomes acima do placar, alinhados a rede
  local half = config.WINDOW_W / 2
  local gap = 40
  love.graphics.setFont(name_font)
  love.graphics.setColor(1, 1, 1, 0.8)
  love.graphics.printf(names[1], 0, config.NAME_Y, half - gap, "right")
  love.graphics.printf(names[2], half + gap, config.NAME_Y, half - gap, "left")
  love.graphics.setColor(1, 1, 1, 1)
end

function court.draw_net()
  local segment_length = config.WINDOW_H / config.NET_DASH_COUNT
  local net_x = config.WINDOW_W / 2

  local line_width = love.graphics.getLineWidth()
  love.graphics.setLineWidth(config.NET_LINE_WIDTH)

  -- Desenha a rede tracejada
  for i = 0, config.NET_DASH_COUNT - 1, 2 do
    love.graphics.line(net_x, i * segment_length, net_x, (i + 1) * segment_length)
  end

  love.graphics.setLineWidth(line_width)
end

return court
