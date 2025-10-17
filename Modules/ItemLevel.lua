--========================================================
-- Bagnon ItemLevel Ascension (Wrath/Ascension compatible)
--========================================================
local Addon, Private = ...
local Module = Bagnon:NewModule("Bagnon_ItemLevel")

local cache = {}
Private.cache[Module] = cache

-- Colores por rareza
local colors = {
    [0] = {0.61, 0.61, 0.61}, -- Poor
    [1] = {0.94, 0.94, 0.94}, -- Common
    [2] = {0.12, 1.00, 0.00}, -- Uncommon
    [3] = {0.00, 0.44, 0.87}, -- Rare
    [4] = {0.64, 0.21, 0.93}, -- Epic
    [5] = {1.00, 0.38, 0.00}, -- Legendary
    [6] = {0.90, 0.80, 0.50}, -- Artifact
    [7] = {0.31, 0.78, 1.00}  -- Heirloom
}

-- APIs seguras
local GetContainerItemLink = GetContainerItemLink
local GetItemInfo = GetItemInfo

Private.AddUpdater(Module, function(button)
    local db = BagnonItemInfo_DB
    if not db then return end

    -- Si el toggle está desactivado, ocultar cualquier texto previo
    if not db.enableItemLevel then
        if cache[button] then
            cache[button]:SetText("")
        end
        return
    end

    -- Detectar bag y slot (Wrath compatible)
    local bag, slot
    if button.GetBag and button:GetBag() then
        bag = button:GetBag()
    elseif button.bag then
        bag = button.bag
    end
    if button.GetID and button:GetID() then
        slot = button:GetID()
    elseif button.slot then
        slot = button.slot
    end
    if not bag or not slot then return end

    local link = GetContainerItemLink(bag, slot)
    if not link then
        if cache[button] then
            cache[button]:SetText("")
        end
        return
    end

local _, _, quality, level = GetItemInfo(link)

-- ❌ Ocultar si no tiene nivel o no es equipable
if not level or level <= 0 or not IsEquippableItem(link) then
    if cache[button] then
        cache[button]:SetText("")
    end
    return
end

    -- Crear el label si no existe
    local label = cache[button]
    if not label then
        label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", 2, -2)
        label:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        label:SetShadowOffset(1, -1)
        cache[button] = label
    end

    -- Colorear por rareza si está habilitado
    local color = {1, 1, 1}
    if db.enableRarityColoring and quality and colors[quality] then
        color = colors[quality]
    end

    -- Mostrar el item level
    label:SetText(level)
    label:SetTextColor(color[1], color[2], color[3])
end)
