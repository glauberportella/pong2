-- Creditos

local config = require("src.config")
local ui = require("src.ui")
local scene = require("src.scene")
local backgrounds = require("src.backgrounds")

local credits = {}

local version = nil
local buttons = nil

local LINES = {
  { "DESENVOLVIMENTO", "title" },
  { "Glauber Portella", "big" },
  { "glauberportella@gmail.com", "muted" },
  { "", "gap" },
  { "FEITO COM", "title" },
  { "Lua (LuaJIT) e o framework LÖVE 11.5", "text" },
  { "Efeitos sonoros e trilha gerados por código em tempo real", "text" },
  { "Fonte Pong-Game e arte em pixel art", "text" },
  { "Binários para macOS, Windows e Linux (AppImage)", "text" },
}

function credits.enter()
  if not version then
    local content = love.filesystem.read("VERSION")
    version = content and content:gsub("%s+$", "") or nil
  end
  local w, h = 260, 56
  buttons = ui.button_list({
    ui.button("VOLTAR", (config.WINDOW_W - w) / 2, 725, w, h, function() scene.switch("menu") end),
  })
end

function credits.keypressed(key)
  if key == "escape" then
    scene.switch("menu")
  else
    buttons:keypressed(key)
  end
end

function credits.mousemoved(x, y)
  buttons:mousemoved(x, y)
end

function credits.mousepressed(x, y, button)
  buttons:mousepressed(x, y, button)
end

local STYLES = {
  title = { size = 22, color = ui.colors.cyan, height = 34 },
  big = { size = 36, color = ui.colors.yellow, height = 46 },
  text = { size = 20, color = ui.colors.text, height = 30 },
  muted = { size = 20, color = ui.colors.muted, height = 30 },
  gap = { size = 10, color = ui.colors.text, height = 20 },
}

function credits.draw()
  backgrounds.draw_title(0.4)
  local px, pw = 280, 800
  ui.panel(px, 320, pw, 385)

  local y = 340
  for _, line in ipairs(LINES) do
    local style = STYLES[line[2]]
    ui.text(line[1], px, y, pw, style.size, style.color, "center")
    y = y + style.height
  end
  if version then
    ui.text("Versão " .. version, px, y + 6, pw, 16, ui.colors.muted, "center")
  end

  buttons:draw()
end

return credits
