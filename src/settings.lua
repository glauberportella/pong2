-- Preferencias lembradas entre execucoes: fundo, ultimos nomes e pontos

local save = require("src.save")

local FILE = "settings.lua"

local settings = {
  background = 1,
  names = { "Jogador 1", "Jogador 2" },
  target = 10,
}

function settings.load()
  local data = save.read(FILE)
  if not data then
    return
  end
  if type(data.background) == "number" then settings.background = data.background end
  if type(data.target) == "number" then settings.target = data.target end
  if type(data.names) == "table" and type(data.names[1]) == "string" and type(data.names[2]) == "string" then
    settings.names = { data.names[1], data.names[2] }
  end
end

function settings.save()
  save.write(FILE, {
    background = settings.background,
    names = settings.names,
    target = settings.target,
  })
end

return settings
