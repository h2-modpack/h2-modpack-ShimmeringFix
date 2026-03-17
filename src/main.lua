local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
local lib = mods['adamant-Modpack_Lib'].public

config = chalk.auto('config.lua')
public.config = config

local backup, restore = lib.createBackupSystem()

-- =============================================================================
-- MODULE DEFINITION
-- =============================================================================

public.definition = {
    id       = "ShimmeringFix",
    name     = "Shimmering Moonshot Fix",
    category = "BugFixes",
    group    = "Boons & Hammers",
    tooltip  = "Fixes Shimmering Moonshot not applying damage bonus to omega special.",
    default  = true,
    dataMutation = true,
}

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local function apply()
    if not TraitData.StaffJumpSpecialTrait then return end
    backup(TraitData.StaffJumpSpecialTrait.AddOutgoingDamageModifiers, "ProjectileName")
    backup(TraitData.StaffJumpSpecialTrait.AddOutgoingDamageModifiers, "ValidProjectiles")
    backup(TraitData.StaffJumpSpecialTrait, "PropertyChanges")
    TraitData.StaffJumpSpecialTrait.AddOutgoingDamageModifiers.ProjectileName = nil
    TraitData.StaffJumpSpecialTrait.AddOutgoingDamageModifiers.ValidProjectiles = { "ProjectileStaffBall", "ProjectileStaffBallCharged" }
    for _, propertyChange in ipairs(TraitData.StaffJumpSpecialTrait.PropertyChanges) do
        propertyChange.ProjectileNames = { "ProjectileStaffBall", "ProjectileStaffBallCharged" }
    end
end

local function registerHooks()
end

-- =============================================================================
-- Wiring
-- =============================================================================

public.definition.enable = apply
public.definition.disable = restore

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if config.Enabled then apply() end
        if public.definition.dataMutation and not mods['adamant-Core'] then
            SetupRunData()
        end
    end)
end)

lib.standaloneUI(public.definition, config, apply, restore)
