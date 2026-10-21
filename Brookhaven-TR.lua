-- Kavo UI Kütüphanesini Yükle
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Brookhaven | Utku Özel Versiyon", "Sentinel")

-- 1. ANA SAYFA (HOME) SEKMESİ
local Home = Window:NewTab("Home")
local HomeSection = Home:NewSection("Genel Bilgi")

HomeSection:NewLabel("Hoş geldin, Utku!")
HomeSection:NewLabel("Bu script senin için özel tasarlandı.")
HomeSection:NewLabel("Oyun: Brookhaven RP")

-- 2. OYUNCU (PLAYER) SEKMESİ
local PlayerTab = Window:NewTab("Player")
local PlayerSection = PlayerTab:NewSection("Karakter Ayarları")

PlayerSection:NewSlider("Walkspeed", "Karakter hızını değiştirir", 250, 16, function(s)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = s
    end
end)

PlayerSection:NewSlider("Jumppower", "Zıplama yüksekliğini değiştirir", 250, 50, function(j)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").JumpPower = j
        char:FindFirstChildOfClass("Humanoid").UseJumpPower = true
    end
end)

PlayerSection:NewButton("Inf Jumps", "Havada sınırsız zıplamanı sağlar", function()
    local InfiniteJumpEnabled = true
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if InfiniteJumpEnabled then
            local humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState("Jumping")
            end
        end
    end)
end)

-- 3. GÖRSEL / ESP (VISUALS) SEKMESİ
local VisualsTab = Window:NewTab("Visuals")
local VisualsSection = VisualsTab:NewSection("ESP & Göstergeler")

local ESPEnabled = false
local ESPObjects = {}

local function ClearESP()
    for _, esp in pairs(ESPObjects) do
        if esp then esp:Destroy() end
    end
    ESPObjects = {}
end

VisualsSection:NewToggle("Oyuncu ESP (İsim & Mesafe)", "Duvar arkasından oyuncuları ve mesafeyi gösterir", function(state)
    ESPEnabled = state
    if not ESPEnabled then
        ClearESP()
    else
        task.spawn(function()
            while ESPEnabled do
                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                        local head = plr.Character.Head
                        local myChar = game.Players.LocalPlayer.Character
                        
                        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                            local dist = math.floor((myChar.HumanoidRootPart.Position - head.Position).Magnitude)
                            local billboard = head:FindFirstChild("UtkuESP")
                            
                            if not billboard then
                                billboard = Instance.new("BillboardGui")
                                billboard.Name = "UtkuESP"
                                billboard.AlwaysOnTop = true
                                billboard.Size = UDim2.new(0, 150, 0, 40)
                                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                                billboard.Parent = head
                                table.insert(ESPObjects, billboard)

                                local textLabel = Instance.new("TextLabel")
                                textLabel.Name = "ESPLabel"
                                textLabel.Size = UDim2.new(1, 0, 1, 0)
                                textLabel.BackgroundTransparency = 1
                                textLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                                textLabel.TextStrokeTransparency = 0
                                textLabel.TextScaled = false
                                textLabel.TextSize = 14
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
            ClearESP()
        end)
    end
end)

-- 4. AVATAR SEKMESİ
local AvatarTab = Window:NewTab("Avatar")
local AvatarSection = AvatarTab:NewSection("Avatar Kopyalama")

local PlayerList = {}
for _, v in pairs(game:GetService("Players"):GetChildren()) do
    if v ~= game.Players.LocalPlayer then
        table.insert(PlayerList, v.Name)
    end
end

local SelectedAvatarPlayer = ""
AvatarSection:NewDropdown("Oyuncu Seç", "Kıyafetini almak istediğin kişiyi seç", PlayerList, function(t)
    SelectedAvatarPlayer = t
end)

AvatarSection:NewButton("Avatarı Kopyala", "Seçtiğin oyuncunun kıyafet ve görünümünü alır", function()
    local targetPlr = game.Players:FindFirstChild(SelectedAvatarPlayer)
    local myChar = game.Players.LocalPlayer.Character
    
    if targetPlr and targetPlr.Character then
        local targetHumanoid = targetPlr.Character:FindFirstChildOfClass("Humanoid")
        local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
        
        if targetHumanoid and myHumanoid then
            local success, desc = pcall(function()
                return game.Players:GetHumanoidDescriptionFromUserId(targetPlr.UserId)
            end)
            
            if success and desc then
                myHumanoid:ApplyDescription(desc)
            else
                for _, item in pairs(targetPlr.Character:GetChildren()) do
                    if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("Accessory") then
                        local clonedItem = item:Clone()
                        clonedItem.Parent = myChar
                    end
                end
            end
        end
    end
end)

AvatarSection:NewButton("Kendi Avatarına Dön", "Kendi orijinal avatarını yükler", function()
    local myChar = game.Players.LocalPlayer.Character
    local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if myHumanoid then
        local desc = game.Players:GetHumanoidDescriptionFromUserId(game.Players.LocalPlayer.UserId)
        if desc then
            myHumanoid:ApplyDescription(desc)
        end
    end
end)

-- 5. BROOKHAVEN ÖZEL (EV & BAN) SEKMESİ
local HouseTab = Window:NewTab("Ev / World")
local HouseSection = HouseTab:NewSection("Ev Kısıtlamaları")

HouseSection:NewButton("Ev Banlarını Kaldır (Unban All)", "Seni banlayan evlerin kapı/ban engellerini söker", function()
    local count = 0
    -- Brookhaven ev sistemindeki ban/bariyer nesnelerini temizler
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "BanBlock" or obj.Name == "BanBariyer" or obj.Name == "HouseBan" or (obj:IsA("BasePart") and string.find(string.lower(obj.Name), "ban")) then
            obj:Destroy()
            count = count + 1
        end
    end
    
    -- Karakterdeki ban durumunu resetleme
    local plr = game.Players.LocalPlayer
    if plr and plr.Character then
        for _, v in pairs(plr.Character:GetDescendants()) do
            if v.Name == "Ban" or v.Name == "HouseBan" then
                v:Destroy()
            end
        end
    end
end)

-- 6. IŞINLANMA (TELEPORT) SEKMESİ
local TP = Window:NewTab("Teleports")
local TPSection = TP:NewSection("Oyuncu Işınlanma")

local SelectedPlayer = ""
TPSection:NewDropdown("Oyuncu Seç", "Işınlanılacak kişiyi seç", PlayerList, function(t)
    SelectedPlayer = t
end)

TPSection:NewButton("Seçilen Kişiye Işınlan", "Oyuncunun yanına gider", function()
    local target = game.Players:FindFirstChild(SelectedPlayer)
    local localChar = game.Players.LocalPlayer.Character
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and localChar and localChar:FindFirstChild("HumanoidRootPart") then
        localChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
    end
end)

-- 7. AYARLAR (SETTINGS) SEKMESİ
local SettingsTab = Window:NewTab("Settings")
local SettingsSection = SettingsTab:NewSection("Arayüz Ayarları")

SettingsSection:NewKeybind("UI Kapat/Aç", "Menüyü gizleyip açar", Enum.KeyCode.F, function()
    Library:ToggleUI()
end)
