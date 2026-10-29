--[========================================================================]--
--  Script Name : flexys1903
--  Theme       : Beige & Gray (Bej ve Gri) + Atatürk Memorial Page
--  Note        : Hiçbir işlevsel kod/mantık bozulmadan güncellenmiştir.
--[========================================================================]--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

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

local function applyBeigeGrayThemeAndAtaturk()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	local viewPlayer = playerGui and playerGui:FindFirstChild("ViewPlayer")
	if not viewPlayer then return end
	local main = viewPlayer:FindFirstChild("Main")
	if not main then return end

	-- Mobil için menü küçültme ve adaptasyon
	main.Size = UDim2.new(0, 360, 0, 480)
	main.Position = UDim2.new(0.5, -180, 0.5, -240)

	-- Arka plan için arkaplan.jpg entegrasyonu (GitHub raw linki veya asset ID)
	local bgImage = main:FindFirstChild("BackgroundTheme")
	if not bgImage then
		bgImage = Instance.new("ImageLabel")
		bgImage.Name = "BackgroundTheme"
		bgImage.Size = UDim2.new(1, 0, 1, 0)
		bgImage.BackgroundTransparency = 1
		bgImage.Image = "rbxassetid://0" -- arkaplan.jpg github linkiniz veya ID'niz buraya eklenecektir
		bgImage.ScaleType = Enum.ScaleType.Slice
		bgImage.ZIndex = 0
		bgImage.Parent = main
	end

	-- Bej ve Gri renk entegrasyonu (Beige: Color3.fromRGB(245, 240, 230), Gray: Color3.fromRGB(100, 100, 100))
	for _, desc in ipairs(main:GetDescendants()) do
		if desc:IsA("Frame") or desc:IsA("ScrollingFrame") then
			desc.BackgroundColor3 = Color3.fromRGB(45, 45, 48) -- Koyu gri arkaplan
			if desc:FindFirstChildOfClass("UIStroke") == nil then
				local stroke = Instance.new("UIStroke")
				stroke.Color = Color3.fromRGB(210, 195, 175) -- Bej tonlarında kenarlık
				stroke.Thickness = 1.2
				stroke.Parent = desc
			end
		elseif desc:IsA("TextButton") then
			desc.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
			desc.TextColor3 = Color3.fromRGB(240, 235, 225) -- Açık bej metin
		elseif desc:IsA("TextLabel") then
			desc.TextColor3 = Color3.fromRGB(220, 215, 205)
		end
	end

	-- Atatürk'e özel ayrı sayfa (Memorial Page) eklenmesi
	local menu = main:FindFirstChild("Menu")
	if menu and not menu:FindFirstChild("AtaturkPage") then
		local ataturkBtn = Instance.new("TextButton")
		ataturkBtn.Name = "AtaturkButton"
		ataturkBtn.Size = UDim2.new(1, 0, 0, 35)
		ataturkBtn.BackgroundColor3 = Color3.fromRGB(80, 75, 70)
		ataturkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		ataturkBtn.Text = "Atatürk Anı Sayfası"
		ataturkBtn.Font = Enum.Font.SourceSansBold
		ataturkBtn.TextSize = 14
		ataturkBtn.Parent = menu

		local ataturkPage = Instance.new("ScrollingFrame")
		ataturkPage.Name = "AtaturkPage"
		ataturkPage.Size = UDim2.new(1, 0, 1, -40)
		ataturkPage.Position = UDim2.new(0, 0, 0, 40)
		ataturkPage.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
		ataturkPage.Visible = false
		ataturkPage.Parent = menu

		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 10)
		layout.Parent = ataturkPage

		local img = Instance.new("ImageLabel")
		img.Size = UDim2.new(1, 0, 0, 140)
		img.BackgroundTransparency = 1
		img.Image = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHMGE6fFJ82M8xKtbEALog6UUsa0fiOEiUErrgyZkjqw&s"
		img.ScaleType = Enum.ScaleType.Fit
		img.Parent = ataturkPage

		local info = Instance.new("TextLabel")
		info.Size = UDim2.new(1, 0, 0, 200)
		info.BackgroundTransparency = 1
		info.TextColor3 = Color3.fromRGB(235, 230, 220)
		info.TextWrapped = true
		info.TextSize = 13
		info.Font = Enum.Font.SourceSans
		info.Text = "Mustafa Kemal Atatürk'ün Başarıları:\n\n" ..
				"• Türkiye Cumhuriyeti'nin Kurucusu ve İlk Cumhurbaşkanı\n" ..
				"• Kurtuluş Savaşı Başkomutanlığı\n" ..
				"• Saltanatın Kaldırılması ve Cumhuriyetin İlanı\n" ..
				"• Harf İnkılabı ve Modern Eğitim Reformları\n" ..
				"• Kadın Hakları ve Eşitlik İlkesinin Kabulü\n" ..
				"• 'Yurtta Sulh, Cihanda Sulh' İlkesi"
		info.Parent = ataturkPage

		ataturkBtn.MouseButton1Click:Connect(function()
			ataturkPage.Visible = not ataturkPage.Visible
		end)
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

	applyBeigeGrayThemeAndAtaturk()
	return true
end

task.spawn(function()
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
	local uid = 1
	pcall(function()
		uid = Players:GetUserIdFromNameAsync("flexys1903")
	end)

	local cb = Instance.new("BindableFunction")
	cb.OnInvoke = function(btn)
		if btn == "Discord Profile" then
			local link = "https://discord.com/users/798692960325730315"
			if setclipboard then
				setclipboard(link)
			elseif toclipboard then
				toclipboard(link)
			end
		end
	end

	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Click on someone to view the Steal Outfit buttons",
			Text = "flexys1903 v2.0 - Bej & Gri Tema",
			Duration = 8,
			Button1 = "Okay",
		})
	end)

	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "flexys1903 tarafından güncellendi",
			Text = "Atatürk Anı Sayfası Eklendi",
			Icon = "rbxthumb://type=AvatarHeadShot&id=" .. uid .. "&w=150&h=150",
			Duration = 8,
			Button1 = "Discord Profile",
			Button2 = "Kapat",
			Callback = cb,
		})
	end)
end)
