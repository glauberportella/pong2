-- Quadra: rede e placar

local config = require("src.config")

local court = {}

local score_texts = {}

function court.load()
  local font = love.graphics.newFont(config.FONT_PATH, config.SCORE_FONT_SIZE)
  score_texts.player1 = love.graphics.newText(font, "0")
  score_texts.player2 = love.graphics.newText(font, "0")
end

function court.set_score(score)
  score_texts.player1:set(string.format("%d", score.player1))
  score_texts.player2:set(string.format("%d", score.player2))
end

function court.draw_score()
  love.graphics.draw(score_texts.player1, config.SCORE_LEFT_X, config.SCORE_LEFT_Y)
  love.graphics.draw(score_texts.player2, config.SCORE_RIGHT_X, config.SCORE_RIGHT_Y)
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
