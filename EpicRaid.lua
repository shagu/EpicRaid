local function MoveMouseDown() this:StartMoving() end
local function MoveMouseUp() this:StopMovingOrSizing() end
local SkinButton = pfUI and pfUI.api and pfUI.api.SkinButton or function(frame) return end
local CreateBackdrop = pfUI and pfUI.api and pfUI.api.CreateBackdrop or function(frame)
  frame:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = false, tileSize = 0,
    edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 1,
    insets = {left = -1, right = -1, top = -1, bottom = -1},
  })
  frame:SetBackdropColor(0,0,0,.75)
  frame:SetBackdropBorderColor(.1,.1,.1,1)
end

local epic = CreateFrame("Frame", nil, UIParent)
epic:Hide()
epic:SetWidth(200)
epic:SetHeight(200)
epic:SetPoint("RIGHT", -75, 0)
epic:SetMovable(true)
epic:EnableMouse(true)
epic:SetScript("OnMouseDown", MoveMouseDown)
epic:SetScript("OnMouseUp", MoveMouseUp)
epic:SetScript("OnShow", function()
  epic:ClearAllPoints()
  epic:SetPoint("RIGHT", -75, 0)
end)

SLASH_EPIC1, SLASH_EPIC2 = "/epic", "/epicraid"
function SlashCmdList.EPIC(msg, editbox)
  if epic:IsShown() then
    epic:Hide()
  else
    epic:Show()
  end
end

local db = {
  ["food"] = {
    "Arcane Intellect",
  },
  ["elixir"] = {
    "Mage Armor",
    "Flask of Pure Death",
    "Molten Armor",
  },
}

local rows = {}

local function BuffEnter()
  GameTooltip:SetOwner(this, "ANCHOR_LEFT", -10, -5)
  GameTooltip:ClearLines()
  GameTooltip:SetUnitBuff(this.unitstr, this.id)
  GameTooltip:Show()
end

local function BuffLeave()
  GameTooltip:Hide()
end

local function HasWeaponBuff(unitstr)
  -- todo
  return nil
end

local function HasBuff(unitstr, typ)
  for id=1,32 do
    local name = UnitBuff(unitstr, id)
    for _, check in pairs(db[typ]) do
      if name == check then
        return id
      end
    end
  end

  return nil
end

local function ClearRoster()
  for id, frame in pairs(rows) do
    frame:Hide()
  end
end

local function AddToRoster(unitstr, id, parent)
  rows[id] = rows[id] or CreateFrame("Frame", nil, parent)
  rows[id]:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -8-id*16)
  rows[id]:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, 8+id*16)
  rows[id]:SetHeight(16)

  local _, class = UnitClass(unitstr)
  local color = RAID_CLASS_COLORS[class]

  rows[id].name = rows[id].name or rows[id]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
  rows[id].name:SetFont(STANDARD_TEXT_FONT, 10)
  rows[id].name:SetPoint("LEFT", 2, 0)
  rows[id].name:SetText(UnitName(unitstr))
  rows[id].name:SetJustifyH("LEFT")
  rows[id].name:SetWidth(86)
  if color then
    rows[id].name:SetTextColor(color.r, color.g, color.b, 1)
  else
    rows[id].name:SetTextColor(.5,.5,.5,1)
  end

  rows[id].food = rows[id].food or CreateFrame("Button", nil, rows[id])
  rows[id].food:SetPoint("LEFT", rows[id].name, "RIGHT", 0, 0)
  rows[id].food:SetWidth(14)
  rows[id].food:SetHeight(14)
  rows[id].food:SetScript("OnEnter", BuffEnter)
  rows[id].food:SetScript("OnLeave", BuffLeave)
  rows[id].food.tex = rows[id].food.tex or rows[id].food:CreateTexture(nil)
  rows[id].food.tex:SetAllPoints()
  rows[id].food.tex:SetTexture(1,1,0,1)
  rows[id].food.tex:SetTexCoord(.08, .92, .08, .92)
  local food = HasBuff(unitstr, "food")
  if food then
    local name, _, icon = UnitBuff(unitstr, food)
    rows[id].food.unitstr = unitstr
    rows[id].food.id = food
    rows[id].food.tex:SetTexture(icon)
    rows[id].food:Show()
  else
    rows[id].food:Hide()
  end

  rows[id].elixir = rows[id].elixir or CreateFrame("Button", nil, rows[id])
  rows[id].elixir:SetPoint("LEFT", rows[id].food, "RIGHT", 26, 0)
  rows[id].elixir:SetWidth(14)
  rows[id].elixir:SetHeight(14)
  rows[id].elixir:SetScript("OnEnter", BuffEnter)
  rows[id].elixir:SetScript("OnLeave", BuffLeave)
  rows[id].elixir.tex = rows[id].elixir.tex or rows[id].elixir:CreateTexture(nil)
  rows[id].elixir.tex:SetAllPoints()
  rows[id].elixir.tex:SetTexture(1,0,0,1)
  rows[id].elixir.tex:SetTexCoord(.08, .92, .08, .92)
  local elixir = HasBuff(unitstr, "elixir")
  if elixir then
    local name, _, icon = UnitBuff(unitstr, elixir)
    rows[id].elixir.unitstr = unitstr
    rows[id].elixir.id = elixir
    rows[id].elixir.tex:SetTexture(icon)
    rows[id].elixir:Show()
  else
    rows[id].elixir:Hide()
  end

  rows[id].weapon = rows[id].weapon or CreateFrame("Button", nil, rows[id])
  rows[id].weapon:SetPoint("LEFT", rows[id].elixir, "RIGHT", 26, 0)
  rows[id].weapon:SetWidth(14)
  rows[id].weapon:SetHeight(14)
  rows[id].weapon.tex = rows[id].weapon.tex or rows[id].weapon:CreateTexture(nil)
  rows[id].weapon.tex:SetAllPoints()
  rows[id].weapon.tex:SetTexture(0,1,1,1)
  rows[id]:Show()
  local weapon = HasWeaponBuff(unitstr)
  if weapon then
    -- todo
    rows[id].weapon:Show()
  else
    rows[id].weapon:Hide()
  end

  parent:SetHeight((id+1)*16+8)
end

do -- topbar
  epic.topbar = CreateFrame("Frame", nil, epic)
  epic.topbar:SetPoint("TOPLEFT", epic, 2, -2)
  epic.topbar:SetPoint("TOPRIGHT", epic, -2, 2)
  epic.topbar:SetHeight(20)
  CreateBackdrop(epic.topbar)

  epic.topbar.scan = CreateFrame("Button", nil, epic.topbar, "UIPanelButtonTemplate")
  epic.topbar.scan:SetPoint("LEFT", 2, 0)
  epic.topbar.scan:SetWidth(48)
  epic.topbar.scan:SetHeight(18)
  epic.topbar.scan:SetText("Scan")
  SkinButton(epic.topbar.scan)
  epic.topbar.scan:SetScript("OnClick", function()
    ClearRoster()

    local current = 1
    for i=1, 40 do
      if UnitExists("raid"..i) then
        AddToRoster("raid"..i, current, epic)
        current = current + 1
      end
    end
  end)

  epic.topbar.weapon = epic.topbar:CreateFontString(nil, "OVERLAY", "GameFontWhite")
  epic.topbar.weapon:SetFont(STANDARD_TEXT_FONT, 10)
  epic.topbar.weapon:SetPoint("RIGHT", -5, 0)
  epic.topbar.weapon:SetText("Weapon")
  epic.topbar.weapon:SetWidth(42)
  epic.topbar.weapon:SetJustifyH("CENTER")

  epic.topbar.elixir = epic.topbar:CreateFontString(nil, "OVERLAY", "GameFontWhite")
  epic.topbar.elixir:SetFont(STANDARD_TEXT_FONT, 10)
  epic.topbar.elixir:SetPoint("RIGHT", epic.topbar.weapon, "LEFT", 5, 0)
  epic.topbar.elixir:SetText("Elixir")
  epic.topbar.elixir:SetWidth(42)
  epic.topbar.elixir:SetJustifyH("CENTER")

  epic.topbar.food = epic.topbar:CreateFontString(nil, "OVERLAY", "GameFontWhite")
  epic.topbar.food:SetFont(STANDARD_TEXT_FONT, 10)
  epic.topbar.food:SetPoint("RIGHT", epic.topbar.elixir, "LEFT", 5, 0)
  epic.topbar.food:SetText("Food")
  epic.topbar.food:SetWidth(42)
  epic.topbar.food:SetJustifyH("CENTER")
end

CreateBackdrop(epic)
