-- Trilha de tensao gerada por codigo, tocada enquanto um power-up esta ativo.
-- Ostinato grave em semitons (estilo "Tubarao"), tique-taque de relogio e um
-- par de notas dissonantes com tremolo. Acelera nos ultimos segundos.

local music = {}

local RATE = 22050
local STEP = 0.2         -- duracao de cada colcheia (s)
local STEPS = 16         -- passos no loop
local VOLUME = 0.22      -- volume baixo para nao cansar
local FADE_TIME = 0.6    -- fade de entrada e saida (s)
local RUSH_TIME = 10     -- nos ultimos segundos a musica acelera
local RUSH_PITCH = 0.25  -- aceleracao maxima (+25%)

local source = nil
local volume = 0
local fading_out = false

local function note(semitones_from_a4)
  return 440 * 2 ^ (semitones_from_a4 / 12)
end

local function triangle(phase)
  local p = phase % 1
  return p < 0.5 and (4 * p - 1) or (3 - 4 * p)
end

local function build()
  local length = STEPS * STEP
  local samples = math.floor(length * RATE)
  local data = love.sound.newSoundData(samples, RATE, 16, 1)

  local E2, F2 = note(-29), note(-28) -- baixo: mi e fa (meio tom de distancia)
  local A4, BB4 = note(0), note(1)    -- par dissonante agudo

  local mix = {}
  local peak = 0
  for i = 0, samples - 1 do
    local t = i / RATE
    local step = math.floor(t / STEP)
    local in_step = t - step * STEP

    -- baixo alternando mi/fa a cada colcheia, com ataque curto e decaimento
    local bass_freq = step % 2 == 0 and E2 or F2
    local bass = triangle(bass_freq * t) * math.exp(-in_step * 9)

    -- tique-taque a cada seminima: ruido curtinho, mais forte no tempo 1
    local tick = 0
    if step % 2 == 0 and in_step < 0.015 then
      local accent = step % 8 == 0 and 1 or 0.5
      tick = (love.math.random() * 2 - 1) * accent * (1 - in_step / 0.015)
    end

    -- notas agudas em meio tom com tremolo, crescendo ao longo do loop
    local swell = 0.3 + 0.7 * (t / length)
    local tremolo = 0.5 + 0.5 * math.sin(2 * math.pi * 7 * t)
    local pad = (math.sin(2 * math.pi * A4 * t) + math.sin(2 * math.pi * BB4 * t)) * 0.5 * tremolo * swell

    -- suaviza a emenda do loop
    local edge = math.min(1, t / 0.01, (length - t) / 0.01)

    local v = (bass * 0.6 + tick * 0.25 + pad * 0.18) * edge
    mix[i] = v
    peak = math.max(peak, math.abs(v))
  end

  local gain = peak > 0 and 0.9 / peak or 1
  for i = 0, samples - 1 do
    data:setSample(i, mix[i] * gain)
  end

  local s = love.audio.newSource(data)
  s:setLooping(true)
  return s
end

function music.start()
  source = source or build()
  fading_out = false
  if not source:isPlaying() then
    volume = 0
    source:setVolume(0)
    source:setPitch(1)
    source:seek(0)
    source:play()
  end
end

-- Para com fade out
function music.stop()
  fading_out = true
end

-- Para na hora (ex.: ao sair da partida)
function music.stop_now()
  fading_out = false
  volume = 0
  if source then
    source:stop()
  end
end

-- time_left: segundos restantes do power-up (nil quando nenhum ativo)
function music.update(dt, time_left)
  if not source or not source:isPlaying() then
    return
  end

  if fading_out then
    volume = volume - VOLUME * dt / FADE_TIME
    if volume <= 0 then
      music.stop_now()
      return
    end
  else
    volume = math.min(VOLUME, volume + VOLUME * dt / FADE_TIME)
  end
  source:setVolume(volume)

  if time_left and time_left < RUSH_TIME then
    source:setPitch(1 + RUSH_PITCH * (1 - time_left / RUSH_TIME))
  end
end

return music
