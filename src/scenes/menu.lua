-- Tela inicial: escolha do fundo e botoes Iniciar, Recordes, Creditos e Sair

local ui = require("src.ui")
local scene = require("src.scene")
local settings = require("src.settings")
local backgrounds = require("src.backgrounds")

local menu = {}

-- Previa do fundo escolhido (lado esquerdo)
local PREVIEW = { x = 250, y = 400, w = 340, h = 200 }
local ARROW_W = 44
local arrow_left = { x = PREVIEW.x - ARROW_W - 12, y = PREVIEW.y, w = ARROW_W, h = PREVIEW.h }
local arrow_right = { x = PREVIEW.x + PREVIEW.w + 12, y = PREVIEW.y, w = ARROW_W, h = PREVIEW.h }

local buttons = nil

local function change_background(delta)
  local n = backgrounds.count()
  settings.background = (backgrounds.clamp(settings.background) - 1 + delta) % n + 1
  settings.save()
end

function menu.enter()
  settings.background = backgrounds.clamp(settings.background)
  local x, w, h, gap = 800, 360, 64, 18
  local y = 380
  buttons = ui.button_list({
    ui.button("INICIAR", x, y, w, h, function() scene.switch("setup") end),
    ui.button("RECORDES", x, y + (h + gap), w, h, function() scene.switch("records") end),
    ui.button("CRÉDITOS", x, y + 2 * (h + gap), w, h, function() scene.switch("credits") end),
    ui.button("SAIR", x, y + 3 * (h + gap), w, h, function() love.event.quit() end),
  })
end

function menu.keypressed(key)
  if key == "left" then
    change_background(-1)
  elseif key == "right" then
    change_background(1)
  elseif key == "escape" then
    love.event.quit()
  else
    buttons:keypressed(key)
  end
end

function menu.mousemoved(x, y)
  buttons:mousemoved(x, y)
end

function menu.mousepressed(x, y, button)
  if button == 1 and ui.hit(arrow_left, x, y) then
    change_background(-1)
  elseif button == 1 and ui.hit(arrow_right, x, y) then
    change_background(1)
  else
    buttons:mousepressed(x, y, button)
  end
end

local function draw_arrow(area, left)
  local cx = area.x + area.w / 2
  local cy = area.y + area.h / 2
  ui.set_color(ui.colors.cyan)
  if left then
    love.graphics.polygon("fill", cx + 10, cy - 18, cx + 10, cy + 18, cx - 12, cy)
  else
    love.graphics.polygon("fill", cx - 10, cy - 18, cx - 10, cy + 18, cx + 12, cy)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

function menu.draw()
  backgrounds.draw_title()

  -- painel do fundo
  ui.panel(arrow_left.x - 16, 340, (arrow_right.x + arrow_right.w + 16) - (arrow_left.x - 16), 340)
  ui.text("FUNDO DA QUADRA", PREVIEW.x, 355, PREVIEW.w, 24, ui.colors.yellow, "center")
  backgrounds.draw(settings.background, 0, PREVIEW.x, PREVIEW.y, PREVIEW.w, PREVIEW.h)
  -- rede e raquetes na previa, para dar ideia de como fica
  love.graphics.setColor(1, 1, 1, 0.8)
  love.graphics.rectangle("fill", PREVIEW.x + PREVIEW.w / 2 - 1, PREVIEW.y, 2, PREVIEW.h)
  love.graphics.rectangle("fill", PREVIEW.x + 12, PREVIEW.y + 70, 5, 40)
  love.graphics.rectangle("fill", PREVIEW.x + PREVIEW.w - 17, PREVIEW.y + 90, 5, 40)
  ui.set_color(ui.colors.cyan)
  love.graphics.rectangle("line", PREVIEW.x, PREVIEW.y, PREVIEW.w, PREVIEW.h)
  draw_arrow(arrow_left, true)
  draw_arrow(arrow_right, false)
  ui.text(backgrounds.name(settings.background), PREVIEW.x, PREVIEW.y + PREVIEW.h + 14, PREVIEW.w, 32, ui.colors.text, "center")
  ui.text("SETAS ESQUERDA / DIREITA TROCAM O FUNDO", PREVIEW.x - 60, PREVIEW.y + PREVIEW.h + 56, PREVIEW.w + 120, 14, ui.colors.muted, "center")

  buttons:draw()

  ui.text_center("CIMA / BAIXO ESCOLHE   ENTER CONFIRMA   ESC SAI", 765, 16, ui.colors.muted)
end

return menu
