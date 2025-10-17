--========================================================
-- Bagnon ItemLevel Ascension - Options.lua (Wrath Compatible)
--========================================================

local addonName, addon = ...
local panel = CreateFrame("Frame", addonName .. "Options", UIParent)
panel.name = "Bagnon ItemLevel Ascension"

----------------------------------------------------------
-- Helper: Checkbox
----------------------------------------------------------
local function CreateCheckbox(parent, label, key, yOffset)
    local cb = CreateFrame("CheckButton", "$parent" .. key, parent, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 16, yOffset)
    cb:SetChecked(BagnonItemInfo_DB[key])

    local text = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("LEFT", cb, "RIGHT", 4, 1)
    text:SetText(label)
    cb.label = text

    cb:SetScript("OnClick", function(self)
        BagnonItemInfo_DB[key] = self:GetChecked()

        if addon.Private and addon.Private.Forceupdate then
            addon.Private.Forceupdate()
        end

        -- 🔄 Real-time refresh for visible buttons (Wrath-safe)
        for name, frame in pairs(_G) do
            if type(frame) == "table" and frame.itemFrame and frame.itemFrame.buttons then
                for _, button in pairs(frame.itemFrame.buttons) do
                    if button and button:IsVisible() then
                        for _, func in pairs(addon.Private.updates or {}) do
                            pcall(func, button)
                        end
                    end
                end
            end
        end
    end)

    return cb
end

----------------------------------------------------------
-- Create UI
----------------------------------------------------------
panel:SetScript("OnShow", function(self)
    if self.initialized then return end
    self.initialized = true

    local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Bagnon ItemLevel Ascension")

    local subtext = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtext:SetText("Customize item level, binding display, and garbage filtering for your Bagnon bags.")

    local y = -60
    CreateCheckbox(self, "Show item levels", "enableItemLevel", y)
    CreateCheckbox(self, "Show unbound items", "enableItemBind", y - 30)

    -- Checkbox: Colorize item level text by rarity
    local rarityCB = CreateFrame("CheckButton", "$parentenableRarityColoring", self, "InterfaceOptionsCheckButtonTemplate")
    rarityCB:SetPoint("TOPLEFT", 16, y - 60)
    rarityCB:SetChecked(BagnonItemInfo_DB.enableRarityColoring)

    local rarityLabel = rarityCB:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    rarityLabel:SetPoint("LEFT", rarityCB, "RIGHT", 4, 1)
    rarityLabel:SetText("Colorize item level text by rarity")

    rarityCB.tooltipText = "Changes only the color of the item level text to match the item's quality (common, rare, epic, etc)."

    rarityCB:SetScript("OnClick", function(self)
        BagnonItemInfo_DB.enableRarityColoring = self:GetChecked()

        if addon.Private and addon.Private.Forceupdate then
            addon.Private.Forceupdate()
        end

        -- 🔄 Real-time refresh for visible buttons (Wrath-safe)
        for name, frame in pairs(_G) do
            if type(frame) == "table" and frame.itemFrame and frame.itemFrame.buttons then
                for _, button in pairs(frame.itemFrame.buttons) do
                    if button and button:IsVisible() then
                        for _, func in pairs(addon.Private.updates or {}) do
                            pcall(func, button)
                        end
                    end
                end
            end
        end
    end)

    CreateCheckbox(self, "Desaturate and tone down garbage items", "enableGarbage", y - 90)
end)

----------------------------------------------------------
-- Register panel
----------------------------------------------------------
InterfaceOptions_AddCategory(panel)
