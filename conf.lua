local config = require("src.config")

function love.conf(t)
  t.identity = "pong2" -- pasta de save (recordes e preferencias)
  t.window.title = "Pong2"
  t.window.width = config.WINDOW_W
  t.window.height = config.WINDOW_H
end
