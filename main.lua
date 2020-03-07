local isAndroid = love.system.getOS() == "Android"
--local isAndroid = true
print("isAndroid", isAndroid)

local lb = require "kons".new()
local inspect = require "inspect"
local fieldWidth, fieldHeight = 20, 50
local lg = love.graphics
local quadWidth = 10
local paused = true
local scores = 0
local field = {}
local figure = {}
local figureWidth, figureHeight = 4, 4
local sndClick = love.audio.newSource("sfx/click.wav", "static")

local figures = {
  --[[
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
  }, --]]
  { 
    {false, false, false, false},
    {false, false, false, false},
    {true, true, true, true},
    {false, false, false, false},
  },
  { 
    {false, false, false, false},
    {true, false, false, false},
    {true, true, true, false},
    {false, false, false, false},
  },
  { 
    {false, false, false, false},
    {false, false, false, true},
    {false, true, true, true},
    {false, false, false, false},
  },
  { 
    {false, false, false, false},
    {false, true, true, false},
    {false, true, true, false},
    {false, false, false, false},
  },
  { 
    {false, false, false, false},
    {false, true, true, false},
    {true, true, false, false},
    {false, false, false, false},
  },
  { 
    {false, false, false, false},
    {false, true, true, false},
    {false, false, true, true},
    {false, false, false, false},
  },
  { 
    {false, false, false, false},
    {false, false, true, false},
    {false, true, true, true},
    {false, false, false, false},
  },
}

function drawNextFigure()
    local nextfig = copyFigureInternal(figures[nextFigure])
    local w, h = lg.getDimensions()
    local startx, starty = (w - fieldWidth * quadWidth) / 2, (h - fieldHeight *
        quadWidth) / 2
    --print("drawNextFigure", startx, starty)
    local gap = 1
    local cleanColor = {0, 0, 0}
    local filledColor = {1, 1, 1}
    --print(inspect(figure))
    local x, y = (startx + fieldWidth * quadWidth) - figureWidth * quadWidth, 2
    print("x, y", x, y)
    local d = 2 -- почему правильно рисуется при d == 2??

    lg.setColor(filledColor)
    for i = 1, figureHeight do
        for j = 1, figureWidth do
            if nextfig[i][j] then
                lg.rectangle("fill", x + (j - 1) * quadWidth + gap, 
                    y + (i - 1)* quadWidth + gap, 
                    quadWidth - gap, quadWidth - gap)
            end
        end
    end
    lg.setColor{1, 1, 1}
    lg.rectangle("line", x, y, figureWidth * quadWidth, figureHeight * quadWidth)
end

function drawField(field)
  local w, h = lg.getDimensions()
  local startx, starty = (w - fieldWidth * quadWidth) / 2, (h - fieldHeight *
    quadWidth) / 2
  local gap = 1
  local cleanColor = {0, 0, 0}
  local filledColor = {1, 1, 1}
  local d = 1

  for i = 1, fieldHeight do
    lg.line(startx, starty + i * quadWidth, startx + fieldWidth * quadWidth, starty + i * quadWidth)
  end
  for i = 1, fieldWidth do
    lg.line(startx + i * quadWidth, starty, startx + i * quadWidth, starty + fieldHeight * quadWidth)
  end

  for i = 1, fieldHeight do
    for j = 1, fieldWidth do
      if field[i][j] then
        lg.setColor(filledColor)
      else
        lg.setColor(cleanColor)
      end
      lg.rectangle("fill", startx + (j - d) * quadWidth + gap, 
        starty + (i - d) * quadWidth + gap, quadWidth - gap, 
        quadWidth - gap)
    end
  end
  
  lg.setColor{0.2, 0.8, 0.1}
  lg.rectangle("fill", startx, starty, quadWidth, quadWidth)
  --print(startx, starty)
  lg.setColor{1, 1, 1, 1}
  lg.rectangle("line", startx - gap, starty - gap, fieldWidth * quadWidth +
    gap * 2, fieldHeight * quadWidth + gap * 2)
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
  lg.setColor{0.7, 0.1, 0.1}
  lg.rectangle("line", startx + (figure.x - 1) * quadWidth, starty + (figure.y - 1) * quadWidth, figureWidth * quadWidth, figureHeight * quadWidth)
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
      scores = scores + fieldWidth
      if scores > highscores then
        highscores = scores
      end
    end
    rowi = rowi - 1
  until rowi <= 1
end

-- returns figure
function createFigure(field)
  local figure = { 
    fig = copyFigureInternal(figures[nextFigure]),
    x = 1,
    y = 1,
  }
  nextFigure = math.random(1, #figures)
  return figure
end

function rotateFigireLeft(figure)
  local new = { x = figure.x, y = figure.y, fig = {}}
  local f = new.fig
  for i = 1, figureHeight do
    local row = {}
    for j = 1, figureWidth do
      row[#row + 1] = false
    end
    f[#f + 1] = row
  end
  if checkFigureOnField(new, field) then
--    print("new", inspect(new))
--    print("figure", inspect(figure))
    for i = 1, figureHeight do
      for j = 1, figureWidth do
        f[figureHeight - j + 1][i] = figure.fig[i][j]
      end
    end
    figure.fig = f
  else
    print("no")
  end
end

-- некорректно работает поворот вправо
function rotateFigureRight(figure)
  local new = {}
  for i = 1, figureHeight do
    local row = {}
    for j = 1, figureWidth do
      row[#row + 1] = false
    end
    new[#new + 1] = row
  end
  print("new", inspect(new))
  print("figure", inspect(figure))
  for i = 1, figureHeight do
    for j = 1, figureWidth do
      new[j][figureHeight - i + 1] = figure.fig[i][j]
    end
  end
  figure.fig = new
end

function copyFigureInternal(src)
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
local latestSideMove

function love.load(arg)
  --print(inspect(arg))
  --if arg[1] == "-checkFigureOnField_test" then

  if arg[#arg] == "-debug" then require "mobdebug".start() end
  math.randomseed(os.time())
  field = createField()
  --print("field", inspect(field))

--  field[25][1] = true
--  field[26][1] = true
--  field[27][1] = true
--  field[28][1] = true
--  field[29][1] = true

  timestamp = love.timer.getTime()  
  nextFigure = math.random(1, #figures)
  figure = createFigure(field)
  print("start with", inspect(figure))
  latestSideMove = love.timer.getTime()

  local cnt, size = love.filesystem.read("highscores.txt")
  --if size ~= 0 then highscores = tonumber(cnt) else highscores = 0 end
  local value = tonumber(cnt)
  highscores = value and value or 0
  print("cnt", cnt, "size", size)
  love.keyboard.setKeyRepeat(true)
end

local failed = false

function love.update(dt)
    lb:update(dt)
    local time = love.timer.getTime()

    if paused then
        timestamp = time
        return
    end

    local sideMovePause = 0.03
    --  -- еще не удобное управление
    --  if not love.keyboard.isDown("lshift") and love.keyboard.isDown("left") then
    --    if latestSideMove + sideMovePause < time then
    --      moveFigureLeft(figure, field)
    --      latestSideMove = time
    --    end
    --  elseif not love.keyboard.isDown("lshift") and love.keyboard.isDown("right") then
    --    if latestSideMove + sideMovePause < time then
    --      moveFigureRight(figure, field)
    --      latestSideMove = time
    --    end
    --  end

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
      if f[i][j] and ((j + x - 1) < 1) or ((j + x - 1) > fieldWidth) then
--        return false
      end
      if f[i][j] and y + i - 2 == fieldHeight then
        print("Fail to ceil")
        --mergeFigure(figure, field)
        return false
      end
      -- collision figure with field
      if f[i][j] and field[i + y - 1][j + x - 1] then
        return false
      end
    end
  end
  for i = 1, figureHeight do
    for j = 1, figureWidth do
      -- ограничение передвижения фигуры по ширине поля
      if f[i][j] and ((j + x - 1) < 1) or ((j + x - 2) > fieldWidth) then
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
    print("not right")
    figure.x = figure.x - 1
  end
end

function love.keypressed(_, key, isrepeat)
    if key == "escape" then
        love.event.quit()
    elseif key == "p" then
        paused = not paused
    elseif love.keyboard.isDown("lshift") and key == "left" then
        rotateFigireLeft(figure)
    elseif love.keyboard.isDown("lshift") and key == "right" then
        rotateFigureRight(figure)
        -- еще не удобное управление
    elseif not love.keyboard.isDown("lshift") and key == "left" then
        moveFigureLeft(figure, field)
    elseif not love.keyboard.isDown("lshift") and key == "right" then
        moveFigureRight(figure, field)
    elseif key == "r" then
        isAndroid = not isAndroid
    end
    lb:push(0.5, "key %s", tostring(key))
end

function drawGameOver(startx, starty)
    lg.printf("Game over", startx, starty, 0, "center")
    lg.printf("Press 'c' to new round", startx, 
        starty + lg.getFont():getHeight(), 0, "center")
end

function rotatePortrait()
    local w, h = lg.getDimensions()
    lg.translate(w / 2, h / 2)
    lg.rotate(math.pi * 3 / 2)
    lg.translate(-w / 2, -h / 2)
end

function drawScoresAndPos(startx, starty)
    local y = 0
    lg.print(string.format("High scores: %d", highscores), startx, y, 0)
    y = y + lg.getFont():getHeight()
    lg.print(string.format("Scores: %d", scores), startx, y, 0)
    y = y + lg.getFont():getHeight()
    lg.print(string.format("x, y %d %d", figure.x, figure.y), startx, y, 0)
    y = y + lg.getFont():getHeight()
end

local drawList = {}

function love.touchmoved(id, x, y, dx, dy, pressure)
    table.insert(drawList, function()
        lg.setColor{0, 0.2, 0}
        lg.circle("fill", x, y, 10)
    end)
end

function love.touchpressed(id, x, y, _, _, pressure)
    sndClick:play()
    if paused then
        paused = false
    end
end

function love.draw()
    --lg.translate(0.5, 0.5)
    if isAndroid then
        --rotatePortrait()
    end

    local w, h = lg.getDimensions()
    local fieldWidthPx = fieldWidth * quadWidth
    local startx, starty = (w - fieldWidthPx) / 2, (h - fieldHeight *
        quadWidth) / 2
    if gameover then
        drawGameOver(startx, starty)
    end
    lg.setColor{1, 1, 1}
    drawScoresAndPos(startx, starty)
    drawField(field)
    drawFigure(figure)
    drawNextFigure()
    if failed then
        lb:pushi("Failed")
    end
    lb:draw()

    for _, v in pairs(drawList) do
        v()
    end

    lg.push()
    lg.scale(0.5, 0.5)
    lg.setColor{0, 1, 0}
    lg.circle("fill", 0, 0, 10)
    lg.circle("fill", w / 2, 0, 10)
    lg.circle("fill", w, h, 100)
    lg.circle("fill", w / 2, h / 2, 10)
    lg.pop()

    drawList = {}
end

function love.quit()
  love.filesystem.write("highscores.txt", tostring(highscores))
end
