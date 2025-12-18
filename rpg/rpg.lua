-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- Player references
local plr = Players.LocalPlayer
local mouse = plr:GetMouse()
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- Remote events
local ev = ReplicatedStorage:WaitForChild("RocketSystem"):WaitForChild("Events")
local fx = ev:WaitForChild("RocketReloadedFX")
local fire = ev:WaitForChild("FireRocket")
local hit = ev:WaitForChild("RocketHit")

-- State
local rpgClickEnabled = false
local singleShotEnabled = false
local quadShotEnabled = false
local swastikaEnabled = false
local targetEnabled = false
local javelinClickEnabled = false  -- НОВАЯ ПЕРЕМЕННАЯ ДЛЯ ДЖЕВЕЛИН КЛИК
local stingerClickEnabled = false   -- НОВАЯ ПЕРЕМЕННАЯ ДЛЯ СТИНГЕР КЛИК
local firingDelay = 0.015
local quadShotSpamRate = 0.001
local javelinClickDelay = 0.015     -- ЗАДЕРЖКА ДЛЯ ДЖЕВЕЛИН КЛИК
local stingerClickDelay = 0.015     -- ЗАДЕРЖКА ДЛЯ СТИНГЕР КЛИК
local maxDistance = 4000
local whitelist = {}
local isFiring = false
local lastFireTime = 0
local rocketCount = 0

-- UI Variables
local guiEnabled = true

-- СОЗДАЕМ ГРАФИЧЕСКИЙ ИНТЕРФЕЙС
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RPGSystemGUI"
ScreenGui.Parent = plr:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Основной фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 550)  -- Увеличил высоту
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Закругление
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Тень
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(50, 50, 60)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.BorderSizePixel = 0
Title.Text = "🔥 RPG SYSTEM 🔥"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 7)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Title

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

-- Вкладки
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Size = UDim2.new(1, 0, 0, 40)
TabsFrame.Position = UDim2.new(0, 0, 0, 45)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainFrame

-- Кнопки вкладок
local CombatTabButton = Instance.new("TextButton")  -- НОВАЯ ВКЛАДКА КОМБАТ
CombatTabButton.Name = "CombatTabButton"
CombatTabButton.Size = UDim2.new(0.166, 0, 1, 0)
CombatTabButton.Position = UDim2.new(0, 0, 0, 0)
CombatTabButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
CombatTabButton.BorderSizePixel = 0
CombatTabButton.Text = "Combat"
CombatTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CombatTabButton.TextSize = 14
CombatTabButton.Font = Enum.Font.GothamBold
CombatTabButton.Parent = TabsFrame

local RPGTabButton = Instance.new("TextButton")
RPGTabButton.Name = "RPGTabButton"
RPGTabButton.Size = UDim2.new(0.166, 0, 1, 0)
RPGTabButton.Position = UDim2.new(0.166, 0, 0, 0)
RPGTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
RPGTabButton.BorderSizePixel = 0
RPGTabButton.Text = "RPG"
RPGTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
RPGTabButton.TextSize = 14
RPGTabButton.Font = Enum.Font.Gotham
RPGTabButton.Parent = TabsFrame

local QuadShotTabButton = Instance.new("TextButton")
QuadShotTabButton.Name = "QuadShotTabButton"
QuadShotTabButton.Size = UDim2.new(0.166, 0, 1, 0)
QuadShotTabButton.Position = UDim2.new(0.332, 0, 0, 0)
QuadShotTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
QuadShotTabButton.BorderSizePixel = 0
QuadShotTabButton.Text = "Quad"
QuadShotTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
QuadShotTabButton.TextSize = 14
QuadShotTabButton.Font = Enum.Font.Gotham
QuadShotTabButton.Parent = TabsFrame

local SwastikaTabButton = Instance.new("TextButton")
SwastikaTabButton.Name = "SwastikaTabButton"
SwastikaTabButton.Size = UDim2.new(0.166, 0, 1, 0)
SwastikaTabButton.Position = UDim2.new(0.498, 0, 0, 0)
SwastikaTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
SwastikaTabButton.BorderSizePixel = 0
SwastikaTabButton.Text = "Swastika"
SwastikaTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
SwastikaTabButton.TextSize = 14
SwastikaTabButton.Font = Enum.Font.Gotham
SwastikaTabButton.Parent = TabsFrame

local DebugTabButton = Instance.new("TextButton")
DebugTabButton.Name = "DebugTabButton"
DebugTabButton.Size = UDim2.new(0.166, 0, 1, 0)
DebugTabButton.Position = UDim2.new(0.664, 0, 0, 0)
DebugTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
DebugTabButton.BorderSizePixel = 0
DebugTabButton.Text = "Debug"
DebugTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
DebugTabButton.TextSize = 14
DebugTabButton.Font = Enum.Font.Gotham
DebugTabButton.Parent = TabsFrame

local TargetTabButton = Instance.new("TextButton")
TargetTabButton.Name = "TargetTabButton"
TargetTabButton.Size = UDim2.new(0.166, 0, 1, 0)
TargetTabButton.Position = UDim2.new(0.83, 0, 0, 0)
TargetTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
TargetTabButton.BorderSizePixel = 0
TargetTabButton.Text = "Target"
TargetTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
TargetTabButton.TextSize = 14
TargetTabButton.Font = Enum.Font.Gotham
TargetTabButton.Parent = TabsFrame

-- Закругление вкладок
for _, button in ipairs({CombatTabButton, RPGTabButton, QuadShotTabButton, SwastikaTabButton, DebugTabButton, TargetTabButton}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
end

-- Контейнер для вкладок
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -135)
ContentFrame.Position = UDim2.new(0, 10, 0, 95)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Фреймы вкладок
local CombatTabFrame = Instance.new("Frame")  -- НОВАЯ ВКЛАДКА
CombatTabFrame.Name = "CombatTabFrame"
CombatTabFrame.Size = UDim2.new(1, 0, 1, 0)
CombatTabFrame.BackgroundTransparency = 1
CombatTabFrame.Visible = true
CombatTabFrame.Parent = ContentFrame

local RPGTabFrame = Instance.new("Frame")
RPGTabFrame.Name = "RPGTabFrame"
RPGTabFrame.Size = UDim2.new(1, 0, 1, 0)
RPGTabFrame.BackgroundTransparency = 1
RPGTabFrame.Visible = false
RPGTabFrame.Parent = ContentFrame

local QuadShotTabFrame = Instance.new("Frame")
QuadShotTabFrame.Name = "QuadShotTabFrame"
QuadShotTabFrame.Size = UDim2.new(1, 0, 1, 0)
QuadShotTabFrame.BackgroundTransparency = 1
QuadShotTabFrame.Visible = false
QuadShotTabFrame.Parent = ContentFrame

local SwastikaTabFrame = Instance.new("Frame")
SwastikaTabFrame.Name = "SwastikaTabFrame"
SwastikaTabFrame.Size = UDim2.new(1, 0, 1, 0)
SwastikaTabFrame.BackgroundTransparency = 1
SwastikaTabFrame.Visible = false
SwastikaTabFrame.Parent = ContentFrame

local DebugTabFrame = Instance.new("Frame")
DebugTabFrame.Name = "DebugTabFrame"
DebugTabFrame.Size = UDim2.new(1, 0, 1, 0)
DebugTabFrame.BackgroundTransparency = 1
DebugTabFrame.Visible = false
DebugTabFrame.Parent = ContentFrame

local TargetTabFrame = Instance.new("Frame")
TargetTabFrame.Name = "TargetTabFrame"
TargetTabFrame.Size = UDim2.new(1, 0, 1, 0)
TargetTabFrame.BackgroundTransparency = 1
TargetTabFrame.Visible = false
TargetTabFrame.Parent = ContentFrame

-- Функция для создания элементов UI
local function createButton(parent, text, position, size, color)
    local button = Instance.new("TextButton")
    button.Size = size or UDim2.new(1, -10, 0, 40)
    button.Position = position or UDim2.new(0, 5, 0, 5)
    button.BackgroundColor3 = color or Color3.fromRGB(70, 70, 80)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 110)
    stroke.Thickness = 1
    stroke.Parent = button
    
    return button
end

local function createLabel(parent, text, position, size)
    local label = Instance.new("TextLabel")
    label.Size = size or UDim2.new(1, -10, 0, 25)
    label.Position = position or UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    return label
end

-- Создаем элементы для вкладки Combat
createLabel(CombatTabFrame, "Джевелин Клик:", UDim2.new(0, 5, 0, 10))

local javelinToggleButton = createButton(CombatTabFrame, "🎯 ВКЛЮЧИТЬ ДЖЕВЕЛИН КЛИК", UDim2.new(0, 5, 0, 40), nil, Color3.fromRGB(100, 180, 255))

createLabel(CombatTabFrame, "Стингер Клик:", UDim2.new(0, 5, 0, 90))

local stingerToggleButton = createButton(CombatTabFrame, "⚡ ВКЛЮЧИТЬ СТИНГЕР КЛИК", UDim2.new(0, 5, 0, 120), nil, Color3.fromRGB(100, 255, 150))

createLabel(CombatTabFrame, "RPG Клик:", UDim2.new(0, 5, 0, 170))

local rpgCombatToggleButton = createButton(CombatTabFrame, "🚀 ВКЛЮЧИТЬ RPG CLICK", UDim2.new(0, 5, 0, 200))

createLabel(CombatTabFrame, "Скорость стрельбы (Джевелин):", UDim2.new(0, 5, 0, 250))

-- Слайдер для скорости джевелин
local javelinSpeedSliderFrame = Instance.new("Frame")
javelinSpeedSliderFrame.Size = UDim2.new(1, -10, 0, 30)
javelinSpeedSliderFrame.Position = UDim2.new(0, 5, 0, 275)
javelinSpeedSliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
javelinSpeedSliderFrame.BorderSizePixel = 0
javelinSpeedSliderFrame.Parent = CombatTabFrame

local javelinSpeedCorner = Instance.new("UICorner")
javelinSpeedCorner.CornerRadius = UDim.new(0, 6)
javelinSpeedCorner.Parent = javelinSpeedSliderFrame

local javelinSpeedFill = Instance.new("Frame")
javelinSpeedFill.Name = "JavelinSpeedFill"
javelinSpeedFill.Size = UDim2.new(0.3, 0, 1, 0) -- 30% для 0.015 задержки
javelinSpeedFill.Position = UDim2.new(0, 0, 0, 0)
javelinSpeedFill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
javelinSpeedFill.BorderSizePixel = 0
javelinSpeedFill.Parent = javelinSpeedSliderFrame

local javelinSpeedFillCorner = Instance.new("UICorner")
javelinSpeedFillCorner.CornerRadius = UDim.new(0, 6)
javelinSpeedFillCorner.Parent = javelinSpeedFill

local javelinSpeedText = Instance.new("TextLabel")
javelinSpeedText.Size = UDim2.new(1, 0, 1, 0)
javelinSpeedText.Position = UDim2.new(0, 0, 0, 0)
javelinSpeedText.BackgroundTransparency = 1
javelinSpeedText.Text = "Скорость: ~66 выстр/сек"
javelinSpeedText.TextColor3 = Color3.fromRGB(255, 255, 255)
javelinSpeedText.TextSize = 14
javelinSpeedText.Font = Enum.Font.Gotham
javelinSpeedText.Parent = javelinSpeedSliderFrame

createLabel(CombatTabFrame, "Зажми ЛКМ для автоматической стрельбы", UDim2.new(0, 5, 0, 315))
createLabel(CombatTabFrame, "Для Джевелин, Стингер или РПГ", UDim2.new(0, 5, 0, 335))

-- Создаем элементы для вкладки RPG Click
createLabel(RPGTabFrame, "Автоматическая стрельба:", UDim2.new(0, 5, 0, 10))

local rpgToggleButton = createButton(RPGTabFrame, "🚀 ВКЛЮЧИТЬ RPG CLICK", UDim2.new(0, 5, 0, 40))

createLabel(RPGTabFrame, "Одиночный выстрел:", UDim2.new(0, 5, 0, 90))

local singleToggleButton = createButton(RPGTabFrame, "🔫 ВКЛЮЧИТЬ SINGLE SHOT", UDim2.new(0, 5, 0, 120))

createLabel(RPGTabFrame, "Скорость стрельбы:", UDim2.new(0, 5, 0, 170))

-- Слайдер для скорости
local speedSliderFrame = Instance.new("Frame")
speedSliderFrame.Size = UDim2.new(1, -10, 0, 30)
speedSliderFrame.Position = UDim2.new(0, 5, 0, 195)
speedSliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
speedSliderFrame.BorderSizePixel = 0
speedSliderFrame.Parent = RPGTabFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedSliderFrame

local speedFill = Instance.new("Frame")
speedFill.Name = "SpeedFill"
speedFill.Size = UDim2.new(0.3, 0, 1, 0) -- 30% для 0.015 задержки
speedFill.Position = UDim2.new(0, 0, 0, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(80, 140, 220)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedSliderFrame

local speedFillCorner = Instance.new("UICorner")
speedFillCorner.CornerRadius = UDim.new(0, 6)
speedFillCorner.Parent = speedFill

local speedText = Instance.new("TextLabel")
speedText.Size = UDim2.new(1, 0, 1, 0)
speedText.Position = UDim2.new(0, 0, 0, 0)
speedText.BackgroundTransparency = 1
speedText.Text = "Скорость: ~66 выстр/сек"
speedText.TextColor3 = Color3.fromRGB(255, 255, 255)
speedText.TextSize = 14
speedText.Font = Enum.Font.Gotham
speedText.Parent = speedSliderFrame

createLabel(RPGTabFrame, "Зажми ЛКМ для автоматической стрельбы", UDim2.new(0, 5, 0, 235))
createLabel(RPGTabFrame, "Нажми ЛКМ для одиночного выстрела", UDim2.new(0, 5, 0, 255))
createLabel(RPGTabFrame, "Стрельба ведется по точке курсора", UDim2.new(0, 5, 0, 275))

-- Создаем элементы для вкладки Quad Shot
createLabel(QuadShotTabFrame, "Quad Shot (4 выстрела):", UDim2.new(0, 5, 0, 10))

local quadToggleButton = createButton(QuadShotTabFrame, "🔥 ВКЛЮЧИТЬ QUAD SHOT", UDim2.new(0, 5, 0, 40), nil, Color3.fromRGB(220, 120, 50))

createLabel(QuadShotTabFrame, "Дистанция между выстрелами:", UDim2.new(0, 5, 0, 90))

local quadDistanceSliderFrame = Instance.new("Frame")
quadDistanceSliderFrame.Size = UDim2.new(1, -10, 0, 30)
quadDistanceSliderFrame.Position = UDim2.new(0, 5, 0, 120)
quadDistanceSliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
quadDistanceSliderFrame.BorderSizePixel = 0
quadDistanceSliderFrame.Parent = QuadShotTabFrame

local quadDistanceCorner = Instance.new("UICorner")
quadDistanceCorner.CornerRadius = UDim.new(0, 6)
quadDistanceCorner.Parent = quadDistanceSliderFrame

local quadDistanceFill = Instance.new("Frame")
quadDistanceFill.Name = "QuadDistanceFill"
quadDistanceFill.Size = UDim2.new(0.5, 0, 1, 0) -- 50% для 10 метров
quadDistanceFill.Position = UDim2.new(0, 0, 0, 0)
quadDistanceFill.BackgroundColor3 = Color3.fromRGB(220, 120, 50)
quadDistanceFill.BorderSizePixel = 0
quadDistanceFill.Parent = quadDistanceSliderFrame

local quadDistanceFillCorner = Instance.new("UICorner")
quadDistanceFillCorner.CornerRadius = UDim.new(0, 6)
quadDistanceFillCorner.Parent = quadDistanceFill

local quadDistanceText = Instance.new("TextLabel")
quadDistanceText.Size = UDim2.new(1, 0, 1, 0)
quadDistanceText.Position = UDim2.new(0, 0, 0, 0)
quadDistanceText.BackgroundTransparency = 1
quadDistanceText.Text = "Дистанция: 10 м"
quadDistanceText.TextColor3 = Color3.fromRGB(255, 255, 255)
quadDistanceText.TextSize = 14
quadDistanceText.Font = Enum.Font.Gotham
quadDistanceText.Parent = quadDistanceSliderFrame

createLabel(QuadShotTabFrame, "Скорость спама Quad выстрелов:", UDim2.new(0, 5, 0, 160))

local quadSpeedSliderFrame = Instance.new("Frame")
quadSpeedSliderFrame.Size = UDim2.new(1, -10, 0, 30)
quadSpeedSliderFrame.Position = UDim2.new(0, 5, 0, 185)
quadSpeedSliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
quadSpeedSliderFrame.BorderSizePixel = 0
quadSpeedSliderFrame.Parent = QuadShotTabFrame

local quadSpeedCorner = Instance.new("UICorner")
quadSpeedCorner.CornerRadius = UDim.new(0, 6)
quadSpeedCorner.Parent = quadSpeedSliderFrame

local quadSpeedFill = Instance.new("Frame")
quadSpeedFill.Name = "QuadSpeedFill"
quadSpeedFill.Size = UDim2.new(0.1, 0, 1, 0) -- 10% для 0.001 скорости
quadSpeedFill.Position = UDim2.new(0, 0, 0, 0)
quadSpeedFill.BackgroundColor3 = Color3.fromRGB(220, 120, 50)
quadSpeedFill.BorderSizePixel = 0
quadSpeedFill.Parent = quadSpeedSliderFrame

local quadSpeedFillCorner = Instance.new("UICorner")
quadSpeedFillCorner.CornerRadius = UDim.new(0, 6)
quadSpeedFillCorner.Parent = quadSpeedFill

local quadSpeedText = Instance.new("TextLabel")
quadSpeedText.Size = UDim2.new(1, 0, 1, 0)
quadSpeedText.Position = UDim2.new(0, 0, 0, 0)
quadSpeedText.BackgroundTransparency = 1
quadSpeedText.Text = "Скорость: 0.001 сек"
quadSpeedText.TextColor3 = Color3.fromRGB(255, 255, 255)
quadSpeedText.TextSize = 14
quadSpeedText.Font = Enum.Font.Gotham
quadSpeedText.Parent = quadSpeedSliderFrame

createLabel(QuadShotTabFrame, "Зажми ЛКМ для быстрого спама 4 выстрелов", UDim2.new(0, 5, 0, 225))
createLabel(QuadShotTabFrame, "Выстрелы создаются в квадрате 10x10 метров", UDim2.new(0, 5, 0, 245))
createLabel(QuadShotTabFrame, "Центр - точка курсора", UDim2.new(0, 5, 0, 265))

-- Создаем элементы для вкладки Swastika
createLabel(SwastikaTabFrame, "Свастика:", UDim2.new(0, 5, 0, 10))

local swastikaToggleButton = createButton(SwastikaTabFrame, "卐 ВКЛЮЧИТЬ СВАСТИКУ", UDim2.new(0, 5, 0, 40), nil, Color3.fromRGB(180, 60, 60))

createLabel(SwastikaTabFrame, "Размер свастики:", UDim2.new(0, 5, 0, 95))

local sizeSliderFrame = Instance.new("Frame")
sizeSliderFrame.Size = UDim2.new(1, -10, 0, 30)
sizeSliderFrame.Position = UDim2.new(0, 5, 0, 120)
sizeSliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
sizeSliderFrame.BorderSizePixel = 0
sizeSliderFrame.Parent = SwastikaTabFrame

local sizeCorner = Instance.new("UICorner")
sizeCorner.CornerRadius = UDim.new(0, 6)
sizeCorner.Parent = sizeSliderFrame

local sizeFill = Instance.new("Frame")
sizeFill.Name = "SizeFill"
sizeFill.Size = UDim2.new(0.4, 0, 1, 0) -- 40% для размера 10
sizeFill.Position = UDim2.new(0, 0, 0, 0)
sizeFill.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
sizeFill.BorderSizePixel = 0
sizeFill.Parent = sizeSliderFrame

local sizeFillCorner = Instance.new("UICorner")
sizeFillCorner.CornerRadius = UDim.new(0, 6)
sizeFillCorner.Parent = sizeFill

local sizeText = Instance.new("TextLabel")
sizeText.Size = UDim2.new(1, 0, 1, 0)
sizeText.Position = UDim2.new(0, 0, 0, 0)
sizeText.BackgroundTransparency = 1
sizeText.Text = "Размер: 10 точек"
sizeText.TextColor3 = Color3.fromRGB(255, 255, 255)
sizeText.TextSize = 14
sizeText.Font = Enum.Font.Gotham
sizeText.Parent = sizeSliderFrame

createLabel(SwastikaTabFrame, "Разброс свастики:", UDim2.new(0, 5, 0, 160))

local spreadSliderFrame = Instance.new("Frame")
spreadSliderFrame.Size = UDim2.new(1, -10, 0, 30)
spreadSliderFrame.Position = UDim2.new(0, 5, 0, 185)
spreadSliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
spreadSliderFrame.BorderSizePixel = 0
spreadSliderFrame.Parent = SwastikaTabFrame

local spreadCorner = Instance.new("UICorner")
spreadCorner.CornerRadius = UDim.new(0, 6)
spreadCorner.Parent = spreadSliderFrame

local spreadFill = Instance.new("Frame")
spreadFill.Name = "SpreadFill"
spreadFill.Size = UDim2.new(0.25, 0, 1, 0) -- 25% для разброса 5
spreadFill.Position = UDim2.new(0, 0, 0, 0)
spreadFill.BackgroundColor3 = Color3.fromRGB(180, 100, 200)
spreadFill.BorderSizePixel = 0
spreadFill.Parent = spreadSliderFrame

local spreadFillCorner = Instance.new("UICorner")
spreadFillCorner.CornerRadius = UDim.new(0, 6)
spreadFillCorner.Parent = spreadFill

local spreadText = Instance.new("TextLabel")
spreadText.Size = UDim2.new(1, 0, 1, 0)
spreadText.Position = UDim2.new(0, 0, 0, 0)
spreadText.BackgroundTransparency = 1
spreadText.Text = "Разброс: 5.0"
spreadText.TextColor3 = Color3.fromRGB(255, 255, 255)
spreadText.TextSize = 14
spreadText.Font = Enum.Font.Gotham
spreadText.Parent = spreadSliderFrame

createLabel(SwastikaTabFrame, "Нажми ЛКМ для выстрела свастикой", UDim2.new(0, 5, 0, 225))

-- Создаем элементы для вкладки Debug
createLabel(DebugTabFrame, "Отладка системы:", UDim2.new(0, 5, 0, 10))

local debugCheckButton = createButton(DebugTabFrame, "🔍 ПРОВЕРИТЬ СИСТЕМУ", UDim2.new(0, 5, 0, 40), nil, Color3.fromRGB(60, 160, 80))

local debugStatusLabel = createLabel(DebugTabFrame, "Статус: Не проверено", UDim2.new(0, 5, 0, 90))
debugStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

local debugInfoLabel = createLabel(DebugTabFrame, "", UDim2.new(0, 5, 0, 120))
debugInfoLabel.Size = UDim2.new(1, -10, 0, 100)
debugInfoLabel.TextWrapped = true

local debugReloadButton = createButton(DebugTabFrame, "🔄 ПЕРЕЗАГРУЗИТЬ СКРИПТ", UDim2.new(0, 5, 0, 230), nil, Color3.fromRGB(80, 80, 160))

local breakBasesButton = createButton(DebugTabFrame, "💥 ЛОМАТЬ ВСЕ БАЗЫ", UDim2.new(0, 5, 0, 280), nil, Color3.fromRGB(255, 50, 50))

-- Создаем элементы для вкладки Target
createLabel(TargetTabFrame, "Авто таргетинг:", UDim2.new(0, 5, 0, 10))

local targetToggleButton = createButton(TargetTabFrame, "🎯 ВКЛЮЧИТЬ TARGET", UDim2.new(0, 5, 0, 40), nil, Color3.fromRGB(150, 150, 50))

createLabel(TargetTabFrame, "Задержка стрельбы:", UDim2.new(0, 5, 0, 95))

local fireRateSliderFrame = Instance.new("Frame")
fireRateSliderFrame.Size = UDim2.new(1, -10, 0, 30)
fireRateSliderFrame.Position = UDim2.new(0, 5, 0, 120)
fireRateSliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
fireRateSliderFrame.BorderSizePixel = 0
fireRateSliderFrame.Parent = TargetTabFrame

local fireRateCorner = Instance.new("UICorner")
fireRateCorner.CornerRadius = UDim.new(0, 6)
fireRateCorner.Parent = fireRateSliderFrame

local fireRateFill = Instance.new("Frame")
fireRateFill.Name = "FireRateFill"
fireRateFill.Size = UDim2.new(0.001, 0, 1, 0)
fireRateFill.Position = UDim2.new(0, 0, 0, 0)
fireRateFill.BackgroundColor3 = Color3.fromRGB(150, 150, 50)
fireRateFill.BorderSizePixel = 0
fireRateFill.Parent = fireRateSliderFrame

local fireRateFillCorner = Instance.new("UICorner")
fireRateFillCorner.CornerRadius = UDim.new(0, 6)
fireRateFillCorner.Parent = fireRateFill

local fireRateText = Instance.new("TextLabel")
fireRateText.Size = UDim2.new(1, 0, 1, 0)
fireRateText.Position = UDim2.new(0, 0, 0, 0)
fireRateText.BackgroundTransparency = 1
fireRateText.Text = "Задержка: 0.001 сек"
fireRateText.TextColor3 = Color3.fromRGB(255, 255, 255)
fireRateText.TextSize = 14
fireRateText.Font = Enum.Font.Gotham
fireRateText.Parent = fireRateSliderFrame

createLabel(TargetTabFrame, "Макс расстояние:", UDim2.new(0, 5, 0, 160))

local maxDistSliderFrame = Instance.new("Frame")
maxDistSliderFrame.Size = UDim2.new(1, -10, 0, 30)
maxDistSliderFrame.Position = UDim2.new(0, 5, 0, 185)
maxDistSliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
maxDistSliderFrame.BorderSizePixel = 0
maxDistSliderFrame.Parent = TargetTabFrame

local maxDistCorner = Instance.new("UICorner")
maxDistCorner.CornerRadius = UDim.new(0, 6)
maxDistCorner.Parent = maxDistSliderFrame

local maxDistFill = Instance.new("Frame")
maxDistFill.Name = "MaxDistFill"
maxDistFill.Size = UDim2.new(0.8, 0, 1, 0) -- approx for 4000/5000
maxDistFill.Position = UDim2.new(0, 0, 0, 0)
maxDistFill.BackgroundColor3 = Color3.fromRGB(150, 150, 50)
maxDistFill.BorderSizePixel = 0
maxDistFill.Parent = maxDistSliderFrame

local maxDistFillCorner = Instance.new("UICorner")
maxDistFillCorner.CornerRadius = UDim.new(0, 6)
maxDistFillCorner.Parent = maxDistFill

local maxDistText = Instance.new("TextLabel")
maxDistText.Size = UDim2.new(1, 0, 1, 0)
maxDistText.Position = UDim2.new(0, 0, 0, 0)
maxDistText.BackgroundTransparency = 1
maxDistText.Text = "Расстояние: 4000"
maxDistText.TextColor3 = Color3.fromRGB(255, 255, 255)
maxDistText.TextSize = 14
maxDistText.Font = Enum.Font.Gotham
maxDistText.Parent = maxDistSliderFrame

createLabel(TargetTabFrame, "Whitelist:", UDim2.new(0, 5, 0, 225))

local whitelistDropdown = Instance.new("ScrollingFrame")
whitelistDropdown.Size = UDim2.new(1, -10, 0, 100)
whitelistDropdown.Position = UDim2.new(0, 5, 0, 250)
whitelistDropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
whitelistDropdown.BorderSizePixel = 0
whitelistDropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
whitelistDropdown.ScrollBarThickness = 6
whitelistDropdown.Parent = TargetTabFrame

local whitelistCorner = Instance.new("UICorner")
whitelistCorner.CornerRadius = UDim.new(0, 6)
whitelistCorner.Parent = whitelistDropdown

-- Статус бар
local StatusBar = Instance.new("Frame")
StatusBar.Name = "StatusBar"
StatusBar.Size = UDim2.new(1, -20, 0, 40)
StatusBar.Position = UDim2.new(0, 10, 1, -50)
StatusBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusBar

local StatusText = Instance.new("TextLabel")
StatusText.Name = "StatusText"
StatusText.Size = UDim2.new(1, -10, 1, 0)
StatusText.Position = UDim2.new(0, 5, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "RPG SYSTEM загружен"
StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusText.TextSize = 14
StatusText.Font = Enum.Font.Gotham
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusBar

local RocketCounter = Instance.new("TextLabel")
RocketCounter.Name = "RocketCounter"
RocketCounter.Size = UDim2.new(0.4, 0, 1, 0)
RocketCounter.Position = UDim2.new(0.6, 0, 0, 0)
RocketCounter.BackgroundTransparency = 1
RocketCounter.Text = "Ракет: 0"
RocketCounter.TextColor3 = Color3.fromRGB(255, 200, 50)
RocketCounter.TextSize = 14
RocketCounter.Font = Enum.Font.GothamBold
RocketCounter.TextXAlignment = Enum.TextXAlignment.Right
RocketCounter.Parent = StatusBar

-- НАСТРОЙКИ СВАСТИКИ
local horizontalSpread = 5.0
local verticalSpread = 5.0
local swastikaSize = 10
local thickness = 1
local shotOffsets = {}

-- НАСТРОЙКИ QUAD SHOT
local quadDistance = 10  -- Расстояние между выстрелами в метрах

-- НАСТРОЙКИ ДЖЕВЕЛИН
local javelinSpamRate = 0.015  -- Скорость спама для джевелин

-- НАСТРОЙКИ СТИНГЕР
local stingerSpamRate = 0.015  -- Скорость спама для стингер

local function createSwastikaPoints()
    shotOffsets = {}
    local half_thick = math.floor(thickness / 2)
    
    -- Вертикальная линия
    for dh = -half_thick, half_thick do
        for v = -swastikaSize, swastikaSize do
            table.insert(shotOffsets, {h = dh, v = v})
        end
    end
    
    -- Горизонтальная линия
    for h = -swastikaSize, swastikaSize do
        for dv = -half_thick, half_thick do
            table.insert(shotOffsets, {h = h, v = dv})
        end
    end
    
    -- Верхний крючок
    for h = half_thick + 1, half_thick + swastikaSize do
        for v = swastikaSize - half_thick, swastikaSize + half_thick do
            table.insert(shotOffsets, {h = h, v = v})
        end
    end
    
    -- Правый крючок
    for h = swastikaSize - half_thick, swastikaSize + half_thick do
        for v = -swastikaSize - half_thick, -half_thick - 1 do
            table.insert(shotOffsets, {h = h, v = v})
        end
    end
    
    -- Нижний крючок
    for h = -swastikaSize - half_thick, -half_thick - 1 do
        for v = -swastikaSize - half_thick, -swastikaSize + half_thick do
            table.insert(shotOffsets, {h = h, v = v})
        end
    end
    
    -- Левый крючок
    for h = -swastikaSize - half_thick, -swastikaSize + half_thick do
        for v = half_thick + 1, half_thick + swastikaSize do
            table.insert(shotOffsets, {h = h, v = v})
        end
    end
    
    return #shotOffsets
end

local totalSwastikaPoints = createSwastikaPoints()

-- Функция для обновления статуса
local function updateStatus(text, color)
    StatusText.Text = text
    StatusText.TextColor3 = color or Color3.fromRGB(200, 200, 200)
end

local function updateRocketCounter()
    RocketCounter.Text = "Ракет: " .. rocketCount
end

-- ОБЩИЕ ФУНКЦИИ
local function findWeaponInInventory(weaponName)
    local char = plr.Character
    if not char then return nil end
    
    -- Сначала проверяем в руках
    for _, item in ipairs(char:GetChildren()) do
        if item.Name == weaponName and item:IsA("Tool") then
            return item
        end
    end
    
    -- Затем в бэкпаке
    local backpack = plr:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item.Name == weaponName and item:IsA("Tool") then
                return item
            end
        end
    end
    
    return nil
end

local function getTargetPoint()
    local camera = Workspace.CurrentCamera
    if not camera then return Vector3.new(0, 0, 0) end
    
    local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.IgnoreWater = true
    
    local raycastResult = Workspace:Raycast(ray.Origin, ray.Direction * 5000, raycastParams)
    
    if raycastResult then
        return raycastResult.Position
    else
        return ray.Origin + ray.Direction * 5000
    end
end

local function fireSingleRocket(targetPos, weapon, target)
    if not hrp then return false end
    
    local adjustedTarget = targetPos + Vector3.new(0, 2.5, 0)
    local directionFromPlayer = (adjustedTarget - hrp.Position).Unit
    
    local success = pcall(function()
        fx:FireServer(weapon, true)
        fire:InvokeServer(directionFromPlayer, weapon, weapon, adjustedTarget)
        
        local uniqueId = plr.Name.."_RPG_"..tostring(os.clock() * 1000)
        hit:FireServer(adjustedTarget, directionFromPlayer, weapon, weapon, target, nil, uniqueId)
    end)
    
    if success then
        rocketCount = rocketCount + 1
        updateRocketCounter()
    end
    
    return success
end

-- ФУНКЦИЯ RPG CLICK
local function fireRPGClick()
    local tool = findWeaponInInventory("RPG")
    if not tool then
        rpgClickEnabled = false
        rpgToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
        updateStatus("РПГ не найден в инвентаре!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local targetPoint = getTargetPoint()
    local char = plr.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local playerToTarget = targetPoint - hrp.Position
    local dist = playerToTarget.Magnitude
    if dist < 5 then return end
    
    return fireSingleRocket(targetPoint, tool, mouse.Target)
end

-- ФУНКЦИЯ ДЖЕВЕЛИН КЛИК
local function fireJavelinClick()
    local tool = findWeaponInInventory("Javelin")
    if not tool then
        javelinClickEnabled = false
        javelinToggleButton.Text = "🎯 ВКЛЮЧИТЬ ДЖЕВЕЛИН КЛИК"
        updateStatus("Джевелин не найден в инвентаре!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local targetPoint = getTargetPoint()
    local char = plr.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local playerToTarget = targetPoint - hrp.Position
    local dist = playerToTarget.Magnitude
    if dist < 5 then return end
    
    return fireSingleRocket(targetPoint, tool, mouse.Target)
end

-- ФУНКЦИЯ СТИНГЕР КЛИК
local function fireStingerClick()
    local tool = findWeaponInInventory("Stinger")
    if not tool then
        stingerClickEnabled = false
        stingerToggleButton.Text = "⚡ ВКЛЮЧИТЬ СТИНГЕР КЛИК"
        updateStatus("Стингер не найден в инвентаре!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local targetPoint = getTargetPoint()
    local char = plr.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local playerToTarget = targetPoint - hrp.Position
    local dist = playerToTarget.Magnitude
    if dist < 5 then return end
    
    return fireSingleRocket(targetPoint, tool, mouse.Target)
end

-- ФУНКЦИЯ QUAD SHOT (4 выстрела в квадрате 10x10 метров)
local function fireQuadShot()
    local tool = findWeaponInInventory("RPG")
    if not tool then
        quadShotEnabled = false
        quadToggleButton.Text = "🔥 ВКЛЮЧИТЬ QUAD SHOT"
        updateStatus("РПГ не найден в инвентаре!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local centerPoint = getTargetPoint()
    local char = plr.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local playerToTarget = centerPoint - hrp.Position
    local dist = playerToTarget.Magnitude
    if dist < 5 then 
        updateStatus("Слишком близко для стрельбы!", Color3.fromRGB(255, 100, 100))
        return 
    end
    
    local camera = Workspace.CurrentCamera
    local direction = camera.CFrame.LookVector
    local up = Vector3.new(0, 1, 0)
    local right = direction:Cross(up).Unit
    
    -- Создаем 4 точки в квадрате
    local quadPoints = {
        centerPoint + (right * -quadDistance) + (up * -quadDistance),  -- Левый нижний
        centerPoint + (right * quadDistance) + (up * -quadDistance),   -- Правый нижний
        centerPoint + (right * -quadDistance) + (up * quadDistance),   -- Левый верхний
        centerPoint + (right * quadDistance) + (up * quadDistance)     -- Правый верхний
    }
    
    -- Быстрый спам 4 выстрелов
    for i, point in ipairs(quadPoints) do
        task.spawn(function()
            fireSingleRocket(point, tool, mouse.Target)
        end)
        
        -- Очень маленькая задержка между выстрелами для эффекта спама
        if i < #quadPoints then
            task.wait(quadShotSpamRate)
        end
    end
    
    updateStatus("Quad Shot: 4 ракеты выпущены!", Color3.fromRGB(255, 150, 50))
end

-- ФУНКЦИЯ СВАСТИКИ
local function fireSwastika()
    local tool = findWeaponInInventory("RPG")
    if not tool then
        swastikaEnabled = false
        swastikaToggleButton.Text = "卐 ВКЛЮЧИТЬ СВАСТИКУ"
        updateStatus("РПГ не найден в инвентаре!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local targetPoint = getTargetPoint()
    local char = plr.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local playerToTarget = targetPoint - hrp.Position
    local dist = playerToTarget.Magnitude
    if dist < 5 then 
        updateStatus("Слишком близко для стрельбы!", Color3.fromRGB(255, 100, 100))
        return 
    end
    
    local direction = playerToTarget.Unit
    local up = Vector3.new(0, 1, 0)
    local right = direction:Cross(up).Unit
    local target = mouse.Target
    
    updateStatus("Свастика: выстрел...", Color3.fromRGB(255, 200, 50))
    
    for i, offsetData in ipairs(shotOffsets) do
        local horiz = offsetData.h
        local vert = offsetData.v
        local offset = (right * horiz * horizontalSpread) + (up * vert * verticalSpread)
        local finalPos = targetPoint + offset
        
        task.spawn(function()
            fireSingleRocket(finalPos, tool, target)
        end)
        
        if i % 4 == 0 then
            task.wait(0.001)
        end
    end
    
    updateStatus("Свастика: " .. #shotOffsets .. " ракет выпущено!", Color3.fromRGB(100, 255, 100))
end

-- ФУНКЦИЯ ДЛЯ TARGET
local function getTargets()
    local lst = {}
    for _, w in pairs(Players:GetPlayers()) do
        if w ~= plr and w.Character and w.Character:FindFirstChild("HumanoidRootPart") and not whitelist[w] then
            local distance = (w.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if distance <= maxDistance then
                table.insert(lst, w)
            end
        end
    end
    return lst
end

-- ФУНКЦИЯ ЛОМАНИЯ БАЗ
local function breakAllBases()
    local tycoons = Workspace.Tycoon.Tycoons:GetChildren()
    local forcefieldsBroken = 0
    
    local objectsToBreak = {
        "Factory Garage Door Three",
        "Factory Garage Door",
        "Factory Garage Door Two",
        "Factory Building Armored Door Two",
        "Factory Building Armored Door",
        "Plane Hangar Door",
        "Small Gate 3",
        "Hovercraft Gate",
        "Hovercraft Room Armored Door",
        "Large Oil 1",
        "Large Oil 2",
        "Large Oil 3",
        "Large Oil 4"
    }
    
    for _, tycoon in ipairs(tycoons) do
        local purchasedObjects = tycoon:FindFirstChild("PurchasedObjects")
        if purchasedObjects then
            for _, objName in ipairs(objectsToBreak) do
                local obj = purchasedObjects:FindFirstChild(objName)
                if obj then
                    if obj:FindFirstChild("FF2") then
                        obj.FF2:Destroy()
                        forcefieldsBroken = forcefieldsBroken + 1
                    end
                    if obj:FindFirstChild("FF1") then
                        obj.FF1:Destroy()
                        forcefieldsBroken = forcefieldsBroken + 1
                    end
                    local electricalBox = obj:FindFirstChild("ElectricalBox")
                    if electricalBox then
                        if electricalBox:FindFirstChild("Forcefield") then
                            electricalBox.Forcefield:Destroy()
                            forcefieldsBroken = forcefieldsBroken + 1
                        end
                        if electricalBox:FindFirstChild("FF1") then
                            electricalBox.FF1:Destroy()
                            forcefieldsBroken = forcefieldsBroken + 1
                        end
                    end
                end
            end
        end
    end
    
    updateStatus("Базы сломаны! Уничтожено " .. forcefieldsBroken .. " форсфилдов", Color3.fromRGB(255, 50, 50))
end

-- ОБРАБОТКА ВВОДА
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if rpgClickEnabled then
            isFiring = true
            lastFireTime = os.clock() - firingDelay
            updateStatus("RPG Click: стрельба...", Color3.fromRGB(100, 255, 100))
        elseif quadShotEnabled then
            isFiring = true
            lastFireTime = os.clock() - quadShotSpamRate
            updateStatus("Quad Shot: спам...", Color3.fromRGB(255, 150, 50))
        elseif javelinClickEnabled then
            isFiring = true
            lastFireTime = os.clock() - javelinClickDelay
            updateStatus("Джевелин Клик: стрельба...", Color3.fromRGB(100, 180, 255))
        elseif stingerClickEnabled then
            isFiring = true
            lastFireTime = os.clock() - stingerClickDelay
            updateStatus("Стингер Клик: стрельба...", Color3.fromRGB(100, 255, 150))
        elseif singleShotEnabled then
            fireRPGClick()
        elseif swastikaEnabled then
            fireSwastika()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if rpgClickEnabled or quadShotEnabled or javelinClickEnabled or stingerClickEnabled then
            isFiring = false
            local statusMsg = ""
            if rpgClickEnabled then statusMsg = "RPG Click: готов"
            elseif quadShotEnabled then statusMsg = "Quad Shot: готов"
            elseif javelinClickEnabled then statusMsg = "Джевелин Клик: готов"
            elseif stingerClickEnabled then statusMsg = "Стингер Клик: готов"
            end
            updateStatus(statusMsg, Color3.fromRGB(200, 200, 200))
        end
    end
end)

-- ЦИКЛ СТРЕЛЬБЫ ДЛЯ RPG CLICK
RunService.RenderStepped:Connect(function()
    if not (rpgClickEnabled or javelinClickEnabled or stingerClickEnabled) or not isFiring then return end
    
    local currentTime = os.clock()
    
    if rpgClickEnabled and currentTime - lastFireTime >= firingDelay then
        fireRPGClick()
        lastFireTime = currentTime
    elseif javelinClickEnabled and currentTime - lastFireTime >= javelinClickDelay then
        fireJavelinClick()
        lastFireTime = currentTime
    elseif stingerClickEnabled and currentTime - lastFireTime >= stingerClickDelay then
        fireStingerClick()
        lastFireTime = currentTime
    end
end)

-- ЦИКЛ СТРЕЛЬБЫ ДЛЯ QUAD SHOT
RunService.RenderStepped:Connect(function()
    if not quadShotEnabled or not isFiring then return end
    
    local currentTime = os.clock()
    
    if currentTime - lastFireTime >= quadShotSpamRate then
        fireQuadShot()
        lastFireTime = currentTime
    end
end)

-- ЦИКЛ ДЛЯ TARGET
RunService.Heartbeat:Connect(function()
    if not targetEnabled then return end
    
    local tool = findWeaponInInventory("RPG")
    if not tool then
        updateStatus("РПГ не найден для таргета!", Color3.fromRGB(255, 100, 100))
        return
    end

    local targets = getTargets()
    for _, w in pairs(targets) do
        local pos = w.Character.HumanoidRootPart.Position + Vector3.new(0, 2.5, 0)
        local dir = (pos - hrp.Position).Unit
        fx:FireServer(tool, true)
        fire:InvokeServer(dir, tool, tool, pos)
        local uniqueId = plr.Name.."_RPG_"..tostring(os.clock() * 1000)
        hit:FireServer(pos, dir, tool, tool, w.Character.HumanoidRootPart, nil, uniqueId)
        rocketCount = rocketCount + 1
        updateRocketCounter()
        task.wait(0.001)
    end
end)

-- ОБРАБОТЧИКИ КНОПОК
-- Переключение вкладок
CombatTabButton.MouseButton1Click:Connect(function()
    CombatTabFrame.Visible = true
    RPGTabFrame.Visible = false
    QuadShotTabFrame.Visible = false
    SwastikaTabFrame.Visible = false
    DebugTabFrame.Visible = false
    TargetTabFrame.Visible = false
    
    CombatTabButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    CombatTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CombatTabButton.Font = Enum.Font.GothamBold
    
    RPGTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    RPGTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    RPGTabButton.Font = Enum.Font.Gotham
    
    QuadShotTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    QuadShotTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    QuadShotTabButton.Font = Enum.Font.Gotham
    
    SwastikaTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SwastikaTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    SwastikaTabButton.Font = Enum.Font.Gotham
    
    DebugTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    DebugTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    DebugTabButton.Font = Enum.Font.Gotham

    TargetTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    TargetTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TargetTabButton.Font = Enum.Font.Gotham
end)

RPGTabButton.MouseButton1Click:Connect(function()
    CombatTabFrame.Visible = false
    RPGTabFrame.Visible = true
    QuadShotTabFrame.Visible = false
    SwastikaTabFrame.Visible = false
    DebugTabFrame.Visible = false
    TargetTabFrame.Visible = false
    
    CombatTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    CombatTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    CombatTabButton.Font = Enum.Font.Gotham
    
    RPGTabButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    RPGTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RPGTabButton.Font = Enum.Font.GothamBold
    
    QuadShotTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    QuadShotTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    QuadShotTabButton.Font = Enum.Font.Gotham
    
    SwastikaTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SwastikaTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    SwastikaTabButton.Font = Enum.Font.Gotham
    
    DebugTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    DebugTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    DebugTabButton.Font = Enum.Font.Gotham

    TargetTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    TargetTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TargetTabButton.Font = Enum.Font.Gotham
end)

QuadShotTabButton.MouseButton1Click:Connect(function()
    CombatTabFrame.Visible = false
    RPGTabFrame.Visible = false
    QuadShotTabFrame.Visible = true
    SwastikaTabFrame.Visible = false
    DebugTabFrame.Visible = false
    TargetTabFrame.Visible = false
    
    CombatTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    CombatTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    CombatTabButton.Font = Enum.Font.Gotham
    
    RPGTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    RPGTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    RPGTabButton.Font = Enum.Font.Gotham
    
    QuadShotTabButton.BackgroundColor3 = Color3.fromRGB(220, 120, 50)
    QuadShotTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    QuadShotTabButton.Font = Enum.Font.GothamBold
    
    SwastikaTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SwastikaTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    SwastikaTabButton.Font = Enum.Font.Gotham
    
    DebugTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    DebugTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    DebugTabButton.Font = Enum.Font.Gotham

    TargetTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    TargetTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TargetTabButton.Font = Enum.Font.Gotham
end)

SwastikaTabButton.MouseButton1Click:Connect(function()
    CombatTabFrame.Visible = false
    RPGTabFrame.Visible = false
    QuadShotTabFrame.Visible = false
    SwastikaTabFrame.Visible = true
    DebugTabFrame.Visible = false
    TargetTabFrame.Visible = false
    
    CombatTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    CombatTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    CombatTabButton.Font = Enum.Font.Gotham
    
    RPGTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    RPGTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    RPGTabButton.Font = Enum.Font.Gotham
    
    QuadShotTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    QuadShotTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    QuadShotTabButton.Font = Enum.Font.Gotham
    
    SwastikaTabButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    SwastikaTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SwastikaTabButton.Font = Enum.Font.GothamBold
    
    DebugTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    DebugTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    DebugTabButton.Font = Enum.Font.Gotham

    TargetTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    TargetTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TargetTabButton.Font = Enum.Font.Gotham
end)

DebugTabButton.MouseButton1Click:Connect(function()
    CombatTabFrame.Visible = false
    RPGTabFrame.Visible = false
    QuadShotTabFrame.Visible = false
    SwastikaTabFrame.Visible = false
    DebugTabFrame.Visible = true
    TargetTabFrame.Visible = false
    
    CombatTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    CombatTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    CombatTabButton.Font = Enum.Font.Gotham
    
    RPGTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    RPGTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    RPGTabButton.Font = Enum.Font.Gotham
    
    QuadShotTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    QuadShotTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    QuadShotTabButton.Font = Enum.Font.Gotham
    
    SwastikaTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SwastikaTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    SwastikaTabButton.Font = Enum.Font.Gotham
    
    DebugTabButton.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
    DebugTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DebugTabButton.Font = Enum.Font.GothamBold

    TargetTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    TargetTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TargetTabButton.Font = Enum.Font.Gotham
end)

TargetTabButton.MouseButton1Click:Connect(function()
    CombatTabFrame.Visible = false
    RPGTabFrame.Visible = false
    QuadShotTabFrame.Visible = false
    SwastikaTabFrame.Visible = false
    DebugTabFrame.Visible = false
    TargetTabFrame.Visible = true
    
    CombatTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    CombatTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    CombatTabButton.Font = Enum.Font.Gotham
    
    RPGTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    RPGTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    RPGTabButton.Font = Enum.Font.Gotham
    
    QuadShotTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    QuadShotTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    QuadShotTabButton.Font = Enum.Font.Gotham
    
    SwastikaTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SwastikaTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    SwastikaTabButton.Font = Enum.Font.Gotham
    
    DebugTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    DebugTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    DebugTabButton.Font = Enum.Font.Gotham

    TargetTabButton.BackgroundColor3 = Color3.fromRGB(150, 150, 50)
    TargetTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TargetTabButton.Font = Enum.Font.GothamBold
end)

-- Кнопка закрытия
CloseButton.MouseButton1Click:Connect(function()
    guiEnabled = not guiEnabled
    MainFrame.Visible = guiEnabled
    
    if guiEnabled then
        updateStatus("GUI включен", Color3.fromRGB(100, 255, 100))
    else
        updateStatus("GUI выключен (ПКМ чтобы вернуть)", Color3.fromRGB(255, 100, 100))
    end
end)

-- Кнопка Джевелин Клик
javelinToggleButton.MouseButton1Click:Connect(function()
    javelinClickEnabled = not javelinClickEnabled
    rpgClickEnabled = false
    quadShotEnabled = false
    swastikaEnabled = false
    targetEnabled = false
    stingerClickEnabled = false
    
    if javelinClickEnabled then
        javelinToggleButton.Text = "✅ ДЖЕВЕЛИН КЛИК АКТИВЕН"
        updateStatus("Джевелин Клик включен! Зажми ЛКМ", Color3.fromRGB(100, 180, 255))
    else
        javelinToggleButton.Text = "🎯 ВКЛЮЧИТЬ ДЖЕВЕЛИН КЛИК"
        updateStatus("Джевелин Клик выключен", Color3.fromRGB(200, 200, 200))
    end
    rpgToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    rpgCombatToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    quadToggleButton.Text = "🔥 ВКЛЮЧИТЬ QUAD SHOT"
    swastikaToggleButton.Text = "卐 ВКЛЮЧИТЬ СВАСТИКУ"
    targetToggleButton.Text = "🎯 ВКЛЮЧИТЬ TARGET"
    stingerToggleButton.Text = "⚡ ВКЛЮЧИТЬ СТИНГЕР КЛИК"
end)

-- Кнопка Стингер Клик
stingerToggleButton.MouseButton1Click:Connect(function()
    stingerClickEnabled = not stingerClickEnabled
    rpgClickEnabled = false
    quadShotEnabled = false
    swastikaEnabled = false
    targetEnabled = false
    javelinClickEnabled = false
    
    if stingerClickEnabled then
        stingerToggleButton.Text = "✅ СТИНГЕР КЛИК АКТИВЕН"
        updateStatus("Стингер Клик включен! Зажми ЛКМ", Color3.fromRGB(100, 255, 150))
    else
        stingerToggleButton.Text = "⚡ ВКЛЮЧИТЬ СТИНГЕР КЛИК"
        updateStatus("Стингер Клик выключен", Color3.fromRGB(200, 200, 200))
    end
    rpgToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    rpgCombatToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    quadToggleButton.Text = "🔥 ВКЛЮЧИТЬ QUAD SHOT"
    swastikaToggleButton.Text = "卐 ВКЛЮЧИТЬ СВАСТИКУ"
    targetToggleButton.Text = "🎯 ВКЛЮЧИТЬ TARGET"
    javelinToggleButton.Text = "🎯 ВКЛЮЧИТЬ ДЖЕВЕЛИН КЛИК"
end)

-- Кнопка RPG Click в Combat
rpgCombatToggleButton.MouseButton1Click:Connect(function()
    rpgClickEnabled = not rpgClickEnabled
    quadShotEnabled = false
    swastikaEnabled = false
    targetEnabled = false
    javelinClickEnabled = false
    stingerClickEnabled = false
    
    if rpgClickEnabled then
        rpgCombatToggleButton.Text = "✅ RPG CLICK АКТИВЕН"
        updateStatus("RPG Click включен! Зажми ЛКМ", Color3.fromRGB(100, 255, 100))
    else
        rpgCombatToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
        updateStatus("RPG Click выключен", Color3.fromRGB(200, 200, 200))
    end
    rpgToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    quadToggleButton.Text = "🔥 ВКЛЮЧИТЬ QUAD SHOT"
    swastikaToggleButton.Text = "卐 ВКЛЮЧИТЬ СВАСТИКУ"
    targetToggleButton.Text = "🎯 ВКЛЮЧИТЬ TARGET"
    javelinToggleButton.Text = "🎯 ВКЛЮЧИТЬ ДЖЕВЕЛИН КЛИК"
    stingerToggleButton.Text = "⚡ ВКЛЮЧИТЬ СТИНГЕР КЛИК"
end)

-- Кнопка RPG Click
rpgToggleButton.MouseButton1Click:Connect(function()
    rpgClickEnabled = not rpgClickEnabled
    quadShotEnabled = false
    swastikaEnabled = false
    targetEnabled = false
    javelinClickEnabled = false
    stingerClickEnabled = false
    
    if rpgClickEnabled then
        rpgToggleButton.Text = "✅ RPG CLICK АКТИВЕН"
        updateStatus("RPG Click включен! Зажми ЛКМ", Color3.fromRGB(100, 255, 100))
    else
        rpgToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
        updateStatus("RPG Click выключен", Color3.fromRGB(200, 200, 200))
    end
    rpgCombatToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    quadToggleButton.Text = "🔥 ВКЛЮЧИТЬ QUAD SHOT"
    swastikaToggleButton.Text = "卐 ВКЛЮЧИТЬ СВАСТИКУ"
    targetToggleButton.Text = "🎯 ВКЛЮЧИТЬ TARGET"
    javelinToggleButton.Text = "🎯 ВКЛЮЧИТЬ ДЖЕВЕЛИН КЛИК"
    stingerToggleButton.Text = "⚡ ВКЛЮЧИТЬ СТИНГЕР КЛИК"
end)

-- Кнопка Single Shot
singleToggleButton.MouseButton1Click:Connect(function()
    singleShotEnabled = not singleShotEnabled
    rpgClickEnabled = false
    quadShotEnabled = false
    swastikaEnabled = false
    targetEnabled = false
    javelinClickEnabled = false
    stingerClickEnabled = false
    
    if singleShotEnabled then
        singleToggleButton.Text = "✅ SINGLE SHOT АКТИВЕН"
        updateStatus("Single Shot включен! Нажми ЛКМ", Color3.fromRGB(100, 255, 100))
    else
        singleToggleButton.Text = "🔫 ВКЛЮЧИТЬ SINGLE SHOT"
        updateStatus("Single Shot выключен", Color3.fromRGB(200, 200, 200))
    end
    rpgToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    rpgCombatToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    quadToggleButton.Text = "🔥 ВКЛЮЧИТЬ QUAD SHOT"
    swastikaToggleButton.Text = "卐 ВКЛЮЧИТЬ СВАСТИКУ"
    targetToggleButton.Text = "🎯 ВКЛЮЧИТЬ TARGET"
    javelinToggleButton.Text = "🎯 ВКЛЮЧИТЬ ДЖЕВЕЛИН КЛИК"
    stingerToggleButton.Text = "⚡ ВКЛЮЧИТЬ СТИНГЕР КЛИК"
end)

-- Кнопка Quad Shot
quadToggleButton.MouseButton1Click:Connect(function()
    quadShotEnabled = not quadShotEnabled
    rpgClickEnabled = false
    singleShotEnabled = false
    swastikaEnabled = false
    targetEnabled = false
    javelinClickEnabled = false
    stingerClickEnabled = false
    
    if quadShotEnabled then
        quadToggleButton.Text = "✅ QUAD SHOT АКТИВЕН"
        updateStatus("Quad Shot включен! Зажми ЛКМ для спама", Color3.fromRGB(255, 150, 50))
    else
        quadToggleButton.Text = "🔥 ВКЛЮЧИТЬ QUAD SHOT"
        updateStatus("Quad Shot выключен", Color3.fromRGB(200, 200, 200))
    end
    rpgToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    rpgCombatToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    singleToggleButton.Text = "🔫 ВКЛЮЧИТЬ SINGLE SHOT"
    swastikaToggleButton.Text = "卐 ВКЛЮЧИТЬ СВАСТИКУ"
    targetToggleButton.Text = "🎯 ВКЛЮЧИТЬ TARGET"
    javelinToggleButton.Text = "🎯 ВКЛЮЧИТЬ ДЖЕВЕЛИН КЛИК"
    stingerToggleButton.Text = "⚡ ВКЛЮЧИТЬ СТИНГЕР КЛИК"
end)

-- Кнопка Swastika
swastikaToggleButton.MouseButton1Click:Connect(function()
    swastikaEnabled = not swastikaEnabled
    rpgClickEnabled = false
    singleShotEnabled = false
    quadShotEnabled = false
    targetEnabled = false
    javelinClickEnabled = false
    stingerClickEnabled = false
    
    if swastikaEnabled then
        swastikaToggleButton.Text = "✅ СВАСТИКА АКТИВНА"
        updateStatus("Свастика включена! Нажми ЛКМ", Color3.fromRGB(100, 255, 100))
    else
        swastikaToggleButton.Text = "卐 ВКЛЮЧИТЬ СВАСТИКУ"
        updateStatus("Свастика выключена", Color3.fromRGB(200, 200, 200))
    end
    rpgToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    rpgCombatToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    singleToggleButton.Text = "🔫 ВКЛЮЧИТЬ SINGLE SHOT"
    quadToggleButton.Text = "🔥 ВКЛЮЧИТЬ QUAD SHOT"
    targetToggleButton.Text = "🎯 ВКЛЮЧИТЬ TARGET"
    javelinToggleButton.Text = "🎯 ВКЛЮЧИТЬ ДЖЕВЕЛИН КЛИК"
    stingerToggleButton.Text = "⚡ ВКЛЮЧИТЬ СТИНГЕР КЛИК"
end)

-- Кнопка Target
targetToggleButton.MouseButton1Click:Connect(function()
    targetEnabled = not targetEnabled
    rpgClickEnabled = false
    singleShotEnabled = false
    quadShotEnabled = false
    swastikaEnabled = false
    javelinClickEnabled = false
    stingerClickEnabled = false
    
    if targetEnabled then
        targetToggleButton.Text = "✅ TARGET АКТИВЕН"
        updateStatus("Target включен! Автострельба по игрокам", Color3.fromRGB(100, 255, 100))
    else
        targetToggleButton.Text = "🎯 ВКЛЮЧИТЬ TARGET"
        updateStatus("Target выключен", Color3.fromRGB(200, 200, 200))
    end
    rpgToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    rpgCombatToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    singleToggleButton.Text = "🔫 ВКЛЮЧИТЬ SINGLE SHOT"
    quadToggleButton.Text = "🔥 ВКЛЮЧИТЬ QUAD SHOT"
    swastikaToggleButton.Text = "卐 ВКЛЮЧИТЬ СВАСТИКУ"
    javelinToggleButton.Text = "🎯 ВКЛЮЧИТЬ ДЖЕВЕЛИН КЛИК"
    stingerToggleButton.Text = "⚡ ВКЛЮЧИТЬ СТИНГЕР КЛИК"
end)

-- Слайдер скорости Джевелин
javelinSpeedSliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = javelinSpeedSliderFrame.AbsolutePosition.X
            local sliderSize = javelinSpeedSliderFrame.AbsoluteSize.X
            
            local relativeX = math.clamp(mousePos.X - sliderPos, 0, sliderSize)
            local percentage = relativeX / sliderSize
            
            javelinSpeedFill.Size = UDim2.new(percentage, 0, 1, 0)
            
            -- Диапазон: 0.001 (1000 выстр/сек) до 0.1 (10 выстр/сек)
            local minDelay = 0.001
            local maxDelay = 0.1
            javelinClickDelay = maxDelay - (percentage * (maxDelay - minDelay))
            
            local shotsPerSecond = math.floor(1/javelinClickDelay)
            javelinSpeedText.Text = "Скорость: ~"..shotsPerSecond.." выстр/сек"
        end)
        
        UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end
end)

-- Слайдер скорости
speedSliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = speedSliderFrame.AbsolutePosition.X
            local sliderSize = speedSliderFrame.AbsoluteSize.X
            
            local relativeX = math.clamp(mousePos.X - sliderPos, 0, sliderSize)
            local percentage = relativeX / sliderSize
            
            speedFill.Size = UDim2.new(percentage, 0, 1, 0)
            
            -- Диапазон: 0.001 (1000 выстр/сек) до 0.1 (10 выстр/сек)
            local minDelay = 0.001
            local maxDelay = 0.1
            firingDelay = maxDelay - (percentage * (maxDelay - minDelay))
            
            local shotsPerSecond = math.floor(1/firingDelay)
            speedText.Text = "Скорость: ~"..shotsPerSecond.." выстр/сек"
        end)
        
        UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end
end)

-- Слайдер дистанции для Quad Shot
quadDistanceSliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = quadDistanceSliderFrame.AbsolutePosition.X
            local sliderSize = quadDistanceSliderFrame.AbsoluteSize.X
            
            local relativeX = math.clamp(mousePos.X - sliderPos, 0, sliderSize)
            local percentage = relativeX / sliderSize
            
            quadDistanceFill.Size = UDim2.new(percentage, 0, 1, 0)
            
            -- Диапазон: от 5 до 20 метров
            local minDist = 5
            local maxDist = 20
            quadDistance = math.floor(minDist + (percentage * (maxDist - minDist)))
            quadDistanceText.Text = "Дистанция: " .. quadDistance .. " м"
        end)
        
        UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end
end)

-- Слайдер скорости для Quad Shot
quadSpeedSliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = quadSpeedSliderFrame.AbsolutePosition.X
            local sliderSize = quadSpeedSliderFrame.AbsoluteSize.X
            
            local relativeX = math.clamp(mousePos.X - sliderPos, 0, sliderSize)
            local percentage = relativeX / sliderSize
            
            quadSpeedFill.Size = UDim2.new(percentage, 0, 1, 0)
            
            -- Диапазон: от 0.001 до 0.1 секунды
            local minSpeed = 0.001
            local maxSpeed = 0.1
            quadShotSpamRate = minSpeed + (percentage * (maxSpeed - minSpeed))
            quadSpeedText.Text = "Скорость: " .. string.format("%.3f", quadShotSpamRate) .. " сек"
        end)
        
        UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end
end)

-- Слайдер размера свастики
sizeSliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sizeSliderFrame.AbsolutePosition.X
            local sliderSize = sizeSliderFrame.AbsoluteSize.X
            
            local relativeX = math.clamp(mousePos.X - sliderPos, 0, sliderSize)
            local percentage = relativeX / sliderSize
            
            sizeFill.Size = UDim2.new(percentage, 0, 1, 0)
            
            swastikaSize = math.floor(percentage * 15) + 5
            sizeText.Text = "Размер: " .. swastikaSize .. " точек"
            createSwastikaPoints()
        end)
        
        UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end
end)

-- Слайдер разброса свастики
spreadSliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = spreadSliderFrame.AbsolutePosition.X
            local sliderSize = spreadSliderFrame.AbsoluteSize.X
            
            local relativeX = math.clamp(mousePos.X - sliderPos, 0, sliderSize)
            local percentage = relativeX / sliderSize
            
            spreadFill.Size = UDim2.new(percentage, 0, 1, 0)
            
            horizontalSpread = math.floor(percentage * 19) + 1
            verticalSpread = horizontalSpread
            spreadText.Text = "Разброс: " .. string.format("%.1f", horizontalSpread)
        end)
        
        UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end
end)

-- Слайдер задержки для target
fireRateSliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = fireRateSliderFrame.AbsolutePosition.X
            local sliderSize = fireRateSliderFrame.AbsoluteSize.X
            
            local relativeX = math.clamp(mousePos.X - sliderPos, 0, sliderSize)
            local percentage = relativeX / sliderSize
            
            fireRateFill.Size = UDim2.new(percentage, 0, 1, 0)
            
            local minDelay = 0.001
            local maxDelay = 0.1
            fireRate = minDelay + (percentage * (maxDelay - minDelay))
            fireRateText.Text = "Задержка: " .. string.format("%.3f", fireRate) .. " сек"
        end)
        
        UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end
end)

-- Слайдер макс расстояния
maxDistSliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = maxDistSliderFrame.AbsolutePosition.X
            local sliderSize = maxDistSliderFrame.AbsoluteSize.X
            
            local relativeX = math.clamp(mousePos.X - sliderPos, 0, sliderSize)
            local percentage = relativeX / sliderSize
            
            maxDistFill.Size = UDim2.new(percentage, 0, 1, 0)
            
            local minDist = 100
            local maxDistVal = 5000
            maxDistance = math.floor(minDist + (percentage * (maxDistVal - minDist)))
            maxDistText.Text = "Расстояние: " .. maxDistance
        end)
        
        UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end
end)

-- Whitelist refresh
local function refreshWhitelist()
    whitelistDropdown:ClearAllChildren()
    local y = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr then
            local btn = createButton(whitelistDropdown, p.Name, UDim2.new(0, 0, 0, y), UDim2.new(1, 0, 0, 30), Color3.fromRGB(70, 70, 80))
            if whitelist[p] then
                btn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
            end
            btn.MouseButton1Click:Connect(function()
                whitelist[p] = not whitelist[p]
                btn.BackgroundColor3 = whitelist[p] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(70, 70, 80)
            end)
            y = y + 35
        end
    end
    whitelistDropdown.CanvasSize = UDim2.new(0, 0, 0, y)
end

refreshWhitelist()
Players.PlayerAdded:Connect(refreshWhitelist)
Players.PlayerRemoving:Connect(function(p)
    whitelist[p] = nil
    refreshWhitelist()
end)

-- Кнопки Debug
debugCheckButton.MouseButton1Click:Connect(function()
    local rpgFound = findWeaponInInventory("RPG") ~= nil
    local javelinFound = findWeaponInInventory("Javelin") ~= nil
    local stingerFound = findWeaponInInventory("Stinger") ~= nil
    
    debugStatusLabel.Text = "Статус: " .. (rpgFound and "✅ РПГ НАЙДЕН" or "❌ РПГ НЕ НАЙДЕН")
    debugStatusLabel.TextColor3 = rpgFound and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    
    local info = "Информация:\n"
    info = info .. "• RemoteEvents: ✅ Найдены\n"
    info = info .. "• РПГ в инвентаре: " .. (rpgFound and "✅ Да" or "❌ Нет") .. "\n"
    info = info .. "• Джевелин в инвентаре: " .. (javelinFound and "✅ Да" or "❌ Нет") .. "\n"
    info = info .. "• Стингер в инвентаре: " .. (stingerFound and "✅ Да" or "❌ Нет") .. "\n"
    info = info .. "• Свастика: " .. totalSwastikaPoints .. " точек\n"
    info = info .. "• Quad Shot: 4 выстрела, " .. quadDistance .. "м дистанция\n"
    info = info .. "• Скорость RPG: ~" .. math.floor(1/firingDelay) .. " выстр/сек"
    
    debugInfoLabel.Text = info
    updateStatus("Система проверена", Color3.fromRGB(100, 255, 100))
end)

debugReloadButton.MouseButton1Click:Connect(function()
    rpgClickEnabled = false
    singleShotEnabled = false
    quadShotEnabled = false
    swastikaEnabled = false
    targetEnabled = false
    javelinClickEnabled = false
    stingerClickEnabled = false
    isFiring = false
    rocketCount = 0
    
    rpgToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    rpgCombatToggleButton.Text = "🚀 ВКЛЮЧИТЬ RPG CLICK"
    singleToggleButton.Text = "🔫 ВКЛЮЧИТЬ SINGLE SHOT"
    quadToggleButton.Text = "🔥 ВКЛЮЧИТЬ QUAD SHOT"
    swastikaToggleButton.Text = "卐 ВКЛЮЧИТЬ СВАСТИКУ"
    targetToggleButton.Text = "🎯 ВКЛЮЧИТЬ TARGET"
    javelinToggleButton.Text = "🎯 ВКЛЮЧИТЬ ДЖЕВЕЛИН КЛИК"
    stingerToggleButton.Text = "⚡ ВКЛЮЧИТЬ СТИНГЕР КЛИК"
    
    updateRocketCounter()
    updateStatus("Скрипт перезагружен", Color3.fromRGB(100, 255, 100))
    
    debugStatusLabel.Text = "Статус: Не проверено"
    debugStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    debugInfoLabel.Text = ""
end)

-- Кнопка ломания баз
breakBasesButton.MouseButton1Click:Connect(function()
    breakAllBases()
end)

-- ПКМ - показать/скрыть GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            updateStatus("GUI показан", Color3.fromRGB(100, 255, 100))
        end
    end
end)

-- ПРИЦЕЛ
local crosshairGui = Instance.new("ScreenGui")
crosshairGui.Name = "RPGCursor"
crosshairGui.Parent = plr:WaitForChild("PlayerGui")
crosshairGui.ResetOnSpawn = false
crosshairGui.Enabled = false

local centerDot = Instance.new("Frame")
centerDot.Size = UDim2.new(0, 8, 0, 8)
centerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
centerDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
centerDot.BorderSizePixel = 0
centerDot.ZIndex = 999
centerDot.Parent = crosshairGui

local centerCorner = Instance.new("UICorner")
centerCorner.CornerRadius = UDim.new(1, 0)
centerCorner.Parent = centerDot

-- Обновление прицела
RunService.RenderStepped:Connect(function()
    crosshairGui.Enabled = rpgClickEnabled or singleShotEnabled or quadShotEnabled or swastikaEnabled or targetEnabled or javelinClickEnabled or stingerClickEnabled
    
    if crosshairGui.Enabled then
        if rpgClickEnabled then
            centerDot.BackgroundColor3 = Color3.fromRGB(80, 140, 220)
        elseif singleShotEnabled then
            centerDot.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        elseif quadShotEnabled then
            centerDot.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
        elseif swastikaEnabled then
            centerDot.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
        elseif targetEnabled then
            centerDot.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        elseif javelinClickEnabled then
            centerDot.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
        elseif stingerClickEnabled then
            centerDot.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
        end
    end
end)

-- Начальная настройка
updateStatus("RPG SYSTEM готов к работе", Color3.fromRGB(100, 255, 100))

-- Сделаем окно перетаскиваемым
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Информация о загрузке
warn("========================================")
warn("🔥 RPG SYSTEM ЗАГРУЖЕН 🔥")
warn("========================================")
warn("🎯 Combat Tab: Джевелин Клик и Стингер Клик")
warn("🚀 RPG Click: Автострельба при зажатии ЛКМ")
warn("🔥 Quad Shot: 4 выстрела в квадрате 10x10 метров")
warn("⚡ Single Shot: Одиночный выстрел на ЛКМ")
warn("⚡ Swastika: Нажми ЛКМ для выстрела свастикой")
warn("🎯 Target: Автострельба по игрокам")
warn("⚡ Ломать базы: Кнопка в Debug")
warn("⚡ ПКМ - показать/скрыть меню")
warn("========================================")

print("✅ RPG SYSTEM загружен!")
print("🎯 Добавлен Combat Tab с Джевелин и Стингер Кликом!")
print("📁 GUI создан. Нажмите ПКМ чтобы показать меню.")
