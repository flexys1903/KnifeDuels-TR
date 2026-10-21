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

-- Yürüme Hızı (WalkSpeed) Ayarı
PlayerSection:NewSlider("Walkspeed", "Karakter hızını değiştirir", 250, 16, function(s)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = s
    end
end)

-- Zıplama Gücü (JumpPower) Ayarı
PlayerSection:NewSlider("Jumppower", "Zıplama yüksekliğini değiştirir", 250, 50, function(j)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").JumpPower = j
        char:FindFirstChildOfClass("Humanoid").UseJumpPower = true
    end
end)

-- Sınırsız Zıplama (Inf Jump)
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

-- 3. AVATAR & KIYAFET (AVATAR COPY) SEKMESİ
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

-- Avatar Kopyalama Butonu
AvatarSection:NewButton("Avatarı Kopyala", "Seçtiğin oyuncunun kıyafet ve görünümünü alır", function()
    local targetPlr = game.Players:FindFirstChild(SelectedAvatarPlayer)
    local myChar = game.Players.LocalPlayer.Character
    
    if targetPlr and targetPlr.Character then
        local targetHumanoid = targetPlr.Character:FindFirstChildOfClass("Humanoid")
        local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
        
        if targetHumanoid and myHumanoid then
            -- HumanoidDescription çekip kendi karakterimize uyguluyoruz
            local success, desc = pcall(function()
                return game.Players:GetHumanoidDescriptionFromUserId(targetPlr.UserId)
            end)
            
            if success and desc then
                myHumanoid:ApplyDescription(desc)
            else
                -- Eğer GetHumanoidDescription çalışmazsa karakter üzerindeki aksesuarları/kıyafetleri kopyalar
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

-- Kendi Avatarına Geri Dön / Sıfrla
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

-- 4. IŞINLANMA (TELEPORT) SEKMESİ
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

-- 5. AYARLAR (SETTINGS) SEKMESİ
local SettingsTab = Window:NewTab("Settings")
local SettingsSection = SettingsTab:NewSection("Arayüz Ayarları")

SettingsSection:NewKeybind("UI Kapat/Aç", "Menüyü gizleyip açar", Enum.KeyCode.F, function()
    Library:ToggleUI()
end)
