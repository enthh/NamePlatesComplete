local _, priv = ...

function NamePlatesComplete.CreateSettingsSpellSearchInitializer(name, searchText, onSpellAdded, tooltip)
    local data = { name = name, searchText = searchText, onSpellAdded = onSpellAdded, tooltip = tooltip }
    local initializer = Settings.CreateElementInitializer("NamePlatesCompleteSpellSelectorTemplate", data)
    initializer:AddSearchTags(name)
    return initializer
end

function NamePlatesComplete.CreateSettingsSpellInitializerData(spellID, onSpellRemoved)
    local name, _, icon, _, _, _, spellID, _ = GetSpellInfo(spellID)
    local tooltip = GetSpellDescription(spellID)
    if name then
        return { name = name, tooltip = tooltip, icon = icon, spellID = spellID, onSpellRemoved = onSpellRemoved }
    end
end

function NamePlatesComplete.CreateSettingsSpellInitializer(data)
    local initializer = Settings.CreateElementInitializer("NamePlatesCompleteSpellTemplate", data)
    initializer:AddSearchTags(data.name)
    return initializer
end

function NamePlatesComplete.CreateSpellList(category, setting, heading)
    local layout = SettingsPanel:GetLayout(category)

    local function remove(spellID)
        local tbl = setting:GetValue()
        for i = 1, #tbl do
            if tbl[i] == spellID then
                table.remove(tbl, i)
            end
        end
        setting:SetValue(tbl, true)
    end

    local function add(spellID)
        local tbl = setting:GetValue()
        remove(spellID)
        table.insert(tbl, 1, spellID)
        setting:SetValue(tbl, true)
    end

    do
        local search = "Search Spell ID or Name. Press enter to add."
        local tooltip = "Enter a spell name or spell ID until the icon appears. Press enter to add."
        local initializer = NamePlatesComplete.CreateSettingsSpellSearchInitializer(
            heading, search, add, tooltip)
        layout:AddInitializer(initializer)
    end

    do
        for _, spellID in ipairs(setting:GetValue()) do
            local data = NamePlatesComplete.CreateSettingsSpellInitializerData(spellID, remove)
            if data then
                local initializer = NamePlatesComplete.CreateSettingsSpellInitializer(data)
                layout:AddInitializer(initializer)
            end
        end
    end
end

function NamePlatesComplete.RegisterSavedSetting(category, saved, name, variable, default)
    local setting = Settings.RegisterAddOnSetting(category, name, variable, type(default), default)

    setting:SetValue(saved[variable])
    Settings.SetOnValueChangedCallback(variable, function(_, modifiedSetting, value)
        saved[modifiedSetting:GetVariable()] = value
    end)

    if setting:GetValue() == nil then
        setting:SetValueToDefault()
    end

    return setting
end

function NamePlatesComplete.LayoutSettings(category, layoutFunc, ...)
    local initialize = GenerateClosure(layoutFunc, category, ...)

    local function reset(initializers)
        for _, init in ipairs(initializers) do
            init:AddShownPredicate(function() return false end)
        end
        table.wipe(initializers)
    end

    local function reload()
        reset(SettingsPanel:GetLayout(category):GetInitializers())
        initialize()
        SettingsInbound.RepairDisplay()
    end

    for _, setting in ipairs({...}) do
        Settings.SetOnValueChangedCallback(setting:GetVariable(), reload)
    end

    initialize()
end

local function RegisterSettings()
    local category = Settings.RegisterVerticalLayoutCategory("Nameplates Complete")
    Settings.RegisterAddOnCategory(category)
    -- Settings.OpenToCategory(category.ID)

    NamePlatesComplete.SettingsCategory = category
end

SettingsRegistrar:AddRegistrant(RegisterSettings)

NamePlatesCompleteSpellSelectorMixin = CreateFromMixins(SettingsListSectionHeaderMixin)

function NamePlatesCompleteSpellSelectorMixin:OnLoad()
    self.SearchBox:HookScript("OnTextChanged", GenerateClosure(self.OnSearchTextChanged, self))
    self.SearchBox:HookScript("OnEnterPressed", GenerateClosure(self.OnSearchEnterPressed, self))
end

function NamePlatesCompleteSpellSelectorMixin:Init(initializer)
    SettingsListSectionHeaderMixin.Init(self, initializer)

    self.Tooltip:SetCustomTooltipAnchoring(self.SearchBox, "ANCHOR_LEFT", 0, 0)
end

function NamePlatesCompleteSpellSelectorMixin:OnSearchTextChanged()
    local text = self.SearchBox:GetText()
    local name, _, icon, _, _, _, spellID, _ = GetSpellInfo(text)

    if name then
        self.Icon:SetTexture(icon)
        self.Icon:Show()

        self.Tooltip.tooltipText = GetSpellDescription(spellID) .. "\r\r|cnGRAY_FONT_COLOR:" .. spellID .. "|r"
        self.Tooltip:OnEnter()
    else
        self.Tooltip.tooltipText = "Search for a spell name or ID to add"
        self.Icon:Hide()
        self.Tooltip:OnLeave()
    end
end

function NamePlatesCompleteSpellSelectorMixin:OnSearchEnterPressed()
    local text = self.SearchBox:GetText()
    local name, _, icon, _, _, _, spellID, _ = GetSpellInfo(text)
    if name then
        local initializer = self:GetElementData()
        local data = initializer:GetData()
        data.onSpellAdded(spellID)
        self.SearchBox:SetText("")
    end
end

NamePlatesCompleteSpellMixin = CreateFromMixins(SettingsListElementMixin)

function NamePlatesCompleteSpellMixin:OnLoad()
    SettingsListElementMixin.OnLoad(self)
    self.CloseButton:HookScript("OnClick", GenerateClosure(self.OnCloseButtonClicked, self))
end

function NamePlatesCompleteSpellMixin:OnCloseButtonClicked()
    local initializer = self:GetElementData()
    local data = initializer:GetData()
    data.onSpellRemoved(data.spellID)
end

function NamePlatesCompleteSpellMixin:Init(initializer)
    SettingsListElementMixin.Init(self, initializer)

    local data = initializer:GetData()
    self.Text:SetText(data.name .. " |cnGRAY_FONT_COLOR:" .. data.spellID .. "|r")
    self.Icon:SetTexture(data.icon)
end
