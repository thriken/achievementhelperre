--[[
AchievementHelperRE (AHRE)
在物品鼠标提示中标记成就所需的食物 / 饮料 / 装备，并显示"可使用 / 已使用"。

重写要点（相对旧版）：
* 旧版目录名 achievementhelperRE 与 toc 文件名不一致，客户端不会加载 -> 改为同名。
* 旧版用 1..30000 当作 criteriaID 暴搜。正式服 criteriaID 可能是很大的 UID -> 改为优先遍历成就条件，
  取不到的成就再走分批扫描（上限 99999）。
* 去掉 XML 帧与专业界面过滤，只保留物品提示。

命令：/ahre 状态 / /ahre <物品ID> 查询 / /ahre debug 详细 / /ahre scan 强制重扫
]]

local _, ns = ...

-- 语言表由 Locales.lua 提供（万一没加载就给空表，下面取值处会显示占位符但不报错）
local L = ns and ns.L or {}

local function LText(key)
	return L[key] or ("<" .. key .. ">")
end

-- ---------------------------------------------------------------------------
-- 配置：需要监控的成就。扩展时直接往这张表里加一行。
--   id     : 成就 ID
--   action : 动词类型，对应 Locales.lua 里的 *_TODO / *_DONE，
--            目前支持 EAT（食用）/ DRINK（饮用）/ EQUIP（装备）
-- ---------------------------------------------------------------------------
local ACHIEVEMENTS = {
	{ id = 1775, action = "EAT" },
	{ id = 1774, action = "DRINK" },
	{ id = 621,  action = "EQUIP" },
	{ id = 9502, action = "EAT" },
	{ id = 7330, action = "EAT" },
	{ id = 7329, action = "EAT" },
}

-- ---------------------------------------------------------------------------
-- API 兼容层
-- ---------------------------------------------------------------------------
local GetAchievementInfo = _G.GetAchievementInfo
local GetAchievementNumCriteria = _G.GetAchievementNumCriteria
local GetAchievementCriteriaInfo = _G.GetAchievementCriteriaInfo
local GetAchievementCriteriaInfoByID = _G.GetAchievementCriteriaInfoByID
	or (_G.C_AchievementInfo and _G.C_AchievementInfo.GetCriteriaInfoByID)

-- ---------------------------------------------------------------------------
-- 数据
-- ---------------------------------------------------------------------------
local DB = {}      -- [itemID] = { achievementID, criteriaID }
local LABELS = {}  -- [achievementID] = { todo, done, name }
local COUNTS = {}  -- [achievementID] = 已收录物品数
local NUMCRIT = {} -- [achievementID] = GetAchievementNumCriteria 结果

local function BuildLabels()
	for _, entry in ipairs(ACHIEVEMENTS) do
		local name = GetAchievementInfo and (select(2, GetAchievementInfo(entry.id)))
		local action = entry.action

		LABELS[entry.id] = {
			todo = L[action and (action .. "_TODO")] or LText("USE_TODO"),
			done = L[action and (action .. "_DONE")] or LText("USE_DONE"),
			name = name or LText("ACHIEVEMENT_FALLBACK"):format(entry.id),
		}
	end
end

local function RegisterItem(itemID, achievementID, criteriaID)
	DB[itemID] = { achievementID, criteriaID }
	COUNTS[achievementID] = (COUNTS[achievementID] or 0) + 1
end

-- ---------------------------------------------------------------------------
-- 兜底扫描：对没抓到条件的成就，按 criteriaID 递增分批扫描（分帧执行，不卡游戏）
-- ---------------------------------------------------------------------------
local SCAN_CHUNK = 5000
local SCAN_MAX = 99999

local scanFrame = CreateFrame("Frame")
local scanQueue = {}
local scanAchievementIndex
local scanCriteriaID = 0

scanFrame:Hide()
scanFrame:SetScript("OnUpdate", function(self)
	if not scanAchievementIndex then
		self:Hide()
		return
	end

	local achievementID = scanQueue[scanAchievementIndex]

	if not achievementID then
		scanAchievementIndex = nil
		self:Hide()
		return
	end

	local last = math.min(scanCriteriaID + SCAN_CHUNK, SCAN_MAX)

	for criteriaID = scanCriteriaID + 1, last do
		local _, _, _, _, _, _, _, assetID = GetAchievementCriteriaInfoByID(achievementID, criteriaID)

		if assetID and assetID ~= 0 then
			RegisterItem(assetID, achievementID, criteriaID)
		end
	end

	scanCriteriaID = last

	if scanCriteriaID >= SCAN_MAX then
		scanAchievementIndex = scanAchievementIndex + 1
		scanCriteriaID = 0

		if not scanQueue[scanAchievementIndex] then
			scanAchievementIndex = nil
			self:Hide()
		end
	end
end)

local function QueueScan(achievementID)
	if not GetAchievementCriteriaInfoByID then return end

	scanQueue[#scanQueue + 1] = achievementID

	if not scanAchievementIndex then
		scanAchievementIndex = 1
		scanCriteriaID = 0
		scanFrame:Show()
	end
end

-- ---------------------------------------------------------------------------
-- 建库
-- ---------------------------------------------------------------------------
local function BuildDatabase()
	wipe(DB)
	wipe(COUNTS)
	wipe(NUMCRIT)
	wipe(scanQueue)

	scanAchievementIndex = nil
	scanFrame:Hide()

	for _, entry in ipairs(ACHIEVEMENTS) do
		local achievementID = entry.id
		local numCriteria = GetAchievementNumCriteria and (GetAchievementNumCriteria(achievementID) or 0) or 0

		NUMCRIT[achievementID] = numCriteria
		COUNTS[achievementID] = 0

		for index = 1, numCriteria do
			-- criteriaString, criteriaType, completed, quantity, reqQuantity, charName,
			-- flags, assetID, quantityString, criteriaID, eligible
			local _, _, _, _, _, _, _, assetID, _, criteriaID = GetAchievementCriteriaInfo(achievementID, index)

			if assetID and assetID ~= 0 and criteriaID then
				RegisterItem(assetID, achievementID, criteriaID)
			end
		end

		if COUNTS[achievementID] == 0 then
			QueueScan(achievementID)
		end
	end
end

-- ---------------------------------------------------------------------------
-- 鼠标提示
-- ---------------------------------------------------------------------------
local function ProcessTooltip(tooltip, itemID)
	if not tooltip or not itemID then return end

	local entry = DB[itemID]

	if not entry or not GetAchievementCriteriaInfoByID then return end

	local achievementID, criteriaID = entry[1], entry[2]
	local _, _, completed = GetAchievementCriteriaInfoByID(achievementID, criteriaID)
	local label = LABELS[achievementID]

	if not label then return end

	if completed then
		-- 已使用：深绿色
		tooltip:AddLine(label.name .. "：" .. label.done, 0.0, 0.55, 0.0)
	else
		-- 未使用：红色
		tooltip:AddLine(label.name .. "：" .. label.todo, 1.0, 0.1, 0.1)
	end
end

local function GetTooltipItemID(tooltip)
	if not tooltip or not tooltip.GetItem then return nil end

	local _, link = tooltip:GetItem()

	if type(link) ~= "string" then return nil end

	return tonumber(link:match("item:(%d+)"))
end

local TooltipDataProcessor = _G.TooltipDataProcessor

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and _G.Enum and _G.Enum.TooltipDataType then
	-- 正式路线：10.1 起的 TooltipDataProcessor，同时覆盖 GameTooltip / ItemRefTooltip / 比较提示等
	TooltipDataProcessor.AddTooltipPostCall(_G.Enum.TooltipDataType.Item, function(tooltip, data)
		ProcessTooltip(tooltip, (data and data.id) or GetTooltipItemID(tooltip))
	end)
else
	local function OnTooltipSetItem(tooltip)
		ProcessTooltip(tooltip, GetTooltipItemID(tooltip))
	end

	-- 兜底时使用 pcall，避免某个提示框不允许 HookScript 时中断整个文件加载
	for _, tooltip in ipairs({ _G.GameTooltip, _G.ItemRefTooltip, _G.ShoppingTooltip1, _G.ShoppingTooltip2 }) do
		if tooltip and tooltip.HookScript then
			pcall(tooltip.HookScript, tooltip, "OnTooltipSetItem", OnTooltipSetItem)
		end
	end
end

-- ---------------------------------------------------------------------------
-- 初始化：成就数据要在登录后才可靠
-- ---------------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
	BuildLabels()
	BuildDatabase()
end)

-- ---------------------------------------------------------------------------
-- 诊断命令
-- ---------------------------------------------------------------------------
local function PrintStatus()
	local total = 0

	for _ in pairs(DB) do
		total = total + 1
	end

	print(("|cff880303[AHRE]|r %s"):format(LText("ITEMS_LOADED"):format(total, scanAchievementIndex and LText("SCANNING") or "")))

	for _, entry in ipairs(ACHIEVEMENTS) do
		local label = LABELS[entry.id]

		print(("|cff880303[AHRE]|r %s"):format(LText("STATS_LINE"):format(
			entry.id,
			label and label.name or "?",
			tostring(NUMCRIT[entry.id]),
			COUNTS[entry.id] or 0
		)))
	end
end

SLASH_ACHIEVEMENTHELPERRE1 = "/ahre"

_G.SlashCmdList["ACHIEVEMENTHELPERRE"] = function(msg)
	local itemID = tonumber(msg)

	if msg == "debug" then
		PrintStatus()

		if GetAchievementCriteriaInfo then
			for _, entry in ipairs(ACHIEVEMENTS) do
				local numCriteria = NUMCRIT[entry.id] or 0

				for index = 1, math.min(numCriteria, 3) do
					local criteriaString, criteriaType, completed, _, _, _, _, assetID, _, criteriaID = GetAchievementCriteriaInfo(entry.id, index)

					print(("|cff880303[AHRE]|r %s"):format(LText("CRITERIA_DEBUG"):format(
						entry.id, index, tostring(criteriaString), tostring(assetID),
						tostring(criteriaType), tostring(criteriaID), tostring(completed)
					)))
				end
			end
		end

		return
	end

	if msg == "scan" then
		BuildDatabase()
		PrintStatus()
		return
	end

	PrintStatus()

	if itemID then
		local entry = DB[itemID]

		if not entry then
			print(("|cff880303[AHRE]|r %s"):format(LText("ITEM_NOT_FOUND"):format(itemID)))
			return
		end

		local _, _, completed = GetAchievementCriteriaInfoByID(entry[1], entry[2])

		print(("|cff880303[AHRE]|r %s"):format(LText("ITEM_INFO"):format(
			itemID, entry[1], entry[2], tostring(completed)
		)))
	end
end
