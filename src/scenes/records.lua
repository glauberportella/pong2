-- Recordes: ranking geral de vitorias e confrontos mais recentes

local ui = require("src.ui")
local scene = require("src.scene")
local records = require("src.records")
local backgrounds = require("src.backgrounds")
local config = require("src.config")

local screen = {}

local ranking = nil
local rivalries = nil
local buttons = nil

function screen.enter()
  ranking = records.ranking(10)
  rivalries = records.rivalries(10)
  local w, h = 260, 56
  buttons = ui.button_list({
    ui.button("VOLTAR", (config.WINDOW_W - w) / 2, 725, w, h, function() scene.switch("menu") end),
  })
end

function screen.keypressed(key)
  if key == "escape" then
    scene.switch("menu")
  else
    buttons:keypressed(key)
  end
end

function screen.mousemoved(x, y)
  buttons:mousemoved(x, y)
end

function screen.mousepressed(x, y, button)
  buttons:mousepressed(x, y, button)
end

local function draw_ranking(x, y, w)
  ui.panel(x, y, w, 400)
  ui.text("RECORDES: VITÓRIAS", x, y + 16, w, 24, ui.colors.cyan, "center")
  if #ranking == 0 then
    ui.text("Nenhuma partida terminada ainda", x, y + 180, w, 18, ui.colors.muted, "center")
    return
  end
  ui.text("VITÓRIAS   PARTIDAS", x + 24, y + 56, w - 48, 14, ui.colors.muted, "right")
  for i, e in ipairs(ranking) do
    local ly = y + 80 + (i - 1) * 31
    local color = i == 1 and ui.colors.yellow or ui.colors.text
    ui.text(string.format("%d. %s", i, e.name), x + 24, ly, w - 48, 20, color)
    ui.text(string.format("%d          %d", e.wins, e.played), x + 24, ly, w - 70, 20, color, "right")
  end
end

local function draw_rivalries(x, y, w)
  ui.panel(x, y, w, 400)
  ui.text("CONFRONTOS RECENTES", x, y + 16, w, 24, ui.colors.cyan, "center")
  if #rivalries == 0 then
    ui.text("Nenhum confronto registrado", x, y + 180, w, 18, ui.colors.muted, "center")
    return
  end
  for i, r in ipairs(rivalries) do
    local ly = y + 64 + (i - 1) * 32
    ui.text(string.format("%s  %d x %d  %s", r.a, r.wins[1], r.wins[2], r.b), x + 24, ly, w - 48, 20)
    ui.text(string.format("%d jogo(s)", r.total), x + 24, ly + 3, w - 48, 14, ui.colors.muted, "right")
  end
end

function screen.draw()
  backgrounds.draw_title(0.45)
  draw_ranking(120, 315, 540)
  draw_rivalries(700, 315, 540)
  buttons:draw()
end

return screen
