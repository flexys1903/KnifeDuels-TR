-- Roblox Hizmetleri
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
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
MainFrame.Size = UDim2.new(0, 360, 0, 270)
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
HeaderTitle.Text = " Brookhaven RP | Utku Özel Versiyon"
HeaderTitle.TextColor3 = BEIGE_ACCENT
HeaderTitle.Font = Enum.Font.SourceSansBold
HeaderTitle.TextSize = 16
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Menü Açma/Kapatma
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 3. SEKMELER SİSTEMİ
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.BackgroundColor3 = HEADER_COLOR
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.Size = UDim2.new(0, 100, 1, -40)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 105, 0, 45)
ContentArea.Size = UDim2.new(1, -110, 1, -50)

local Tabs = {}

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = TabBar
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.Position = UDim2.new(0, 0, 0, #Tabs * 35)
    TabBtn.BackgroundColor3 = BTN_COLOR
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = name
    TabBtn.TextColor3 = TEXT_COLOR
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 13

    local Container = Instance.new("ScrollingFrame")
    Container.Parent = ContentArea
    Container.Size = UDim2.new(1, 0, 1, 0)
    Container.BackgroundTransparency = 1
    Container.Visible = false
    Container.CanvasSize = UDim2.new(0, 0, 2, 0)
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
local PlayerTab = CreateTab("Player")
local AvatarTab = CreateTab("Avatar")
local VisualsTab = CreateTab("Visuals")
local HouseTab = CreateTab("Ev / Ban")

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(1, -5, 0, 32)
    btn.BackgroundColor3 = BTN_COLOR
    btn.Text = text
    btn.TextColor3 = BEIGE_ACCENT
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ==================== 1. PLAYER SEKMESİ ====================
CreateButton(PlayerTab, "Hızlandır (Speed: 50)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 50
    end
end)

CreateButton(PlayerTab, "Normal Hız (Speed: 16)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    end
end)

CreateButton(PlayerTab, "Yüksek Zıplama", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 100
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

-- ==================== 2. AVATAR SEKMESİ (TEMİZLEYİP KOPYALAMA) ====================
local SelectedPlayer = nil

CreateButton(AvatarTab, "En Yakındaki Oyuncuyu Seç", function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    local closestPlr = nil
    local shortestDist = math.huge
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (myChar.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closestPlr = plr
            end
        end
    end
    
    if closestPlr then
        SelectedPlayer = closestPlr
        print("Seçilen Oyuncu: " .. SelectedPlayer.Name)
    end
end)

-- ÖNCE ÜSTÜNDEKİLERİ TEMİZLE, SONRA KOPYALA
CreateButton(AvatarTab, "Seçilinin Avatarını Kopyala", function()
    if not SelectedPlayer or not SelectedPlayer.Character then return end
    local myChar = LocalPlayer.Character
    local targetChar = SelectedPlayer.Character
    
    if myChar and targetChar then
        -- 1. Aşama: Karakterinin üzerindeki TÜM aksesuar ve kıyafetleri sök
        for _, item in pairs(myChar:GetChildren()) do
            if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("Accessory") or item:IsA("BodyColors") then
                item:Destroy()
            end
        end
        
        -- Bekleme ekleyerek kıyafetlerin tamamen kaldırıldığından emin olalım
        task.wait(0.1)
        
        -- 2. Aşama: Hedef oyuncunun kıyafet ve aksesuarlarını klonlayıp giydir
        for _, item in pairs(targetChar:GetChildren()) do
            if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("Accessory") or item:IsA("BodyColors") then
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
            if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("Accessory") then
                item:Destroy()
            end
        end
    end
end)

-- ==================== 3. VISUALS (ESP) SEKMESİ ====================
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

-- ==================== 4. EV BAN KALDIRMA SEKMESİ ====================
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

-- PC için F tuşu ile gizleme
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
