-- Roblox Hub Script | Utku Mega Hub - Framed Edition
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UtkuMegaHubFramedEdition"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui or Player:WaitForChild("PlayerGui")

local TargetPlayer = nil
local AttachBehind = false
local AttachInFront = false
local FlingActive = false
local TargetLeaveCount = 0
local TargetJoinCount = 0

local ESPActive = false
local UltraInstinctActive = false
local UltraInstinctDistance = 3
local AntiBangActive = false

local AntiSit, AntiFling, AntiLag, AntiVoid, AntiAFK = false, false, false, false, false
local AntiCopyOutfit = false
local AntiBrookhavenToolLag = false
local AntiGiantSkinsActive = false 
local AntiMusicActive = false

-- 🎨 İstediğin Gri & Bej Tonları ve Vurgu Renkleri
local Theme = {
    Bg = Color3.fromRGB(40, 40, 40),          -- Koyu Gri Arka Plan
    Sidebar = Color3.fromRGB(30, 30, 30),     -- Başlık / Yan Menü Grisi
    Card = Color3.fromRGB(55, 55, 55),        -- Buton ve Kart Grisi
    Accent = Color3.fromRGB(200, 185, 155),   -- Bej Vurgu Rengi
    Text = Color3.fromRGB(245, 240, 230),     -- Krem / Bej Yazı Rengi
    Active = Color3.fromRGB(150, 135, 105)    -- Aktif Buton Bej Tonu
}

-- [⚡ Dairesel Aç/Kapat Butonu]
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 44, 0, 44)
ToggleBtn.Position = UDim2.new(0.03, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Theme.Bg
ToggleBtn.Text = "MENU"
ToggleBtn.TextColor3 = Theme.Accent
ToggleBtn.TextSize = 12
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Visible = true
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

-- [📦 Ana Pencere]
local Main = Instance.new("Frame", ScreenGui)
Main.Name = "Main"
Main.Size = UDim2.new(0, 420, 0, 270)
Main.Position = UDim2.new(0.5, -210, 0.5, -135)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- [🖼️ Arka Plan Görseli]
local BgImage = Instance.new("ImageLabel", Main)
BgImage.Name = "BgImage"
BgImage.Size = UDim2.new(1, 0, 1, 0)
BgImage.BackgroundTransparency = 1
BgImage.Image = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR6Nwyg25bOjkSB0DNgFRcP5elemNjKa38UUzkm8asXnWORQzMmOFNVc10&s=10"
BgImage.ScaleType = Enum.ScaleType.Slice
BgImage.ZIndex = 0

-- Saydamlık için ek katman (yazıların okunabilirliği adına)
local BgOverlay = Instance.new("Frame", Main)
BgOverlay.Size = UDim2.new(1, 0, 1, 0)
BgOverlay.BackgroundColor3 = Theme.Bg
BgOverlay.BackgroundTransparency = 0.35
BgOverlay.BorderSizePixel = 0
BgOverlay.ZIndex = 1
Instance.new("UICorner", BgOverlay).CornerRadius = UDim.new(0, 10)

-- Ana Çerçeve Çizgisi
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1.5
MainStroke.ZIndex = 2

ToggleBtn.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

-- [📋 Sol Kenar Çubuğu]
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 125, 1, 0)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, 0, 0, 32)
Title.Text = "UTKU MEGA HUB"
Title.TextColor3 = Theme.Accent
Title.TextSize = 10
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.ZIndex = 3

local TabContainer = Instance.new("ScrollingFrame", Sidebar)
TabContainer.Size = UDim2.new(1, 0, 1, -38)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.BackgroundTransparency = 1
TabContainer.ScrollBarThickness = 0
TabContainer.ZIndex = 3

local TabList = Instance.new("UIListLayout", TabContainer)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 3)

-- [🖼️ İçerik Alanı]
local ContentArea = Instance.new("Frame", Main)
ContentArea.Size = UDim2.new(1, -135, 1, -12)
ContentArea.Position = UDim2.new(0, 131, 0, 6)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 2

local function createPage(isScroll)
	local page
	if isScroll then
		page = Instance.new("ScrollingFrame", ContentArea)
		page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Theme.Accent
	else
		page = Instance.new("Frame", ContentArea)
	end
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.ZIndex = 2
	return page
end

-- 1️⃣ [1. Hakkımda]
local CreditsPage = createPage(true)
CreditsPage.Visible = true

local CreditsLayout = Instance.new("UIListLayout", CreditsPage)
CreditsLayout.SortOrder = Enum.SortOrder.LayoutOrder
CreditsLayout.Padding = UDim.new(0, 5)

local function createCreditCard(roleTitle, nameText, icon)
    local Card = Instance.new("Frame", CreditsPage)
    Card.Size = UDim2.new(1, -6, 0, 40)
    Card.BackgroundColor3 = Theme.Card
    Card.BackgroundTransparency = 0.2
    Card.BorderSizePixel = 0
    Card.ZIndex = 2
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
    
    local RoleLbl = Instance.new("TextLabel", Card)
    RoleLbl.Size = UDim2.new(1, -8, 0, 16)
    RoleLbl.Position = UDim2.new(0, 6, 0, 3)
    RoleLbl.Text = icon .. " " .. roleTitle
    RoleLbl.TextColor3 = Theme.Accent
    RoleLbl.TextSize = 10
    RoleLbl.Font = Enum.Font.GothamBold
    RoleLbl.TextXAlignment = Enum.TextXAlignment.Left
    RoleLbl.BackgroundTransparency = 1
    RoleLbl.ZIndex = 3
    
    local NameLbl = Instance.new("TextLabel", Card)
    NameLbl.Size = UDim2.new(1, -8, 0, 16)
    NameLbl.Position = UDim2.new(0, 6, 0, 20)
    NameLbl.Text = nameText
    NameLbl.TextColor3 = Theme.Text
    NameLbl.TextSize = 11
    NameLbl.Font = Enum.Font.Gotham
    NameLbl.TextXAlignment = Enum.TextXAlignment.Left
    NameLbl.BackgroundTransparency = 1
    NameLbl.ZIndex = 3
end

createCreditCard("Geliştirici", "Utku", "👑")
createCreditCard("Roblox Hesabı", "AMATOR_TURK", "🎮")
createCreditCard("Instagram", "utku.ss", "📸")

local DescCard = Instance.new("Frame", CreditsPage)
DescCard.Size = UDim2.new(1, -6, 0, 55)
DescCard.BackgroundColor3 = Theme.Card
DescCard.BackgroundTransparency = 0.2
DescCard.BorderSizePixel = 0
DescCard.ZIndex = 2
Instance.new("UICorner", DescCard).CornerRadius = UDim.new(0, 6)

local DescLbl = Instance.new("TextLabel", DescCard)
DescLbl.Size = UDim2.new(1, -10, 1, -4)
DescLbl.Position = UDim2.new(0, 5, 0, 2)
DescLbl.Text = "Bu 1 9 0 3 , Brookhaven ve diğer oyunlar için özel olarak tasarlanmıştır. İyi eğlenceler!"
DescLbl.TextColor3 = Theme.Text
DescLbl.TextSize = 9
DescLbl.Font = Enum.Font.GothamBold
DescLbl.TextWrapped = true
DescLbl.TextYAlignment = Enum.TextYAlignment.Center
DescLbl.BackgroundTransparency = 1
DescLbl.ZIndex = 3

-- 2️⃣ [2. Hedef / Oyuncu Seç]
local TargetPage = createPage(true)

local TargetInput = Instance.new("TextBox", TargetPage)
TargetInput.Size = UDim2.new(1, -6, 0, 30)
TargetInput.Position = UDim2.new(0, 0, 0, 2)
TargetInput.PlaceholderText = "Hedef oyuncu adı..."
TargetInput.Text = ""
TargetInput.BackgroundColor3 = Theme.Card
TargetInput.BackgroundTransparency = 0.2
TargetInput.TextColor3 = Theme.Text
TargetInput.Font = Enum.Font.Gotham
TargetInput.TextSize = 10
TargetInput.BorderSizePixel = 0
TargetInput.ZIndex = 2
Instance.new("UICorner", TargetInput).CornerRadius = UDim.new(0, 6)

local TargetListContainer = Instance.new("Frame", TargetPage)
TargetListContainer.Size = UDim2.new(1, -6, 0, 300)
TargetListContainer.Position = UDim2.new(0, 0, 0, 35)
TargetListContainer.BackgroundTransparency = 1
TargetListContainer.ZIndex = 2

local TargetLayout = Instance.new("UIListLayout", TargetListContainer)
TargetLayout.SortOrder = Enum.SortOrder.LayoutOrder
TargetLayout.Padding = UDim.new(0, 5)

local LeaveCard = Instance.new("TextLabel", TargetListContainer)
LeaveCard.Size = UDim2.new(1, 0, 0, 28)
LeaveCard.BackgroundColor3 = Theme.Card
LeaveCard.BackgroundTransparency = 0.2
LeaveCard.BorderSizePixel = 0
LeaveCard.Text = "🚪 Hedef Çıkış Sayısı: 0"
LeaveCard.TextColor3 = Theme.Accent
LeaveCard.Font = Enum.Font.GothamBold
LeaveCard.TextSize = 10
LeaveCard.ZIndex = 2
Instance.new("UICorner", LeaveCard).CornerRadius = UDim.new(0, 6)

local JoinCard = Instance.new("TextLabel", TargetListContainer)
JoinCard.Size = UDim2.new(1, 0, 0, 28)
JoinCard.BackgroundColor3 = Theme.Card
JoinCard.BackgroundTransparency = 0.2
JoinCard.BorderSizePixel = 0
JoinCard.Text = "📥 Hedef Giriş Sayısı: 0"
JoinCard.TextColor3 = Theme.Accent
JoinCard.Font = Enum.Font.GothamBold
JoinCard.TextSize = 10
JoinCard.ZIndex = 2
Instance.new("UICorner", JoinCard).CornerRadius = UDim.new(0, 6)

local function getTarget(inputText)
    local text = string.lower(inputText or TargetInput.Text)
    if text == "" then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            if string.sub(string.lower(p.Name), 1, #text) == text or string.sub(string.lower(p.DisplayName), 1, #text) == text then
                return p
            end
        end
    end
    return nil
end

TargetInput:GetPropertyChangedSignal("Text"):Connect(function()
    TargetPlayer = getTarget()
    TargetLeaveCount = 0
    TargetJoinCount = 0
    LeaveCard.Text = "🚪 Hedef Çıkış Sayısı: 0"
    JoinCard.Text = "📥 Hedef Giriş Sayısı: 0"
end)

local function createTargetActionBtn(btnText, callback)
    local Btn = Instance.new("TextButton", TargetListContainer)
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.Text = btnText
    Btn.BackgroundColor3 = Theme.Card
    Btn.BackgroundTransparency = 0.2
    Btn.TextColor3 = Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Btn.BorderSizePixel = 0
    Btn.ZIndex = 2
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    Btn.MouseButton1Click:Connect(function()
        TargetPlayer = getTarget()
        callback(Btn)
    end)
end

createTargetActionBtn("👁️ İzle (Spectate)", function()
    if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChildOfClass("Humanoid") then
        workspace.CurrentCamera.CameraSubject = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
end)

createTargetActionBtn("🚫 İzlemeyi Bırak", function()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        workspace.CurrentCamera.CameraSubject = Player.Character:FindFirstChildOfClass("Humanoid")
    end
end)

createTargetActionBtn("📍 Hedefe Işınlan (Teleport)", function()
    if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    end
end)

createTargetActionBtn("🌪️ Fling (Fırlat): [Kapalı ❌]", function(btn)
    FlingActive = not FlingActive
    if FlingActive then
        btn.Text = "🌪️ Fling (Fırlat): [Açık ✅]"
        btn.BackgroundColor3 = Theme.Active
        task.spawn(function()
            local oldPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.CFrame
            while FlingActive do
                if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = Player.Character.HumanoidRootPart
                    local targetHrp = TargetPlayer.Character.HumanoidRootPart
                    local bv = Instance.new("BodyAngularVelocity", hrp)
                    bv.AngularVelocity = Vector3.new(0, 99999, 0)
                    bv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    hrp.CFrame = targetHrp.CFrame
                    task.wait(0.05)
                    bv:Destroy()
                else
                    task.wait(0.5)
                end
            end
            if oldPos and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = oldPos
            end
        end)
    else
        btn.Text = "🌪️ Fling (Fırlat): [Kapalı ❌]"
        btn.BackgroundColor3 = Theme.Card
    end
end)

createTargetActionBtn("💥 Arkaya Yapış: [Kapalı]", function(btn)
    AttachBehind = not AttachBehind
    if AttachBehind then
        AttachInFront = false
        btn.Text = "💥 Arkaya Yapış: [Açık ✅]"
        btn.BackgroundColor3 = Theme.Active
    else
        btn.Text = "💥 Arkaya Yapış: [Kapalı ❌]"
        btn.BackgroundColor3 = Theme.Card
    end
end)

createTargetActionBtn("💥 Öne Yapış: [Kapalı]", function(btn)
    AttachInFront = not AttachInFront
    if AttachInFront then
        AttachBehind = false
        btn.Text = "💥 Öne Yapış: [Açık ✅]"
        btn.BackgroundColor3 = Theme.Active
    else
        btn.Text = "💥 Öne Yapış: [Kapalı ❌]"
        btn.BackgroundColor3 = Theme.Card
    end
end)

Players.PlayerAdded:Connect(function(p)
    local inputName = string.lower(TargetInput.Text)
    if inputName ~= "" and (string.find(string.lower(p.Name), inputName) or string.find(string.lower(p.DisplayName), inputName)) then
        TargetPlayer = p
        TargetJoinCount = TargetJoinCount + 1
        JoinCard.Text = "📥 Hedef Giriş Sayısı: " .. tostring(TargetJoinCount)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if TargetPlayer and p == TargetPlayer then
        TargetLeaveCount = TargetLeaveCount + 1
        LeaveCard.Text = "🚪 Hedef Çıkış Sayısı: " .. tostring(TargetLeaveCount)
    end
end)

RunService.RenderStepped:Connect(function()
    local myChar = Player.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = TargetPlayer.Character.HumanoidRootPart
        local fastTime = tick() * 18
        local bounceOffset = math.sin(fastTime) * 1.2
        if AttachBehind then
            myChar.HumanoidRootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.2 + bounceOffset)
        elseif AttachInFront then
            myChar.HumanoidRootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 2.2, -0.7 - bounceOffset) * CFrame.Angles(0, math.pi, 0)
        end
    end
end)

-- 3️⃣ [3. Savunma]
local DefensePage = createPage(true)
local DefenseListLayout = Instance.new("UIListLayout", DefensePage)
DefenseListLayout.SortOrder = Enum.SortOrder.LayoutOrder
DefenseListLayout.Padding = UDim.new(0, 5)

local function applyRedESP(p)
    if p ~= Player then
        p.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if ESPActive and char:FindFirstChild("Head") and not char.Head:FindFirstChild("RedESP") then
                local bg = Instance.new("BillboardGui", char.Head)
                bg.Name = "RedESP"
                bg.Size = UDim2.new(0, 100, 0, 30)
                bg.StudsOffset = Vector3.new(0, 2.5, 0)
                bg.AlwaysOnTop = true
                local lbl = Instance.new("TextLabel", bg)
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = p.Name
                lbl.TextColor3 = Color3.fromRGB(255, 40, 40)
                lbl.TextSize = 12
                lbl.Font = Enum.Font.GothamBold
            end
        end)
    end
end

for _, p in pairs(Players:GetPlayers()) do applyRedESP(p) end
Players.PlayerAdded:Connect(applyRedESP)

local function createDefBtnVertical(text, callback)
    local Btn = Instance.new("TextButton", DefensePage)
    Btn.Size = UDim2.new(1, -6, 0, 30)
    Btn.Text = text
    Btn.BackgroundColor3 = Theme.Card
    Btn.BackgroundTransparency = 0.2
    Btn.TextColor3 = Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Btn.BorderSizePixel = 0
    Btn.ZIndex = 2
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Theme.Active or Theme.Card
        callback(state, Btn)
    end)
    return Btn
end

createDefBtnVertical("👁️ Kırmızı Oyuncu İsimleri (ESP)", function(state)
    ESPActive = state
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("Head") then
            local old = p.Character.Head:FindFirstChild("RedESP")
            if ESPActive then
                if not old then
                    local bg = Instance.new("BillboardGui", p.Character.Head)
                    bg.Name = "RedESP"
                    bg.Size = UDim2.new(0, 100, 0, 30)
                    bg.StudsOffset = Vector3.new(0, 2.5, 0)
                    bg.AlwaysOnTop = true
                    local lbl = Instance.new("TextLabel", bg)
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = p.Name
                    lbl.TextColor3 = Color3.fromRGB(255, 40, 40)
                    lbl.TextSize = 12
                    lbl.Font = Enum.Font.GothamBold
                end
            else
                if old then old:Destroy() end
            end
        end
    end
end)

createDefBtnVertical("💥 Anti-Bang (Koruma)", function(state, btn)
    AntiBangActive = state
    if AntiBangActive then
        btn.Text = "💥 Anti-Bang [Açık ✅]"
        task.spawn(function()
            pcall(function()
                loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Invisible-87066"))()
            end)
        end)
    else
        btn.Text = "💥 Anti-Bang (Koruma)"
    end
end)

createDefBtnVertical("⚡ Ultra Instinct (Otomatik Kaçış)", function(state, btn)
    UltraInstinctActive = state
    if UltraInstinctActive then
        btn.Text = "⚡ Ultra Instinct [Açık ✅]"
    else
        btn.Text = "⚡ Ultra Instinct (Otomatik Kaçış)"
    end
end)

local SliderFrame = Instance.new("Frame", DefensePage)
SliderFrame.Size = UDim2.new(1, -6, 0, 38)
SliderFrame.BackgroundColor3 = Theme.Card
SliderFrame.BackgroundTransparency = 0.2
SliderFrame.BorderSizePixel = 0
SliderFrame.ZIndex = 2
Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

local SliderLabel = Instance.new("TextLabel", SliderFrame)
SliderLabel.Size = UDim2.new(1, 0, 0, 16)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "📏 Kaçış Mesafesi: " .. tostring(UltraInstinctDistance) .. " metre"
SliderLabel.TextColor3 = Theme.Accent
SliderLabel.Font = Enum.Font.GothamBold
SliderLabel.TextSize = 10
SliderLabel.ZIndex = 3

local SliderTrack = Instance.new("Frame", SliderFrame)
SliderTrack.Size = UDim2.new(0.9, 0, 0, 5)
SliderTrack.Position = UDim2.new(0.05, 0, 0.65, 0)
SliderTrack.BackgroundColor3 = Color3.fromRGB(45, 38, 65)
SliderTrack.BorderSizePixel = 0
SliderTrack.ZIndex = 3
Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame", SliderTrack)
SliderFill.Size = UDim2.new((UltraInstinctDistance - 1) / 9, 0, 1, 0)
SliderFill.BackgroundColor3 = Theme.Accent
SliderFill.BorderSizePixel = 0
SliderFill.ZIndex = 4
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

local UserInputService = game:GetService("UserInputService")
local isDragging = false

local function updateSlider(input)
    local pos = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
    UltraInstinctDistance = math.floor(1 + (pos * 9))
    SliderFill.Size = UDim2.new((UltraInstinctDistance - 1) / 9, 0, 1, 0)
    SliderLabel.Text = "📏 Kaçış Mesafesi: " .. tostring(UltraInstinctDistance) .. " metre"
end

SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- 4️⃣ [4. Korumalar]
local ProtectionsPage = createPage(true)
local ProtListLayout = Instance.new("UIListLayout", ProtectionsPage)
ProtListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ProtListLayout.Padding = UDim.new(0, 5)

local function createVerticalProtBtn(name, callback)
    local Btn = Instance.new("TextButton", ProtectionsPage)
    Btn.Size = UDim2.new(1, -6, 0, 30)
    Btn.Text = name
    Btn.BackgroundColor3 = Theme.Card
    Btn.BackgroundTransparency = 0.2
    Btn.TextColor3 = Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Btn.BorderSizePixel = 0
    Btn.ZIndex = 2
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Theme.Active or Theme.Card
        callback(state, Btn)
    end)
end

createVerticalProtBtn("🪑 Oturma Koruması (Anti-Sit)", function(s) 
    AntiSit = s 
    if AntiSit and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        hum.Sit = false
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
end)

createVerticalProtBtn("🌀 Fling Koruması (Anti-Fling)", function(s) AntiFling = s end)

createVerticalProtBtn("🎵 Rahatsız Edici Ses Koruması", function(s)
    AntiMusicActive = s
    if AntiMusicActive then
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("Sound") then
                pcall(function()
                    obj:Stop()
                    obj.Volume = 0
                end)
            end
        end
    end
end)

createVerticalProtBtn("👤 Dev/Devasa Cilt Koruması", function(s)
    AntiGiantSkinsActive = s
    if AntiGiantSkinsActive then
        task.spawn(function()
            while AntiGiantSkinsActive do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= Player and p.Character then
                        local char = p.Character
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                if part.Size.X > 15 or part.Size.Y > 15 or part.Size.Z > 15 then
                                    pcall(function() part:Destroy() end)
                                end
                            end
                        end
                    end
                end
                task.wait(1.5)
            end
        end)
    end
end)

createVerticalProtBtn("👕 Kıyafet Kopyalama Koruması", function(s)
    AntiCopyOutfit = s
    local myChar = Player.Character
    if myChar then
        for _, v in pairs(myChar:GetChildren()) do
            if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") or v:IsA("ShirtGraphic") then
                if AntiCopyOutfit then v.Name = "Protected_Item" end
            end
        end
    end
end)

createVerticalProtBtn("🛠️ Brookhaven Eşya Lag Koruması", function(s)
    AntiBrookhavenToolLag = s
    if AntiBrookhavenToolLag then
        task.spawn(function()
            for _, item in pairs(workspace:GetDescendants()) do
                if item:IsA("Tool") or item:IsA("Accessory") then
                    if not item:IsDescendantOf(Player.Character) and not Players:GetPlayerFromCharacter(item.Parent) then
                        pcall(function() item:Destroy() end)
                    end
                end
            end
        end)
    end
end)

createVerticalProtBtn("⚡ Genel Lag Önleyici", function(s)
    AntiLag = s
    if AntiLag then
        pcall(function()
            settings().Rendering.QualityLevel = 1
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
            end
        end)
    end
end)

createVerticalProtBtn("🕳️ Boşluk (Void) Koruması", function(s) AntiVoid = s end)
createVerticalProtBtn("⏰ AFK Kalma Koruması", function(s) AntiAFK = s end)

-- 5️⃣ [5. Popüler Scriptler]
local ScriptsPage = createPage(true)
local ScriptsLayout = Instance.new("UIListLayout", ScriptsPage)
ScriptsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ScriptsLayout.Padding = UDim.new(0, 5)

local function createScriptBtnVertical(btnName, url)
	local Btn = Instance.new("TextButton", ScriptsPage)
	Btn.Size = UDim2.new(1, -6, 0, 30)
	Btn.Text = btnName
	Btn.BackgroundColor3 = Theme.Card
	Btn.BackgroundTransparency = 0.2
	Btn.TextColor3 = Theme.Text
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 10
	Btn.BorderSizePixel = 0
	Btn.ZIndex = 2
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
	
	Btn.MouseButton1Click:Connect(function()
		task.spawn(function()
			pcall(function() loadstring(game:HttpGet(url))() end)
		end)
	end)
end

local function createKillPointScriptBtn(btnName, scriptFunction)
	local Btn = Instance.new("TextButton", ScriptsPage)
	Btn.Size = UDim2.new(1, -6, 0, 30)
	Btn.Text = btnName
	Btn.BackgroundColor3 = Theme.Card
	Btn.BackgroundTransparency = 0.2
	Btn.TextColor3 = Theme.Text
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 10
	Btn.BorderSizePixel = 0
	Btn.ZIndex = 2
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
	
	Btn.MouseButton1Click:Connect(function()
		task.spawn(function()
			pcall(scriptFunction)
		end)
	end)
end

createKillPointScriptBtn("Kill Point Tracker 🎯", function()
    local KP_ScreenGui = Instance.new("ScreenGui")
    local KP_MainFrame = Instance.new("Frame")
    local KP_Title = Instance.new("TextLabel")
    local KP_TextBox = Instance.new("TextBox")
    local KP_TrackButton = Instance.new("TextButton")
    local KP_ResultLabel = Instance.new("TextLabel")
    local KP_AvatarImage = Instance.new("ImageLabel")
    local KP_AvatarCorner = Instance.new("UICorner")

    KP_ScreenGui.Parent = game.CoreGui or game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local KP_LogoButton = Instance.new("ImageButton")
    local KP_LogoCorner = Instance.new("UICorner")
    local KP_LogoStroke = Instance.new("UIStroke")

    KP_LogoButton.Name = "KillPointLogo"
    KP_LogoButton.Parent = KP_ScreenGui
    KP_LogoButton.Position = UDim2.new(0.02, 0, 0.4, 0)
    KP_LogoButton.Size = UDim2.new(0, 60, 0, 60)
    KP_LogoButton.Image = "rbxassetid://106318991316694"
    KP_LogoButton.Active = true
    KP_LogoButton.Draggable = true

    KP_LogoCorner.CornerRadius = UDim.new(1, 0)
    KP_LogoCorner.Parent = KP_LogoButton

    KP_LogoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    KP_LogoStroke.Color = Color3.fromRGB(255, 255, 255)
    KP_LogoStroke.Thickness = 2
    KP_LogoStroke.Parent = KP_LogoButton

    KP_MainFrame.Parent = KP_ScreenGui
    KP_MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    KP_MainFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
    KP_MainFrame.Size = UDim2.new(0, 320, 0, 280)
    KP_MainFrame.Active = true
    KP_MainFrame.Draggable = true
    KP_MainFrame.Visible = true

    local KP_Corner = Instance.new("UICorner")
    KP_Corner.CornerRadius = UDim.new(0, 10)
    KP_Corner.Parent = KP_MainFrame

    KP_Title.Parent = KP_MainFrame
    KP_Title.BackgroundTransparency = 1
    KP_Title.Position = UDim2.new(0, 0, 0, 8)
    KP_Title.Size = UDim2.new(1, 0, 0, 30)
    KP_Title.Font = Enum.Font.SourceSansBold
    KP_Title.Text = "Sunucu Oyuncu Takibi - Brookhaven"
    KP_Title.TextColor3 = Color3.fromRGB(200, 185, 155)
    KP_Title.TextSize = 16

    KP_TextBox.Parent = KP_MainFrame
    KP_TextBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    KP_TextBox.Position = UDim2.new(0.1, 0, 0.16, 0)
    KP_TextBox.Size = UDim2.new(0.8, 0, 0, 35)
    KP_TextBox.Font = Enum.Font.SourceSans
    KP_TextBox.PlaceholderText = "İlk harfleri yazın..."
    KP_TextBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    KP_TextBox.Text = ""
    KP_TextBox.TextColor3 = Color3.fromRGB(245, 240, 230)
    KP_TextBox.TextSize = 16
    Instance.new("UICorner", KP_TextBox).CornerRadius = UDim.new(0, 6)

    KP_TrackButton.Parent = KP_MainFrame
    KP_TrackButton.BackgroundColor3 = Color3.fromRGB(200, 185, 155)
    KP_TrackButton.Position = UDim2.new(0.2, 0, 0.31, 0)
    KP_TrackButton.Size = UDim2.new(0.6, 0, 0, 32)
    KP_TrackButton.Font = Enum.Font.SourceSansBold
    KP_TrackButton.Text = "Takibi Başlat"
    KP_TrackButton.TextColor3 = Color3.fromRGB(40, 40, 40)
    KP_TrackButton.TextSize = 16
    Instance.new("UICorner", KP_TrackButton).CornerRadius = UDim.new(0, 6)

    KP_AvatarImage.Parent = KP_MainFrame
    KP_AvatarImage.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    KP_AvatarImage.Position = UDim2.new(0.08, 0, 0.47, 0)
    KP_AvatarImage.Size = UDim2.new(0, 75, 0, 75)
    KP_AvatarImage.Image = ""
    KP_AvatarImage.Visible = false

    KP_AvatarCorner.CornerRadius = UDim.new(0, 10)
    KP_AvatarCorner.Parent = KP_AvatarImage

    KP_ResultLabel.Parent = KP_MainFrame
    KP_ResultLabel.BackgroundTransparency = 1
    KP_ResultLabel.Position = UDim2.new(0.35, 0, 0.45, 0)
    KP_ResultLabel.Size = UDim2.new(0.6, 0, 0, 90)
    KP_ResultLabel.Font = Enum.Font.SourceSans
    KP_ResultLabel.Text = "İsim girip takibe başlayın..."
    KP_ResultLabel.TextColor3 = Color3.fromRGB(245, 240, 230)
    KP_ResultLabel.TextSize = 15
    KP_ResultLabel.TextXAlignment = Enum.TextXAlignment.Left
    KP_ResultLabel.TextYAlignment = Enum.TextYAlignment.Top
    KP_ResultLabel.TextWrapped = true

    KP_LogoButton.MouseButton1Click:Connect(function()
        KP_MainFrame.Visible = not KP_MainFrame.Visible
    end)

    local killCounts = {}
    local currentTrackID = 0

    local function monitorPlayer(player)
        killCounts[player.Name] = killCounts[player.Name] or 0
        player.CharacterAdded:Connect(function(char)
            local humanoid = char:WaitForChild("Humanoid", 5)
            if humanoid then
                humanoid.Died:Connect(function()
                    killCounts[player.Name] = killCounts[player.Name] + 1
                end)
            end
        end)
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Died:Connect(function()
                    killCounts[player.Name] = killCounts[player.Name] + 1
                end)
            end
        end
    end

    for _, player in pairs(game.Players:GetPlayers()) do
        monitorPlayer(player)
    end
    game.Players.PlayerAdded:Connect(monitorPlayer)

    KP_TrackButton.MouseButton1Click:Connect(function()
        local input = KP_TextBox.Text:lower()
        local foundPlayer = nil
        currentTrackID = currentTrackID + 1
        local myTrackID = currentTrackID
        
        if #input > 0 then
            for _, player in pairs(game.Players:GetPlayers()) do
                local name = player.Name:lower()
                local displayName = player.DisplayName:lower()
                if string.sub(name, 1, #input) == input or string.sub(displayName, 1, #input) == input then
                    foundPlayer = player
                    break
                end
            end
        end
        
        if foundPlayer then
            local thumbType = Enum.ThumbnailType.HeadShot
            local thumbSize = Enum.ThumbnailSize.Size100x100
            local content, isReady = game.Players:GetUserThumbnailAsync(foundPlayer.UserId, thumbType, thumbSize)
            
            KP_AvatarImage.Image = content
            KP_AvatarImage.Visible = true
            KP_ResultLabel.Position = UDim2.new(0.35, 0, 0.45, 0)
            KP_ResultLabel.Size = UDim2.new(0.6, 0, 0, 110)

            task.spawn(function()
                while foundPlayer and foundPlayer.Parent == game.Players and currentTrackID == myTrackID do
                    KP_ResultLabel.Text = "Kullanıcı: " .. foundPlayer.Name .. 
                                     "\nGörünen Ad: " .. foundPlayer.DisplayName .. 
                                     "\nÖlüm Sayısı: " .. (killCounts[foundPlayer.Name] or 0)
                    task.wait(0.5)
                end
            end)
        else
            KP_AvatarImage.Visible = false
            KP_ResultLabel.Position = UDim2.new(0.05, 0, 0.47, 0)
            KP_ResultLabel.Size = UDim2.new(0.9, 0, 0, 60)
            KP_ResultLabel.Text = "Bu isimle eşleşen oyuncu bulunamadı!"
        end
    end)
end)


-- 6️⃣ [6. Sohbet Scriptleri]
local ChatPage = createPage(true)
local ChatLayout = Instance.new("UIListLayout", ChatPage)
ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder
ChatLayout.Padding = UDim.new(0, 5)

local function createChatScriptBtn(btnName, url)
	local Btn = Instance.new("TextButton", ChatPage)
	Btn.Size = UDim2.new(1, -6, 0, 30)
	Btn.Text = btnName
	Btn.BackgroundColor3 = Theme.Card
	Btn.BackgroundTransparency = 0.2
	Btn.TextColor3 = Theme.Text
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 10
	Btn.BorderSizePixel = 0
	Btn.ZIndex = 2
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
	
	Btn.MouseButton1Click:Connect(function()
		task.spawn(function()
			pcall(function() loadstring(game:HttpGet(url))() end)
		end)
	end)
end


-- 7️⃣ [7. Kostümler / Sكنات]
local SkinPage = createPage(true)
local SkinLayout = Instance.new("UIListLayout", SkinPage)
SkinLayout.SortOrder = Enum.SortOrder.LayoutOrder
SkinLayout.Padding = UDim.new(0, 5)

local SkinInput = Instance.new("TextBox", SkinPage)
SkinInput.Size = UDim2.new(1, -6, 0, 30)
SkinInput.PlaceholderText = "Oyuncu adının ilk harfleri..."
SkinInput.Text = ""
SkinInput.BackgroundColor3 = Theme.Card
SkinInput.BackgroundTransparency = 0.2
SkinInput.TextColor3 = Theme.Text
SkinInput.Font = Enum.Font.Gotham
SkinInput.TextSize = 10
SkinInput.BorderSizePixel = 0
SkinInput.ZIndex = 2
Instance.new("UICorner", SkinInput).CornerRadius = UDim.new(0, 6)

local CopySkinBtn = Instance.new("TextButton", SkinPage)
CopySkinBtn.Size = UDim2.new(1, -6, 0, 32)
CopySkinBtn.Text = "👕 Oyuncu Kıyafetini Kopyala"
CopySkinBtn.BackgroundColor3 = Theme.Accent
CopySkinBtn.TextColor3 = Theme.Bg
CopySkinBtn.Font = Enum.Font.GothamBold
CopySkinBtn.TextSize = 10
CopySkinBtn.BorderSizePixel = 0
CopySkinBtn.ZIndex = 2
Instance.new("UICorner", CopySkinBtn).CornerRadius = UDim.new(0, 6)

CopySkinBtn.MouseButton1Click:Connect(function()
    local target = getTarget(SkinInput.Text)
    if target and target.Character then
        local myChar = Player.Character
        if myChar then
            for _, item in pairs(myChar:GetChildren()) do
                if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("BodyColors") or item:IsA("Accessory") then
                    item:Destroy()
                end
            end
            for _, item in pairs(target.Character:GetChildren()) do
                if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("BodyColors") then
                    item:Clone().Parent = myChar
                elseif item:IsA("Accessory") then
                    item:Clone().Parent = myChar
                end
            end
            CopySkinBtn.Text = "✅ Başarıyla Kopyalandı!"
            task.wait(2)
            CopySkinBtn.Text = "👕 Oyuncu Kıyafetini Kopyala"
        end
    else
        CopySkinBtn.Text = "❌ Oyuncu Bulunamadı!"
        task.wait(2)
        CopySkinBtn.Text = "👕 Oyuncu Kıyafetini Kopyala"
    end
end)

-- [Arka Plan Koruma İşlemleri]
game.DescendantAdded:Connect(function(child)
    if AntiMusicActive and child:IsA("Sound") then
        task.wait()
        pcall(function()
            child:Stop()
            child.Volume = 0
        end)
    end
end)

RunService.Stepped:Connect(function()
    local myChar = Player.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    if AntiSit then 
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.Sit then 
                hum.Sit = false 
                hum:ChangeState(Enum.HumanoidStateType.Running)
                hum.Jump = true
            end
        end
    end

    if AntiFling then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= Player and otherPlayer.Character then
                for _, part in pairs(otherPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    end

    if AntiVoid and myChar.HumanoidRootPart.Position.Y < -50 then 
        myChar.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0) 
    end
end)

RunService.RenderStepped:Connect(function()
    local myChar = Player.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") and UltraInstinctActive then
        local myRoot = myChar.HumanoidRootPart
        local studDistance = UltraInstinctDistance * 3.57
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= Player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local otherRoot = otherPlayer.Character.HumanoidRootPart
                local distance = (myRoot.Position - otherRoot.Position).Magnitude
                if distance < studDistance then
                    local sideOffset = (math.random() > 0.5 and (studDistance + 2) or -(studDistance + 2))
                    local upOffset = math.random(2, 5)
                    local dodgeVector = (myRoot.CFrame.RightVector * sideOffset) + Vector3.new(0, upOffset, 0)
                    myRoot.CFrame = myRoot.CFrame + dodgeVector
                    myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end)

Player.Idled:Connect(function()
    if AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- 🔘 [Yan Menü Sekmelerini Oluşturma]
local function createTabButton(name, targetPage)
	local TabBtn = Instance.new("TextButton", TabContainer)
	TabBtn.Size = UDim2.new(1, -6, 0, 30)
	TabBtn.Text = name
	TabBtn.BackgroundColor3 = Theme.Sidebar
	TabBtn.BackgroundTransparency = 0.2
	TabBtn.TextColor3 = Theme.Text
	TabBtn.Font = Enum.Font.GothamBold
	TabBtn.TextSize = 10
	TabBtn.BorderSizePixel = 0
	TabBtn.ZIndex = 3
	Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
	
	TabBtn.MouseButton1Click:Connect(function()
		for _, p in pairs({CreditsPage, TargetPage, DefensePage, ProtectionsPage, ScriptsPage, ChatPage, SkinPage}) do p.Visible = false end
		targetPage.Visible = true
	end)
end

createTabButton("Hakkımda 📜", CreditsPage)
createTabButton("Saldırı Sistemi 🎯", TargetPage)
createTabButton("Savunma Sistemi 🛡️", DefensePage)
createTabButton("Korumalar ⚡", ProtectionsPage)
createTabButton("Scriptler 📜", ScriptsPage)
createTabButton("Sohbet Scriptleri 💬", ChatPage)
createTabButton("Kıyafetler 👕", SkinPage)
