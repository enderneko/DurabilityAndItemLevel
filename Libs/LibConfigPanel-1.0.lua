-----------------------------------------------
-- LibConfigPanel-1.0
-- fyhcslb (enderneko)
-- 2018-08-20 09:10:07
-----------------------------------------------
local MAJOR, MINOR = "LibConfigPanel-1.0", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

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
    cb.label.color = {cb.label:GetTextColor()}
    cb:SetChecked(configTable[configKey])

    if tooltip then
        cb:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
            GameTooltip:SetText(label, nil, nil, nil, nil, true)
            GameTooltip:AddLine(tooltip, 1.0, 1.0, 1.0, true)
            GameTooltip:Show()
        end)
        cb:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end

    cb:SetScript("OnEnable", function()
        cb.label:SetTextColor(unpack(cb.label.color))
    end)
    cb:SetScript("OnDisable", function()
        cb.label:SetTextColor(0.6, 0.6, 0.6)
    end)

    return cb
end

-----------------------------------------------
-- Slider
-----------------------------------------------
function lib:CreateSlider(panel, label, low, high, tooltip, configTable, configKey, valueChangedFunc)
    local slider = CreateFrame("Slider", panel.name .. "ConfigSlider_" .. label, panel, "UISliderTemplate")
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

    if tooltip then
        slider:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(label, nil, nil, nil, nil, true)
            GameTooltip:AddLine(tooltip, 1.0, 1.0, 1.0, true)
            GameTooltip:Show()
        end)
        slider:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end

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
    local dropdown = CreateFrame("Frame", panel.name .. "ConfigDropDown_" .. label, panel, "UIDropDownMenuTemplate")
    -- dropdown:SetWidth(200)

    local dropdownLabel = dropdown:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dropdownLabel:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 16, 3)
    dropdownLabel:SetText(label)

    _G[dropdown:GetName().."Text"]:SetWidth(_G[dropdown:GetName().."Middle"]:GetWidth()-20)

    function dropdown:SetWidth(width)
        _G[dropdown:GetName().."Middle"]:SetWidth(width)
        _G[dropdown:GetName().."Text"]:SetWidth(_G[dropdown:GetName().."Middle"]:GetWidth()-20)
    end

    UIDropDownMenu_Initialize(dropdown, function()
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(self)
            configTable[configKey] = self.value
            UIDropDownMenu_SetSelectedValue(dropdown, self.value)
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
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedValue(dropdown, configTable[configKey])

    return dropdown
end

-----------------------------------------------
-- ColorSwatch
-----------------------------------------------
local function ShowColorPicker(r, g, b, a, changedCallback)
    ColorPickerFrame:SetupColorPickerAndShow({
        r = r,
        g = g,
        b = b,
        swatchFunc = changedCallback,
        hasOpacity = a ~= nil,
        opacity = a,
        opacityFunc = changedCallback,
        cancelFunc = changedCallback,
    })
end

function lib:CreateColorSwatch(panel, label, tooltip, hasAlpha, valueChangedFunc)
    local swatch = CreateFrame("Button", panel.name .. "ColorSwatch_" .. label, panel, "ColorSwatchTemplate")
    swatch:SetSize(20, 20)

    swatch.label = swatch:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    swatch.label:SetPoint("LEFT", swatch, "RIGHT")
    swatch.label:SetText(label)
    swatch.label.color = {swatch.label:GetTextColor()}

    function swatch:SetColor(r, g, b, a)
        swatch.r, swatch.g, swatch.b, swatch.a = r, g, b, a
        swatch.Color:SetVertexColor(r, g, b, a)
    end

    local function ColorCallback(restore)
        local newR, newG, newB, newA
        if restore then
            newR, newG, newB, newA = unpack(restore)
        else
            newA, newR, newG, newB = ColorPickerFrame:GetColorAlpha(), ColorPickerFrame:GetColorRGB()
        end

        if hasAlpha then
            swatch:SetColor(newR, newG, newB, newA)
            valueChangedFunc(newR, newG, newB, newA)
        else
            swatch:SetColor(newR, newG, newB)
            valueChangedFunc(newR, newG, newB)
        end
    end

    swatch:SetScript("OnClick", function(self, button)
        ShowColorPicker(swatch.r, swatch.g, swatch.b, swatch.a, ColorCallback)
    end)

    swatch:HookScript("OnEnable", function()
        swatch.label:SetTextColor(unpack(swatch.label.color))
    end)
    swatch:HookScript("OnDisable", function()
        swatch.label:SetTextColor(0.6, 0.6, 0.6)
    end)

    return swatch
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
function lib:CreateConfigPanel(addonName)
    local panel = CreateFrame("Frame")
    panel.name = addonName

	local category, layout = Settings.RegisterCanvasLayoutCategory(panel, addonName);
	Settings.RegisterAddOnCategory(category)

    SetTitle(panel)

    return panel
end
