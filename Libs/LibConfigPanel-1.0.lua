-----------------------------------------------
-- LibConfigPanel-1.0
-- fyhcslb (enderneko)
-- 2018-08-20 09:10:07
-----------------------------------------------
local MAJOR, MINOR = "LibConfigPanel-1.0", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

local LDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

-----------------------------------------------
-- CheckButton
-----------------------------------------------
function lib:CreateCheckButton(panel, label, tooltip, configTable, configKey, valueChangedFunc)
	local cb = CreateFrame("CheckButton", panel.name .. "ConfigCheckButton_" .. label, panel, "InterfaceOptionsCheckButtonTemplate")
    cb:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		configTable[configKey] = checked
		if valueChangedFunc then valueChangedFunc(checked) end
	end)
	cb.label = _G[cb:GetName() .. "Text"]
	cb.label:SetText(label)
	cb.tooltipText = label
	cb.tooltipRequirement = tooltip
	cb:SetChecked(configTable[configKey])

	return cb
end

-----------------------------------------------
-- Slider
-----------------------------------------------
function lib:CreateSlider(panel, label, low, high, tooltip, configTable, configKey, valueChangedFunc)
	local slider = CreateFrame("Slider", panel.name .. "ConfigSlider_" .. label, panel, "HorizontalSliderTemplate")
	-- slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(low, high)
    slider:SetValueStep(1)
	slider:SetObeyStepOnDrag(true)
	slider:SetSize(120, 17)
	
	local sliderLabel = slider:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	sliderLabel:SetPoint("BOTTOM", slider, "TOP")
	sliderLabel:SetText(label)
	
	if tooltip then
		slider.tooltipText = label
		slider.tooltipRequirement = tooltip
	end

	-- OptionsPanelTemplates.xml 110
	slider:SetScript("OnEnter", function(self)
		if (self.tooltipText) then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
		end
		if (self.tooltipRequirement) then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, true)
			GameTooltip:Show()
		end
	end)

	slider:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	local vText = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	vText:SetHeight(35)
	vText:SetPoint("LEFT", slider, "RIGHT", 5, 0)
	
    slider:SetScript("OnValueChanged", function(self, value)
		vText:SetText(value)
		configTable[configKey] = value
		if valueChangedFunc then valueChangedFunc(value) end
    end)
	
	vText:SetText(configTable[configKey])
	slider:SetValue(configTable[configKey])

	return slider
end

-----------------------------------------------
-- Dropdown
-----------------------------------------------
-- valueChangedFunc: excute on value changed
-- valueFunc: process value into a specific format
function lib:CreateDropDown(panel, label, values, configTable, configKey, valueChangedFunc, valueFunc)
	local dropdown = LDD:Create_UIDropDownMenu(panel.name .. "ConfigDropDown_" .. label, panel)
	-- dropdown:SetWidth(200)
	local dropdownLabel = dropdown:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	dropdownLabel:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 16, 3)
	dropdownLabel:SetText(label)

	_G[dropdown:GetName().."Text"]:SetWidth(_G[dropdown:GetName().."Middle"]:GetWidth()-20)

	function dropdown:SetWidth(width)
		_G[dropdown:GetName().."Middle"]:SetWidth(width)
		_G[dropdown:GetName().."Text"]:SetWidth(_G[dropdown:GetName().."Middle"]:GetWidth()-20)
	end
	
	LDD:UIDropDownMenu_Initialize(dropdown, function()
		local info = LDD:UIDropDownMenu_CreateInfo()
		info.func = function(self)
			configTable[configKey] = self.value
			LDD:UIDropDownMenu_SetSelectedValue(dropdown, self.value)
			if valueChangedFunc then valueChangedFunc(self.value) end
		end

		for i, value in ipairs(values) do
			info.text = value
			info.value = valueFunc and valueFunc(value) or value
			
			if (configTable[configKey] == info.value) then
				info.checked = 1
			else
				info.checked = nil
			end
			LDD:UIDropDownMenu_AddButton(info)
		end
	end)
	LDD:UIDropDownMenu_SetSelectedValue(dropdown, configTable[configKey])

	return dropdown
end

-----------------------------------------------
-- Title
-----------------------------------------------
local function SetTitle(panel)
	panel.title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 16, -16)
    panel.title:SetText(panel.name)
end

-----------------------------------------------
-- Panel
-----------------------------------------------
-- local function Panel_OnCancel()
-- 	print("Panel_OnCancel")
-- end
-- local function Panel_OnSave()
-- 	print("Panel_OnSave")
-- end
-- local function Panel_OnDefaults()
-- 	print("Panel_OnDefaults")
-- end
-- local function Panel_OnRefresh()
-- 	print("Panel_OnRefresh")
-- end

function lib:CreateConfigPanel(addonName)
	local panel = CreateFrame("Frame")
	panel.name = addonName
	-- panel.okay = Panel_OnSave
	-- panel.cancel = Panel_OnCancel
	-- panel.default  = Panel_OnDefaults
	-- panel.refresh  = Panel_OnRefresh
	InterfaceOptions_AddCategory(panel)

	SetTitle(panel)

	return panel
end

