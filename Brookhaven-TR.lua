-- Roblox Hizmetleri
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Var olan UI varsa temizle
if game:GetService("CoreGui"):FindFirstChild("UtkuBrookhavenGUI") then
    game:GetService("CoreGui").UtkuBrookhavenGUI:Destroy()
end

-- ScreenGui Oluşturma
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UtkuBrookhavenGUI"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Renk Paleti (Gri & Bej - Utku Özel Tasarım)
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
HeaderTitle.Text = " Brookhaven RP | Utku Mega Hub"
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
local ToolsTab = CreateTab("İşlemler")
local TPTab = CreateTab("Işınlanma")
local HouseTab = CreateTab("Ev / Ban")
local AboutTab = CreateTab("Hakkımda")

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
                SelectedLabel.Text = "Seçilen: " + plr.Name -- Fix below
                SelectedLabel.Text = "Seçilen: " .. plr.Name
            end)
        end
    end
end

CreateButton(TargetTab, "Oyuncu Listesini Yenile", RefreshPlayerList)
RefreshPlayerList()

-- ==================== 1. İŞLEMLER SEKMESİ (VIEW & TP) ====================
local Viewing = false

CreateButton(ToolsTab, "Seçilen Oyuncuyu İzle (View)", function()
    Viewing = not Viewing
    local cam = workspace.CurrentCamera
    
    if Viewing then
        if SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChildOfClass("Humanoid") then
            cam.CameraSubject = SelectedTarget.Character:FindFirstChildOfClass("Humanoid")
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            cam.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end
end)

CreateButton(ToolsTab, "Seçilen Oyuncuya Işınlan", function()
    if SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = SelectedTarget.Character.HumanoidRootPart.CFrame
        end
    end
end)

-- ==================== 2. IŞINLANMA (TELEPORT) SEKMESİ ====================
local Locations = {
    ["Merkez / Spawn"] = Vector3.new(-12, 18, 120),
    ["Karakol / Polis"] = Vector3.new(-140, 18, 180),
    ["Hastane"] = Vector3.new(-220, 18, 50),
    ["Banka"] = Vector3.new(-30, 18, -100),
    ["Okul"] = Vector3.new(-330, 18, 200),
    ["Kasa / Gizli Oda"] = Vector3.new(-50, 20, -110)
}

for name, pos in pairs(Locations) do
    CreateButton(TPTab, name + "'a Işınlan", function() -- syntax fix
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
        end
    end)
end

-- ==================== 3. EV BAN KALDIRMA SEKMESİ ====================
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

-- ==================== 4. HAKKIMDA SEKMESİ ====================
local AboutLabel = Instance.new("TextLabel")
AboutLabel.Parent = AboutTab
AboutLabel.Size = UDim2.new(1, -5, 0, 30)
AboutLabel.BackgroundTransparency = 1
AboutLabel.Text = "Roblox: AMATOR_TURK"
AboutLabel.TextColor3 = BEIGE_ACCENT
AboutLabel.Font = Enum.Font.SourceSansBold
AboutLabel.TextSize = 15

-- Boydan Avatar Görüntüsü (Thumbnail API)
local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Parent = AboutTab
AvatarImage.Size = UDim2.new(0, 140, 0, 140)
AvatarImage.Position = UDim2.new(0.5, -70, 0, 35)
AvatarImage.BackgroundTransparency = 1

-- AMATOR_TURK kullanıcısının ID'sini çekip boydan (FullBody) resmini koyma
task.spawn(function()
    local ok, userId = pcall(function()
        return Players:GetUserIdFromNameAsync("AMATOR_TURK")
    end)
    if ok and userId then
        local thumbOk, thumbUrl = pcall(function()
            return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.和?.ThumbnailSize, Enum.ThumbnailSize.Size420x420)
        end)
        -- Fallback olarak standard headshot/fullbody endpoint
        AvatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
        
        -- Tam boy görünüm için API URL denemesi
        pcall(function()
            local url = "https://thumbnails.roblox.com/v1/users/avatar?userIds=" .. userId .. "&size=420x420&format=Png&isCircular=false"
            local response = HttpService:JSONDecode(game:HttpGet(url))
            if response and response.data and response.data[1] then
                AvatarImage.Image = response.data[1].imageUrl
            end
        end)
    end
end)

-- Instagram Butonu (utku.ss)
local IGButton = Instance.new("TextButton")
IGButton.Parent = AboutTab
IGButton.Size = UDim2.new(1, -5, 0, 35)
IGButton.Position = UDim2.new(0, 0, 0, 185)
IGButton.BackgroundColor3 = BTN_COLOR
IGButton.Text = "Instagram: utku.ss (Tıkla)"
IGButton.TextColor3 = BEIGE_ACCENT
IGButton.Font = Enum.Font.SourceSansBold
IGButton.TextSize = 14

local IGCorners = Instance.new("UICorner")
IGCorners.CornerRadius = UDim.new(0, 6)
IGCorners.Parent = IGButton

IGButton.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard("https://instagram.com/utku.ss")
        end
        if syn and syn.request then
            syn.request({
                Url = "http://127.0.0.1:6463/rpc?v=1",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json", ["Origin"] = "https://discord.com"},
                Body = HttpService:JSONEncode({cmd = "BROWSER_OPEN", args = {href = "https://instagram.com/utku.ss"}, nonce = HttpService:GenerateGUID(false)})
            })
        elseif request then
            request({Url = "https://instagram.com/utku.ss", Method = "GET"})
        end
    end)
end)

-- PC için F tuşu ile gizleme
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
