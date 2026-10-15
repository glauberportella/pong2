-- Fim de partida: vencedor, placar, confronto e ultimas partidas da dupla

local config = require("src.config")
local ui = require("src.ui")
local scene = require("src.scene")
local settings = require("src.settings")
local records = require("src.records")
local backgrounds = require("src.backgrounds")

local gameover = {}

local result = nil
local rivalry = nil
local buttons = nil

function gameover.enter(r)
  result = r
  rivalry = records.head_to_head(r.names[1], r.names[2], 8)

  local w, h = 300, 60
  local gap = 30
  local x = (config.WINDOW_W - 2 * w - gap) / 2
  buttons = ui.button_list({
    ui.button("JOGAR DE NOVO", x, 710, w, h, function()
      scene.switch("play", { names = result.names, target = result.target })
    end),
    ui.button("MENU", x + w + gap, 710, w, h, function() scene.switch("menu") end),
  }, true)
end

function gameover.keypressed(key)
  if key == "escape" then
    scene.switch("menu")
  else
    buttons:keypressed(key)
  end
end

function gameover.mousemoved(x, y)
  buttons:mousemoved(x, y)
end

function gameover.mousepressed(x, y, button)
  buttons:mousepressed(x, y, button)
end

local function match_line(m)
  return string.format("%s   %s %d x %d %s", m.date, m.p1, m.s1, m.s2, m.p2)
end

function gameover.draw()
  backgrounds.draw(settings.background, 0.7)
  local names = result.names

  ui.text_center(names[result.winner] .. " VENCEU!", 40, 64, ui.colors.yellow)
  ui.text_center(string.format("%s  %d  x  %d  %s", names[1], result.score[1], result.score[2], names[2]), 130, 40)
  ui.text_center(string.format("Partida até %d pontos", result.target), 185, 18, ui.colors.muted)

  -- confronto
  local px, pw = 180, 1000
  ui.panel(px, 230, pw, 450)
  ui.text("CONFRONTO", px, 248, pw, 26, ui.colors.cyan, "center")
  ui.text(string.format("%s  %d  x  %d  %s", names[1], rivalry.wins[1], rivalry.wins[2], names[2]),
    px, 290, pw, 34, ui.colors.text, "center")
  ui.text(string.format("%d partida(s) entre os dois", rivalry.total), px, 335, pw, 18, ui.colors.muted, "center")
  if rivalry.best then
    local b = rivalry.best
    local winner = b.s1 > b.s2 and b.p1 or b.p2
    ui.text(string.format("Maior vitória: %s (%s %d x %d %s)", winner, b.p1, b.s1, b.s2, b.p2),
      px, 365, pw, 18, ui.colors.yellow, "center")
  end

  ui.text("ÚLTIMAS PARTIDAS", px, 410, pw, 22, ui.colors.cyan, "center")
  for i, m in ipairs(rivalry.history) do
    ui.text(match_line(m), px, 440 + (i - 1) * 28, pw, 18, i == 1 and ui.colors.text or ui.colors.muted, "center")
  end

  buttons:draw()
end

return gameover
