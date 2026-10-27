-- Roblox Hizmetleri
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

-- Var olan UI varsa temizle
if PlayerGui:FindFirstChild("UtkuBrookhavenGUI") then
    PlayerGui.UtkuBrookhavenGUI:Destroy()
end
if PlayerGui:FindFirstChild("PremiumAvatarCopier") then
    PlayerGui.PremiumAvatarCopier:Destroy()
end
if game:GetService("CoreGui"):FindFirstChild("UtkuBrookhavenGUI") then
    game:GetService("CoreGui").UtkuBrookhavenGUI:Destroy()
end

-- ==================== AVATAR KOPYALAMA DEĞİŞKENLERİ ====================
local FOLDER_NAME = "Catalog Avatar Premium Clipboard"
local FILE_PATH = FOLDER_NAME .. "/SavedOutfits.json"

if makefolder and isfolder then
    if not isfolder(FOLDER_NAME) then
        makefolder(FOLDER_NAME)
    end
end

local copiedAvatars = {}
local copying = false
local selectedPlayer = nil
local holdingCopy = false
local holdStart = 0
local HOLD_TIME = 0.7

local function rgb(c)
    return {
        r = math.floor(c.R * 255),
        g = math.floor(c.G * 255),
        b = math.floor(c.B * 255),
        IsRGBTable = true
    }
end

local function vector(v)
    return {
        X = v.X,
        Y = v.Y,
        Z = v.Z,
        Vector3 = true
    }
end

local function getLayeredAccessories(desc)
    local result = {}
    for _, accessory in pairs(desc:GetAccessories(true)) do
        if accessory.IsLayered then
            table.insert(result, {
                Rotation = vector(accessory.Rotation),
                AssetId = accessory.AssetId,
                AccessoryType = accessory.AccessoryType.Name,
                Position = vector(accessory.Position),
                Order = accessory.Order,
                IsLayered = true,
                Puffiness = accessory.Puffiness,
                Scale = vector(accessory.Scale)
            })
        end
    end
    return result
end

local function createCopiedProperties(desc)
    local props = {
        ["WalkAnimation"] = desc.WalkAnimation,
        ["MoodAnimation"] = desc.MoodAnimation,
        ["ClimbAnimation"] = desc.ClimbAnimation,
        ["FallAnimation"] = desc.FallAnimation,
        ["RunAnimation"] = desc.RunAnimation,
        ["SwimAnimation"] = desc.SwimAnimation,
        ["IdleAnimation"] = desc.IdleAnimation,
        ["JumpAnimation"] = desc.JumpAnimation,

        ["Face"] = desc.Face,
        ["Shirt"] = desc.Shirt,
        ["Pants"] = desc.Pants,
        ["GraphicTShirt"] = desc.GraphicTShirt,

        ["RightArmColor"] = rgb(desc.RightArmColor),
        ["TorsoColor"] = rgb(desc.TorsoColor),
        ["RightLegColor"] = rgb(desc.RightLegColor),
        ["LeftLegColor"] = rgb(desc.LeftLegColor),
        ["LeftArmColor"] = rgb(desc.LeftArmColor),
        ["HeadColor"] = rgb(desc.HeadColor),

        ["Head"] = desc.Head,
        ["Torso"] = desc.Torso,
        ["LeftArm"] = desc.LeftArm,
        ["RightArm"] = desc.RightArm,
        ["LeftLeg"] = desc.LeftLeg,
        ["RightLeg"] = desc.RightLeg,

        ["ProportionScale"] = desc.ProportionScale,
        ["DepthScale"] = desc.DepthScale,
        ["HeightScale"] = desc.HeightScale,
        ["WidthScale"] = desc.WidthScale,
        ["BodyTypeScale"] = desc.BodyTypeScale,
        ["HeadScale"] = desc.HeadScale,

        ["FaceAccessory"] = desc.FaceAccessory,
        ["HairAccessory"] = desc.HairAccessory,
        ["WaistAccessory"] = desc.WaistAccessory,
        ["ShouldersAccessory"] = desc.ShouldersAccessory,
        ["NeckAccessory"] = desc.NeckAccessory,
        ["HatAccessory"] = desc.HatAccessory,
        ["FrontAccessory"] = desc.FrontAccessory,
        ["BackAccessory"] = desc.BackAccessory,

        ["LayeredAccessories"] = getLayeredAccessories(desc),
        ["AccessoryRefinements"] = {}
    }

    pcall(function() props["EyelashAccessory"] = desc.EyelashAccessory end)
    pcall(function() props["EyebrowAccessory"] = desc.EyebrowAccessory end)
    pcall(function() props["MoodAccessory"] = desc.MoodAccessory end)

    return props
end

local function getAvatarSignature(properties, rigType)
    local success, result = pcall(function()
        return HttpService:JSONEncode({
            Properties = properties,
            RigType = tostring(rigType)
        })
    end)
    return success and result or tostring(properties)
end

local function saveToWorkspace()
    if not writefile then return end
    local exportData = {}
    for index, data in ipairs(copiedAvatars) do
        table.insert(exportData, {
            FileName = "@" .. data.Name,
            Name = data.Name,
            DisplayName = data.DisplayName,
            Properties = data.Properties,
            RigType = tostring(data.RigType),
            Signature = data.Signature,
            Order = index
        })
    end
    pcall(function()
        writefile(FILE_PATH, HttpService:JSONEncode(exportData))
    end)
end

-- ScreenGui Oluşturma (Garantili Yerleşim)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UtkuBrookhavenGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

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
local AvatarTab = CreateTab("Avatar")
local TPTab = CreateTab("Işınlanma")
local HouseTab = CreateTab("Ev / Ban")
local VisualsTab = CreateTab("Visuals")
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

-- ==================== 2. AVATAR KOPYALAMA SEKMESİ ====================
local AvatarStatus = Instance.new("TextLabel")
AvatarStatus.Parent = AvatarTab
AvatarStatus.Size = UDim2.new(1, -5, 0, 25)
AvatarStatus.BackgroundTransparency = 1
AvatarStatus.Text = "Kopyalanan Avatar: 0"
AvatarStatus.TextColor3 = BEIGE_ACCENT
AvatarStatus.Font = Enum.Font.SourceSansBold
AvatarStatus.TextSize = 12

local AvatarScroll = Instance.new("ScrollingFrame")
AvatarScroll.Parent = AvatarTab
AvatarScroll.Size = UDim2.new(1, -5, 0, 160)
AvatarScroll.BackgroundColor3 = HEADER_COLOR
AvatarScroll.CanvasSize = UDim2.new(0, 0, 3, 0)
AvatarScroll.ScrollBarThickness = 4

local AvatarLayout = Instance.new("UIListLayout")
AvatarLayout.Parent = AvatarScroll
AvatarLayout.Padding = UDim.new(0, 3)

local function updateAvatarStatus()
    AvatarStatus.Text = "Kopyalanan Avatar: " .. tostring(#copiedAvatars)
end

local function wearCopiedAvatar(data)
    if not data then return end
    local wearPayload = {{
        ["Properties"] = data.Properties,
        ["Action"] = "CreateAndWearHumanoidDescription",
        ["RigType"] = data.RigType
    }}
    pcall(function()
        ReplicatedStorage.Events.CatalogGuiRemote:InvokeServer(unpack(wearPayload))
    end)
end

local function createAvatarEntry(data, index)
    local Entry = Instance.new("Frame")
    Entry.Size = UDim2.new(1, -5, 0, 30)
    Entry.BackgroundColor3 = BTN_COLOR
    Entry.Parent = AvatarScroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Entry

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -65, 1, 0)
    NameLabel.Position = UDim2.new(0, 5, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = "@" .. data.Name
    NameLabel.TextColor3 = TEXT_COLOR
    NameLabel.TextSize = 11
    NameLabel.Font = Enum.Font.SourceSans
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Entry

    local WearButton = Instance.new("TextButton")
    WearButton.Size = UDim2.new(0, 55, 0, 22)
    WearButton.Position = UDim2.new(1, -60, 0, 4)
    WearButton.BackgroundColor3 = BEIGE_ACCENT
    WearButton.Text = "GİY"
    WearButton.TextColor3 = BG_COLOR
    WearButton.TextSize = 10
    WearButton.Font = Enum.Font.SourceSansBold
    WearButton.Parent = Entry

    local WearCorner = Instance.new("UICorner")
    WearCorner.CornerRadius = UDim.new(0, 4)
    WearCorner.Parent = WearButton

    WearButton.MouseButton1Click:Connect(function()
        wearCopiedAvatar(data)
    end)
end

local function copyForStorage(targetPlayer)
    if copying or not targetPlayer or not targetPlayer.Character then return end
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    copying = true
    local success, data = pcall(function()
        local desc = humanoid:GetAppliedDescription()
        local properties = createCopiedProperties(desc)
        return {
            Name = targetPlayer.Name,
            DisplayName = targetPlayer.DisplayName,
            Properties = properties,
            RigType = humanoid.RigType,
            Signature = getAvatarSignature(properties, humanoid.RigType),
            Order = 1
        }
    end)

    if not success then
        copying = false
        return
    end

    for _, existing in ipairs(copiedAvatars) do
        if existing.Signature == data.Signature then
            copying = false
            return
        end
    end

    table.insert(copiedAvatars, 1, data)
    createAvatarEntry(data, 1)
    saveToWorkspace()
    updateAvatarStatus()

    task.delay(0.3, function()
        copying = false
    end)
end

CreateButton(AvatarTab, "Seçilen Oyuncunun Avatarını Kaydet", function()
    if SelectedTarget then
        copyForStorage(SelectedTarget)
    end
end)

CreateButton(AvatarTab, "Mevcut Kıyafetimi Kaydet", function()
    pcall(function()
        ReplicatedStorage.Events.SavedOutfitsRemote:InvokeServer({
            OutfitName = "Utku Outfit",
            Configs = {},
            Action = "CreateNewOutfit"
        })
    end)
end)

-- ==================== 3. IŞINLANMA (TELEPORT) SEKMESİ ====================
local Locations = {
    ["Merkez / Spawn"] = Vector3.new(-12, 18, 120),
    ["Karakol / Polis"] = Vector3.new(-140, 18, 180),
    ["Hastane"] = Vector3.new(-220, 18, 50),
    ["Banka"] = Vector3.new(-30, 18, -100),
    ["Okul"] = Vector3.new(-330, 18, 200),
    ["Kasa / Gizli Oda"] = Vector3.new(-50, 20, -110)
}

for name, pos in pairs(Locations) do
    CreateButton(TPTab, name .. " Işınlan", function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
        end
    end)
end

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

-- ==================== 5. VISUALS (ESP) SEKMESİ ====================
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

-- ==================== 6. HAKKIMDA SEKMESİ ====================
local AboutLabel = Instance.new("TextLabel")
AboutLabel.Parent = AboutTab
AboutLabel.Size = UDim2.new(1, -5, 0, 30)
AboutLabel.BackgroundTransparency = 1
AboutLabel.Text = "Roblox: AMATOR_TURK"
AboutLabel.TextColor3 = BEIGE_ACCENT
AboutLabel.Font = Enum.Font.SourceSansBold
AboutLabel.TextSize = 15

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Parent = AboutTab
AvatarImage.Size = UDim2.new(0, 140, 0, 140)
AvatarImage.Position = UDim2.new(0.5, -70, 0, 35)
AvatarImage.BackgroundTransparency = 1

task.spawn(function()
    local ok, userId = pcall(function()
        return Players:GetUserIdFromNameAsync("AMATOR_TURK")
    end)
    if ok and userId then
        AvatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
    end
end)

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
            IGButton.Text = "Link Kopyalandı!"
            task.wait(1.5)
            IGButton.Text = "Instagram: utku.ss (Tıkla)"
        end
    end)
end)

-- PC için F tuşu ile gizleme
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
