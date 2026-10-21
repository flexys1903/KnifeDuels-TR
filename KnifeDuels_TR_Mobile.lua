-- Wait for the game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------
-- GAME VERIFICATION (KNIFE DUELS ONLY)
---------------------------------------------------------
local isKnifeDuels = false
local successInfo, info = pcall(function()
    return MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)
end)

if successInfo and info and string.find(string.lower(info.Name), "knife duels") then
    isKnifeDuels = true
end

if ReplicatedStorage:FindFirstChild("CombatService") or ReplicatedStorage:FindFirstChild("KnifeService") then
    isKnifeDuels = true
end

if not isKnifeDuels then
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Knife Duels Scripti",
            Text = "Çalıştırma durduruldu: Bu script yalnızca Knife Duels içindir.",
            Duration = 5
        })
    end)
    return 
end

---------------------------------------------------------
-- CONFIGURATION & PERSISTENCE ENGINE
---------------------------------------------------------
local ConfigFolder = "KnifeDuels"

local Config = {
    -- Combat
    Aimbot = false,      
    ShowFOV = false,
    FOVRadius = 120,
    Smoothing = 0.15,
    TargetPart = "Head", 
    WallCheck = false,
    TeamCheck = false,
    Keybind = Enum.KeyCode.E, 
    
    -- Visuals
    BoxESP = false,
    SkeletonESP = false,
    ChamsESP = false,
    NameESP = false,
    Tracers = false,
    Crosshair = false,
    CrosshairSize = 10,
    
    -- SkinChanger
    SelectedKnife = "Glass Karambit",
    SelectedSkin = "Ruby",

    -- Player
    Spinbot = false,
    SpinSpeed = 20,
    InfiniteJump = false,
    JumpPower = 50,

    -- System
    MenuKeybind = Enum.KeyCode.RightControl
}

-- Input & State Tracking
local isAimingKey = false

-- Sleek Modern Theme (Bej & Gri)
local Theme = {
    MainBG = Color3.fromRGB(43, 44, 45),
    Accent = Color3.fromRGB(202, 188, 160), -- Bej
    AccentGlow = Color3.fromRGB(230, 218, 194),
    TextWhite = Color3.fromRGB(242, 239, 232),
    TextDim = Color3.fromRGB(176, 171, 161),
    ToggleOff = Color3.fromRGB(57, 58, 58),
    ToggleHover = Color3.fromRGB(70, 69, 65),
    Border = Color3.fromRGB(100, 95, 84),
    BackgroundPattern = "rbxassetid://2151741365"
}

---------------------------------------------------------
-- NOTIFICATION & GUI BYPASS (SAFE VERSION)
---------------------------------------------------------
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Knife Duels Scripti",
        Text = "FlexysHub (Güvenli Sürüm) Yüklendi!",
        Duration = 3
    })
end)

local function generateRandomName() return HttpService:GenerateGUID(false):gsub("-", "") end
local function Tween(obj, props, time)
    if not obj then return end
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = generateRandomName()
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local guiSuccess, parent = false, nil
if type(gethui) == "function" then
    guiSuccess, parent = pcall(gethui)
end
if not guiSuccess or not parent then parent = CoreGui end
if not parent then parent = LocalPlayer:WaitForChild("PlayerGui") end
ScreenGui.Parent = parent

pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui)
    elseif ProtectInstance then ProtectInstance(ScreenGui) end
end)

---------------------------------------------------------
-- UNIVERSAL TEAM CHECK
---------------------------------------------------------
local function IsTeammate(player)
    if not Config.TeamCheck then return false end
    if player == LocalPlayer then return true end

    if LocalPlayer.Team ~= nil and player.Team ~= nil then
        if LocalPlayer.Team == player.Team then return true end
    end
    return false
end

---------------------------------------------------------
-- CUSTOM WATERMARK
---------------------------------------------------------
local Watermark = Instance.new("Frame")
Watermark.Parent = ScreenGui
Watermark.BackgroundColor3 = Theme.MainBG
Watermark.Position = UDim2.new(0, 15, 0, 15)
Watermark.Size = UDim2.new(0, 260, 0, 34)
Watermark.BorderSizePixel = 0
local WMCorner = Instance.new("UICorner")
WMCorner.CornerRadius = UDim.new(0, 6)
WMCorner.Parent = Watermark
local WMStroke = Instance.new("UIStroke")
WMStroke.Color = Theme.Accent
WMStroke.Thickness = 1.5
WMStroke.Transparency = 0.3
WMStroke.Parent = Watermark

local WMText = Instance.new("TextLabel")
WMText.Parent = Watermark
WMText.BackgroundTransparency = 1
WMText.Size = UDim2.new(1, 0, 1, 0)
WMText.Font = Enum.Font.GothamMedium
WMText.Text = " FlexysHub | Knife Duels (Güvenli)"
WMText.TextColor3 = Theme.TextWhite
WMText.TextSize = 12

local fpsCount, lastFpsTick = 0, tick()
RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    if tick() - lastFpsTick >= 1 then
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        WMText.Text = string.format(" FlexysHub | FPS: %d | Ping: %dms", fpsCount, ping)
        fpsCount = 0
        lastFpsTick = tick()
    end
end)

---------------------------------------------------------
-- UI BASED ESP UTILITIES 
---------------------------------------------------------
local function getESPFolder()
    local folder = ScreenGui:FindFirstChild("ESP_Layer")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "ESP_Layer"
        folder.Parent = ScreenGui
    end
    return folder
end

local function DrawLineGUI(parent, name, p1, p2, color, thickness)
    local frame = parent:FindFirstChild(name)
    if not frame then
        frame = Instance.new("Frame")
        frame.Name = name
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.BorderSizePixel = 0
        frame.Parent = parent
    end
    frame.BackgroundColor3 = color
    local distance = (p2 - p1).Magnitude
    frame.Size = UDim2.new(0, distance, 0, thickness)
    frame.Position = UDim2.new(0, (p1.X + p2.X) / 2, 0, (p1.Y + p2.Y) / 2)
    frame.Rotation = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
    frame.Visible = true
    return frame
end

local FOVFrame = Instance.new("Frame")
FOVFrame.Parent = ScreenGui
FOVFrame.BackgroundTransparency = 1
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Visible = false
local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame
local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Theme.Accent
FOVStroke.Thickness = 1.2
FOVStroke.Transparency = 0.3
FOVStroke.Parent = FOVFrame

local CrosshairLines = {
    Top = Instance.new("Frame"), Bottom = Instance.new("Frame"),
    Left = Instance.new("Frame"), Right = Instance.new("Frame")
}
for _, line in pairs(CrosshairLines) do
    line.Parent = ScreenGui
    line.BackgroundColor3 = Theme.Accent
    line.BorderSizePixel = 0
    line.Visible = false
    line.ZIndex = 100
end

local function updateCrosshair()
    if not Config.Crosshair then
        for _, line in pairs(CrosshairLines) do line.Visible = false end
        return
    end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local center = cam.ViewportSize / 2
    local size, gap, thick = Config.CrosshairSize, 3, 2

    CrosshairLines.Top.Size = UDim2.new(0, thick, 0, size)
    CrosshairLines.Top.Position = UDim2.new(0, center.X - (thick/2), 0, center.Y - gap - size)
    CrosshairLines.Bottom.Size = UDim2.new(0, thick, 0, size)
    CrosshairLines.Bottom.Position = UDim2.new(0, center.X - (thick/2), 0, center.Y + gap)
    CrosshairLines.Left.Size = UDim2.new(0, size, 0, thick)
    CrosshairLines.Left.Position = UDim2.new(0, center.X - gap - size, 0, center.Y - (thick/2))
    CrosshairLines.Right.Size = UDim2.new(0, size, 0, thick)
    CrosshairLines.Right.Position = UDim2.new(0, center.X + gap, 0, center.Y - (thick/2))

    for _, line in pairs(CrosshairLines) do line.Visible = true end
end

---------------------------------------------------------
-- REMASTERED TABBED UI CONSTRUCTION
---------------------------------------------------------
local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.BorderSizePixel = 0
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UserInputService.TouchEnabled and UDim2.new(0.92, 0, 0.75, 0) or UDim2.new(0, 470, 0, 450)
Main.Active = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.MainBG),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 36, 36))
})
MainGradient.Rotation = 45
MainGradient.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1.5
MainStroke.Parent = Main

local Topbar = Instance.new("Frame")
Topbar.Parent = Main
Topbar.BackgroundTransparency = 1
Topbar.BorderSizePixel = 0
Topbar.Size = UDim2.new(1, 0, 0, 50)

local Title = Instance.new("TextLabel")
Title.Parent = Topbar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Font = Enum.Font.GothamBlack
Title.Text = "FLEXYSHUB - KNIFE DUELS"
Title.TextColor3 = Theme.Accent
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Tab Navigation Bar
local TabBar = Instance.new("Frame")
TabBar.Parent = Main
TabBar.BackgroundTransparency = 1
TabBar.Position = UDim2.new(0, 15, 0, 50)
TabBar.Size = UDim2.new(1, -30, 0, 35)

local TabBarLayout = Instance.new("UIListLayout")
TabBarLayout.Parent = TabBar
TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabBarLayout.Padding = UDim.new(0, 6)

local TabSeparator = Instance.new("Frame")
TabSeparator.Parent = Main
TabSeparator.BackgroundColor3 = Theme.Border
TabSeparator.BorderSizePixel = 0
TabSeparator.Position = UDim2.new(0, 15, 0, 85)
TabSeparator.Size = UDim2.new(1, -30, 0, 2)

local ActiveTabLine = Instance.new("Frame")
ActiveTabLine.Parent = TabSeparator
ActiveTabLine.BackgroundColor3 = Theme.Accent
ActiveTabLine.BorderSizePixel = 0
ActiveTabLine.Size = UDim2.new(0.2, -6, 1, 0)
ActiveTabLine.Position = UDim2.new(0, 0, 0, 0)

local Pages = Instance.new("Frame")
Pages.Parent = Main
Pages.BackgroundTransparency = 1
Pages.Position = UDim2.new(0, 15, 0, 100)
Pages.Size = UDim2.new(1, -30, 1, -115)

---------------------------------------------------------
-- UI COMPONENT GENERATORS
---------------------------------------------------------
local TabsList = {}

local function CreateTab(name, isFirst)
    local btnFrame = Instance.new("Frame")
    btnFrame.Parent = TabBar
    btnFrame.BackgroundTransparency = 1
    btnFrame.Size = UDim2.new(0.2, -6, 1, 0)

    local btn = Instance.new("TextButton")
    btn.Parent = btnFrame
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.TextColor3 = isFirst and Theme.TextWhite or Theme.TextDim
    btn.TextSize = 11
    
    local page = Instance.new("ScrollingFrame")
    page.Parent = Pages
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = isFirst
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.BorderSizePixel = 0
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = page
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local uipad = Instance.new("UIPadding")
    uipad.Parent = page
    uipad.PaddingTop = UDim.new(0, 2)
    uipad.PaddingBottom = UDim.new(0, 5)
    uipad.PaddingLeft = UDim.new(0, 2)
    uipad.PaddingRight = UDim.new(0, 8)
    
    table.insert(TabsList, {btn = btn, page = page, frame = btnFrame})
    
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(TabsList) do
            t.page.Visible = (t.page == page)
            Tween(t.btn, {TextColor3 = (t.page == page) and Theme.TextWhite or Theme.TextDim})
            if t.page == page then
                Tween(ActiveTabLine, {Position = UDim2.new(0, t.frame.Position.X.Offset, 0, 0)}, 0.3)
            end
        end
    end)
    
    return page
end

local function CreateToggle(parent, text, configKey, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = Theme.ToggleOff
    frame.Size = UDim2.new(1, 0, 0, 44)
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(1, -65, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Config[configKey] and Theme.TextWhite or Theme.TextDim
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = frame
    toggleBtn.BackgroundColor3 = Config[configKey] and Theme.Accent or Color3.fromRGB(78, 77, 72)
    toggleBtn.Position = UDim2.new(1, -48, 0.5, -11)
    toggleBtn.Size = UDim2.new(0, 38, 0, 22)
    toggleBtn.Text = ""
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn

    local knob = Instance.new("Frame")
    knob.Parent = toggleBtn
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Position = Config[configKey] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.Size = UDim2.new(0, 18, 0, 18)
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local function toggle()
        Config[configKey] = not Config[configKey]
        local state = Config[configKey]
        Tween(toggleBtn, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(78, 77, 72)})
        Tween(knob, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
        Tween(label, {TextColor3 = state and Theme.TextWhite or Theme.TextDim})
        if callback then callback(state) end
    end

    toggleBtn.MouseButton1Click:Connect(toggle)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggle()
        end
    end)
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = Theme.ToggleOff
    btn.Size = UDim2.new(1, 0, 0, 44)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.TextColor3 = Theme.TextWhite
    btn.TextSize = 12
    btn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateSlider(parent, text, min, max, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = Theme.ToggleOff
    frame.Size = UDim2.new(1, 0, 0, 52)
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 6)
    label.Size = UDim2.new(1, -24, 0, 16)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Theme.TextDim
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel")
    valLabel.Parent = frame
    valLabel.BackgroundTransparency = 1
    valLabel.Position = UDim2.new(0, 12, 0, 6)
    valLabel.Size = UDim2.new(1, -24, 0, 16)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.Text = tostring(defaultVal)
    valLabel.TextColor3 = Theme.TextWhite
    valLabel.TextSize = 12
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("TextButton")
    track.Parent = frame
    track.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    track.Position = UDim2.new(0, 12, 0, 30)
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Text = ""
    track.AutoButtonColor = false
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Parent = track
    fill.BackgroundColor3 = Theme.Accent
    local pct = (defaultVal - min) / (max - min)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local dragging = false
    local function update(input)
        local pos = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local percent = pos / track.AbsoluteSize.X
        local value = math.floor(min + ((max - min) * percent) + 0.5)
        
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valLabel.Text = tostring(value)
        if callback then callback(value) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

---------------------------------------------------------
-- POPULATE TABBED UI
---------------------------------------------------------
local CombatTab = CreateTab("Savaş", true)
local VisualsTab = CreateTab("Görünüm", false)
local SkinsTab = CreateTab("Skinler", false)
local PlayerTab = CreateTab("Oyuncu", false)
local SettingsTab = CreateTab("Ayarlar", false)

-- [Combat Options]
CreateToggle(CombatTab, "Nişan yardımını aç", "Aimbot")
CreateSlider(CombatTab, "Nişan takip hızı", 1, 10, 2, function(val) Config.Smoothing = (val == 10) and 1.0 or (0.05 + ((val - 1) * 0.1)) end)
CreateToggle(CombatTab, "Takım kontrolü", "TeamCheck")
CreateToggle(CombatTab, "Duvar kontrolü", "WallCheck")

-- [Visual Options]
CreateToggle(VisualsTab, "Görüş dairesini göster", "ShowFOV")
CreateToggle(VisualsTab, "2D kutu ESP", "BoxESP")
CreateToggle(VisualsTab, "İskelet ESP", "SkeletonESP")
CreateToggle(VisualsTab, "Karakter vurgusu ESP", "ChamsESP")
CreateToggle(VisualsTab, "İsim ESP", "NameESP")
CreateToggle(VisualsTab, "İz çizgileri ESP", "Tracers")
CreateToggle(VisualsTab, "Özel nişangâh", "Crosshair")
CreateSlider(VisualsTab, "Nişangâh boyutu", 4, 30, 10, function(val) Config.CrosshairSize = val end)

-- [SkinChanger (Glass Karambit dahil)]
local knifeList = {
    "Glass Karambit", "Karambit", "Butterfly Knife", "M9 Bayonet", "Talon Knife", 
    "Bayonet", "Flip Knife", "Gut Knife", "Huntsman Knife", 
    "Falchion Knife", "Bowie Knife", "Shadow Daggers", "Navaja Knife", 
    "Stiletto Knife", "Ursus Knife", "Classic Knife", "Paracord Knife", 
    "Survival Knife", "Nomad Knife", "Skeleton Knife"
}

local skinList = {
    "Ruby", "Sapphire", "Emerald", "Black Pearl", 
    "Fade (100%)", "Case Hardened (Blue Gem)", "Lore", "Tiger Tooth", 
    "Doppler", "Gamma Doppler", "Damascus Steel", "Autotronic", 
    "Slaughter", "Freehand", "Boreal Forest", "Safari Mesh"
}

local function applySkinChanger()
    pcall(function()
        local char = LocalPlayer.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then
            tool.Name = Config.SelectedKnife .. " | " .. Config.SelectedSkin
            if tool:FindFirstChild("Handle") then
                for _, child in pairs(tool.Handle:GetChildren()) do
                    if child:IsA("SpecialMesh") or child:IsA("MeshPart") then
                        if Config.SelectedKnife == "Glass Karambit" then
                            child.Transparency = 0.4
                            child.Color = Color3.fromRGB(200, 230, 255)
                        else
                            child.Transparency = 0
                        end
                    end
                end
            end
        end
    end)
end

for _, knifeName in ipairs(knifeList) do
    CreateButton(SkinsTab, "Bıçak: " .. knifeName, function()
        Config.SelectedKnife = knifeName
        applySkinChanger()
        StarterGui:SetCore("SendNotification", {
            Title = "SkinChanger",
            Text = knifeName .. " aktif edildi!",
            Duration = 2
        })
    end)
end

for _, skinName in ipairs(skinList) do
    CreateButton(SkinsTab, "Kaplama: " .. skinName, function()
        Config.SelectedSkin = skinName
        applySkinChanger()
        StarterGui:SetCore("SendNotification", {
            Title = "SkinChanger",
            Text = skinName .. " uygulandı!",
            Duration = 2
        })
    end)
end

-- [Player Options]
CreateToggle(PlayerTab, "Spinbot", "Spinbot")
CreateSlider(PlayerTab, "Spinbot hızı", 1, 100, 20, function(val) Config.SpinSpeed = val end)
CreateToggle(PlayerTab, "Sonsuz zıplama", "InfiniteJump")
CreateSlider(PlayerTab, "Zıplama gücü", 50, 300, 50, function(val) Config.JumpPower = val end)

-- [Settings Options]
CreateButton(SettingsTab, "Scripti kapat", function() ScreenGui:Destroy() end)

---------------------------------------------------------
-- MENU TOGGLE BUTTON (KÜÇÜK YUVARLAK AÇ/KAPA DAİRESİ)
---------------------------------------------------------
local MenuToggleFrame = Instance.new("Frame")
MenuToggleFrame.Parent = ScreenGui
MenuToggleFrame.BackgroundColor3 = Theme.MainBG
MenuToggleFrame.Position = UDim2.new(0, 15, 0.5, -20)
MenuToggleFrame.Size = UDim2.new(0, 42, 0, 42)
MenuToggleFrame.Active = true

local MenuToggleCorner = Instance.new("UICorner")
MenuToggleCorner.CornerRadius = UDim.new(1, 0)
MenuToggleCorner.Parent = MenuToggleFrame
local MenuToggleStroke = Instance.new("UIStroke")
MenuToggleStroke.Color = Theme.Accent
MenuToggleStroke.Thickness = 2
MenuToggleStroke.Parent = MenuToggleFrame

local MenuToggleButton = Instance.new("TextButton")
MenuToggleButton.Parent = MenuToggleFrame
MenuToggleButton.BackgroundTransparency = 1
MenuToggleButton.Size = UDim2.new(1, 0, 1, 0)
MenuToggleButton.Font = Enum.Font.GothamBold
MenuToggleButton.Text = "FX"
MenuToggleButton.TextColor3 = Theme.Accent
MenuToggleButton.TextSize = 14

local isDraggingMenuToggle, hasMovedMenuToggle, dragStartMenuToggle, startPosMenuToggle
MenuToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingMenuToggle = true
        hasMovedMenuToggle = false
        dragStartMenuToggle = input.Position
        startPosMenuToggle = MenuToggleFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDraggingMenuToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartMenuToggle
        if delta.Magnitude > 5 then
            hasMovedMenuToggle = true
            MenuToggleFrame.Position = UDim2.new(startPosMenuToggle.X.Scale, startPosMenuToggle.X.Offset + delta.X, startPosMenuToggle.Y.Scale, startPosMenuToggle.Y.Offset + delta.Y)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if isDraggingMenuToggle and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        isDraggingMenuToggle = false
        if not hasMovedMenuToggle then
            Main.Visible = not Main.Visible
        end
    end
end)

---------------------------------------------------------
-- MOBILE AIM BUTTON (KİLİTLEME/NİŞAN DAİRESİ)
---------------------------------------------------------
local MobileAimFrame = Instance.new("Frame")
MobileAimFrame.Parent = ScreenGui
MobileAimFrame.BackgroundColor3 = Theme.MainBG
MobileAimFrame.Position = UDim2.new(0.8, -35, 0.6, -35)
MobileAimFrame.Size = UDim2.new(0, 70, 0, 70)
MobileAimFrame.Active = true

local MobileAimCorner = Instance.new("UICorner")
MobileAimCorner.CornerRadius = UDim.new(1, 0)
MobileAimCorner.Parent = MobileAimFrame
local MobileAimStroke = Instance.new("UIStroke")
MobileAimStroke.Color = Theme.Accent
MobileAimStroke.Thickness = 2
MobileAimStroke.Parent = MobileAimFrame

local MobileAimButton = Instance.new("TextButton")
MobileAimButton.Parent = MobileAimFrame
MobileAimButton.BackgroundTransparency = 1
MobileAimButton.Size = UDim2.new(1, 0, 1, 0)
MobileAimButton.Font = Enum.Font.GothamBold
MobileAimButton.Text = "NİŞAN"
MobileAimButton.TextColor3 = Theme.TextWhite
MobileAimButton.TextSize = 14

local isDraggingMobile, hasMovedMobile, dragStartAim, startPosAim
MobileAimButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingMobile = true
        hasMovedMobile = false
        dragStartAim = input.Position
        startPosAim = MobileAimFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDraggingMobile and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartAim
        if delta.Magnitude > 5 then
            hasMovedMobile = true
            MobileAimFrame.Position = UDim2.new(startPosAim.X.Scale, startPosAim.X.Offset + delta.X, startPosAim.Y.Scale, startPosAim.Y.Offset + delta.Y)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if isDraggingMobile and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        isDraggingMobile = false
        if not hasMovedMobile then
            isAimingKey = not isAimingKey
            Tween(MobileAimFrame, {BackgroundColor3 = isAimingKey and Theme.Accent or Theme.MainBG})
            MobileAimButton.TextColor3 = isAimingKey and Color3.fromRGB(40, 40, 40) or Theme.TextWhite
            MobileAimButton.Text = isAimingKey and "KİLİTLİ" or "NİŞAN"
        end
    end
end)

---------------------------------------------------------
-- WINDOW DRAGGING (PC & MOBILE)
---------------------------------------------------------
local draggingMain, dragStartMain, startPosMain
Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = true
        dragStartMain = input.Position
        startPosMain = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartMain
        Main.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = false
    end
end)

---------------------------------------------------------
-- CORE INPUT LOGIC
---------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

---------------------------------------------------------
-- THE MASTER LOOP: ESP & FOV ENGINE
---------------------------------------------------------
local function isPartVisible(targetPart, targetCharacter)
    local cam = Workspace.CurrentCamera
    if not cam then return false end
    local origin = cam.CFrame.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    local result = Workspace:Raycast(origin, targetPart.Position - origin, raycastParams)
    return (not result) or (result.Instance:IsDescendantOf(targetCharacter))
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        local cam = Workspace.CurrentCamera
        if not cam then return end

        local screenCenter = cam.ViewportSize / 2

        if FOVFrame then
            FOVFrame.Visible = Config.ShowFOV
            if Config.ShowFOV then
                FOVFrame.Size = UDim2.new(0, Config.FOVRadius * 2, 0, Config.FOVRadius * 2)
                FOVFrame.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
            end
        end

        local espFolder = getESPFolder()
        local closestTarget = nil
        local shortestDistance = Config.FOVRadius

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end

            local isFriendly = IsTeammate(player)
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            local hum = char and char:FindFirstChild("Humanoid")
            local isAlive = hum and hum.Health > 0
            
            local pName = tostring(player.UserId)

            if isAlive and root and head and not isFriendly then
                local rootPos, onScreen = cam:WorldToViewportPoint(root.Position)

                local targetPart = char:FindFirstChild(Config.TargetPart)
                if targetPart then
                    local screenPos, tOnScreen = cam:WorldToViewportPoint(targetPart.Position)
                    if tOnScreen then
                        local isVis = true
                        if Config.WallCheck then
                            isVis = isPartVisible(targetPart, char)
                        end
                        if isVis then
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if distance < shortestDistance then
                                closestTarget = targetPart
                                shortestDistance = distance
                            end
                        end
                    end
                end

                if Config.BoxESP and onScreen then
                    local headPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.6
                    
                    local box = espFolder:FindFirstChild(pName .. "_Box")
                    if not box then
                        box = Instance.new("Frame")
                        box.Name = pName .. "_Box"
                        box.BackgroundTransparency = 1
                        box.Parent = espFolder
                        local stroke = Instance.new("UIStroke")
                        stroke.Color = Theme.TextWhite
                        stroke.Thickness = 1.5
                        stroke.Parent = box
                    end
                    box.Size = UDim2.new(0, width, 0, height)
                    box.Position = UDim2.new(0, rootPos.X - width / 2, 0, headPos.Y)
                    box.Visible = true
                else
                    local box = espFolder:FindFirstChild(pName .. "_Box")
                    if box then box.Visible = false end
                end

                if Config.Tracers and onScreen then
                    DrawLineGUI(espFolder, pName .. "_Tracer", screenCenter, Vector2.new(rootPos.X, rootPos.Y), Theme.Accent, 1.5)
                else
                    local t = espFolder:FindFirstChild(pName .. "_Tracer")
                    if t then t.Visible = false end
                end

                if Config.ChamsESP then
                    local hl = espFolder:FindFirstChild(pName .. "_Chams")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = pName .. "_Chams"
                        hl.FillColor = Theme.Accent
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Theme.TextWhite
                        hl.OutlineTransparency = 0.2
                        hl.Parent = espFolder
                    end
                    hl.Adornee = char
                    hl.Enabled = true
                else
                    local hl = espFolder:FindFirstChild(pName .. "_Chams")
                    if hl then hl.Enabled = false end
                end
            else
                local box = espFolder:FindFirstChild(pName .. "_Box")
                if box then box.Visible = false end
                local t = espFolder:FindFirstChild(pName .. "_Tracer")
                if t then t.Visible = false end
                local hl = espFolder:FindFirstChild(pName .. "_Chams")
                if hl then hl.Enabled = false end
            end
        end

        if Config.Aimbot and isAimingKey and closestTarget then
            local newCFrame = CFrame.new(cam.CFrame.Position, closestTarget.Position)
            cam.CFrame = (Config.Smoothing >= 1.0) and newCFrame or cam.CFrame:Lerp(newCFrame, Config.Smoothing)
        end

        if Config.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(Config.SpinSpeed), 0)
        end

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local lp_hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if Config.JumpPower ~= 50 and lp_hum.JumpPower ~= Config.JumpPower then lp_hum.JumpPower = Config.JumpPower end
        end

        updateCrosshair()
    end)
    end)
