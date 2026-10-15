-- Elementos de interface: fontes, paineis, textos e botoes

local config = require("src.config")

local ui = {}

ui.colors = {
  text = { 1, 1, 1 },
  muted = { 0.75, 0.75, 0.85 },
  cyan = { 0.45, 0.9, 1 },
  pink = { 1, 0.35, 0.75 },
  yellow = { 1, 0.85, 0.35 },
  red = { 1, 0.4, 0.4 },
  panel = { 0.06, 0.03, 0.12, 0.75 },
}

local fonts = {}

function ui.font(size)
  if not fonts[size] then
    fonts[size] = love.graphics.newFont(config.FONT_PATH, size)
  end
  return fonts[size]
end

function ui.set_color(color, alpha)
  love.graphics.setColor(color[1], color[2], color[3], alpha or color[4] or 1)
end

function ui.panel(x, y, w, h)
  ui.set_color(ui.colors.panel)
  love.graphics.rectangle("fill", x, y, w, h, 12, 12)
  ui.set_color(ui.colors.pink, 0.6)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", x, y, w, h, 12, 12)
  love.graphics.setLineWidth(1)
  love.graphics.setColor(1, 1, 1, 1)
end

-- Texto alinhado dentro de uma faixa [x, x + w] ("left", "center" ou "right")
function ui.text(text, x, y, w, size, color, align)
  love.graphics.setFont(ui.font(size))
  ui.set_color(color or ui.colors.text)
  love.graphics.printf(text, x, y, w, align or "left")
  love.graphics.setColor(1, 1, 1, 1)
end

function ui.text_center(text, y, size, color)
  ui.text(text, 0, y, config.WINDOW_W, size, color, "center")
end

-- Botao: { label, x, y, w, h, action }
function ui.button(label, x, y, w, h, action)
  return { label = label, x = x, y = y, w = w, h = h, action = action }
end

function ui.hit(b, mx, my)
  return mx >= b.x and mx <= b.x + b.w and my >= b.y and my <= b.y + b.h
end

function ui.draw_button(b, focused)
  if focused then
    ui.set_color(ui.colors.pink, 0.9)
  else
    ui.set_color(ui.colors.panel)
  end
  love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 10, 10)
  ui.set_color(focused and ui.colors.yellow or ui.colors.cyan)
  love.graphics.setLineWidth(focused and 3 or 2)
  love.graphics.rectangle("line", b.x, b.y, b.w, b.h, 10, 10)
  love.graphics.setLineWidth(1)

  local size = math.floor(b.h * 0.5)
  local font = ui.font(size)
  ui.text(b.label, b.x, b.y + (b.h - font:getHeight()) / 2, b.w, size, ui.colors.text, "center")
end

-- Lista de botoes navegavel por teclado (cima/baixo, ou esquerda/direita) e mouse
function ui.button_list(buttons, horizontal)
  local list = { buttons = buttons, focus = 1, horizontal = horizontal }

  function list:draw(active)
    for i, b in ipairs(self.buttons) do
      ui.draw_button(b, active ~= false and i == self.focus)
    end
  end

  -- Retorna true se a tecla foi tratada
  function list:keypressed(key)
    local prev = self.horizontal and "left" or "up"
    local next = self.horizontal and "right" or "down"
    if key == prev then
      self.focus = (self.focus - 2) % #self.buttons + 1
      return true
    elseif key == next then
      self.focus = self.focus % #self.buttons + 1
      return true
    elseif key == "return" or key == "kpenter" or key == "space" then
      self.buttons[self.focus].action()
      return true
    end
    return false
  end

  function list:mousemoved(x, y)
    for i, b in ipairs(self.buttons) do
      if ui.hit(b, x, y) then
        self.focus = i
        return true
      end
    end
    return false
  end

  function list:mousepressed(x, y, button)
    if button ~= 1 then
      return false
    end
    for i, b in ipairs(self.buttons) do
      if ui.hit(b, x, y) then
        self.focus = i
        b.action()
        return true
      end
    end
    return false
  end

  return list
end

return ui
