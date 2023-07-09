SettingsTableDB = {
    TableSettingValues = {
        1, 2, 3
    }
}

local function CreateSettingsSpellSearchInitializer(name, searchText, onSpellAdded, tooltip)
    local data = { name = name, searchText = searchText, onSpellAdded = onSpellAdded, tooltip = tooltip }
    local initializer = Settings.CreateElementInitializer("NamePlatesCompleteSpellSelectorTemplate", data)
    initializer:AddSearchTags(name)
    return initializer
end

local function CreateSettingsSpellInitializerData(spellID, onSpellRemoved)
    local name, _, icon, _, _, _, spellID, _ = GetSpellInfo(spellID)
    local tooltip = GetSpellDescription(spellID)
    if name then
        return { name = name, tooltip = tooltip, icon = icon, spellID = spellID, onSpellRemoved = onSpellRemoved }
    end
end

local function CreateSettingsSpellInitializer(data)
    local initializer = Settings.CreateElementInitializer("NamePlatesCompleteSpellTemplate", data)
    initializer:AddSearchTags(data.name)
    return initializer
end

local function SaveSetting(_, setting, value)
    local variable = setting:GetVariable()
    SettingsTableDB[variable] = value
end

local function InitSettingsLayout(layout, setting)
    assert(setting:GetVariableType() == "table")

    do
        local function OnSpellSelected(name, spellID)
            local tbl = setting:GetValue()
            table.insert(tbl, 1, spellID)
            setting:SetValue(tbl, true)
        end
        local name = "Add a spell"
        local searchText = "Search Spell ID or Name"
        local tooltipText = "Press me"
        local initializer = CreateSettingsSpellSearchInitializer(name, searchText, OnSpellSelected,
            tooltipText)
        layout:AddInitializer(initializer)
    end

    do
        for _, spellID in ipairs(setting:GetValue()) do
            local function OnSpellRemoved(spellID)
                local tbl = setting:GetValue()
                for i = 1, #tbl do
                    if tbl[i] == spellID then
                        table.remove(tbl, i)
                    end
                end
                setting:SetValue(tbl, true)
            end

            local data = CreateSettingsSpellInitializerData(spellID, OnSpellRemoved)
            if data then
                local initializer = CreateSettingsSpellInitializer(data)
                layout:AddInitializer(initializer)
            end
        end
    end
end

local function RegisterSettings()
    local category, layout = Settings.RegisterVerticalLayoutCategory("Dynamic Vertical Settings Example")

    -- This is the interface between Settings/Options UI and the addon tables
    local name = "Example Table Setting"
    local variable = "TableSettingValues"
    local defaultValue = SettingsTableDB[variable]
    local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)

    Settings.SetOnValueChangedCallback(variable, SaveSetting)
    Settings.SetOnValueChangedCallback(variable, function()
        -- Reset the layout
        -- ShouldShow() == false removes SettingsList elements by filtering the initializer from the SettingsList ScrollBox DataProvider
        for _, init in ipairs(layout:GetInitializers()) do
            init:AddShownPredicate(function() return false end)
        end
        table.wipe(layout:GetInitializers())

        InitSettingsLayout(layout, setting)

        SettingsInbound.RepairDisplay()
    end)

    InitSettingsLayout(layout, setting)

    Settings.RegisterAddOnCategory(category)
    Settings.OpenToCategory(category.ID)
end

SettingsRegistrar:AddRegistrant(RegisterSettings)

NamePlatesCompleteSpellSelectorMixin = CreateFromMixins(SettingsListSectionHeaderMixin)

function NamePlatesCompleteSpellSelectorMixin:OnLoad()
    self.SearchBox:HookScript("OnTextChanged", GenerateClosure(self.OnSearchTextChanged, self))
    self.SearchBox:HookScript("OnEnterPressed", GenerateClosure(self.OnSearchEnterPressed, self))
end

function NamePlatesCompleteSpellSelectorMixin:Init(initializer)
    SettingsListSectionHeaderMixin.Init(self, initializer)

    -- local tooltip = GenerateClosure(Settings.InitTooltip, "stuff", "morestuff")
    -- self.Tooltip:SetTooltipFunc(GenerateClosure(InitializeSettingTooltip, initializer))
    self.Tooltip:SetCustomTooltipAnchoring(self.SearchBox, "ANCHOR_LEFT", 0, 0)
    self.Tooltip.tooltipText = "Ohai"

    self.Tooltip:HookScript("OnEnter", function() print("enter") end)
    print("search init")
end

function NamePlatesCompleteSpellSelectorMixin:OnSearchTextChanged()
    local text = self.SearchBox:GetText()
    local name, _, icon, _, _, _, spellID, _ = GetSpellInfo(text)

    if name then
        self.Icon:SetTexture(icon)
        self.Icon:Show()

        self.Tooltip.tooltipText = GetSpellDescription(spellID) .. "\r" .. spellID
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
        data.onSpellAdded(name, spellID)
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
    DevTools_Dump(data)
    data.onSpellRemoved(data.spellID)
end

function NamePlatesCompleteSpellMixin:Init(initializer)
    SettingsListElementMixin.Init(self, initializer)

    local data  = initializer:GetData()
    self.Icon:SetTexture(data.icon)
end
