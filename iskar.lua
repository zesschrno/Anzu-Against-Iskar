local btn = CreateFrame("Button", "AnzuButton", UIParent, "SecureActionButtonTemplate,SecureHandlerStateTemplate,SecureHandlerAttributeTemplate")

  local anzu_name, _, anzu_icon = GetSpellInfo(179202) -- obtener el nombre del hechizo de ojo de anzu
  btn:SetMovable(true)
  btn:SetSize(30,30)
  --btn:SetScale(ExtraActionButton1:GetScale())
  btn:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  btn:SetHighlightTexture("Interface\Buttons\ButtonHilight-Square")
  btn:SetNormalTexture(anzu_icon)
  btn:Show()
  
  btn:SetScript('OnLoad', function(self)
    print('Me estoy cargando')
  end)
  
  btn:SetScript('OnShow', function(self)
    print('Me estoy mostrando')
  end)
  btn:SetScript('OnEvent', function(self, event, ...)
    if(self[event]) then
      self[event](self, event, ...)
    end
  end)
  
  btn:RegisterEvent("PLAYER_LOGIN")
  btn:RegisterEvent('UNIT_AURA')

  function btn:UNIT_AURA(event, unit)
    if unit == "player" then
      local enumIskarBuffs = {
        phantasmalWinds = 181957,
        phantasmalWounds = 182325,
        felBomb = 181753,
        phantasmalCorruption = 181824,
        eyeOfAnzu = 179202
      }
      local spell_name = GetSpellInfo(enumIskarBuffs.eyeOfAnzu)
      local aura_name, _, _, _, _, _, _, _, _, _, aura_spellID = UnitAura("player", spell_name, nil)
      if aura_name ~= nil then
        self:SetAttribute("type", "spell")
        local target, iskarSpell, role, dispellID = nil --getWhoNeedsAnzu()
        if target == "player" and iskarSpell == nil then
        elseif target == "player" and iskarSpell == enumIskarBuffs.felBomb and role == "HEALER" then
          local dispellName = GetSpellInfo(dispellID)
          self:SetAttribute("spell", dispellName, target)
        elseif target ~= "player" then
          self:SetAttribute("spell", anzu_name, target)
        end
      end
    end
  end
  
  
function getWhoNeedsAnzu()
  local afectedByPhantasmalWinds = {}
  local countPhantasmalWinds = 0
  local afectedByPhantasmalWounds = {}
  local countPhantasmalWounds = 0
  local afectedByFelBomb = {}
  local countFelBomb = 0
  local afectedByPhantasmalCorruption = {}
  local countPhantasmalCorruption = 0
  
  local enumIskarBuffs = {
    phantasmalWinds = 181957,
    phantasmalWounds = 182325,
    felBomb = 181753,
    phantasmalCorruption = 181824,
    eyeOfAnzu = 179202
  }
  
  local spellName0 = GetSpellInfo(enumIskarBuffs.phantasmalWinds) -- Vientos Fantasmales/Phantasmal Winds
  local spellName1 = GetSpellInfo(enumIskarBuffs.phantasmalWounds) -- Heridas Fantasmales/Phantasmal Wounds
  local spellName2 = GetSpellInfo(enumIskarBuffs.felBomb) -- Bomba vil/Fel Bomb
  local spellName3 = GetSpellInfo(enumIskarBuffs.phantasmalCorruption) -- Corrupción fantasmal/Phantasmal Corruption

  local raidIndex = UnitInRaid("player") -- [1-40|nil]
  local _, _, classIndex = UnitClass("player") -- [1-11|0]
  local enumClasses = {
    none = 0,
    warrior = 1,
    paladin = 2,
    hunter = 3,
    rogue = 4,
    priest = 5,
    deathKnight = 6,
    shaman = 7,
    mage = 8,
    warlock = 9,
    monk = 10,
    druid = 11
  }
  
  for i = 1, GetNumGroupMembers() do 
    local _, _, _, _, _, _, _, _, _, _, aura_spellID0 = UnitAura("raid" .. i, spellName0, nil)
    local _, _, _, _, _, _, _, _, _, _, aura_spellID1 = UnitAura("raid" .. i, spellName1, nil)
    local _, _, _, _, _, _, _, _, _, _, aura_spellID2 = UnitAura("raid" .. i, spellName2, nil)
    local _, _, _, _, _, _, _, _, _, _, aura_spellID3 = UnitAura("raid" .. i, spellName3, nil)
    local specID = GetInspectSpecialization('raid' .. i)
    local role = GetSpecializationRoleByID(specID)
    if aura_spellID0 == enumIskarBuffs.phantasmalWinds then
      if raidIndex == tostring(i) then
        table.insert(afectedByPhantasmalWinds, "player")
      else
        table.insert(afectedByPhantasmalWinds, "raid" .. i)
      end
      countPhantasmalWinds = countPhantasmalWinds + 1
    end
    if aura_spellID1 == enumIskarBuffs.phantasmalWounds then
      if raidIndex == tostring(i) then
        table.insert(afectedByPhantasmalWounds, "player")
      else
        table.insert(afectedByPhantasmalWounds, "raid" .. i)
      end
      countPhantasmalWounds = countPhantasmalWounds + 1
    end
    if aura_spellID2 == enumIskarBuffs.felBomb and role == "HEALER" then
      if raidIndex == tostring(i) then
        table.insert(afectedByFelBomb, "player")
      else
        table.insert(afectedByFelBomb, "raid" .. i)
      end
      countFelBomb = countFelBomb + 1
    end
    if aura_spellID3 == enumIskarBuffs.phantasmalCorruption and role == "TANK" then
      if raidIndex == tostring(i) then
        table.insert(afectedByPhantasmalCorruption, "player")
      else
        table.insert(afectedByPhantasmalCorruption, "raid" .. i)
      end
      countPhantasmalCorruption = countPhantasmalCorruption + 1
    end
  end
  
  if countFelBomb >= 1 then
    if classIndex == enumClasses.druid then
      return afectedByFelBomb[1], enumIskarBuffs.felBomb, "HEALER", 88423
    elseif classIndex == enumClasses.priest then
      return afectedByFelBomb[1], enumIskarBuffs.felBomb, "HEALER", 527
    elseif classIndex == enumClasses.paladin then
      return afectedByFelBomb[1], enumIskarBuffs.felBomb, "HEALER", 4987
    elseif classIndex == enumClasses.shaman then
      return afectedByFelBomb[1], enumIskarBuffs.felBomb, "HEALER", 77130
    elseif classIndex == enumClasses.monk then
      return afectedByFelBomb[1], enumIskarBuffs.felBomb, "HEALER", 115450
    end
  end
  if countPhantasmalCorruption >= 1 then
    return afectedByPhantasmalCorruption[1], enumIskarBuffs.phantasmalCorruption, "TANK", nil
  end
  if countPhantasmalWounds >= 1 then
    return afectedByPhantasmalWounds[1], enumIskarBuffs.phantasmalWounds, "ANY", nil
  end
  if countPhantasmalWinds >= 1 then
    return afectedByPhantasmalWinds[1], enumIskarBuffs.phantasmalWinds, "ANY", nil
  end
  return "player", nil, "ANY", nil
end
