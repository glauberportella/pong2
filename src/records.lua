-- Recordes: guarda todas as partidas terminadas e calcula confrontos e ranking

local save = require("src.save")

local FILE = "records.lua"
local MAX_MATCHES = 1000

local records = {}

local matches = {} -- { date, p1, p2, s1, s2, target }, mais antiga primeiro

-- Nomes iguais ignorando maiusculas e espacos nas pontas
function records.key(name)
  return (name:gsub("^%s+", ""):gsub("%s+$", ""):lower())
end

function records.load()
  local data = save.read(FILE)
  matches = {}
  if data and type(data.matches) == "table" then
    for _, m in ipairs(data.matches) do
      if type(m.p1) == "string" and type(m.p2) == "string" and type(m.s1) == "number" and type(m.s2) == "number" then
        table.insert(matches, m)
      end
    end
  end
end

function records.add(p1, p2, s1, s2, target)
  table.insert(matches, {
    date = os.date("%d/%m/%Y %H:%M"),
    p1 = p1, p2 = p2, s1 = s1, s2 = s2, target = target,
  })
  while #matches > MAX_MATCHES do
    table.remove(matches, 1)
  end
  save.write(FILE, { matches = matches })
end

local function winner_of(m)
  return m.s1 > m.s2 and m.p1 or m.p2
end

-- Confronto entre dois jogadores. Retorna:
-- { wins = {a, b}, total, best = partida de maior diferenca, history = ultimas partidas (mais recente primeiro) }
function records.head_to_head(a, b, history_size)
  local ka, kb = records.key(a), records.key(b)
  local result = { wins = { 0, 0 }, total = 0, best = nil, history = {} }
  for i = #matches, 1, -1 do
    local m = matches[i]
    local k1, k2 = records.key(m.p1), records.key(m.p2)
    if (k1 == ka and k2 == kb) or (k1 == kb and k2 == ka) then
      result.total = result.total + 1
      if records.key(winner_of(m)) == ka then
        result.wins[1] = result.wins[1] + 1
      else
        result.wins[2] = result.wins[2] + 1
      end
      if not result.best or math.abs(m.s1 - m.s2) > math.abs(result.best.s1 - result.best.s2) then
        result.best = m
      end
      if #result.history < (history_size or 10) then
        table.insert(result.history, m)
      end
    end
  end
  return result
end

-- Ranking geral por vitorias: { name, wins, played }
function records.ranking(limit)
  local by_key = {}
  local list = {}
  local function entry(name)
    local k = records.key(name)
    if not by_key[k] then
      by_key[k] = { name = name, wins = 0, played = 0 }
      table.insert(list, by_key[k])
    end
    return by_key[k]
  end
  for _, m in ipairs(matches) do
    local e1, e2 = entry(m.p1), entry(m.p2)
    e1.played = e1.played + 1
    e2.played = e2.played + 1
    entry(winner_of(m)).wins = entry(winner_of(m)).wins + 1
  end
  table.sort(list, function(x, y)
    if x.wins ~= y.wins then return x.wins > y.wins end
    return x.played < y.played
  end)
  local top = {}
  for i = 1, math.min(limit or #list, #list) do
    top[i] = list[i]
  end
  return top
end

-- Confrontos mais recentes: { a, b, wins = {a, b}, total }
function records.rivalries(limit)
  local seen = {}
  local list = {}
  for i = #matches, 1, -1 do
    local m = matches[i]
    local k1, k2 = records.key(m.p1), records.key(m.p2)
    local pair = k1 < k2 and (k1 .. "|" .. k2) or (k2 .. "|" .. k1)
    if not seen[pair] then
      seen[pair] = true
      local h = records.head_to_head(m.p1, m.p2, 0)
      table.insert(list, { a = m.p1, b = m.p2, wins = h.wins, total = h.total })
      if #list >= (limit or 10) then
        break
      end
    end
  end
  return list
end

return records
