-- Nova partida: nomes dos jogadores e pontos para vencer

local utf8 = require("utf8")
local config = require("src.config")
local ui = require("src.ui")
local scene = require("src.scene")
local settings = require("src.settings")
local records = require("src.records")
local backgrounds = require("src.backgrounds")

local setup = {}

local PANEL = { x = 380, y = 320, w = 600, h = 460 }
local FIELD_X, FIELD_W = 430, 500

local names = { "", "" }
local target_index = 2
local focus = 1
local error_message = nil

-- Itens focaveis, na ordem de navegacao
local items = {
  { kind = "name", player = 1, label = "JOGADOR 1   (W / S)", y = 380 },
  { kind = "name", player = 2, label = "JOGADOR 2   (O / L)", y = 470 },
  { kind = "target", label = "PONTOS PARA VENCER", y = 560 },
  { kind = "button", label = "JOGAR", x = FIELD_X, w = 240, y = 700 },
  { kind = "button", label = "VOLTAR", x = FIELD_X + 260, w = 240, y = 700 },
}

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function field_rect(item)
  if item.kind == "button" then
    return { x = item.x, y = item.y, w = item.w, h = 56 }
  end
  return { x = FIELD_X, y = item.y + 26, w = FIELD_W, h = 48 }
end

local function target()
  return config.TARGET_OPTIONS[target_index]
end

local function start()
  local n1, n2 = trim(names[1]), trim(names[2])
  if n1 == "" or n2 == "" then
    error_message = "Digite o nome dos dois jogadores"
    return
  end
  if records.key(n1) == records.key(n2) then
    error_message = "Os nomes precisam ser diferentes"
    return
  end
  settings.names = { n1, n2 }
  settings.target = target()
  settings.save()
  scene.switch("play", { names = { n1, n2 }, target = target() })
end

local function back()
  scene.switch("menu")
end

local function activate(item)
  if item.label == "JOGAR" then
    start()
  elseif item.label == "VOLTAR" then
    back()
  else
    focus = focus % #items + 1
  end
end

local function change_target(delta)
  target_index = (target_index - 1 + delta) % #config.TARGET_OPTIONS + 1
end

function setup.enter()
  names = { settings.names[1], settings.names[2] }
  target_index = 2
  for i, t in ipairs(config.TARGET_OPTIONS) do
    if t == settings.target then
      target_index = i
    end
  end
  focus = 1
  error_message = nil
end

function setup.textinput(text)
  local item = items[focus]
  if item.kind ~= "name" then
    return
  end
  local current = names[item.player]
  if utf8.len(current) + utf8.len(text) <= config.NAME_MAX_LENGTH then
    names[item.player] = current .. text
    error_message = nil
  end
end

function setup.keypressed(key)
  local item = items[focus]
  if key == "escape" then
    back()
  elseif key == "tab" then
    local shift = love.keyboard.isDown("lshift", "rshift")
    focus = (focus - 1 + (shift and -1 or 1)) % #items + 1
  elseif key == "up" then
    focus = (focus - 2) % #items + 1
  elseif key == "down" then
    focus = focus % #items + 1
  elseif key == "backspace" and item.kind == "name" then
    local s = names[item.player]
    local last = utf8.offset(s, -1)
    if last then
      names[item.player] = s:sub(1, last - 1)
    end
  elseif (key == "left" or key == "right") and item.kind == "target" then
    change_target(key == "left" and -1 or 1)
  elseif (key == "left" or key == "right") and item.kind == "button" then
    focus = item.label == "JOGAR" and focus + 1 or focus - 1
  elseif key == "return" or key == "kpenter" then
    activate(item)
  end
end

function setup.mousemoved(x, y)
  for i, item in ipairs(items) do
    if item.kind == "button" and ui.hit(field_rect(item), x, y) then
      focus = i
    end
  end
end

function setup.mousepressed(x, y, button)
  if button ~= 1 then
    return
  end
  for i, item in ipairs(items) do
    local r = field_rect(item)
    if ui.hit(r, x, y) then
      focus = i
      if item.kind == "button" then
        activate(item)
      elseif item.kind == "target" then
        change_target(x < r.x + r.w / 2 and -1 or 1)
      end
      return
    end
  end
end

local function draw_field(item, focused)
  local r = field_rect(item)
  ui.text(item.label, r.x, item.y, r.w, 20, focused and ui.colors.yellow or ui.colors.cyan)

  love.graphics.setColor(0, 0, 0, 0.6)
  love.graphics.rectangle("fill", r.x, r.y, r.w, r.h, 8, 8)
  ui.set_color(focused and ui.colors.pink or ui.colors.cyan, focused and 1 or 0.6)
  love.graphics.setLineWidth(focused and 3 or 2)
  love.graphics.rectangle("line", r.x, r.y, r.w, r.h, 8, 8)
  love.graphics.setLineWidth(1)

  local font = ui.font(30)
  local ty = r.y + (r.h - font:getHeight()) / 2
  if item.kind == "name" then
    local text = names[item.player]
    -- cursor piscando no campo com foco
    if focused and math.floor(love.timer.getTime() * 2) % 2 == 0 then
      text = text .. "_"
    end
    ui.text(text, r.x + 14, ty, r.w - 28, 30)
  else
    ui.text("<", r.x + 14, ty, 40, 30, ui.colors.cyan)
    ui.text(string.format("%d", target()), r.x, ty, r.w, 30, ui.colors.text, "center")
    ui.text(">", r.x + r.w - 54, ty, 40, 30, ui.colors.cyan, "right")
  end
end

-- Linha com o historico do confronto, se esses dois ja jogaram
local function draw_rivalry()
  local n1, n2 = trim(names[1]), trim(names[2])
  if n1 == "" or n2 == "" or records.key(n1) == records.key(n2) then
    return
  end
  local h = records.head_to_head(n1, n2, 0)
  local text
  if h.total == 0 then
    text = "Primeiro confronto entre os dois"
  else
    text = string.format("Confronto: %s %d x %d %s", n1, h.wins[1], h.wins[2], n2)
  end
  ui.text(text, PANEL.x, 655, PANEL.w, 18, ui.colors.muted, "center")
end

function setup.draw()
  backgrounds.draw_title(0.35)
  ui.panel(PANEL.x, PANEL.y, PANEL.w, PANEL.h)
  ui.text("NOVA PARTIDA", PANEL.x, PANEL.y + 14, PANEL.w, 30, ui.colors.yellow, "center")

  for i, item in ipairs(items) do
    if item.kind == "button" then
      ui.draw_button(ui.button(item.label, item.x, item.y, item.w, 56), i == focus)
    else
      draw_field(item, i == focus)
    end
  end

  if error_message then
    ui.text(error_message, PANEL.x, 655, PANEL.w, 18, ui.colors.red, "center")
  else
    draw_rivalry()
  end

  ui.text_center("TAB / SETAS NAVEGAM   ENTER CONFIRMA   ESC VOLTA", 785, 14, ui.colors.muted)
end

return setup
