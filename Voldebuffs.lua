--[[ Text by class color
Class    AARRGGBB (Alpha, R,G,B)
Druid    ffff7d0a
Hunter    ffabd473
Mage    ff69ccf0
Paladin    fff58cba
Priest    ffffffff
Rogue    fffff569
Shaman    ff0070de
Warlock    ff9482c9
Warrior    ffc79c6e
]]--

local MODNAME = "Voldebuffs"
local vb_addon = LibStub("AceAddon-3.0"):NewAddon(MODNAME, "AceConsole-3.0")

-- declare defaults to be used in the DB
local defaults = {
   profile = {
      vb_enableoutofcombat = false,
      vb_enable = true,
      vb_isMovable = true,
      vb_scale = 1,
      vb_Show_Druid = true,
      vb_Show_Hunter = true,
      vb_Show_Mage = true,
      vb_Show_Paladin = true,
      vb_Show_Priest = true,
      vb_Show_Rogue = true,
      vb_Show_Shaman = true,
      vb_Show_Warlock = true,
      vb_Show_Warrior = true,
      
      vb_Show_HUNTERAURA = true,
      vb_Show_HUNTERASPECT = true,
      vb_Show_WARRIORSHOUT = true,
      vb_Show_PALADINBLESSING = true,
      vb_Show_PALADINAURA = true,
      vb_Show_PALADINSEAL = true,
      vb_Show_SHAMANSHIELD = true,
      vb_Show_MAGEBUFF = true,
      vb_Show_MAGEARMOR = true,
      vb_Show_DRUIDTHORN = true,
      vb_Show_DRUIDBUFF = true,
      vb_Show_PRIESTSTAM = true,
      vb_Show_PRIESTSPIRIT = true,
      vb_Show_PRIESTINNERFIRE = true,
      vb_Show_WARLOCKARMOR = true,
   }
}

function vb_addon:OnInitialize()
   -- Assuming the .toc says ## SavedVariables: vb_optionsDB
   vb_addon.db = LibStub("AceDB-3.0"):New("vb_optionsDB", defaults, true)
   vb_addon.player = UnitName("player")
   vb_updateScale()
   vb_options_init()
   vb_toggleMovable()
end

function vb_addon:OnEnable()
   -- Called when the addon is enabled
end

function vb_addon:OnDisable()
   -- Called when the addon is disabled
end

---------------------------------------------------------
-- Initialize ranged weapon tooltip parser
local vb_f = CreateFrame('GameTooltip', 'MyTooltip', UIParent, 'GameTooltipTemplate')
-- call this every time you want to scan
vb_f:SetOwner(UIParent, 'ANCHOR_NONE')
-- do something with the tooltip, for example set it to a player buff   
vb_f:SetInventoryItem('player',18,false)
vb_tempTooltipText = ""

---------------------------------------------------------
-- Initialize class names to be shown to the player

local VB_DRUID = "|cffff7d0aDruid|r"
local VB_HUNTER = "|cffabd473Hunter|r"
local VB_MAGE = "|cff69ccf0Mage|r"
local VB_PALADIN = "|cfff58cbaPaladin|r"
local VB_PRIEST = "|cffffffffPriest|r"
local VB_ROGUE = "|cfffff569Rogue|r"
local VB_SHAMAN = "|cff0070deShaman|r"
local VB_WARLOCK = "|cff9482c9Warlock|r"
local VB_WARRIOR = "|cffc79c6eWarrior|r"

---------------------------------------------------------
-- Initialize names to be shown to the player
local vb_HUNTERAURA = "Trueshot Aura"
local vb_HUNTERASPECT = "Hunter Aspect"

local vb_WARRIORSHOUT = "Warrior Shout"

local vb_PALADINBLESSING = "Paladin Blessing"
local vb_PALADINAURA = "Paladin Aura"
local vb_PALADINSEAL = "Paladin Seal"

local vb_SHAMANSHIELD = "Shaman Shield"

local vb_MAGEBUFF = "Mage Intellect"
local vb_MAGEARMOR = "Mage Armor"

local vb_DRUIDTHORN = "Thorns"
local vb_DRUIDBUFF = "Druid Buff"

local vb_PRIESTSTAM = "Priest Fortitude"
local vb_PRIESTSPIRIT = "Priest Spirit"
local vb_PRIESTINNERFIRE = "Inner Fire"

local vb_WARLOCKARMOR = "Demon Armor"

---------------------------------------------------------
-- Initialize Options

function vb_OptionsTable()
   if not vb_options then
      vb_options = {
         type = 'group',
         childGroups = "tab",
         get = Get,
         set = Set,
         args = {
            --type = "group",
            --name = MODNAME,
            --args = {
            option1 = {
               name = "General",
               desc = "General options",
               type = "group",
               order = 0,
               args = {
                  version = {
                     order    = 11,
                     type    = "description",
                     name    = MODNAME .. " Version: " .. GetAddOnMetadata(MODNAME, "Version"),
                  },
                  spacer1 = {
                     order    = 12,
                     type    = "description",
                     name    = "\n",
                  },
                  header1 = {
                     order    = 15,
                     type    = "header",
                     name    = "Main Options",
                  },
                  enabled = {
                     order    = 21,
                     type = "toggle",
                     name = "Enable",
                     desc = "Tick to enable " .. MODNAME,
                     get    = function() return vb_addon.db.profile.vb_enable end,
                     set    = function() vb_addon.db.profile.vb_enable = not vb_addon.db.profile.vb_enable UpdateSpells() end,
                  },
                  showOutOfCombat = {
                     order    = 22,
                     type = "toggle",
                     name = "Show out of combat",
                     desc = "Tick to show " .. MODNAME .. " out of combat",
                     get    = function() return vb_addon.db.profile.vb_enableoutofcombat end,
                     set    = function() vb_addon.db.profile.vb_enableoutofcombat = not vb_addon.db.profile.vb_enableoutofcombat UpdateSpells() end,
                  },
                  toggleMovable = {
                     order    = 23,
                     type = "toggle",
                     name = "Move frame",
                     desc = "Tick to make frame draggable",
                     get    = function() return vb_addon.db.profile.vb_isMovable end,
                     set    = function() vb_addon.db.profile.vb_isMovable = not vb_addon.db.profile.vb_isMovable vb_toggleMovable() end,
                  },
                  scale = {
                     order    = 25,
                     type = "range",
                     name = "Scale",
                     softMin = 0.1, softMax = 1.4, step = 0.1,
                     get    = function() return vb_addon.db.profile.vb_scale end,
                     set    = function(info, value) vb_addon.db.profile.vb_scale = value vb_updateScale() end,
                  },
                  spacer1 = {
                     order    = 28,
                     type    = "description",
                     name    = "\n",
                  },
                  header2 = {
                     order    = 29,
                     type    = "header",
                     name    = "Class Options",
                  },
                  Druid = {
                     order    = 30,
                     type = "toggle",
                     name = VB_DRUID,
                     desc = "Tick to enable " .. VB_DRUID .. " buffs",
                     get    = function() return vb_addon.db.profile.vb_Show_Druid end,
                     set    = function() vb_addon.db.profile.vb_Show_Druid = not vb_addon.db.profile.vb_Show_Druid UpdateSpells() end,
                  },
                  Hunter = {
                     order    = 31,
                     type = "toggle",
                     name = VB_HUNTER,
                     desc = "Tick to enable " .. VB_HUNTER .. " buffs",
                     get    = function() return vb_addon.db.profile.vb_Show_Hunter end,
                     set    = function() vb_addon.db.profile.vb_Show_Hunter = not vb_addon.db.profile.vb_Show_Hunter UpdateSpells() end,
                  },
                  Mage = {
                     order    = 32,
                     type = "toggle",
                     name = VB_MAGE,
                     desc = "Tick to enable " .. VB_MAGE .. " buffs",
                     get    = function() return vb_addon.db.profile.vb_Show_Mage end,
                     set    = function() vb_addon.db.profile.vb_Show_Mage = not vb_addon.db.profile.vb_Show_Mage UpdateSpells() end,
                  },
                  Paladin = {
                     order    = 33,
                     type = "toggle",
                     name = VB_PALADIN,
                     desc = "Tick to enable " .. VB_PALADIN .. " buffs",
                     get    = function() return vb_addon.db.profile.vb_Show_Paladin end,
                     set    = function() vb_addon.db.profile.vb_Show_Paladin = not vb_addon.db.profile.vb_Show_Paladin UpdateSpells() end,
                  },
                  Priest = {
                     order    = 34,
                     type = "toggle",
                     name = VB_PRIEST,
                     desc = "Tick to enable " .. VB_PRIEST .. " buffs",
                     get    = function() return vb_addon.db.profile.vb_Show_Priest end,
                     set    = function() vb_addon.db.profile.vb_Show_Priest = not vb_addon.db.profile.vb_Show_Priest UpdateSpells() end,
                  },
                  Rogue = {
                     order    = 35,
                     type = "toggle",
                     name = VB_ROGUE,
                     desc = "Tick to enable " .. VB_ROGUE .. " buffs",
                     get    = function() return vb_addon.db.profile.vb_Show_Rogue end,
                     set    = function() vb_addon.db.profile.vb_Show_Rogue = not vb_addon.db.profile.vb_Show_Rogue UpdateSpells() end,
                  },
                  Shaman = {
                     order    = 36,
                     type = "toggle",
                     name = VB_SHAMAN,
                     desc = "Tick to enable " .. VB_SHAMAN .. " buffs",
                     get    = function() return vb_addon.db.profile.vb_Show_Shaman end,
                     set    = function() vb_addon.db.profile.vb_Show_Shaman = not vb_addon.db.profile.vb_Show_Shaman UpdateSpells() end,
                  },
                  Warlock = {
                     order    = 37,
                     type = "toggle",
                     name = VB_WARLOCK,
                     desc = "Tick to enable " .. VB_WARLOCK .. " buffs",
                     get    = function() return vb_addon.db.profile.vb_Show_Warlock end,
                     set    = function() vb_addon.db.profile.vb_Show_Warlock = not vb_addon.db.profile.vb_Show_Warlock UpdateSpells() end,
                  },
                  Warrior = {
                     order    = 38,
                     type = "toggle",
                     name = VB_WARRIOR,
                     desc = "Tick to enable " .. VB_WARRIOR .. " buffs",
                     get    = function() return vb_addon.db.profile.vb_Show_Warrior end,
                     set    = function() vb_addon.db.profile.vb_Show_Warrior = not vb_addon.db.profile.vb_Show_Warrior UpdateSpells() end,
                  },
               },
            },
            option2 = {
               name = "Buffs",
               desc = "Enable or disable specific buff types",
               type = "group",
               order = 1,
               args = {
                  headerBuffs1 = {
                     order    = 10,
                     type    = "header",
                     name    = "Buff Selection",
                  },
                  hunterAura = {
                     order    = 21,
                     type = "toggle",
                     name = vb_HUNTERAURA,
                     desc = "Tick to enable |cffabd473" .. vb_HUNTERAURA .. "|r monitoring",
                     get    = function() return vb_addon.db.profile.vb_Show_HUNTERAURA end,
                     set    = function() vb_addon.db.profile.vb_Show_HUNTERAURA = not vb_addon.db.profile.vb_Show_HUNTERAURA UpdateSpells() end,
                  },
                  hunterAspect = {
                     order    = 22,
                     type = "toggle",
                     name = vb_HUNTERASPECT,
                     desc = "Tick to enable |cffabd473" .. vb_HUNTERASPECT .. "|r monitoring",
                     get    = function() return vb_addon.db.profile.vb_Show_HUNTERASPECT end,
                     set    = function() vb_addon.db.profile.vb_Show_HUNTERASPECT = not vb_addon.db.profile.vb_Show_HUNTERASPECT UpdateSpells() end,
                  },
                  warriorShout = {
                     order    = 23,
                     type = "toggle",
                     name = vb_WARRIORSHOUT,
                     desc = "Tick to enable |cffc79c6e" .. vb_WARRIORSHOUT .. "|r monitoring",
                     get    = function() return vb_addon.db.profile.vb_Show_WARRIORSHOUT end,
                     set    = function() vb_addon.db.profile.vb_Show_WARRIORSHOUT = not vb_addon.db.profile.vb_Show_WARRIORSHOUT UpdateSpells() end,
                  },
                  paladinBlessing = {
                     order    = 24,
                     type = "toggle",
                     name = vb_PALADINBLESSING,
                     desc = "Tick to enable |cfff58cba" .. vb_PALADINBLESSING .. "|r monitoring",
                     get    = function() return vb_addon.db.profile.vb_Show_PALADINBLESSING end,
                     set    = function() vb_addon.db.profile.vb_Show_PALADINBLESSING = not vb_addon.db.profile.vb_Show_PALADINBLESSING UpdateSpells() end,
                  },
                  paladinAura = {
                     order    = 25,
                     type = "toggle",
                     name = vb_PALADINAURA,
                     desc = "Tick to enable |cfff58cba" .. vb_PALADINAURA .. "|r monitoring",
                     get    = function() return vb_addon.db.profile.vb_Show_PALADINAURA end,
                     set    = function() vb_addon.db.profile.vb_Show_PALADINAURA = not vb_addon.db.profile.vb_Show_PALADINAURA UpdateSpells() end,
                  },
                  paladinSeal = {
                     order    = 26,
                     type = "toggle",
                     name = vb_PALADINSEAL,
                     desc = "Tick to enable |cfff58cba" .. vb_PALADINSEAL .. "|r monitoring",
                     get    = function() return vb_addon.db.profile.vb_Show_PALADINSEAL end,
                     set    = function() vb_addon.db.profile.vb_Show_PALADINSEAL = not vb_addon.db.profile.vb_Show_PALADINSEAL UpdateSpells() end,
                  },
                  shamanShield = {
                     order    = 27,
                     type = "toggle",
                     name = vb_SHAMANSHIELD,
                     desc = "Tick to enable |cff0070de" .. vb_SHAMANSHIELD .. "|r monitoring",
                     get    = function() return vb_addon.db.profile.vb_Show_SHAMANSHIELD end,
                     set    = function() vb_addon.db.profile.vb_Show_SHAMANSHIELD = not vb_addon.db.profile.vb_Show_SHAMANSHIELD UpdateSpells() end,
                  },
                  mageBuff = {
                     order    = 28,
                     type = "toggle",
                     name = vb_MAGEBUFF,
                     desc = "Tick to enable |cff69ccf0" .. vb_MAGEBUFF .. "|r monitoring",
                     get    = function() return vb_addon.db.profile.vb_Show_MAGEBUFF end,
                     set    = function() vb_addon.db.profile.vb_Show_MAGEBUFF = not vb_addon.db.profile.vb_Show_MAGEBUFF UpdateSpells() end,
                  },
                  mageArmor = {
                     order    = 29,
                     type = "toggle",
                     name = vb_MAGEARMOR,
                     desc = "Tick to enable |cff69ccf0" .. vb_MAGEARMOR .. "|r monitoring",
                     get    = function() return vb_addon.db.profile.vb_Show_MAGEARMOR end,
                     set    = function() vb_addon.db.profile.vb_Show_MAGEARMOR = not vb_addon.db.profile.vb_Show_MAGEARMOR UpdateSpells() end,
                  },
                  druidThorns = {
                     order    = 30,
                     type = "toggle",
                     name = vb_DRUIDTHORN,
                     desc = "Tick to enable |cffff7d0a" .. vb_DRUIDTHORN .. "|r monitoring",
                     get    = function() return vb_addon.db.profile.vb_Show_DRUIDTHORN end,
                     set    = function() vb_addon.db.profile.vb_Show_DRUIDTHORN = not vb_addon.db.profile.vb_Show_DRUIDTHORN UpdateSpells() end,
                  },
                  druidBuff = {
                     order    = 31,
                     type = "toggle",
                     name = vb_DRUIDBUFF,
                     desc = "Tick to enable |cffff7d0a" .. vb_DRUIDBUFF .. "|r monitoring",
                     get    = function() return vb_addon.db.profile.vb_Show_DRUIDBUFF end,
                     set    = function() vb_addon.db.profile.vb_Show_DRUIDBUFF = not vb_addon.db.profile.vb_Show_DRUIDBUFF UpdateSpells() end,
                  },
                  priestStam = {
                     order    = 32,
                     type = "toggle",
                     name = vb_PRIESTSTAM,
                     desc = "Tick to enable |cffffffff" .. vb_PRIESTSTAM .. "|r monitoring",
                     get    = function() return vb_addon.db.profile.vb_Show_PRIESTSTAM end,
                     set    = function() vb_addon.db.profile.vb_Show_PRIESTSTAM = not vb_addon.db.profile.vb_Show_PRIESTSTAM UpdateSpells() end,
                  },
                  priestSpirit = {
                     order    = 33,
                     type = "toggle",
                     name = vb_PRIESTSPIRIT,
                     desc = "Tick to enable |cffffffff" .. vb_PRIESTSPIRIT .. "|r monitoring",
                     get    = function() return vb_addon.db.profile.vb_Show_PRIESTSPIRIT end,
                     set    = function() vb_addon.db.profile.vb_Show_PRIESTSPIRIT = not vb_addon.db.profile.vb_Show_PRIESTSPIRIT UpdateSpells() end,
                  },
                  priestInnerFire = {
                     order    = 34,
                     type = "toggle",
                     name = vb_PRIESTINNERFIRE,
                     desc = "Tick to enable |cffffffff" .. vb_PRIESTINNERFIRE .. "|r monitoring",
                     get    = function() return vb_addon.db.profile.vb_Show_PRIESTINNERFIRE end,
                     set    = function() vb_addon.db.profile.vb_Show_PRIESTINNERFIRE = not vb_addon.db.profile.vb_Show_PRIESTINNERFIRE UpdateSpells() end,
                  },
               },
            }
         }
      }
      
   end
   return vb_options
end

function vb_druidBuffOptions()
   if not druid_options then
      druid_options = {
         type = "group",
         name = MODNAME,
         args = {
            version = {
               order    = 11,
               type    = "description",
               name    = MODNAME .. " Version: " .. GetAddOnMetadata(MODNAME, "Version"),
            },
         },
      }
   end
   return druid_options
end

function vb_options_init()
   LibStub("AceConfig-3.0"):RegisterOptionsTable(MODNAME, vb_OptionsTable)
   vb_addon.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(MODNAME, MODNAME)
   vb_addon:RegisterChatCommand("vb", ChatCommand)
   vb_addon:RegisterChatCommand("voldebuff", ChatCommand)
   vb_addon:RegisterChatCommand("voldebuffs", ChatCommand)
end

function ChatCommand(chat_args)
   chatout = MODNAME
   
   if     chat_args == "enable" then chatout = chatout .. " [Enabled]"
   elseif chat_args == "disable" then chatout = chatout .. " [Disabled]"
   else chatout = chatout .. " use:\n" .. "- Enable\n" .. "- Disable"
   end
   print (chatout)
   
end

---------------------------------------------------------
-- Initialize variables
local vb_enableoutofcombat
local vb_enable
local vb_outText = ""
local vb_currentBuffs = ""
local vb_scale
local vb_isMovable

---------------------------------------------------------
-- Create frame and register events

local MyTextFrame = CreateFrame("frame","VoldebuffsFrame")
MyTextFrame:SetWidth(100)
MyTextFrame:SetHeight(100)
MyTextFrame:SetPoint("CENTER",UIParent,"CENTER",0,0)
MyTextFrame:SetFrameStrata("FULLSCREEN_DIALOG")
MyTextFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
MyTextFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
MyTextFrame:SetMovable(true)
MyTextFrame:SetUserPlaced(true)
MyTextFrame:SetFrameLevel(17)
MyTextFrame:SetScale(1)
MyTextFrame:EnableMouse(true)
MyTextFrame:RegisterForDrag("LeftButton")


local FontrString = MyTextFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
FontrString:SetPoint("CENTER")

local vb_frame = CreateFrame("Frame")

vb_frame:RegisterEvent("UNIT_AURA")
vb_frame:RegisterEvent("PLAYER_ENTER_COMBAT")
vb_frame:RegisterEvent("PLAYER_LEAVE_COMBAT")
vb_frame:RegisterEvent("UNIT_SPELLCAST_START")
vb_frame:RegisterEvent("ADDON_LOADED");
vb_frame:RegisterEvent("PLAYER_LOGOUT");
vb_frame:RegisterEvent("SKILL_LINES_CHANGED");

---------------------------------------------------------
-- Frame scaler function

function vb_updateScale()
   MyTextFrame:SetScale(vb_addon.db.profile.vb_scale)
   return true
end

---------------------------------------------------------
-- Frame movable toggle function

function vb_toggleMovable()
   MyTextFrame:EnableMouse(vb_addon.db.profile.vb_isMovable)
   
   if (vb_addon.db.profile.vb_isMovable)
   then
      MyTextFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", --Set the background and border textures
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
            tile = true, tileSize = 16, edgeSize = 16, 
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
      })
      MyTextFrame:SetBackdropColor(0, 0, 0, 255) --Set the background colour to black
   else
      MyTextFrame:SetBackdrop({bgFile = "", --Set the background and border textures
            edgeFile = "", 
            tile = true, tileSize = 16, edgeSize = 16, 
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
      })
      MyTextFrame:SetBackdropColor(0, 0, 0, 0) --Set the background colour to black
   end
   
end

---------------------------------------------------------
-- Initialize buffs to be monitored

local vb_hunterauras = {
   ["Trueshot Aura"] = true,
}

local vb_shout = {
   ["Battle Shout"] = true,
   ["Commanding Shout"] = true,
}

local vb_blessings = {
   ["Blessing of Might"] = true,
   ["Blessing of Wisdom"] = true,
   ["Blessing of Kings"] = true,
   ["Blessing of Sanctuary"] = true,
   ["Greater Blessing of Might"] = true,
   ["Greater Blessing of Wisdom"] = true,
   ["Greater Blessing of Kings"] = true,
   ["Greater Blessing of Sanctuary"] = true,
}

local vb_shields = {
   ["Water Shield"] = true,
   ["Earth Shield"] = true,
   ["Lightning Shield"] = true,
}

local vb_aspects = {
   ["Aspect of the Monkey"] = true,
   ["Aspect of the Hawk"] = true,
   ["Aspect of the Beast"] = true,
   ["Aspect of the Cheetah"] = true,
   ["Aspect of the Pack"] = true,
   ["Aspect of the Viper"] = true,
   ["Aspect of the Dragonhawk"] = true,
}

local vb_auras = {
   ["Devotion Aura"] = true,
   ["Retribution Aura"] = true,
   ["Concentration Aura"] = true,
   ["Shadow Resistance Aura"] = true,
   ["Fire Resistance Aura"] = true,
   ["Frost Resistance Aura"] = true,
}

local vb_seals = {
   ["Seal of Light"] = true,
   ["Seal of Wisdom"] = true,
   ["Seal of Command"] = true,
   ["Seal of Corruption"] = true,
   ["Seal of Justice"] = true,
   ["Seal of Righteousness"] = true,
   ["Seal of Vengeance"] = true,
}

local vb_magebuffs = {
   ["Arcane Intellect"] = true,
   ["Arcane Brilliance"] = true,   
}

local vb_magearmors = {
   ["Frost Armor"] = true,
   ["Ice Armor"] = true,
   ["Molten Armor"] = true,
   ["Mage Armor"] = true,
}

local vb_weaponBuffs = {
   ["Rockbiter Weapon"] = true,
   ["Flametongue Weapon"] = true,
   ["Frostbrand Weapon"] = true,
   ["Windfury Weapon"] = true,
   ["Earthliving Weapon"] = true,
}

local vb_poisons = {
   ["Instant Poison"] = true,
   ["Wound Poison"] = true,
   ["Anesthetic Poison"] = true,
   ["Deadly Poison"] = true,
}

local vb_druidthorns = {
   ["Thorns"] = true, 
}

local vb_druidbuffs = {
   ["Mark of the Wild"] = true,
   ["Gift of the Wild"] = true,   
}

local vb_priestbuffstam = {
   ["Power Word: Fortitude"] = true,
   ["Prayer of Fortitude"] = true,   
}

local vb_priestbuffspirit = {
   ["Divine Spirit"] = true,
   ["Prayer of Spirit"] = true,   
}

local vb_priestinnerf = {
   ["Inner Fire"] = true, 
}

local vb_wlockarmor = {
   ["Demon Skin"] = true, 
   ["Demon Armor"] = true, 
   ["Fel Armor"] = true, 
}

local vb_wlockweaponbuffs = {
   ["Create Firestone"] = true, 
   ["Create Spellstone"] = true, 
}

---------------------------------------------------------
-- Initialize bag and item counter

local vb_numberofitems
local vb_bags = {
   [0] = true,
   [1] = true,
   [2] = true,
   [3] = true,
   [4] = true,
   
}

---------------------------------------------------------
-- Translater worker

function vb_translater(vb_buffarr,vb_current,vb_out)
   for vb_buff in pairs(vb_buffarr) do
      if (type(vb_current)=="string") then 
         if string.match(vb_current,vb_buff) then
            vb_currentBuffs = vb_currentBuffs .. vb_out .. ", "
         end
      else 
         -- Only debugging, this table will normally never be printed
         if (type(vb_current)=="table") then
            for vb_tempcur in pairs(vb_current) do
               print ("vb_current" .. vb_tempcur)
            end
         end
      end
   end
end

---------------------------------------------------------
-- Translates buff name to screen text

function vb_translatebuffs(vb_inpbuffs)
   
   -- Trueshot aura
   vb_translater(vb_hunterauras,vb_inpbuffs,vb_HUNTERAURA)
   
   -- Warrior shout
   vb_translater(vb_shout,vb_inpbuffs,vb_WARRIORSHOUT)
   
   -- Shaman shields
   vb_translater(vb_shields,vb_inpbuffs,vb_SHAMANSHIELD)
   
   -- Blessings
   vb_translater(vb_blessings,vb_inpbuffs,vb_PALADINBLESSING)
   
   -- Aspects
   vb_translater(vb_aspects,vb_inpbuffs,vb_HUNTERASPECT)
   
   -- Mage Buffs
   vb_translater(vb_magebuffs,vb_inpbuffs,vb_MAGEBUFF)
   vb_translater(vb_magearmors,vb_inpbuffs,vb_MAGEARMOR)
   
   -- Auras
   vb_translater(vb_auras,vb_inpbuffs,vb_PALADINAURA)
   
   -- Seals
   vb_translater(vb_seals,vb_inpbuffs,vb_PALADINSEAL)
   
   -- Druid Thorns
   vb_translater(vb_druidthorns,vb_inpbuffs,vb_DRUIDTHORN)
   
   -- Druid Buffs
   vb_translater(vb_druidbuffs,vb_inpbuffs,vb_DRUIDBUFF)
   
   -- Priest Buffs
   vb_translater(vb_priestbuffstam,vb_inpbuffs,vb_PRIESTSTAM)
   vb_translater(vb_priestbuffspirit,vb_inpbuffs,vb_PRIESTSPIRIT)
   vb_translater(vb_priestinnerf,vb_inpbuffs,vb_PRIESTINNERF)
   
   -- Warlock Buffs
   vb_translater(vb_wlockarmor,vb_inpbuffs,vb_WARLOCKARMOR)
   
end

---------------------------------------------------------
-- Fetches list of current buffs on player

function vb_updatebufflist()
   local vb_charbuffs, i = { }, 1
   local vb_charbuff = UnitBuff("player", i)
   while vb_charbuff do
      vb_charbuffs[#vb_charbuffs + 1] = vb_charbuff
      i = i + 1
      vb_charbuff = UnitBuff("player", i)
   end
   if #vb_charbuffs < 1 then
      --
   else
      vb_charbuffs = table.concat(vb_charbuffs, ", ")
   end
   vb_translatebuffs(vb_charbuffs)
   return true
end

---------------------------------------------------------
-- Checks if player can cast a weapon buff

function vb_canShamanWeaponBuff()
   for vb_weaponBuff in pairs(vb_weaponBuffs) do
      if IsUsableSpell(vb_weaponBuff) then
         return true
      end
   end
   return false
end

function vb_canWarlockWeaponBuff()
   for vb_wlockweaponBuff in pairs(vb_wlockweaponbuffs) do
      if IsUsableSpell(vb_wlockweaponBuff) then
         return true
      end
   end
   return false
end
---------------------------------------------------------
-- Checks if player has poison in bags
function vb_hasPoison(vb_poisonlist)
   --   for vb_bag in pairs(vb_bags) do
   --      vb_numberofitems = GetContainerNumSlots(vb_bag)
   --      
   --      for i=1,vb_numberofitems do 
   --         local vb_link = GetContainerItemLink(vb_bag,i)
   --         local vb_printable = ""
   --         if (vb_link) then vb_printable = gsub(vb_link, "\124", "\124\124") end
   --         
   --         for vb_poison in pairs(vb_poisonlist) do
   --            if string.match(vb_printable,vb_poison) then
   --               return true
   --            end
   --         end
   --      end
   --   end
   return false
end

---------------------------------------------------------
-- Checks if player has poison in skillbook
function vb_hasPoison()
   if IsUsableSpell("Poisons") then
      return true
   end
   return false
end

---------------------------------------------------------
-- Checks if player has poison on currently equipped ranged weapon
function vb_rangedHasPoison()
   
   vb_getRangedWeaponTooltip()
   --print("Test: " .. vb_tempTooltipText)
   
   if (string.find(vb_tempTooltipText,"Poison")) then 
      return true
   else
      return false
   end
end

function vb_appendTooltip(vb_tempTooltipInput)
   -- Worker to simplify
   vb_tempTooltipText = vb_tempTooltipText .. " " .. vb_tempTooltipInput
end

function vb_getRangedWeaponTooltip()
   -- Part of the poison checking, finds ranged wep tooltip and parses it
   -- call this every time you want to scan
   vb_tempTooltipText = ""
   vb_f:SetOwner(UIParent, 'ANCHOR_NONE')
   vb_f:SetInventoryItem('player',18,false)
   
   if (vb_f:NumLines() >= 1) then vb_appendTooltip(MyTooltipTextLeft1:GetText()) end
   if (vb_f:NumLines() >= 2) then vb_appendTooltip(MyTooltipTextLeft2:GetText()) end
   if (vb_f:NumLines() >= 3) then vb_appendTooltip(MyTooltipTextLeft3:GetText()) end
   if (vb_f:NumLines() >= 4) then vb_appendTooltip(MyTooltipTextLeft4:GetText()) end
   if (vb_f:NumLines() >= 5) then vb_appendTooltip(MyTooltipTextLeft5:GetText()) end
   if (vb_f:NumLines() >= 6) then vb_appendTooltip(MyTooltipTextLeft6:GetText()) end
   if (vb_f:NumLines() >= 7) then vb_appendTooltip(MyTooltipTextLeft7:GetText()) end
   if (vb_f:NumLines() >= 8) then vb_appendTooltip(MyTooltipTextLeft8:GetText()) end
   if (vb_f:NumLines() >= 9) then vb_appendTooltip(MyTooltipTextLeft9:GetText()) end
   if (vb_f:NumLines() >= 10) then vb_appendTooltip(MyTooltipTextLeft10:GetText()) end
   if (vb_f:NumLines() >= 11) then vb_appendTooltip(MyTooltipTextLeft11:GetText()) end
   if (vb_f:NumLines() >= 12) then vb_appendTooltip(MyTooltipTextLeft12:GetText()) end
   if (vb_f:NumLines() >= 13) then vb_appendTooltip(MyTooltipTextLeft13:GetText()) end
   if (vb_f:NumLines() >= 14) then vb_appendTooltip(MyTooltipTextLeft14:GetText()) end
   if (vb_f:NumLines() >= 15) then vb_appendTooltip(MyTooltipTextLeft15:GetText()) end
end

---------------------------------------------------------
-- Checks for impossible duplicates, for example Frost/Ice armor

function vb_isduplicate(vb_inpbuff)
   if string.match(vb_outText,vb_inpbuff) then
      return true
   end
   return false
end

---------------------------------------------------------
-- Checks if player already has a certain buff

function vb_alreadyhasbuff(vb_inpbuff)
   if string.match(vb_currentBuffs,vb_inpbuff) then
      -- This might break paladin blessings that are being cast by other players
      -- that the player himself cannot cast.
      -- Try with this if that is the case:
      -- if IsUsableSpell(vb_inpbuff) then
      -- return true
      -- end
      return true
   end
   return false
end

---------------------------------------------------------
-- Function for checking buffs

function vb_checkbuff(vb_buffarr,vb_output)
   for vb_buff in pairs(vb_buffarr) do
      if UnitBuff("player",vb_buff) then
         -- Nothing
      else
         -- If you don't have the buff, check to see if you're still adjusting for it
         if vb_buffarr[vb_buff] then
            -- Only display if player can cast the spell (has it learned, has mana)
            if (IsUsableSpell(vb_buff)) then
               if (vb_isduplicate(vb_output)) then
                  -- Nothing
               else
                  if (vb_alreadyhasbuff(vb_output)) then
                     -- Nothing
                     if (string.match("Viper",vb_buff)) then
                        print (vb_buff)
                        --vb_outText = "Change Aspect!"
                     end
                  else
                     vb_outText = vb_outText .. vb_output .."\n"
                  end
               end
            end
         end
      end
   end
end

---------------------------------------------------------
-- Event script

vb_frame:SetScript("OnEvent", function(self, event, ...)
      
      if (vb_addon.db.profile.vb_enable) then else FontrString:SetText("") return end
      
      if (unit and unit ~= "player") then
         return
      end
      
      ---------------------------------------------------------
      -- Do work  
      vb_outText = ""
      vb_currentBuffs = ""
      
      ---------------------------------------------------------
      -- Populates list of current buffs on player to compare with      
      vb_updatebufflist()
      
      ---------------------------------------------------------
      -- Shaman shields
      if (vb_addon.db.profile.vb_Show_Shaman) then
         if (vb_addon.db.profile.vb_Show_SHAMANSHIELD) then vb_checkbuff(vb_shields,    vb_SHAMANSHIELD) end
      end
      ---------------------------------------------------------
      -- Hunter Buffs
      if (vb_addon.db.profile.vb_Show_Hunter) then
         if (vb_addon.db.profile.vb_Show_HUNTERASPECT) then vb_checkbuff(vb_aspects, vb_HUNTERASPECT) end
         if (vb_addon.db.profile.vb_Show_HUNTERAURA) then vb_checkbuff(vb_hunterauras, vb_HUNTERAURA) end
      end
      ---------------------------------------------------------
      -- Mage Buffs
      if (vb_addon.db.profile.vb_Show_Mage) then
         if (vb_addon.db.profile.vb_Show_MAGEARMOR) then vb_checkbuff(vb_magearmors, vb_MAGEARMOR) end
         if (vb_addon.db.profile.vb_Show_MAGEBUFF) then vb_checkbuff(vb_magebuffs, vb_MAGEBUFF) end
      end
      --------------------------------------------------------- 
      -- Paladin Buffs
      if (vb_addon.db.profile.vb_Show_Paladin) then
         if (vb_addon.db.profile.vb_Show_PALADINAURA) then vb_checkbuff(vb_auras, vb_PALADINAURA) end
         if (vb_addon.db.profile.vb_Show_PALADINBLESSING) then vb_checkbuff(vb_blessings, vb_PALADINBLESSING) end
         if (vb_addon.db.profile.vb_Show_PALADINSEAL) then vb_checkbuff(vb_seals, vb_PALADINSEAL) end
      end
      --------------------------------------------------------- 
      -- Priest Buffs
      if (vb_addon.db.profile.vb_Show_Priest) then
         if (vb_addon.db.profile.vb_Show_PRIESTSTAM) then vb_checkbuff(vb_priestbuffstam, vb_PRIESTSTAM) end
         if (vb_addon.db.profile.vb_Show_PRIESTSPIRIT) then vb_checkbuff(vb_priestbuffspirit, vb_PRIESTSPIRIT) end
         if (vb_addon.db.profile.vb_Show_PRIESTINNERFIRE) then vb_checkbuff(vb_priestinnerf, vb_PRIESTINNERFIRE) end
      end
      ---------------------------------------------------------
      -- Druid Buffs
      if (vb_addon.db.profile.vb_Show_Druid) then
         if (vb_addon.db.profile.vb_Show_DRUIDTHORN) then vb_checkbuff(vb_druidthorns, vb_DRUIDTHORN) end
         if (vb_addon.db.profile.vb_Show_DRUIDBUFF) then vb_checkbuff(vb_druidbuffs, vb_DRUIDBUFF) end
      end
      ---------------------------------------------------------
      -- Warlock Buffs
      if (vb_addon.db.profile.vb_Show_Warlock) then
         if (vb_addon.db.profile.vb_Show_WARLOCKARMOR) then vb_checkbuff(vb_wlockarmor, vb_WARLOCKARMOR) end
      end
      
      ---------------------------------------------------------
      -- Check weapon enhancement, including poison
      vb_hasMainHandEnchant, 
      vb_mainHandExpiration, 
      vb_mainHandCharges, 
      vb_hasOffHandEnchant, 
      vb_offHandExpiration, 
      vb_offHandCharges = GetWeaponEnchantInfo()
      
      vb_hasRangedWeaponEnchant = 0;
      
      -- Important, rest of code will not run with these values as nil
      if vb_hasMainHandEnchant == nil then
         vb_hasMainHandEnchant = 0
      end
      -- Important, rest of code will not run with these values as nil
      if vb_hasOffHandEnchant == nil then
         vb_hasOffHandEnchant = 0
      end
      -- Important, rest of code will not run with these values as nil
      if vb_hasRangedWeaponEnchant == nil then
         vb_hasRangedWeaponEnchant = 0
      end
      
      ---------------------------------------------------------      
      -- Melee weapon enhancements
      if (vb_hasMainHandEnchant == 1 and vb_hasOffHandEnchant == 1) then
         -- Nothing
      else
         if (vb_canShamanWeaponBuff() and vb_addon.db.profile.vb_Show_Shaman) then
            vb_outText = vb_outText .. "Weapon buff" .."\n"
         else
            if (vb_canWarlockWeaponBuff() and vb_addon.db.profile.vb_Show_Warlock) then
               vb_outText = vb_outText .. "Warlock Fire/Spellstone" .."\n"
            end
         end
      end
      
      ---------------------------------------------------------      
      -- Ranged weapon poison
      if (vb_rangedHasPoison()) then
         -- Nothing
      else
         if (vb_hasPoison() and vb_addon.db.profile.vb_Show_Rogue) then
            vb_outText = vb_outText .. "Poison (Ranged)" .."\n"
         else
            -- Nothing
         end
      end
      
      ---------------------------------------------------------      
      -- Combat check
      if (UnitAffectingCombat("player")) then
         FontrString:SetText(vb_outText)
         -- Clear if out of combat
      else
         if (vb_addon.db.profile.vb_enableoutofcombat) then
            FontrString:SetText(vb_outText)
         else
            FontrString:SetText("")
         end
      end 
end)