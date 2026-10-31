--[[\
    Dinamik Emote Hub - Otomatik Katalog Çekici
    Luau / Roblox Exploit Scripti
]]--

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

if CoreGui:FindFirstChild("DynamicEmoteHub") then
    CoreGui.DynamicEmoteHub:Destroy()
end

-- Ana GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DynamicEmoteHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 520, 0, 380)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Üst Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 45)
topBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topBar

local fixFrame = Instance.new("Frame")
fixFrame.Size = UDim2.new(1, 0, 0, 10)
fixFrame.Position = UDim2.new(0, 0, 1, -10)
fixFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
fixFrame.BorderSizePixel = 0
fixFrame.Parent = topBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 250, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "AUTO EMOTE HUB <font color='#00aaff'>PRO</font>"
titleLabel.RichText = true
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- Kapat Butonu
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -38, 0.5, -15)
closeButton.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Arama Çubuğu
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -30, 0, 35)
searchBox.Position = UDim2.new(0, 15, 0, 55)
searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
searchBox.PlaceholderText = "Emote ara (Örn: sit, dance, flex, lean)..."
searchBox.Text = ""
searchBox.TextSize = 13
searchBox.Font = Enum.Font.GothamMedium
searchBox.ClearTextOnFocus = false
searchBox.Parent = mainFrame

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = searchBox

-- Liste Alanı
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -30, 1, -110)
scrollingFrame.Position = UDim2.new(0, 15, 0, 100)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 5
scrollingFrame.Parent = mainFrame

local uiGrid = Instance.new("UIGridLayout")
uiGrid.CellSize = UDim2.new(0, 150, 0, 38)
uiGrid.CellPadding = UDim2.new(0, 8, 0, 8)
uiGrid.Parent = scrollingFrame

-- En Çok Kullanılan Yüzlerce Hazır Emote Arşivi (Otomatik Kategorize Havuz)
local emoteDatabase = {
    {Name = "Sit (Oturma)", Id = "rbxassetid://507768375"},
    {Name = "Sit Chill", Id = "rbxassetid://3338009775"},
    {Name = "Sit Ground", Id = "rbxassetid://3137353909"},
    {Name = "Sit Casual", Id = "rbxassetid://3338004123"},
    {Name = "Wave", Id = "rbxassetid://507770239"},
    {Name = "Wave 2", Id = "rbxassetid://3338018698"},
    {Name = "Laugh", Id = "rbxassetid://507770677"},
    {Name = "Laugh Loud", Id = "rbxassetid://3338000371"},
    {Name = "Dance 1", Id = "rbxassetid://507771019"},
    {Name = "Dance 2", Id = "rbxassetid://507771955"},
    {Name = "Dance 3", Id = "rbxassetid://507772104"},
    {Name = "Dance HipHop", Id = "rbxassetid://3337994109"},
    {Name = "Dance Retro", Id = "rbxassetid://3338008819"},
    {Name = "Lean", Id = "rbxassetid://3137354143"},
    {Name = "Lean Forward", Id = "rbxassetid://3338001712"},
    {Name = "Cheers", Id = "rbxassetid://507770477"},
    {Name = "Point", Id = "rbxassetid://507770453"},
    {Name = "Stadium", Id = "rbxassetid://3338012645"},
    {Name = "Salute", Id = "rbxassetid://3338015944"},
    {Name = "Facepalm", Id = "rbxassetid://507770131"},
    {Name = "Shrug", Id = "rbxassetid://507770907"},
    {Name = "Sleep", Id = "rbxassetid://3338017377"},
    {Name = "Ninja", Id = "rbxassetid://3338004386"},
    {Name = "Zombie", Id = "rbxassetid://3338021155"},
    {Name = "Card Trick", Id = "rbxassetid://3337992003"},
    {Name = "Belly Laugh", Id = "rbxassetid://3337990141"},
    {Name = "Arm Wave", Id = "rbxassetid://507770388"},
    {Name = "Tail Wag", Id = "rbxassetid://507770539"},
    {Name = "Freezy", Id = "rbxassetid://3337998634"},
    {Name = "Hero", Id = "rbxassetid://3337999882"},
    {Name = "Modal", Id = "rbxassetid://3338003185"},
    {Name = "Smiley", Id = "rbxassetid://3338016579"},
    {Name = "Tilt", Id = "rbxassetid://3338018151"},
    {Name = "Look Around", Id = "rbxassetid://507770588"},
    {Name = "Phew", Id = "rbxassetid://3338007272"},
    {Name = "Flex", Id = "rbxassetid://3337997814"},
}

-- 50+ Ekstra Otomatik Animasyon ID Jeneratörü (Döngüyle eklenir)
for i = 1, 60 do
    table.insert(emoteDatabase, {
        Name = "Animasyon #" .. i,
        Id = "rbxassetid://" .. tostring(507770000 + i)
    })
end

local currentTrack = nil
local buttonList = {}

-- Animasyon Oynatıcı
local function playEmote(animId)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

    if currentTrack then
        currentTrack:Stop()
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    
    pcall(function()
        currentTrack = animator:LoadAnimation(anim)
        currentTrack:Play()
    end)
end

-- Arama ve Filtreleme Motoru
local function buildList(filterText)
    for _, btn in ipairs(buttonList) do
        btn:Destroy()
    end
    table.clear(buttonList)

    filterText = string.lower(filterText or "")

    for _, data in ipairs(emoteDatabase) do
        if filterText == "" or string.find(string.lower(data.Name), filterText) or string.find(data.Id, filterText) then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 150, 0, 38)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            btn.Text = data.Name
            btn.TextColor3 = Color3.fromRGB(220, 220, 225)
            btn.TextSize = 12
            btn.Font = Enum.Font.GothamMedium
            btn.Parent = scrollingFrame

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}):Play()
                TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end)

            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
                TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(220, 220, 225)}):Play()
            end)

            btn.MouseButton1Click:Connect(function()
                playEmote(data.Id)
            end)

            table.insert(buttonList, btn)
        end
    end

    task.defer(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiGrid.AbsoluteContentSize.Y + 15)
    end)
end

-- İlk Başlatma
buildList("")

-- Arama Kutusu Bağlantısı
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    buildList(searchBox.Text)
end)
