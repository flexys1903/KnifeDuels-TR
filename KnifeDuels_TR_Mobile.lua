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
local TeleportService = game:GetService("TeleportService")
local Stats = game:GetService("Stats")

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

if game:GetService("ReplicatedStorage"):FindFirstChild("CombatService") or game:GetService("ReplicatedStorage"):FindFirstChild("KnifeService") then
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
    AutoAttack = false,
    StabDistance = 15,
    HitboxExpander = false, 
    ShowHitboxes = false,
    HitboxSize = 15,
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
    
    -- Mobile
    ShowMobileButton = UserInputService.TouchEnabled,
    MobileAutoAttack = false,
    MobileAutoJump = false,

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
local isBindingKey = false
local isBindingMenuKey = false

-- Sleek Modern Theme
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
-- KEYBIND CHECK HELPERS
---------------------------------------------------------
local function GetBindName(bind)
    if typeof(bind) == "EnumItem" then
        if bind == Enum.UserInputType.MouseButton1 then return "Sol tık" end
        if bind == Enum.UserInputType.MouseButton2 then return "Sağ tık" end
        if bind == Enum.UserInputType.MouseButton3 then return "Orta tık" end
        return bind.Name
    end
    return "..."
end

local function CheckBind(input, bind)
    if typeof(bind) == "EnumItem" then
        if bind.EnumType == Enum.KeyCode and input.UserInputType == Enum.UserInputType.Keyboard then
            return input.KeyCode == bind
        elseif bind.EnumType == Enum.UserInputType then
            return input.UserInputType == bind
        end
    end
    return false
end

---------------------------------------------------------
-- FILESYSTEM CONFIG MANAGER (MULTI-PROFILE)
---------------------------------------------------------
local function SaveConfiguration(profileName)
    profileName = profileName or "Default"
    local path = ConfigFolder .. "/" .. profileName .. ".json"
    
    if type(writefile) == "function" and type(makefolder) == "function" then
        pcall(function()
            if type(isfolder) == "function" and not isfolder(ConfigFolder) then
                makefolder(ConfigFolder)
            end
            local serializableConfig = {}
            for k, v in pairs(Config) do
                if typeof(v) == "EnumItem" then
                    serializableConfig[k] = {Type = tostring(v.EnumType), Name = v.Name}
                else
                    serializableConfig[k] = v
                end
            end
            writefile(path, HttpService:JSONEncode(serializableConfig))
            StarterGui:SetCore("SendNotification", {
                Title = "Knife Duels Scripti",
                Text = "'" .. profileName .. "' ayar profili kaydedildi!",
                Duration = 3
            })
        end)
    end
end

local function LoadConfiguration(profileName)
    profileName = profileName or "Default"
    local path = ConfigFolder .. "/" .. profileName .. ".json"
    
    if type(readfile) == "function" and type(isfile) == "function" then
        pcall(function()
            if isfile(path) then
                local decoded = HttpService:JSONDecode(readfile(path))
                for k, v in pairs(decoded) do
                    if type(v) == "table" and v.Type and v.Name then
                        if v.Type == "UserInputType" then
                            Config[k] = Enum.UserInputType[v.Name]
                        elseif v.Type == "KeyCode" then
                            Config[k] = Enum.KeyCode[v.Name]
                        end
                    else
                        Config[k] = v
                    end
                end
                StarterGui:SetCore("SendNotification", {
                    Title = "Knife Duels Scripti",
                    Text = "'" .. profileName .. "' ayar profili yüklendi!",
                    Duration = 3
                })
            else
                StarterGui:SetCore("SendNotification", {
                    Title = "Knife Duels Scripti",
                    Text = "'" .. profileName .. "' ayar profili bulunamadı.",
                    Duration = 3
                })
            end
        end)
    end
end

LoadConfiguration("Default")

---------------------------------------------------------
-- NOTIFICATION & GUI BYPASS
---------------------------------------------------------
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Knife Duels Scripti",
        Text = "Script başarıyla yüklendi",
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

    local myTeam = LocalPlayer:FindFirstChild("Team") or LocalPlayer:FindFirstChild("TeamValue") or LocalPlayer:FindFirstChild("Role")
    local enemyTeam = player:FindFirstChild("Team") or player:FindFirstChild("TeamValue") or player:FindFirstChild("Role")
    
    if myTeam and enemyTeam and myTeam:IsA("StringValue") and enemyTeam:IsA("StringValue") then
        if myTeam.Value == enemyTeam.Value and myTeam.Value ~= "" then return true end
    end

    local myStats = LocalPlayer:FindFirstChild("leaderstats")
    local enemyStats = player:FindFirstChild("leaderstats")
    if myStats and enemyStats then
        local myStatTeam = myStats:FindFirstChild("Team") or myStats:FindFirstChild("Crew")
        local enemyStatTeam = enemyStats:FindFirstChild("Team") or enemyStats:FindFirstChild("Crew")
        if myStatTeam and enemyStatTeam and myStatTeam.Value == enemyStatTeam.Value then return true end
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
Watermark.Size = UserInputService.TouchEnabled and UDim2.new(0, 245, 0, 34) or UDim2.new(0, 320, 0, 30)
Watermark.BorderSizePixel = 0
local WMCorner = Instance.new("UICorner")
WMCorner.CornerRadius = UDim.new(0, 6)
WMCorner.Parent = Watermark
local WMStroke = Instance.new("UIStroke")
WMStroke.Color = Theme.Accent
WMStroke.Thickness = 1.5
WMStroke.Transparency = 0.3
WMStroke.Parent = Watermark
local WMShadow = Instance.new("ImageLabel")
WMShadow.Parent = Watermark
WMShadow.BackgroundTransparency = 1
WMShadow.Position = UDim2.new(0, -15, 0, -15)
WMShadow.Size = UDim2.new(1, 30, 1, 30)
WMShadow.ZIndex = -1
WMShadow.Image = "rbxassetid://1316045217"
WMShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
WMShadow.ImageTransparency = 0.5
WMShadow.ScaleType = Enum.ScaleType.Slice
WMShadow.SliceCenter = Rect.new(10, 10, 118, 118)

local WMText = Instance.new("TextLabel")
WMText.Parent = Watermark
WMText.BackgroundTransparency = 1
WMText.Size = UDim2.new(1, 0, 1, 0)
WMText.Font = Enum.Font.GothamMedium
WMText.Text = " Knife Duels | Oyuncu: " .. LocalPlayer.Name
WMText.TextColor3 = Theme.TextWhite
WMText.TextSize = 12

local fpsCount, lastFpsTick = 0, tick()
RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    if tick() - lastFpsTick >= 1 then
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        WMText.Text = string.format(" BEST FREE knife duels script | User: %s | FPS: %d | Ping: %dms", LocalPlayer.Name, fpsCount, ping)
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
if UserInputService.TouchEnabled then
    Main.Size = UDim2.new(0.94, 0, 0.78, 0)
else
    Main.Size = UDim2.new(0, 470, 0, 450)
end
Main.Active = true

-- Drop shadow for main window
local DropShadow = Instance.new("ImageLabel")
DropShadow.Parent = Main
DropShadow.BackgroundTransparency = 1
DropShadow.Position = UDim2.new(0, -25, 0, -25)
DropShadow.Size = UDim2.new(1, 50, 1, 50)
DropShadow.ZIndex = -1
DropShadow.Image = "rbxassetid://1316045217"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.4
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(10, 10, 118, 118)

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

local BackgroundPattern = Instance.new("ImageLabel")
BackgroundPattern.Parent = Main
BackgroundPattern.BackgroundTransparency = 1
BackgroundPattern.Size = UDim2.new(1, 0, 1, 0)
BackgroundPattern.Image = Theme.BackgroundPattern
BackgroundPattern.ImageTransparency = 0.90
BackgroundPattern.ScaleType = Enum.ScaleType.Tile
BackgroundPattern.TileSize = UDim2.new(0, 150, 0, 150)
local PatternCorner = Instance.new("UICorner")
PatternCorner.CornerRadius = UDim.new(0, 8)
PatternCorner.Parent = BackgroundPattern

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
Title.Text = "KNIFE DUELS SCRIPT"
Title.TextColor3 = Theme.Accent
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local TitleGlow = Instance.new("TextLabel")
TitleGlow.Parent = Title
TitleGlow.BackgroundTransparency = 1
TitleGlow.Size = UDim2.new(1, 0, 1, 0)
TitleGlow.Font = Enum.Font.GothamBlack
TitleGlow.Text = Title.Text
TitleGlow.TextColor3 = Theme.AccentGlow
TitleGlow.TextSize = 18
TitleGlow.TextXAlignment = Enum.TextXAlignment.Left
TitleGlow.TextTransparency = 0.6
TitleGlow.ZIndex = 0

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
TabBarLayout.Padding = UDim.new(0, 10)

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
ActiveTabLine.Size = UDim2.new(0.25, -8, 1, 0)
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
    btnFrame.Size = UDim2.new(0.25, -8, 1, 0)

    local btn = Instance.new("TextButton")
    btn.Parent = btnFrame
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.TextColor3 = isFirst and Theme.TextWhite or Theme.TextDim
    btn.TextSize = 13
    
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
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Padding for the scrolling frame so items don't hit the edges
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
    frame.Size = UDim2.new(1, 0, 0, UserInputService.TouchEnabled and 48 or 40)
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Theme.Border
    frameStroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Config[configKey] and Theme.TextWhite or Theme.TextDim
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = frame
    toggleBtn.BackgroundColor3 = Config[configKey] and Theme.Accent or Color3.fromRGB(78, 77, 72)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -12)
    toggleBtn.Size = UDim2.new(0, 40, 0, 24)
    toggleBtn.Text = ""
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn

    local knob = Instance.new("Frame")
    knob.Parent = toggleBtn
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Position = Config[configKey] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    knob.Size = UDim2.new(0, 20, 0, 20)
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local knobShadow = Instance.new("UIStroke")
    knobShadow.Color = Color3.fromRGB(0,0,0)
    knobShadow.Transparency = 0.8
    knobShadow.Parent = knob

    local function toggle()
        Config[configKey] = not Config[configKey]
        local state = Config[configKey]
        Tween(toggleBtn, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(78, 77, 72)})
        Tween(knob, {Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)})
        Tween(label, {TextColor3 = state and Theme.TextWhite or Theme.TextDim})
        if callback then callback(state) end
    end

    toggleBtn.MouseButton1Click:Connect(toggle)
    
    -- Add hover effects to the entire frame
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            Tween(frame, {BackgroundColor3 = Theme.ToggleHover})
            Tween(frameStroke, {Color = Color3.fromRGB(125, 118, 103)})
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            Tween(frame, {BackgroundColor3 = Theme.ToggleOff})
            Tween(frameStroke, {Color = Theme.Border})
        end
    end)
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = Theme.ToggleOff
    btn.Size = UDim2.new(1, 0, 0, UserInputService.TouchEnabled and 48 or 40)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.TextColor3 = Theme.TextWhite
    btn.TextSize = 13
    btn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Border
    stroke.Parent = btn

    btn.MouseEnter:Connect(function() 
        Tween(btn, {BackgroundColor3 = Theme.ToggleHover}) 
        Tween(stroke, {Color = Theme.Accent, Transparency = 0.5})
    end)
    btn.MouseLeave:Connect(function() 
        Tween(btn, {BackgroundColor3 = Theme.ToggleOff}) 
        Tween(stroke, {Color = Theme.Border, Transparency = 0})
    end)
    btn.MouseButton1Down:Connect(function()
        Tween(btn, {BackgroundColor3 = Theme.Accent})
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(btn, {BackgroundColor3 = Theme.ToggleHover})
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateTextBox(parent, placeholder, defaultText, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 0, UserInputService.TouchEnabled and 48 or 40)

    local box = Instance.new("TextBox")
    box.Parent = frame
    box.BackgroundColor3 = Theme.ToggleOff
    box.Size = UDim2.new(1, 0, 1, 0)
    box.Font = Enum.Font.GothamMedium
    box.Text = defaultText or ""
    box.PlaceholderText = placeholder
    box.TextColor3 = Theme.TextWhite
    box.TextSize = 13
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = box
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Border
    stroke.Parent = box

    box.Focused:Connect(function()
        Tween(stroke, {Color = Theme.Accent})
    end)
    box.FocusLost:Connect(function()
        Tween(stroke, {Color = Theme.Border})
        if callback then callback(box.Text) end
    end)
    return box
end

local function CreateSlider(parent, text, min, max, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = Theme.ToggleOff
    frame.Size = UDim2.new(1, 0, 0, UserInputService.TouchEnabled and 64 or 55)
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Theme.Border
    frameStroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 15, 0, 8)
    label.Size = UDim2.new(1, -30, 0, 18)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Theme.TextDim
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel")
    valLabel.Parent = frame
    valLabel.BackgroundTransparency = 1
    valLabel.Position = UDim2.new(0, 15, 0, 8)
    valLabel.Size = UDim2.new(1, -30, 0, 18)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.Text = tostring(defaultVal)
    valLabel.TextColor3 = Theme.TextWhite
    valLabel.TextSize = 13
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("TextButton")
    track.Parent = frame
    track.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    track.Position = UDim2.new(0, 15, 0, 36)
    track.Size = UDim2.new(1, -30, 0, 6)
    track.Text = ""
    track.AutoButtonColor = false
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = Theme.Border
    trackStroke.Parent = track

    local fill = Instance.new("Frame")
    fill.Parent = track
    fill.BackgroundColor3 = Theme.Accent
    local pct = (defaultVal - min) / (max - min)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local grabber = Instance.new("Frame")
    grabber.Parent = fill
    grabber.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    grabber.AnchorPoint = Vector2.new(0.5, 0.5)
    grabber.Position = UDim2.new(1, 0, 0.5, 0)
    grabber.Size = UDim2.new(0, 14, 0, 14)
    local grabberCorner = Instance.new("UICorner")
    grabberCorner.CornerRadius = UDim.new(1, 0)
    grabberCorner.Parent = grabber
    
    local grabberShadow = Instance.new("UIStroke")
    grabberShadow.Color = Color3.fromRGB(0,0,0)
    grabberShadow.Transparency = 0.8
    grabberShadow.Parent = grabber

    local dragging = false
    local function update(input)
        local pos = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local percent = pos / track.AbsoluteSize.X
        local value = math.floor(min + ((max - min) * percent) + 0.5)
        
        Tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
        valLabel.Text = tostring(value)
        if callback then callback(value) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(input)
            Tween(grabber, {Size = UDim2.new(0, 18, 0, 18)}, 0.15)
            Tween(fill, {BackgroundColor3 = Theme.AccentGlow}, 0.15)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
            Tween(grabber, {Size = UDim2.new(0, 14, 0, 14)}, 0.15)
            Tween(fill, {BackgroundColor3 = Theme.Accent}, 0.15)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            Tween(frame, {BackgroundColor3 = Theme.ToggleHover})
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            Tween(frame, {BackgroundColor3 = Theme.ToggleOff})
        end
    end)
end

---------------------------------------------------------
-- POPULATE TABBED UI
---------------------------------------------------------
local CombatTab = CreateTab("Savaş", true)
local VisualsTab = CreateTab("Görünüm", false)
local PlayerTab = CreateTab("Oyuncu", false)
local SettingsTab = CreateTab("Ayarlar", false)

-- [Combat Options]
CreateToggle(CombatTab, "Nişan yardımını aç", "Aimbot")
CreateSlider(CombatTab, "Nişan takip hızı", 1, 10, 2, function(val) Config.Smoothing = (val == 10) and 1.0 or (0.05 + ((val - 1) * 0.1)) end)
CreateToggle(CombatTab, "Otomatik saldırı (Sapla/Fırlat)", "AutoAttack")
CreateSlider(CombatTab, "Saplama mesafesi", 5, 30, 15, function(val) Config.StabDistance = val end)
CreateToggle(CombatTab, "Vuruş alanını genişlet", "HitboxExpander")
CreateToggle(CombatTab, "Vuruş alanlarını göster", "ShowHitboxes")
CreateSlider(CombatTab, "Vuruş alanı boyutu", 5, 50, 15, function(val) Config.HitboxSize = val end)
CreateToggle(CombatTab, "Takım kontrolü", "TeamCheck")
CreateToggle(CombatTab, "Duvar kontrolü", "WallCheck")

local BindBtn = CreateButton(CombatTab, "Nişan tuşu: [" .. GetBindName(Config.Keybind) .. "]", function() end)
BindBtn.MouseButton1Click:Connect(function()
    task.wait(0.1) 
    isBindingKey = true
    BindBtn.Text = "Bir tuşa veya fare tuşuna bas..."
    Tween(BindBtn, {TextColor3 = Theme.Accent})
end)

-- [Visual Options]
CreateToggle(VisualsTab, "Görüş dairesini göster", "ShowFOV")
CreateToggle(VisualsTab, "2D kutu ESP", "BoxESP")
CreateToggle(VisualsTab, "İskelet ESP", "SkeletonESP")
CreateToggle(VisualsTab, "Karakter vurgusu ESP", "ChamsESP")
CreateToggle(VisualsTab, "İsim ESP", "NameESP")
CreateToggle(VisualsTab, "İz çizgileri ESP", "Tracers")
CreateToggle(VisualsTab, "Özel nişangâh", "Crosshair")
CreateSlider(VisualsTab, "Nişangâh boyutu", 4, 30, 10, function(val) Config.CrosshairSize = val end)

-- [Player Options]
CreateToggle(PlayerTab, "Spinbot (Nişan şaşırtma)", "Spinbot")
CreateSlider(PlayerTab, "Spinbot hızı", 1, 100, 20, function(val) Config.SpinSpeed = val end)
CreateToggle(PlayerTab, "Sonsuz zıplama", "InfiniteJump")
CreateSlider(PlayerTab, "Zıplama gücü", 50, 300, 50, function(val) Config.JumpPower = val end)

-- [Settings Options]
local MenuBindBtn = CreateButton(SettingsTab, "Menü tuşu: [" .. GetBindName(Config.MenuKeybind) .. "]", function() end)
MenuBindBtn.MouseButton1Click:Connect(function()
    task.wait(0.1)
    isBindingMenuKey = true
    MenuBindBtn.Text = "Bir klavye tuşuna bas..."
    Tween(MenuBindBtn, {TextColor3 = Theme.Accent})
end)

CreateButton(SettingsTab, "Hedef bölgesi: " .. (Config.TargetPart == "Head" and "Kafa" or "Gövde"), function()
    Config.TargetPart = (Config.TargetPart == "HumanoidRootPart") and "Head" or "HumanoidRootPart"
    for _, v in pairs(SettingsTab:GetChildren()) do
        if v:IsA("TextButton") and v.Text:match("Target Part") then
            v.Text = "Hedef bölgesi: " .. (Config.TargetPart == "Head" and "Kafa" or "Gövde")
        end
    end
end)

local currentProfileName = "Default"
CreateTextBox(SettingsTab, "Ayar profili adı...", "Default", function(txt)
    currentProfileName = txt
end)

CreateButton(SettingsTab, "Ayarları kaydet", function()
    SaveConfiguration(currentProfileName)
end)

CreateButton(SettingsTab, "Ayarları yükle", function()
    LoadConfiguration(currentProfileName)
end)

CreateButton(SettingsTab, "Scripti kapat", function() ScreenGui:Destroy() end)

---------------------------------------------------------
-- MOBILE BUTTON LOGIC
---------------------------------------------------------
local MobileAimFrame = Instance.new("Frame")
MobileAimFrame.Parent = ScreenGui
MobileAimFrame.BackgroundColor3 = Theme.MainBG
MobileAimFrame.Position = UDim2.new(0.8, -35, 0.6, -35)
MobileAimFrame.Size = UDim2.new(0, 76, 0, 76)
MobileAimFrame.Visible = Config.ShowMobileButton
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
MobileAimButton.TextSize = 16

local isDraggingMobile, hasMovedMobile, dragStartAim, startPosAim
MobileAimButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingMobile = true
        hasMovedMobile = false
        dragStartAim = input.Position
        startPosAim = MobileAimFrame.Position
        Tween(MobileAimFrame, {Size = UDim2.new(0, 72, 0, 72)})
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
        Tween(MobileAimFrame, {Size = UDim2.new(0, 76, 0, 76)})
        if not hasMovedMobile then
            isAimingKey = not isAimingKey
            Tween(MobileAimFrame, {BackgroundColor3 = isAimingKey and Theme.Accent or Theme.MainBG})
            MobileAimButton.Text = isAimingKey and "KİLİTLİ" or "NİŞAN"
        end
    end
end)

---------------------------------------------------------
-- WINDOW DRAGGING
---------------------------------------------------------
local draggingMain, dragInputMain, dragStartMain, startPosMain
Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = true
        dragStartMain = input.Position
        startPosMain = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingMain = false end
        end)
    end
end)
Topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputMain = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInputMain and draggingMain then
        local delta = input.Position - dragStartMain
        Tween(Main, {Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)}, 0.1)
    end
end)

local draggingWM, dragInputWM, dragStartWM, startPosWM
Watermark.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingWM = true
        dragStartWM = input.Position
        startPosWM = Watermark.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingWM = false end
        end)
    end
end)
Watermark.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputWM = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInputWM and draggingWM then
        local delta = input.Position - dragStartWM
        Tween(Watermark, {Position = UDim2.new(startPosWM.X.Scale, startPosWM.X.Offset + delta.X, startPosWM.Y.Scale, startPosWM.Y.Offset + delta.Y)}, 0.1)
    end
end)

---------------------------------------------------------
-- MAX STEALTH UI OBFUSCATION
---------------------------------------------------------
for _, obj in pairs(ScreenGui:GetDescendants()) do
    pcall(function() obj.Name = generateRandomName() end)
end

---------------------------------------------------------
-- CORE INPUT LOGIC
---------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if isBindingMenuKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Config.MenuKeybind = input.KeyCode
            MenuBindBtn.Text = "Menü tuşu: [" .. input.KeyCode.Name .. "]"
            isBindingMenuKey = false
            Tween(MenuBindBtn, {TextColor3 = Theme.TextWhite})
            SaveConfiguration(currentProfileName)
        end
        return
    end

    if isBindingKey then
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
            Config.Keybind = input.KeyCode
            BindBtn.Text = "Nişan tuşu: [" .. input.KeyCode.Name .. "]"
            isBindingKey = false
            Tween(BindBtn, {TextColor3 = Theme.TextWhite})
            SaveConfiguration(currentProfileName)
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
            Config.Keybind = input.UserInputType
            BindBtn.Text = "Nişan tuşu: [" .. GetBindName(input.UserInputType) .. "]"
            isBindingKey = false
            Tween(BindBtn, {TextColor3 = Theme.TextWhite})
            SaveConfiguration(currentProfileName)
        end
        return
    end

    if CheckBind(input, Config.MenuKeybind) then
        Main.Visible = not Main.Visible
    end

    if not gameProcessed then
        if CheckBind(input, Config.Keybind) then
            isAimingKey = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if CheckBind(input, Config.Keybind) then
        if MobileAimButton.Text ~= "KİLİTLİ" then isAimingKey = false end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

---------------------------------------------------------
-- THE MASTER LOOP: ESP, FOV, & HITBOX ENGINE
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

local RigJoints = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}
local R6Joints = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local originalSizes = {}
local lastAutoAttackTick = 0

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

        local lpTeam = LocalPlayer.Team
        local lpTeamValObj = LocalPlayer:FindFirstChild("Team") or LocalPlayer:FindFirstChild("TeamValue") or LocalPlayer:FindFirstChild("Role")
        local lpTeamValStr = lpTeamValObj and lpTeamValObj:IsA("StringValue") and lpTeamValObj.Value or nil
        local lpStats = LocalPlayer:FindFirstChild("leaderstats")
        local lpStatTeamObj = lpStats and (lpStats:FindFirstChild("Team") or lpStats:FindFirstChild("Crew"))
        local lpStatTeamVal = lpStatTeamObj and lpStatTeamObj.Value or nil
        
        local espFolder = getESPFolder()
        local closestTarget = nil
        local shortestDistance = Config.FOVRadius

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end

            local isFriendly = false
            if Config.TeamCheck then
                if lpTeam and player.Team and lpTeam == player.Team then
                    isFriendly = true
                elseif lpTeamValStr then
                    local eTeamValObj = player:FindFirstChild("Team") or player:FindFirstChild("TeamValue") or player:FindFirstChild("Role")
                    if eTeamValObj and eTeamValObj:IsA("StringValue") and lpTeamValStr == eTeamValObj.Value and lpTeamValStr ~= "" then
                        isFriendly = true
                    end
                elseif lpStatTeamVal then
                    local eStats = player:FindFirstChild("leaderstats")
                    local eStatTeamObj = eStats and (eStats:FindFirstChild("Team") or eStats:FindFirstChild("Crew"))
                    if eStatTeamObj and lpStatTeamVal == eStatTeamObj.Value then
                        isFriendly = true
                    end
                end
            end

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
                
                if Config.SkeletonESP and onScreen then
                    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
                    local joints = isR15 and RigJoints or R6Joints
                    for i, connection in ipairs(joints) do
                        local part1 = char:FindFirstChild(connection[1])
                        local part2 = char:FindFirstChild(connection[2])
                        if part1 and part2 then
                            local p1, vis1 = cam:WorldToViewportPoint(part1.Position)
                            local p2, vis2 = cam:WorldToViewportPoint(part2.Position)
                            if vis1 or vis2 then
                                DrawLineGUI(espFolder, pName .. "_Skel_" .. i, Vector2.new(p1.X, p1.Y), Vector2.new(p2.X, p2.Y), Theme.TextWhite, 1.5)
                            else
                                local l = espFolder:FindFirstChild(pName .. "_Skel_" .. i)
                                if l then l.Visible = false end
                            end
                        else
                            local l = espFolder:FindFirstChild(pName .. "_Skel_" .. i)
                            if l then l.Visible = false end
                        end
                    end
                else
                    for i = 1, 14 do
                        local l = espFolder:FindFirstChild(pName .. "_Skel_" .. i)
                        if l then l.Visible = false end
                    end
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

                if Config.NameESP then
                    local bg = espFolder:FindFirstChild(pName .. "_Name")
                    if not bg then
                        bg = Instance.new("BillboardGui")
                        bg.Name = pName .. "_Name"
                        bg.Size = UDim2.new(0, 150, 0, 40)
                        bg.StudsOffset = Vector3.new(0, 2.5, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = espFolder
                        
                        local txt = Instance.new("TextLabel")
                        txt.Parent = bg
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextColor3 = Theme.TextWhite
                        txt.TextStrokeTransparency = 0.1
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 12
                    end
                    bg.Adornee = head
                    bg:FindFirstChildOfClass("TextLabel").Text = player.Name
                    bg.Enabled = true
                else
                    local bg = espFolder:FindFirstChild(pName .. "_Name")
                    if bg then bg.Enabled = false end
                end

                if Config.HitboxExpander then
                    if not originalSizes[player.UserId] then originalSizes[player.UserId] = {} end
                    if not originalSizes[player.UserId]["Head"] then
                        originalSizes[player.UserId]["Head"] = head.Size
                    end
                    
                    local targetSize = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                    if head.Size ~= targetSize then
                        head.Size = targetSize
                        head.CanCollide = false
                        head.Massless = true
                    end
                    if Config.ShowHitboxes then
                        if head.Transparency ~= 0.5 then
                            head.Transparency = 0.5
                            head.Material = Enum.Material.ForceField
                            head.BrickColor = BrickColor.new("Linen")
                        end
                    elseif head.Transparency ~= 1 then
                        head.Transparency = 1 
                    end
                elseif originalSizes[player.UserId] and originalSizes[player.UserId]["Head"] then
                    local origSize = originalSizes[player.UserId]["Head"]
                    if head.Size ~= origSize then
                        head.Size = origSize
                        head.Transparency = 0
                    end
                end

            else
                local box = espFolder:FindFirstChild(pName .. "_Box")
                if box then box.Visible = false end
                local t = espFolder:FindFirstChild(pName .. "_Tracer")
                if t then t.Visible = false end
                local hl = espFolder:FindFirstChild(pName .. "_Chams")
                if hl then hl.Enabled = false end
                local bg = espFolder:FindFirstChild(pName .. "_Name")
                if bg then bg.Enabled = false end
                for i = 1, 14 do
                    local l = espFolder:FindFirstChild(pName .. "_Skel_" .. i)
                    if l then l.Visible = false end
                end
                
                if char and head and originalSizes[player.UserId] and originalSizes[player.UserId]["Head"] then
                    local origSize = originalSizes[player.UserId]["Head"]
                    if head.Size ~= origSize then
                        head.Size = origSize
                        head.Transparency = 0
                    end
                end
            end
        end

        if Config.Aimbot and isAimingKey and closestTarget then
            local jitterX = math.random(-10, 10) * 0.003
            local jitterY = math.random(-10, 10) * 0.003
            local jitterZ = math.random(-10, 10) * 0.003
            local humanizedPos = closestTarget.Position + Vector3.new(jitterX, jitterY, jitterZ)
            
            local newCFrame = CFrame.new(cam.CFrame.Position, humanizedPos)
            cam.CFrame = (Config.Smoothing >= 1.0) and newCFrame or cam.CFrame:Lerp(newCFrame, Config.Smoothing)
        end

        if Config.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(Config.SpinSpeed), 0)
        end

        if Config.AutoAttack and closestTarget and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if isPartVisible(closestTarget, closestTarget.Parent) then
                if tick() - lastAutoAttackTick > 0.2 then
                    lastAutoAttackTick = tick()
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - closestTarget.Position).Magnitude
                    if dist <= Config.StabDistance then
                        if type(mouse1click) == "function" then pcall(mouse1click) end
                    else
                        if type(mouse2click) == "function" then pcall(mouse2click) end
                    end
                end
            end
        end

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local lp_hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if Config.JumpPower ~= 50 and lp_hum.JumpPower ~= Config.JumpPower then lp_hum.JumpPower = Config.JumpPower end
        end

        if isAimingKey and closestTarget and MobileAimButton.Text == "KİLİTLİ" then
            local myChar = LocalPlayer.Character
            if myChar then
                if Config.MobileAutoJump then
                    local lp_hum = myChar:FindFirstChildOfClass("Humanoid")
                    if lp_hum and lp_hum:GetState() ~= Enum.HumanoidStateType.Jumping and lp_hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                        lp_hum.Jump = true
                    end
                end
                if Config.MobileAutoAttack then
                    local tool = myChar:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end

        updateCrosshair()
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if originalSizes[player.UserId] then
        originalSizes[player.UserId] = nil
    end
    local pName = tostring(player.UserId)
    local espFolder = ScreenGui:FindFirstChild("ESP_Layer")
    if espFolder then
        local box = espFolder:FindFirstChild(pName .. "_Box")
        if box then box:Destroy() end
        local t = espFolder:FindFirstChild(pName .. "_Tracer")
        if t then t:Destroy() end
        local hl = espFolder:FindFirstChild(pName .. "_Chams")
        if hl then hl:Destroy() end
        local bg = espFolder:FindFirstChild(pName .. "_Name")
        if bg then bg:Destroy() end
        for i = 1, 14 do
            local l = espFolder:FindFirstChild(pName .. "_Skel_" .. i)
            if l then l:Destroy() end
        end
    end
end)
