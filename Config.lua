local addonName, DAI = ...
local LCP = LibStub:GetLibrary("LibConfigPanel-1.0")
local LSM = LibStub("LibSharedMedia-3.0")
local L = DAI.L

----------------------------------------------
-- functions
----------------------------------------------
local function UpdateDurPoints()
    for _, s in pairs(DAI.durFontStrings) do
        s:ClearAllPoints()
        s:SetPoint(unpack(DurabilityAndItemLevel["durPoint"]))
    end
end

local function UpdateIlvlPoints()
    for _, s in pairs(DAI.ilvlFontStrings) do
        s:ClearAllPoints()
        s:SetPoint(unpack(DurabilityAndItemLevel["ilvlPoint"]))
    end
end

local function UpdateBagPoints()
    for _, s in pairs(DAI.bagFontStrings) do
        s:ClearAllPoints()
        s:SetPoint(unpack(DurabilityAndItemLevel["bagPoint"]))
    end
end

local function UpdateFont()
    local font = DAI:GetFont()
    for _, s in pairs(DAI.durFontStrings) do
        s:SetFont(unpack(font))
    end

    for _, s in pairs(DAI.ilvlFontStrings) do
        s:SetFont(unpack(font))
    end
end

----------------------------------------------
-- init
----------------------------------------------
local DAIConfigPanel = LCP:CreateConfigPanel(addonName)
DAIConfigPanel:Hide()
local points = {"TOPLEFT", "TOPRIGHT", "BOTTOMRIGHT", "BOTTOMLEFT", "TOP", "BOTTOM", "LEFT", "RIGHT", "CENTER"}
local flags = {"OUTLINE", "THICKOUTLINE", "MONOCHROME", "OUTLINE, MONOCHROME"}

DAIConfigPanel:SetScript("OnShow", function(self)
    self:SetScript("OnShow", nil)

    local alwaysShowDurCB

    local showDurCB = LCP:CreateCheckButton(DAIConfigPanel, L["Show Durability"], nil, DurabilityAndItemLevel, "showDur", function(checked)
        DAI:UpdateAllDur()
        alwaysShowDurCB:SetEnabled(checked)
    end)
    showDurCB:SetPoint("TOPLEFT", DAIConfigPanel.title, "BOTTOMLEFT", -2, -16)

    alwaysShowDurCB = LCP:CreateCheckButton(DAIConfigPanel, L["Always Show Durability"], L["Even if dur is 100%."], DurabilityAndItemLevel, "alwaysShowDur", DAI.UpdateAllDur)
    alwaysShowDurCB:SetPoint("TOPLEFT", showDurCB, "TOPRIGHT", 200, 0)
    alwaysShowDurCB:SetEnabled(DurabilityAndItemLevel["showDur"])

    local showInBagsCB = LCP:CreateCheckButton(DAIConfigPanel, L["Show Item Level In Bags"], L["Show iLevel on equippable items in bags/bank."], DurabilityAndItemLevel, "showInBags", DAI.UpdateAllBags)
    showInBagsCB:SetPoint("TOPLEFT", showDurCB, "BOTTOMLEFT", 0, -10)

    -- custom color
    local swatch
    local customColorCB = LCP:CreateCheckButton(DAIConfigPanel, "", nil, DurabilityAndItemLevel["customIlvlColor"], 1, function(checked)
        swatch:SetEnabled(checked)
    end)
    customColorCB:SetPoint("TOPLEFT", showInBagsCB, "BOTTOMLEFT", 0, -10)

    swatch = LCP:CreateColorSwatch(DAIConfigPanel, L["Custom ILevel Color"], nil, false, function(r, g, b, a)
        DurabilityAndItemLevel["customIlvlColor"][2][1] = r
        DurabilityAndItemLevel["customIlvlColor"][2][2] = g
        DurabilityAndItemLevel["customIlvlColor"][2][3] = b
    end)
    swatch:SetPoint("TOPLEFT", customColorCB, "TOPRIGHT", 0, -2)
    swatch:SetColor(unpack(DurabilityAndItemLevel["customIlvlColor"][2]))
    swatch:SetEnabled(DurabilityAndItemLevel["customIlvlColor"][1])

    -- font
    local fontDropDown = LCP:CreateDropDown(DAIConfigPanel, L["Font"], LSM:List("font"), DurabilityAndItemLevel["font"], 1, UpdateFont)
    fontDropDown:SetPoint("TOPLEFT", customColorCB, "BOTTOMLEFT", -15, -60)
    
    local fontSize = LCP:CreateSlider(DAIConfigPanel, L["Font Size"], 6, 20, nil, DurabilityAndItemLevel["font"], 2, UpdateFont)
    fontSize:SetPoint("TOPLEFT", fontDropDown, "TOPRIGHT", 130, 0)
    
    local fontFlagDropDown = LCP:CreateDropDown(DAIConfigPanel, L["Font Flag"], flags, DurabilityAndItemLevel["font"], 3, UpdateFont)
    fontFlagDropDown:SetPoint("TOPLEFT", fontSize, "TOPRIGHT", 35, 0)
    
    -- durbility
    local durPointDropDown = LCP:CreateDropDown(DAIConfigPanel, L["Durability Point"], points, DurabilityAndItemLevel["durPoint"], 1, UpdateDurPoints)
    durPointDropDown:SetPoint("TOPLEFT", fontDropDown, "BOTTOMLEFT", 0, -50)
    
    local durPointX = LCP:CreateSlider(DAIConfigPanel, L["Durability X"], -16, 16, nil, DurabilityAndItemLevel["durPoint"], 2, UpdateDurPoints)
    durPointX:SetPoint("TOPLEFT", durPointDropDown, "TOPRIGHT", 130, 0)
    
    local durPointY = LCP:CreateSlider(DAIConfigPanel, L["Durability Y"], -16, 16, nil, DurabilityAndItemLevel["durPoint"], 3, UpdateDurPoints)
    durPointY:SetPoint("TOPLEFT", durPointX, "TOPRIGHT", 50, 0)
    
    -- itemlevel
    local ilvlPointDropDown = LCP:CreateDropDown(DAIConfigPanel, L["ItemLevel Point"], points, DurabilityAndItemLevel["ilvlPoint"], 1, UpdateIlvlPoints)
    ilvlPointDropDown:SetPoint("TOPLEFT", durPointDropDown, "BOTTOMLEFT", 0, -40)

    local ilvlPointX = LCP:CreateSlider(DAIConfigPanel, L["ItemLevel X"], -16, 16, nil, DurabilityAndItemLevel["ilvlPoint"], 2, UpdateIlvlPoints)
    ilvlPointX:SetPoint("TOPLEFT", ilvlPointDropDown, "TOPRIGHT", 130, 0)

    local ilvlPointY = LCP:CreateSlider(DAIConfigPanel, L["ItemLevel Y"], -16, 16, nil, DurabilityAndItemLevel["ilvlPoint"], 3, UpdateIlvlPoints)
    ilvlPointY:SetPoint("TOPLEFT", ilvlPointX, "TOPRIGHT", 50, 0)

    -- bag & bank
    local bagPointDropDown = LCP:CreateDropDown(DAIConfigPanel, L["Bag/Bank ItemLevel Point"], points, DurabilityAndItemLevel["bagPoint"], 1, UpdateBagPoints)
    bagPointDropDown:SetPoint("TOPLEFT", ilvlPointDropDown, "BOTTOMLEFT", 0, -40)

    local bagPointX = LCP:CreateSlider(DAIConfigPanel, "X", -16, 16, nil, DurabilityAndItemLevel["bagPoint"], 2, UpdateBagPoints)
    bagPointX:SetPoint("TOPLEFT", bagPointDropDown, "TOPRIGHT", 130, 0)

    local bagPointY = LCP:CreateSlider(DAIConfigPanel, "Y", -16, 16, nil, DurabilityAndItemLevel["bagPoint"], 3, UpdateBagPoints)
    bagPointY:SetPoint("TOPLEFT", bagPointX, "TOPRIGHT", 50, 0)

    local iThreshold = LCP:CreateSlider(DAIConfigPanel, L["ILevel Threshold"], 0, 500, nil, DurabilityAndItemLevel, "iThreshold")
    iThreshold:SetValueStep(10)
    iThreshold:SetPoint("TOPLEFT", bagPointY, "TOPRIGHT", 50, 0)
end)