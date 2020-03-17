local isAndroid = love.system.getOS() == "Android"
--local isAndroid = true
print("isAndroid", isAndroid)

local lb = require "kons".new()
local inspect = require "inspect"
require "touchgui.layout"
local fieldWidth, fieldHeight = 20, 50
local lg = love.graphics
local quadWidth = 10
local paused = true
local scores = 0
local field = {}
local figure = {}
local figureWidth, figureHeight = 4, 4

local sndClick = love.audio.newSource("sfx/click.wav", "static")
local sndDone = love.audio.newSource("sfx/done.wav", "static")

--local imgRArrow = lg.newImage("gfx/rarrow.png")
--local quadRAArrow = lg.newQuad(0, 0, imgRArrow:getWidth(), imgRArrow:getHeight(), imgRArrow:getWidth(), imgRArrow:getHeight())
--local imgLArrow = lg.newImage("gfx/larrow.png")
--local quadLArrow = lg.newQuad(0, 0, imgLArrow:getWidth(), imgLArrow:getHeight(), imgLArrow:getWidth(), imgLArrow:getHeight())
--local imgLRotate = lg.newImage("gfx/lrotate.png")
--local quadLRotate = lg.newQuad(0, 0, imgLRotate:getWidth(), imgLRotate:getHeight(), imgLRotate:getWidth(), imgLRotate:getHeight()) 
--local imgRRotate = lg.newImage("gfx/rrotate.png")
--local quadRRotate = lg.newQuad(0, 0, imgRRotate:getWidth(), imgRRotate:getHeight(), imgRRotate:getWidth(), imgRRotate:getHeight()) 

local pause = 0.1
local drawList = {}
local timestamp

local layout

local figures = {
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
    --local startx, starty = 0, 0
    --starty = 0
    local gap = 1
    local cleanColor = {0, 0, 0}
    local filledColor = {1, 1, 1}
    --print(inspect(figure))
    local x, y = (startx + fieldWidth * quadWidth) - figureWidth * quadWidth, 2
    --print("x, y", x, y)
    local d = 2 -- почему правильно рисуется при d == 2??

    lg.push()
    local x0 = (w - figureWidth * quadWidth) / 2
    x = x0
    lg.translate(0, -figureWidth * quadWidth * 3)

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

    lg.pop()
end

function drawField(field)
    lg.setColor{1, 1, 1}
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

    --lg.setColor{0.2, 0.8, 0.1}
    --lg.rectangle("fill", startx, starty, quadWidth, quadWidth)
    --print(startx, starty)
    lg.setColor{1, 1, 1, 1}
    lg.rectangle("line", startx - gap, starty - gap, fieldWidth * quadWidth +
        gap * 2, fieldHeight * quadWidth + gap * 2)
    bottomFieldY = starty - gap + fieldHeight * quadWidth + gap * 2
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
            print(type(scores), type(highscores))
            if scores > highscores then
                highscores = scores
                writeHighScores()
            end
        end
        rowi = rowi - 1
    until rowi <= 1
end

-- returns figure
function createFigure(field)
  local figure = { 
    fig = copyFigureInternal(figures[nextFigure]),
    x = (fieldWidth - figureWidth) / 2 + 1,
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
    sndDone:play()
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

local failed = false

local previousTouches = {}

function checkPreviosTouch(x, y)
    for k, v in pairs(previousTouches) do
        if v[1] == x and v[2] == y then
            return true
        end
    end
    return false
end

function inRect(x, y, rect)
    return x > rect.x and x < rect.x + rect.w 
        and y > rect.y and y < rect.y + rect.h
end

function touchPress(layoutArea)
    if layoutArea.timestamp then
        local now = love.timer.getTime()
        local diff = now - layoutArea.timestamp
        if diff >= 0.15 then
            layoutArea.timestamp = now
            layoutArea.func()
        end
    else
        layoutArea.timestamp = love.timer.getTime()
        layoutArea.func()
    end
end
--[[
-- Если палец касается экрана в новом месте, где раньше не касался, то
-- генерировать событие. Если палец остается на том же месте, прижатый к
-- экрану, но через определенное время начать генерировать события с
-- определенной переодичностью. Если палец не отрываясь перемещается по области
-- экрана(по области кнопки), через определенные промежутки времени
-- генерировать события.
--]]
function processTouches()
    local touches = love.touch.getTouches()
    for _, v in pairs(touches) do
        local x, y = love.touch.getPosition(v)
        print("x, y", x, y)
        for k, u in pairs(layout) do
            if type(u) == "table" then
                --print("cycle")
                table.insert(drawList, function()
                    lg.circle("line", x, y, 40)
                end)
                if inRect(x, y, u) and u.func then
                    touchPress(u)
                end
            end
        end
    end
end

function drawTouchRects()
    lg.setColor{0.3, 0.3, 0.3, 1}
    for k, v in pairs(layout) do
        if type(v) == "table" and v.x and v.y and v.w and v.h then
            lg.rectangle("line", v.x, v.y, v.w, v.h)
        end
    end
end

function drawButtonsImages()
    local l = layout

    --lg.draw(imgLArrow, l.leftMove.x, l.leftMove.y, math.pi / 2, l.leftMove.w / imgLArrow:getWidth())
    --lg.draw(imgLArrow, l.leftMove.x, l.leftMove.y, math.pi / 2, imgLArrow:getWidth() / l.leftMove.w)
    --
    lg.draw(imgLArrow, l.leftMove.x, l.leftMove.y, 0, imgLArrow:getWidth() / l.leftMove.w,
        imgLArrow:getHeight() / l.leftMove.h)
    --lg.draw(imgLArrow, l.leftMove.x, l.leftMove.y, 0, imgLArrow:getWidth() / l.leftMove.w,
        --l.leftMove.h / imgLArrow:getHeight() )

    lg.setColor{1, 1, 1, 0.3}
    lg.rectangle("fill", l.leftMove.x, l.leftMove.y, imgLArrow:getWidth(),
        imgLArrow:getHeight())

    lg.draw(imgRArrow, l.rightMove.x, l.rightMove.y, 0, imgRArrow:getWidth() / l.rightMove.w, 1)

    lg.setColor{1, 1, 1, 0.3}
    lg.rectangle("fill", l.rightMove.x, l.rightMove.y, imgRArrow:getWidth(),
        imgRArrow:getHeight())
end

function drop()
    lb:push(1, "drop!")
    print("drop")
end

function makePause()
    print("makePause")
    paused = not paused
end

function buildLayout()
    local scr = makeScreenTable()
    scr.up, scr.bottom = splitv(scr, 0.9, 0.1)
    scr.left, scr.center, scr.right = splith(scr.up, 0.2, 0.6, 0.2)
    _, _, _, scr.leftRotate, scr.leftMove = splitvByNum(scr.left, 5)
    _, _, _, scr.rightRotate, scr.rightMove = splitvByNum(scr.right, 5)
    return scr
end

function love.load(arg)
    if arg[#arg] == "-debug" then require "mobdebug".start() end
    math.randomseed(os.time())
    field = createField()
    timestamp = love.timer.getTime()  
    nextFigure = math.random(1, #figures)
    figure = createFigure(field)

    print("start with", inspect(figure))
    field[1][1] = true
    field[1][2] = true
    field[1][3] = true
    field[1][4] = true
    field[1][5] = true

    field[2][1] = true
    field[3][1] = true
    field[4][1] = true
    field[5][1] = true

    local value, size = love.filesystem.read("highscores.txt")
    value = tonumber(value)
    highscores = value and value or 0
    print("highscores", highscores, "size", size)

    love.keyboard.setKeyRepeat(true)

    layout = buildLayout()
    print("layout", inspect(layout))
    layout.bottom.func = drop
    layout.center.func = makePause
    layout.leftMove.func = function()
        print("moveFigureLeft")
        moveFigureRight(figure, field)
    end
    layout.rightMove.func = function()
        print("moveFigureRight")
        moveFigureLeft(figure, field)
    end
    layout.leftRotate.func = function()
        print("rotateFigireLeft")
        rotateFigireLeft(figure, field)
    end
    layout.rightRotate.func = function()
        print("rotateFigureRight")
        rotateFigureRight(figure, field)
    end
end

function love.update(dt)
    processTouches()
    lb:update(dt)

    local time = love.timer.getTime()

    if paused then
        timestamp = time
        return
    end

    if not isAndroid then
        pause = love.keyboard.isDown("up") and 0.01 or 0.3
    end

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

function checkFigureOnField_orig(figure, field)
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

-- возвращает true если фигуру можно поместить в данную позицию игрового поля.
function checkFigureOnField(figure, field)
    if not __ONCE__ then
        print("figure", inspect(figure))
        print("figureWidth, figureHeight", figureWidth, figureHeight)
        print("field", inspect(field))
        __ONCE__ = true
    end
    -- field[y][x]
    local x, y = figure.x, figure.y
    local f = figure.fig
    for i = 0, figureHeight - 1 do
        for j = 0, figureWidth - 1 do
            if y + i <= fieldHeight and x + j <= fieldWidth then
                local v = field[y + i][x + j]
                if v and f[i + 1][j + 1] then
                    return false
                end
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
    --lg.scale(0.4, 0.4)
    lg.translate(-w / 2, -h / 2)
end

function drawScoresAndPos()
    local w, h = lg.getDimensions()
    local x, y = -100, 0
    local angle = 3 * math.pi / 2
    lg.setColor{1, 1, 1}
    local fontHeight = lg.getFont():getHeight()
    lg.printf(string.format("High scores: %d", highscores), fontHeight, h, h, "center", angle)
    lg.printf(string.format("Scores: %d", scores), fontHeight * 2, h, h, "center", angle)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
end

function love.touchpressed(id, x, y, _, _, pressure)
    sndClick:play()
    --if paused then
        --paused = false
    --end
end

-- оформить смену состояний игры через сопрограмму
function game()
    isGameOver = false
end

function processDrawList()
    for _, v in pairs(drawList) do
        v()
    end
    drawList = {}
end

function love.draw()
    if isAndroid then
        lg.push()
        rotatePortrait()
    end

    local w, h = lg.getDimensions()
    
    if gameover then
        drawGameOver(startx, starty)
    end

    drawField(field)
    drawFigure(figure)
    drawNextFigure()
    
    if isAndroid then
        lg.pop()
    end

    local w, h = lg.getDimensions()

    if failed then
        lb:pushi("Failed")
    end

    --drawButtonsImages()
    drawScoresAndPos()
    drawTouchRects()
    lb:draw()
    processDrawList()
end

function writeHighScores()
    love.filesystem.write("highscores.txt", tostring(highscores))
end

function love.quit()
    writeHighScores()
end
