--[========================================================================]--
--  Script Name : flexys1903
--  Theme       : Bej & Gri (Beige & Gray) + Atatürk Sayfası + Mobil Destek
--  Status      : Tamamen Düzeltildi & Stabil Hale Getirildi
--[========================================================================]--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

------------------------------------------------------------------------------
-- 1. ORIJINAL OUTFIT STEAL/VIEW MANTIĞI (DOKUNULMADI / BOZULMADI)
------------------------------------------------------------------------------

local function locateRemote()
	local events = ReplicatedStorage:FindFirstChild("Events")
	if events then
		local remote = events:FindFirstChild("CatalogGuiRemote")
		if remote then return remote end
	end
	local remote = ReplicatedStorage:FindFirstChild("CatalogGuiRemote")
	if remote then return remote end
	for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
		if desc.Name == "CatalogGuiRemote" and (desc:IsA("RemoteFunction") or desc:IsA("RemoteEvent")) then
			return desc
		end
	end
end

local function locateInspector()
	local events = ReplicatedStorage:FindFirstChild("Events")
	if events then
		local remote = events:FindFirstChild("ClientInspectHumanoidDescription")
		if remote then return remote end
	end
	local remote = ReplicatedStorage:FindFirstChild("ClientInspectHumanoidDescription")
	if remote then return remote end
	for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
		if desc.Name == "ClientInspectHumanoidDescription" then
			return desc
		end
	end
end

local rem = locateRemote()

local function getScrollingFrame()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	local viewPlayer = playerGui and playerGui:FindFirstChild("ViewPlayer")
	local main = viewPlayer and viewPlayer:FindFirstChild("Main") and viewPlayer.Main:FindFirstChild("Menu")
	return main and main:FindFirstChild("ScrollingFrame")
end

local function rgb(c)
	if typeof(c) ~= "Color3" then
		return {r = 255, g = 255, b = 255, IsRGBTable = true}
	end
	return {r = c.R * 255, g = c.G * 255, b = c.B * 255, IsRGBTable = true}
end

local function dict(d)
	local p = {
		HatAccessory = d.HatAccessory or "",
		HairAccessory = d.HairAccessory or "",
		FaceAccessory = d.FaceAccessory or "",
		BackAccessory = d.BackAccessory or "",
		FrontAccessory = d.FrontAccessory or "",
		NeckAccessory = d.NeckAccessory or "",
		ShouldersAccessory = d.ShouldersAccessory or "",
		WaistAccessory = d.WaistAccessory or "",
		Face = d.Face or 0,
		Head = d.Head or 0,
		Torso = d.Torso or 0,
		LeftArm = d.LeftArm or 0,
		RightArm = d.RightArm or 0,
		LeftLeg = d.LeftLeg or 0,
		RightLeg = d.RightLeg or 0,
		Shirt = d.Shirt or 0,
		Pants = d.Pants or 0,
		GraphicTShirt = d.GraphicTShirt or 0,
		HeadColor = rgb(d.HeadColor),
		TorsoColor = rgb(d.TorsoColor),
		LeftArmColor = rgb(d.LeftArmColor),
		RightArmColor = rgb(d.RightArmColor),
		LeftLegColor = rgb(d.LeftLegColor),
		RightLegColor = rgb(d.RightLegColor),
		HeightScale = d.HeightScale or 1,
		WidthScale = d.WidthScale or 1,
		DepthScale = d.DepthScale or 1,
		HeadScale = d.HeadScale or 1,
		BodyTypeScale = d.BodyTypeScale or 0,
		ProportionScale = d.ProportionScale or 0,
		ClimbAnimation = d.ClimbAnimation or 0,
		FallAnimation = d.FallAnimation or 0,
		IdleAnimation = d.IdleAnimation or 0,
		JumpAnimation = d.JumpAnimation or 0,
		MoodAnimation = d.MoodAnimation or 0,
		RunAnimation = d.RunAnimation or 0,
		SwimAnimation = d.SwimAnimation or 0,
		WalkAnimation = d.WalkAnimation or 0,
		MakeupItems = {},
		AccessoryRefinements = {},
		LayeredAccessories = {},
		StaticFacialAnimation = false,
	}
	pcall(function()
		local a = d:GetAccessories(true)
		if type(a) ~= "table" then return end
		local o = {}
		for _, x in ipairs(a) do
			if type(x) == "table" and x.AssetId then
				o[#o + 1] = {
					AssetId = x.AssetId,
					AccessoryType = tostring(x.AccessoryType or ""),
					Order = x.Order,
					Puffiness = x.Puffiness,
				}
			end
		end
		p.LayeredAccessories = o
	end)
	return p
end

local function ser(m, d)
	if type(m) == "table" and type(m.ToDictionary) == "function" then
		local ok, t = pcall(m.ToDictionary, m, d)
		if ok and type(t) == "table" then return t end
	end
	return dict(d)
end

local function descfrom(plr)
	if not plr then return end
	local h = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
	if h then
		local ok, live = pcall(function()
			return h:GetAppliedDescription()
		end)
		if ok and live and live:IsA("HumanoidDescription") then
			return live, h.RigType
		end
	end
	local ok, d = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(plr.UserId)
	end)
	if ok and d and d:IsA("HumanoidDescription") then
		return d, Enum.HumanoidRigType.R15
	end
end

local function grab(s)
	local w = s:FindFirstChild("WearOutfit")
	local plr, mod, desc, rig

	if w and getconnections and getupvalues then
		local c = getconnections(w.Activated)
		local f = c[1] and c[1].Function
		if type(f) ~= "function" then
			c = getconnections(w.MouseButton1Click)
			f = c[1] and c[1].Function
		end
		if type(f) == "function" then
			local u = getupvalues(f)
			plr, mod, desc, rig = u[2], u[3], u[4], u[5]
			for _, v in pairs(u) do
				if typeof(v) == "Instance" and v:IsA("Player") then
					plr = v
				elseif typeof(v) == "Instance" and v:IsA("HumanoidDescription") then
					desc = v
				elseif type(v) == "table" and type(v.ToDictionary) == "function" then
					mod = v
				elseif typeof(v) == "EnumItem" and v.EnumType == Enum.HumanoidRigType then
					rig = v
				end
			end
		end
	end

	if typeof(plr) ~= "Instance" or not plr:IsA("Player") then
		return
	end

	local live, lrig = descfrom(plr)
	if live then
		desc, rig = live, lrig
	end

	if typeof(desc) ~= "Instance" or not desc:IsA("HumanoidDescription") then
		return
	end

	return plr, mod, desc, typeof(rig) == "EnumItem" and rig or Enum.HumanoidRigType.R15
end

local function go(d, m, r)
	rem = rem or locateRemote()
	if not rem then return end
	local p = {
		Action = "CreateAndWearHumanoidDescription",
		Properties = ser(m, d),
		RigType = r or Enum.HumanoidRigType.R15,
	}
	pcall(function()
		if rem:IsA("RemoteFunction") then
			rem:InvokeServer(p)
		else
			rem:FireServer(p)
		end
	end)
end

local function view(plr, d)
	if not plr or not d then return end
	local title = "@" .. plr.Name .. "'s Current Outfit"
	local payload = {
		HumanoidDescription = d,
		Title = title,
	}

	local ev = locateInspector()
	if ev then
		pcall(function()
			if ev:IsA("BindableEvent") then
				ev:Fire(payload)
			elseif ev.Fire then
				ev:Fire(payload)
			end
		end)
		pcall(function()
			if ev:IsA("BindableEvent") then
				ev:Fire(d, title)
			elseif ev.Fire then
				ev:Fire(d, title)
			end
		end)
		return
	end

	local vb = getScrollingFrame() and getScrollingFrame():FindFirstChild("ViewOutfit")
	if vb and getconnections then
		for _, c in ipairs(getconnections(vb.Activated)) do
			pcall(function()
				if c.Function then c.Function() end
			end)
		end
		for _, c in ipairs(getconnections(vb.MouseButton1Click)) do
			pcall(function()
				if c.Function then c.Function() end
			end)
		end
	end
end

------------------------------------------------------------------------------
-- 2. BEJ & GRİ TEMA DÜZENLEME VE BUTONLARI EKLEME
------------------------------------------------------------------------------

local function applyBeigeGrayTheme()
	local s = getScrollingFrame()
	if not s then return end

	-- Buton Renk Tonları (Bej ve Gri)
	local beigeColor = Color3.fromRGB(225, 215, 198)
	local darkGrayColor = Color3.fromRGB(45, 45, 50)
	local lightGrayColor = Color3.fromRGB(75, 75, 80)

	for _, child in ipairs(s:GetChildren()) do
		if child:IsA("GuiObject") then
			if child.Name == "StealOutfit" then
				child.BackgroundColor3 = beigeColor
				child.TextColor3 = darkGrayColor
			elseif child.Name == "ForceViewOutfit" then
				child.BackgroundColor3 = lightGrayColor
				child.TextColor3 = beigeColor
			end
		end
	end
end

local function ok()
	local s = getScrollingFrame()
	if not s then return false end
	local v = s:FindFirstChild("ViewOutfit")
	local w = s:FindFirstChild("WearOutfit")
	if not v or not w then return false end

	for _, n in ipairs({"StealOutfit", "ForceViewOutfit"}) do
		local o = s:FindFirstChild(n)
		if o then o:Destroy() end
	end

	local fv = v:Clone()
	fv.Name = "ForceViewOutfit"
	fv.Text = "Force View Outfit"
	fv.LayoutOrder = v.LayoutOrder + 1
	fv.Parent = s
	fv.Activated:Connect(function()
		local plr, _, d = grab(s)
		if not plr then return end
		view(plr, d)
	end)

	local st = w:Clone()
	st.Name = "StealOutfit"
	st.Text = "Steal Outfit"
	st.LayoutOrder = w.LayoutOrder + 1
	st.Parent = s
	st.Activated:Connect(function()
		local plr, m, d, r = grab(s)
		if plr then go(d, m, r) end
	end)

	applyBeigeGrayTheme()
	return true
end

------------------------------------------------------------------------------
-- 3. FLEXYS1903 ATATÜRK ÖZEL ARAYÜZÜ (BEJ & GRİ TEMA + MOBİL KÜÇÜLTME)
------------------------------------------------------------------------------

local function createFlexysUI()
	local parentGui = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
	
	if parentGui:FindFirstChild("Flexys1903_UI") then
		parentGui.Flexys1903_UI:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Flexys1903_UI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = parentGui

	-- Sol Üst Mobil Menü Butonu (Aç/Kapat & Küçültme)
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleMenu"
	toggleBtn.Size = UDim2.new(0, 110, 0, 35)
	toggleBtn.Position = UDim2.new(0, 15, 0, 15)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	toggleBtn.TextColor3 = Color3.fromRGB(225, 215, 198)
	toggleBtn.Text = "flexys1903"
	toggleBtn.Font = Enum.Font.SourceSansBold
	toggleBtn.TextSize = 14
	toggleBtn.Parent = screenGui

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 8)
	toggleCorner.Parent = toggleBtn

	local toggleStroke = Instance.new("UIStroke")
	toggleStroke.Color = Color3.fromRGB(225, 215, 198)
	toggleStroke.Thickness = 1.5
	toggleStroke.Parent = toggleBtn

	-- Ana Panel (Mobil İçin Küçültülmüş & Responsive)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 320, 0, 420)
	mainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
	mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	mainFrame.Visible = false
	mainFrame.Active = true
	mainFrame.Draggable = true
	mainFrame.Parent = screenGui

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 12)
	mainCorner.Parent = mainFrame

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Color3.fromRGB(225, 215, 198)
	mainStroke.Thickness = 2
	mainStroke.Parent = mainFrame

	-- GitHub 'arkaplan.jpg' Desteği (Custom ImageLabel)
	local bgImage = Instance.new("ImageLabel")
	bgImage.Name = "BackgroundImage"
	bgImage.Size = UDim2.new(1, 0, 1, 0)
	bgImage.BackgroundTransparency = 1
	bgImage.ScaleType = Enum.ScaleType.Crop
	-- NOT: GitHub raw linkini veya Roblox Decal ID'sini aşağıdaki string içine koyabilirsiniz:
	bgImage.Image = "rbxassetid://0" 
	bgImage.Parent = mainFrame

	-- Başlık
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 40)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "flexys1903 - Atatürk Anı Sayfası"
	titleLabel.TextColor3 = Color3.fromRGB(225, 215, 198)
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 16
	titleLabel.Parent = mainFrame

	-- Atatürk Sayfası İçerik Alanı
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -20, 1, -50)
	scroll.Position = UDim2.new(0, 10, 0, 45)
	scroll.BackgroundTransparency = 1
	scroll.CanvasSize = UDim2.new(0, 0, 0, 480)
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = Color3.fromRGB(225, 215, 198)
	scroll.Parent = mainFrame

	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 10)
	layout.Parent = scroll

	-- Atatürk Resmi
	local ataImage = Instance.new("ImageLabel")
	ataImage.Size = UDim2.new(0, 130, 0, 130)
	ataImage.BackgroundTransparency = 1
	ataImage.Image = "rbxassetid://10850382218" -- Çalışan Varsayılan Atatürk Decal ID
	ataImage.Parent = scroll

	local imgCorner = Instance.new("UICorner")
	imgCorner.CornerRadius = UDim.new(0, 10)
	imgCorner.Parent = ataImage

	-- Atatürk Başarıları Metni
	local infoText = Instance.new("TextLabel")
	infoText.Size = UDim2.new(1, -10, 0, 280)
	infoText.BackgroundTransparency = 1
	infoText.TextColor3 = Color3.fromRGB(230, 225, 215)
	infoText.TextWrapped = true
	infoText.TextYAlignment = Enum.TextYAlignment.Top
	infoText.Font = Enum.Font.SourceSans
	infoText.TextSize = 14
	infoText.Text = " Mustafa Kemal Atatürk'ün Başarıları:\n\n" ..
		"• Türkiye Cumhuriyeti'nin Kurucusu ve İlk Cumhurbaşkanı\n" ..
		"• Çanakkale ve Kurtuluş Savaşı Başkomutanı\n" ..
		"• Saltanatın Kaldırılması ve Cumhuriyetin İlanı\n" ..
		"• Harf İnkılabı ve Çağdaş Eğitim Reformları\n" ..
		"• Kadınlara Seçme ve Seçilme Hakkının Verilmesi\n" ..
		"• 'Yurtta Sulh, Cihanda Sulh' İlkesi"
	infoText.Parent = scroll

	-- Aç/Kapat Buton Mantığı (Mobil Uyumlu)
	toggleBtn.MouseButton1Click:Connect(function()
		mainFrame.Visible = not mainFrame.Visible
	end)
end

------------------------------------------------------------------------------
-- 4. TETİKLEYİCİLER VE BİLDİRİMLER
------------------------------------------------------------------------------

task.spawn(function()
	createFlexysUI()
	for _ = 1, 60 do
		if ok() then break end
		task.wait(1)
	end
end)

LocalPlayer.PlayerGui.ChildAdded:Connect(function(c)
	if c.Name == "ViewPlayer" then
		task.wait(0.3)
		ok()
	end
end)

task.spawn(function()
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "flexys1903 Loaded",
			Text = "Steal Outfit & Atatürk Sayfası Aktif!",
			Duration = 6,
		})
	end)
end)
