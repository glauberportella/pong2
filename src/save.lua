-- Salva e carrega tabelas Lua na pasta de save do LOVE

local save = {}

local function serialize(value, indent)
  indent = indent or ""
  local t = type(value)
  if t == "string" then
    return string.format("%q", value)
  elseif t == "number" or t == "boolean" then
    return tostring(value)
  elseif t == "table" then
    local inner = indent .. "  "
    local parts = {}
    -- parte de array primeiro, para manter a ordem
    for _, v in ipairs(value) do
      table.insert(parts, inner .. serialize(v, inner))
    end
    for k, v in pairs(value) do
      local is_array_key = type(k) == "number" and k >= 1 and k <= #value and k % 1 == 0
      if not is_array_key then
        table.insert(parts, inner .. "[" .. serialize(k) .. "] = " .. serialize(v, inner))
      end
    end
    if #parts == 0 then
      return "{}"
    end
    return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
  end
  error("tipo nao suportado: " .. t)
end

function save.write(file, data)
  return love.filesystem.write(file, "return " .. serialize(data) .. "\n")
end

-- Retorna a tabela salva ou nil se o arquivo nao existe ou esta corrompido
function save.read(file)
  if not love.filesystem.getInfo(file) then
    return nil
  end
  local ok, chunk = pcall(love.filesystem.load, file)
  if not ok or not chunk then
    return nil
  end
  -- executa sem acesso a nenhuma funcao global
  setfenv(chunk, {})
  local ok_run, data = pcall(chunk)
  if ok_run and type(data) == "table" then
    return data
  end
  return nil
end

return save
