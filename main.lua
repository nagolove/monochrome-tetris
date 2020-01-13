local lb = require "kons".new()
local inspect = require "inspect"
local fieldWidth, fieldHeight = 20, 40
local lg = love.graphics
local quadWidth = 10
local paused = false

function drawField(field)
  local w, h = lg.getDimensions()
  local startx, starty = (w - fieldWidth * quadWidth) / 2, (h - fieldHeight *
    quadWidth) / 2
  local gap = 1
  local cleanColor = {0, 0, 0}
  local filledColor = {1, 1, 1}
  local d = 1

  for i = 1, fieldHeight do
    for j = 1, fieldWidth do
      if field[i][j] then
        lg.setColor(filledColor)
      else
        lg.setColor(cleanColor)
      end
      lg.rectangle("fill", startx + (j - d)* quadWidth + gap, 
        starty + (i - d) * quadWidth + gap, quadWidth - gap, 
        quadWidth - gap)
    end
  end
  --print(startx, starty)
  lg.setColor{1, 1, 1, 1}
  lg.rectangle("line", startx - gap, starty - gap, fieldWidth * quadWidth +
    gap * 2, fieldHeight * quadWidth + gap * 2)
end

function updateField(field)
  local toRemove = {}
  for i = 1, #field do
    local free = true
    local arr = field[i]
    for j = 1, #arr do
      free = free and arr[j]
    end
    if free then
      toRemove[#toRemove + 1] = i
    end
  end
  for i = #toRemove, 1, -1 do
    table.remove(field, i)
  end
end

function createField()
  field = {}
  for j = 1, fieldHeight do
    local row = {}
    for i = 1, fieldWidth do
      row[#row + 1] = false
    end
    field[#field + 1] = row
  end
  return field
end

-- удаляет из поля полностью заполненные строки и смещает поле вниз.
function removeFullRows(field)
  local rowi = #field  
  repeat
    local full = true
    for i = 1, fieldWidth do
      full = full and field[rowi][i]
      if not full then break end
    end
    if full then 
      for i = rowi, 2, -1 do
        for j = 1, fieldWidth do
          field[i][j] = field[i - 1][j]
        end
      end
    end
    rowi = rowi - 1
  until rowi <= 1
end

local figure = {}
local field = {}
local figureWidth, figureHeight = 5, 5

local figures = {
    { 
        {false, true, true, true, true},
        {true, true, true, true, true},
        {true, true, true, true, true},
        {true, true, true, true, true},
        {true, true, true, false, true},
    },
    { 
        {true, true, true, true, true},
        {true, true, true, true, true},
        {true, true, true, true, true},
        {true, true, true, true, true},
        {true, true, true, true, true},
    },
    { 
        {true, true, true, true, true},
        {false, false, true, false, false},
        {false, false, true, false, false},
        {false, false, true, false, false},
        {true, true, true, true, true},
    },
    { 
        {false, false, false, false, false},
        {false, false, true, false, false},
        {false, false, true, false, false},
        {false, false, true, false, false},
        {false, true, true, true, false},
    },
    { 
        {false, false, false, false, false},
        {true, true, true, true, true},
        {false, false, false, false, false},
        {false, false, false, false, false},
        {false, false, false, false, false},
    },
    {
        {false, false, false, false, false},
        {false, true, true, true, false},
        {false, true, true, true, false},
        {false, true, true, true, false},
        {false, false, false, false, false},
    }
}

-- returns figure
function createFigure(field)
  local maxIdx = math.random(1, #figures)
  local figure = { 
    fig = copyFigure(figures[maxIdx]),
    x = 1,
    y = 1,
  }
  local fig = figure.fig
  -- ищу место, поместится фигура в поле?
  --[[
       [for i = 1, figureHeight do
       [    for j = 1, figureWidth do
       [        if field[i + figure.x - 1][j + figure.y - 1] and fig[i][j] then
       [            return nil
       [        end
       [    end
       [end
       ]]
  print("figure", inspect(figure))
  return figure
end

function drawFigure(figure)
  local w, h = lg.getDimensions()
  local startx, starty = (w - fieldWidth * quadWidth) / 2, (h - fieldHeight *
    quadWidth) / 2
  local gap = 1
  local cleanColor = {0, 0, 0}
  local filledColor = {1, 1, 1}
  --print(inspect(figure))
  local x, y = figure.x, figure.y
  local d = 2 -- почему правильно рисуется при d == 2??

  lg.setColor(filledColor)
  for i = 1, figureHeight do
    for j = 1, figureWidth do
      if figure.fig[i][j] then
        lg.rectangle("fill", startx + (j - d + x) * quadWidth + gap, 
          starty + (i - d + y) * quadWidth + gap, quadWidth - gap, 
          quadWidth - gap)
      end
    end
  end
end

function rotateFigireLeft(figure, field)
end

function rotateFigureRight(figure, field)
end

function copyFigure(src)
  --print("copyFigure")
  --print("src", inspect(src))
  --print(figureHeight, figureWidth)
  dst = {}
  for i = 1, figureHeight do
    local row = {}
    for j = 1, figureWidth do
      --print("src", src[i][j])
      row[#row + 1] = src[i][j]
    end
    --print("row", inspect(row))
    dst[#dst + 1] = row
  end
  --print("dst", inspect(dst))
  return dst
end

function setupFigure(figure)
  figure = nil
  for i = 1, figureHeight do
    local row = {}
    for j = 1, figureWidth do
      row[#row + 1] = false
    end
    figure[#figure + 1] = row
  end
end

function mergeFigure(figure, field)
  print("mergeFigure")
  local x, y = figure.x, figure.y
  local f = figure.fig
  local d = 1
  for i = 1, figureHeight do
    for j = 1, figureWidth do
      --field[x + i - 1][y + j - 1] = figure.fig[i][j]
      if f[i][j] then
        field[y + i - d][x + j - d] = f[i][j]
      end
    end
  end
end

-- return true if figure failed to ceil
function updateFigure(figure, field)
  local x = figure.x
  local y = figure.y + 1
  for i = 1, figureHeight do
    for j = 1, figureWidth do
      --if figure.fig[i][j] and field[x + i - 1][y + j - 1] then
      ----fieldthen
      --return
      --print("intersection")
      --end
      if figure.fig[i][j] and y + i - 1 == fieldHeight then
        print("Fail to ceil")
        --mergeFigure(figure, field)
        return true
      end
    end
  end
  for i = 1, figureHeight do
    for j = 1, figureWidth do
      if (field[x + i - 1][y + j - 1] and figure.fig[i][j]) then
        --fieldthen
        print("intersection")
        return true
      end
    end
  end
  figure.y = figure.y + 1
  return false
end

local timestamp

function love.load(arg)
  --print(inspect(arg))
  --if arg[1] == "-checkFigureOnField_test" then

  if arg[#arg] == "-debug" then require "mobdebug".start() end
  math.randomseed(os.time())
  field = createField()
  --print("field", inspect(field))

  field[25][1] = true
  field[26][1] = true
  field[27][1] = true
  field[28][1] = true
  field[29][1] = true

  timestamp = love.timer.getTime()
  figure = createFigure(field)
  print("start with", inspect(figure))
end

local failed = false

function love.update(dt)
  local time = love.timer.getTime()

  if paused then
    timestamp = time
    return
  end

  if love.keyboard.isDown("left") then
    moveFigureLeft(figure, field)
  elseif love.keyboard.isDown("right") then
    moveFigureRight(figure, field)
  end

  local pause = love.keyboard.isDown("up") and 0.01 or 0.3
  if timestamp + pause <= time then
    timestamp = time

    figure.y = figure.y + 1
    failed = false
    if not checkFigureOnField(figure, field) then
      figure.y = figure.y - 1
      mergeFigure(figure, field)
      figure = createFigure(field)
      failed = true
    end
  end
  
  removeFullRows(field)
end

-- возвращает true если фигуру можно поместить в данную позицию игрового поля.
function checkFigureOnField(figure, field)
  local x, y = figure.x, figure.y
  local f = figure.fig
  for i = 1, figureHeight do
    for j = 1, figureWidth do
      -- ограничение передвижения фигуры по ширине поля
      if f[i][j] and (j + x - 1) < 1 or (j + x - 1) > fieldWidth then
        return false
      end
      if f[i][j] and y + i - 2 == fieldHeight then
        print("Fail to ceil")
        --mergeFigure(figure, field)
        return false
      end
      if f[i][j] and field[i + y - 1][j + x - 1] then
        return false
      end
    end
  end
  return true
end

function moveFigureLeft(figure, field)
  figure.x = figure.x - 1
  if not checkFigureOnField(figure, field) then
    figure.x = figure.x + 1
  end
end

function moveFigureRight(figure, field)
  figure.x = figure.x + 1
  if not checkFigureOnField(figure, field) then
    figure.x = figure.x - 1
  end
end

function love.keypressed(_, key)
  if key == "escape" then
    love.event.quit()
  elseif key == "p" then
    paused = not paused
  end
end

function love.draw()
  if gameover then
    local w, h = lg.getDimensions()
    local startx, starty = (w - fieldWidth * quadWidth) / 2, (h - fieldHeight *
      quadWidth) / 2
    lg.print("Game over", startx, starty, 0, "center")
    lg.print("Press 'c' to new round", startx, 
      starty + lg.getFont():getHeight(), 0, "center")
  end
  if failed then
    lb:pushi("Failed")
  end
  drawField(field)
  drawFigure(figure)
  lb:draw()
end
