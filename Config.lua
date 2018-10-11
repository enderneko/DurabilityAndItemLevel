local addonName, DAI = ...
local LCP = LibStub:GetLibrary("LibConfigPanel-1.0")
local LSM = LibStub("LibSharedMedia-3.0")

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

    local alwaysShowDurCB = LCP:CreateCheckButton(DAIConfigPanel, "Always Show Durability", "Even if dur is 100%.", DurabilityAndItemLevel, "alwaysShowDur", DAI.UpdateAllDur)
    alwaysShowDurCB:SetPoint("TOPLEFT", DAIConfigPanel.title, "BOTTOMLEFT", -2, -16)

    local showInBagsCB = LCP:CreateCheckButton(DAIConfigPanel, "Show Item Level In Bags", "Show iLevel on equippable items in bags/bank.", DurabilityAndItemLevel, "showInBags", DAI.UpdateAllBags)
    showInBagsCB:SetPoint("LEFT", alwaysShowDurCB, "RIGHT", 200, 0)

    -- font
    local fontDropDown = LCP:CreateDropDown(DAIConfigPanel, "Font", LSM:List("font"), DurabilityAndItemLevel["font"], 1, UpdateFont)
    fontDropDown:SetPoint("TOPLEFT", alwaysShowDurCB, "BOTTOMLEFT", -15, -40)
    
    local fontSize = LCP:CreateSlider(DAIConfigPanel, "Font Size", 6, 20, nil, DurabilityAndItemLevel["font"], 2, UpdateFont)
    fontSize:SetPoint("LEFT", fontDropDown, "RIGHT", 130, 0)
    
    local fontFlagDropDown = LCP:CreateDropDown(DAIConfigPanel, "Font Flag", flags, DurabilityAndItemLevel["font"], 3, UpdateFont)
    fontFlagDropDown:SetPoint("LEFT", fontSize, "RIGHT", 35, 0)
    
    -- durbility
    local durPointDropDown = LCP:CreateDropDown(DAIConfigPanel, "Durability Point", points, DurabilityAndItemLevel["durPoint"], 1, UpdateDurPoints)
    durPointDropDown:SetPoint("TOPLEFT", fontDropDown, "BOTTOMLEFT", 0, -50)
    
    local durPointX = LCP:CreateSlider(DAIConfigPanel, "Durability X", -16, 16, nil, DurabilityAndItemLevel["durPoint"], 2, UpdateDurPoints)
    durPointX:SetPoint("LEFT", durPointDropDown, "RIGHT", 130, 0)
    
    local durPointY = LCP:CreateSlider(DAIConfigPanel, "Durability Y", -16, 16, nil, DurabilityAndItemLevel["durPoint"], 3, UpdateDurPoints)
    durPointY:SetPoint("LEFT", durPointX, "RIGHT", 50, 0)
    
    -- itemlevel
    local ilvlPointDropDown = LCP:CreateDropDown(DAIConfigPanel, "ItemLevel Point", points, DurabilityAndItemLevel["ilvlPoint"], 1, UpdateIlvlPoints)
    ilvlPointDropDown:SetPoint("TOPLEFT", durPointDropDown, "BOTTOMLEFT", 0, -40)

    local ilvlPointX = LCP:CreateSlider(DAIConfigPanel, "ItemLevel X", -16, 16, nil, DurabilityAndItemLevel["ilvlPoint"], 2, UpdateIlvlPoints)
    ilvlPointX:SetPoint("LEFT", ilvlPointDropDown, "RIGHT", 130, 0)

    local ilvlPointY = LCP:CreateSlider(DAIConfigPanel, "ItemLevel Y", -16, 16, nil, DurabilityAndItemLevel["ilvlPoint"], 3, UpdateIlvlPoints)
    ilvlPointY:SetPoint("LEFT", ilvlPointX, "RIGHT", 50, 0)

    -- bag & bank
    local bagPointDropDown = LCP:CreateDropDown(DAIConfigPanel, "Bag/Bank ItemLevel Point", points, DurabilityAndItemLevel["bagPoint"], 1, UpdateBagPoints)
    bagPointDropDown:SetPoint("TOPLEFT", ilvlPointDropDown, "BOTTOMLEFT", 0, -40)

    local bagPointX = LCP:CreateSlider(DAIConfigPanel, "X", -16, 16, nil, DurabilityAndItemLevel["bagPoint"], 2, UpdateBagPoints)
    bagPointX:SetPoint("LEFT", bagPointDropDown, "RIGHT", 130, 0)

    local bagPointY = LCP:CreateSlider(DAIConfigPanel, "Y", -16, 16, nil, DurabilityAndItemLevel["bagPoint"], 3, UpdateBagPoints)
    bagPointY:SetPoint("LEFT", bagPointX, "RIGHT", 50, 0)

    local iThreshold = LCP:CreateSlider(DAIConfigPanel, "iLevel Threshold", 0, 300, nil, DurabilityAndItemLevel, "iThreshold")
    iThreshold:SetValueStep(10)
    iThreshold:SetPoint("TOPLEFT", bagPointDropDown, "BOTTOMLEFT", 20, -40)
end)