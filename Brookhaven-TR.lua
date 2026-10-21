-- Roblox Hizmetleri
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Var olan UI varsa temizle
if game:GetService("CoreGui"):FindFirstChild("UtkuBrookhavenGUI") then
    game:GetService("CoreGui").UtkuBrookhavenGUI:Destroy()
end

-- ScreenGui Oluşturma
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UtkuBrookhavenGUI"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Renk Paleti (Gri & Bej)
local BG_COLOR = Color3.fromRGB(40, 40, 40)       -- Koyu Gri
local HEADER_COLOR = Color3.fromRGB(30, 30, 30)   -- Başlık Grisi
local BEIGE_ACCENT = Color3.fromRGB(200, 185, 155) -- Bej Vurgu Rengi
local BTN_COLOR = Color3.fromRGB(55, 55, 55)      -- Buton Grisi
local TEXT_COLOR = Color3.fromRGB(245, 240, 230)  -- Krem / Bej Yazı

-- 1. YÜZEN AÇ/KAPAT BUTONU (MOBİL & PC)
local ToggleBtn = Instance.new("TextButton")
local ToggleCorner = Instance.new("UICorner")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = BG_COLOR
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Text = "MENU"
ToggleBtn.TextColor3 = BEIGE_ACCENT
ToggleBtn.TextSize = 16
ToggleBtn.Active = true
ToggleBtn.Draggable = true

ToggleCorner.CornerRadius = UDim.new(0, 14)
ToggleCorner.Parent = ToggleBtn

-- 2. ANA PENCERE (MAIN FRAME)
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")
local Header = Instance.new("Frame")
local HeaderTitle = Instance.new("TextLabel")

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 380, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true

MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = HEADER_COLOR
Header.Size = UDim2.new(1, 0, 0, 40)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

HeaderTitle.Parent = Header
HeaderTitle.Size = UDim2.new(1, 0, 1, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = " Brookhaven RP | ig:utku.ss"
HeaderTitle.TextColor3 = BEIGE_ACCENT
HeaderTitle.Font = Enum.Font.SourceSansBold
HeaderTitle.TextSize = 15
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Center

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 3. SEKMELER SİSTEMİ
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.BackgroundColor3 = HEADER_COLOR
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.Size = UDim2.new(0, 105, 1, -40)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 110, 0, 45)
ContentArea.Size = UDim2.new(1, -115, 1, -50)

local Tabs = {}

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = TabBar
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.Position = UDim2.new(0, 0, 0, #Tabs * 32)
    TabBtn.BackgroundColor3 = BTN_COLOR
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = name
    TabBtn.TextColor3 = TEXT_COLOR
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 12

    local Container = Instance.new("ScrollingFrame")
    Container.Parent = ContentArea
    Container.Size = UDim2.new(1, 0, 1, 0)
    Container.BackgroundTransparency = 1
    Container.Visible = false
    Container.CanvasSize = UDim2.new(0, 0, 3.5, 0)
    Container.ScrollBarThickness = 4

    local UIList = Instance.new("UIListLayout")
    UIList.Parent = Container
    UIList.Padding = UDim.new(0, 5)

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Container.Visible = false
            t.Button.BackgroundColor3 = BTN_COLOR
            t.Button.TextColor3 = TEXT_COLOR
        end
        Container.Visible = true
        TabBtn.BackgroundColor3 = BEIGE_ACCENT
        TabBtn.TextColor3 = BG_COLOR
    end)

    table.insert(Tabs, {Button = TabBtn, Container = Container})
    
    if #Tabs == 1 then
        Container.Visible = true
        TabBtn.BackgroundColor3 = BEIGE_ACCENT
        TabBtn.TextColor3 = BG_COLOR
    end

    return Container
end

-- SEKMELERİ OLUŞTUR
local TargetTab = CreateTab("Oyuncu Seç")
local PlayerTab = CreateTab("Player")
local TrollTab = CreateTab("Troll / Fling")
local AvatarTab = CreateTab("Avatar")
local VisualsTab = CreateTab("Visuals")
local HouseTab = CreateTab("Ev / Ban")
local TPTab = CreateTab("Işınlanma")

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(1, -5, 0, 30)
    btn.BackgroundColor3 = BTN_COLOR
    btn.Text = text
    btn.TextColor3 = BEIGE_ACCENT
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Global Seçilen Hedef
local SelectedTarget = nil

-- ==================== 0. OYUNCU SEÇME SEKMESİ ====================
local SelectedLabel = Instance.new("TextLabel")
SelectedLabel.Parent = TargetTab
SelectedLabel.Size = UDim2.new(1, -5, 0, 25)
SelectedLabel.BackgroundTransparency = 1
SelectedLabel.Text = "Seçilen: Yok"
SelectedLabel.TextColor3 = BEIGE_ACCENT
SelectedLabel.Font = Enum.Font.SourceSansBold
SelectedLabel.TextSize = 13

local PlayersFrame = Instance.new("Frame")
PlayersFrame.Parent = TargetTab
PlayersFrame.Size = UDim2.new(1, -5, 0, 180)
PlayersFrame.BackgroundColor3 = HEADER_COLOR

local PlayersScroll = Instance.new("ScrollingFrame")
PlayersScroll.Parent = PlayersFrame
PlayersScroll.Size = UDim2.new(1, 0, 1, 0)
PlayersScroll.BackgroundTransparency = 1
PlayersScroll.CanvasSize = UDim2.new(0, 0, 4, 0)
PlayersScroll.ScrollBarThickness = 4

local PList = Instance.new("UIListLayout")
PList.Parent = PlayersScroll
PList.Padding = UDim.new(0, 3)

local function RefreshPlayerList()
    for _, child in pairs(PlayersScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Parent = PlayersScroll
            pBtn.Size = UDim2.new(1, -5, 0, 25)
            pBtn.BackgroundColor3 = BTN_COLOR
            pBtn.Text = plr.Name
            pBtn.TextColor3 = TEXT_COLOR
            pBtn.Font = Enum.Font.SourceSans
            pBtn.TextSize = 12
            
            pBtn.MouseButton1Click:Connect(function()
                SelectedTarget = plr
                SelectedLabel.Text = "Seçilen: " .. plr.Name
            end)
        end
    end
end

CreateButton(TargetTab, "Oyuncu Listesini Yenile", RefreshPlayerList)
RefreshPlayerList()

-- ==================== 1. PLAYER SEKMESİ ====================
CreateButton(PlayerTab, "Hızlandır (Speed: 50)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 50
    end
end)

CreateButton(PlayerTab, "Süper Hız (Speed: 120)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 120
    end
end)

CreateButton(PlayerTab, "Normal Hız (Speed: 16)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    end
end)

CreateButton(PlayerTab, "Yüksek Zıplama", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 120
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").UseJumpPower = true
    end
end)

CreateButton(PlayerTab, "Inf Jump (Sınırsız Zıplama)", function()
    UserInputService.JumpRequest:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)
end)

local NoclipActive = false
CreateButton(PlayerTab, "Noclip Aç/Kapat (Duvar Geçiş)", function()
    NoclipActive = not NoclipActive
    RunService.Stepped:Connect(function()
        if NoclipActive and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

local Flying = false
CreateButton(PlayerTab, "Uçma Modu (Fly) Aç/Kapat", function()
    Flying = not Flying
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    if Flying then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "UtkuFly"
        bv.MaxForce = Vector3.new(0, 0, 0)
        bv.Velocity = Vector3.new(0,0,0)
        bv.Parent = char.HumanoidRootPart
        
        local bg = Instance.new("BodyGyro")
        bg.Name = "UtkuGyro"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 9e4
        bg.CFrame = char.HumanoidRootPart.CFrame
        bg.Parent = char.HumanoidRootPart
        
        task.spawn(function()
            while Flying do
                task.wait()
                local cam = workspace.CurrentCamera
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Velocity = cam.CFrame.LookVector * 60
                bg.CFrame = cam.CFrame
            end
            if char.HumanoidRootPart:FindFirstChild("UtkuFly") then char.HumanoidRootPart.UtkuFly:Destroy() end
            if char.HumanoidRootPart:FindFirstChild("UtkuGyro") then char.HumanoidRootPart.UtkuGyro:Destroy() end
        end)
    else
        if char.HumanoidRootPart:FindFirstChild("UtkuFly") then char.HumanoidRootPart.UtkuFly:Destroy() end
        if char.HumanoidRootPart:FindFirstChild("UtkuGyro") then char.HumanoidRootPart.UtkuGyro:Destroy() end
    end
end)

-- ==================== 2. TROLL / FLING SEKMESİ ====================
local Flinging = false
CreateButton(TrollTab, "Seçilen Kişiyi Flingle (Fırlat)", function()
    if not SelectedTarget or not SelectedTarget.Character then return end
    Flinging = not Flinging
    
    task.spawn(function()
        local myChar = LocalPlayer.Character
        local targetChar = SelectedTarget.Character
        
        if myChar and targetChar and myChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
            local bvo = Instance.new("BodyAngularVelocity")
            bvo.Name = "FlingVelocity"
            bvo.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bvo.AngularVelocity = Vector3.new(0, 99999, 0)
            bvo.Parent = myChar.HumanoidRootPart
            
            while Flinging and myChar and targetChar and targetChar:FindFirstChild("HumanoidRootPart") do
                myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0)
                RunService.Heartbeat:Wait()
            end
            
            if myChar.HumanoidRootPart:FindFirstChild("FlingVelocity") then
                myChar.HumanoidRootPart.FlingVelocity:Destroy()
            end
        end
    end)
end)

local Spinning = false
CreateButton(TrollTab, "Spin Bot (Karakteri Döndür)", function()
    Spinning = not Spinning
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        if Spinning then
            local spin = Instance.new("BodyAngularVelocity")
            spin.Name = "UtkuSpin"
            spin.MaxTorque = Vector3.new(0, math.huge, 0)
            spin.AngularVelocity = Vector3.new(0, 50, 0)
            spin.Parent = char.HumanoidRootPart
        else
            if char.HumanoidRootPart:FindFirstChild("UtkuSpin") then
                char.HumanoidRootPart.UtkuSpin:Destroy()
            end
        end
    end
end)

-- ==================== 3. AVATAR SEKMESİ (BROOKHAVEN ÖZEL %100 KOPYALAMA) ====================
CreateButton(AvatarTab, "Seçilenin Boyunu & Her Şeyini Kopyala", function()
    if not SelectedTarget then return end
    
    local targetPlr = SelectedTarget
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChildOfClass("Humanoid") then return end
    
    -- 1. ADIM: Brookhaven'ın kendi Avatar Temizleme / Sıfırlama Event'ini Çağır
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        if ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Avatar1Reset1") then
            ReplicatedStorage.RE["1Avatar1Reset1"]:FireServer()
        end
    end)
    
    task.wait(0.2)
    
    -- 2. ADIM: Üstündeki kalan tüm lokal objeleri sök
    for _, item in pairs(myChar:GetChildren()) do
        if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("Accessory") or item:IsA("BodyColors") or item:IsA("WrapLayer") then
            item:Destroy()
        end
    end
    
    task.wait(0.1)
    
    -- 3. ADIM: Hedef Oyuncunun Tüm Avatar Verilerini (HumanoidDescription) İndir
    local success, desc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(targetPlr.UserId)
    end)
    
    if success and desc then
        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        
        -- Vücut Boyutları ve Oranlarını İşle (Boy, En, Kafa)
        if myHum:FindFirstChild("BodyDepthScale") then myHum.BodyDepthScale.Value = desc.BodyDepthScale end
        if myHum:FindFirstChild("BodyHeightScale") then myHum.BodyHeightScale.Value = desc.BodyHeightScale end
        if myHum:FindFirstChild("BodyWidthScale") then myHum.BodyWidthScale.Value = desc.BodyWidthScale end
        if myHum:FindFirstChild("HeadScale") then myHum.HeadScale.Value = desc.HeadScale end
        
        -- Humanoid Description Tam Uygulama
        pcall(function()
            myHum:ApplyDescription(desc)
        end)
    end
    
    -- 4. ADIM: Fiziksel Parçaları ve Katmanlı Kıyafetleri Birebir Klonla
    if targetPlr.Character then
        for _, item in pairs(targetPlr.Character:GetChildren()) do
            if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("Accessory") or item:IsA("BodyColors") or item:IsA("WrapLayer") then
                local clone = item:Clone()
                clone.Parent = myChar
            end
        end
    end
end)

CreateButton(AvatarTab, "Üstündeki Her Şeyi Çıkar", function()
    local myChar = LocalPlayer.Character
    if myChar then
        for _, item in pairs(myChar:GetChildren()) do
            if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("Accessory") or item:IsA("BodyColors") or item:IsA("WrapLayer") then
                item:Destroy()
            end
        end
    end
end)

-- ==================== 4. VISUALS (ESP) SEKMESİ ====================
local ESPEnabled = false
local ESPObjects = {}

CreateButton(VisualsTab, "Oyuncu ESP Aç/Kapat", function()
    ESPEnabled = not ESPEnabled
    
    if not ESPEnabled then
        for _, v in pairs(ESPObjects) do v:Destroy() end
        ESPObjects = {}
    else
        task.spawn(function()
            while ESPEnabled do
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                        local head = plr.Character.Head
                        local myChar = LocalPlayer.Character
                        
                        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                            local dist = math.floor((myChar.HumanoidRootPart.Position - head.Position).Magnitude)
                            local billboard = head:FindFirstChild("UtkuESP")
                            
                            if not billboard then
                                billboard = Instance.new("BillboardGui")
                                billboard.Name = "UtkuESP"
                                billboard.AlwaysOnTop = true
                                billboard.Size = UDim2.new(0, 120, 0, 30)
                                billboard.StudsOffset = Vector3.new(0, 2, 0)
                                billboard.Parent = head
                                table.insert(ESPObjects, billboard)

                                local textLabel = Instance.new("TextLabel")
                                textLabel.Name = "ESPLabel"
                                textLabel.Size = UDim2.new(1, 0, 1, 0)
                                textLabel.BackgroundTransparency = 1
                                textLabel.TextColor3 = BEIGE_ACCENT
                                textLabel.TextSize = 13
                                textLabel.Font = Enum.Font.SourceSansBold
                                textLabel.Parent = billboard
                            end
                            
                            if billboard:FindFirstChild("ESPLabel") then
                                billboard.ESPLabel.Text = plr.Name .. " [" .. tostring(dist) .. "m]"
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end)

-- ==================== 5. EV BAN KALDIRMA SEKMESİ ====================
CreateButton(HouseTab, "Ev Banlarını Kaldır (Unban All)", function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "BanBlock" or obj.Name == "BanBariyer" or obj.Name == "HouseBan" or (obj:IsA("BasePart") and string.find(string.lower(obj.Name), "ban")) then
            obj:Destroy()
        end
    end
    
    if LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v.Name == "Ban" or v.Name == "HouseBan" then
                v:Destroy()
            end
        end
    end
end)

-- ==================== 6. IŞINLANMA (TELEPORT) SEKMESİ ====================
CreateButton(TPTab, "Seçilen Oyuncuya Işınlan", function()
    if SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = SelectedTarget.Character.HumanoidRootPart.CFrame
        end
    end
end)

local Locations = {
    ["Merkez / Spawn"] = Vector3.new(-12, 18, 120),
    ["Karakol / Polis"] = Vector3.new(-140, 18, 180),
    ["Hastane"] = Vector3.new(-220, 18, 50),
    ["Banka"] = Vector3.new(-30, 18, -100),
    ["Okul"] = Vector3.new(-330, 18, 200),
    ["Kasa / Gizli Oda"] = Vector3.new(-50, 20, -110)
}

for name, pos in pairs(Locations) do
    CreateButton(TPTab, name .. "'a Işınlan", function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
        end
    end)
end

-- PC için F tuşu ile gizleme
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
