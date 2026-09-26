--[[
AchievementHelperRE 语言包

新增语言：在下面 LOCALES 里照抄一份即可，key 用 GetLocale() 的返回值（enUS / zhCN / zhTW / ...）。
未收录的语言自动回退到 enUS。

占位符说明：
  %d 数字，%s 字符串，顺序与调用处一致，请勿调整顺序。
]]

local _, ns = ...

local LOCALES = {}

-- ---------------------------------------------------------------------------
-- 英文（默认）
-- ---------------------------------------------------------------------------
LOCALES.enUS = {
	-- 鼠标提示动词：尚未完成 / 已完成
	EAT_TODO = "Can eat",
	EAT_DONE = "Already eaten",
	DRINK_TODO = "Can drink",
	DRINK_DONE = "Already drunk",
	EQUIP_TODO = "Can equip",
	EQUIP_DONE = "Already equipped",
	USE_TODO = "Can use",
	USE_DONE = "Already used",

	-- 成就名取不到时的兜底显示
	ACHIEVEMENT_FALLBACK = "Achievement %d",

	-- /ahre 输出
	ITEMS_LOADED = "Items loaded: %d%s",
	SCANNING = " (scanning...)",
	STATS_LINE = "Achievement %d (%s): criteria %s, items %d",
	ITEM_NOT_FOUND = "Item %d is not in the database",
	ITEM_INFO = "Item %d -> achievement %d / criteria %d, completed: %s",
	CRITERIA_DEBUG = "  %d #%d: %s | asset=%s type=%s uid=%s done=%s",
}

-- ---------------------------------------------------------------------------
-- 简体中文
-- ---------------------------------------------------------------------------
LOCALES.zhCN = {
	EAT_TODO = "可食用",
	EAT_DONE = "已食用",
	DRINK_TODO = "可饮用",
	DRINK_DONE = "已饮用",
	EQUIP_TODO = "可装备",
	EQUIP_DONE = "已装备",
	USE_TODO = "可使用",
	USE_DONE = "已使用",

	ACHIEVEMENT_FALLBACK = "成就 %d",

	ITEMS_LOADED = "物品条目: %d%s",
	SCANNING = "（扫描中...）",
	STATS_LINE = "成就 %d (%s): 条件数 %s, 已收录 %d",
	ITEM_NOT_FOUND = "物品 %d 不在数据库中",
	ITEM_INFO = "物品 %d -> 成就 %d / 条件 %d，已完成: %s",
	CRITERIA_DEBUG = "  %d #%d: %s | asset=%s type=%s uid=%s done=%s",
}

-- ---------------------------------------------------------------------------
-- 繁體中文
-- ---------------------------------------------------------------------------
LOCALES.zhTW = {
	EAT_TODO = "可食用",
	EAT_DONE = "已食用",
	DRINK_TODO = "可飲用",
	DRINK_DONE = "已飲用",
	EQUIP_TODO = "可裝備",
	EQUIP_DONE = "已裝備",
	USE_TODO = "可使用",
	USE_DONE = "已使用",

	ACHIEVEMENT_FALLBACK = "成就 %d",

	ITEMS_LOADED = "物品條目: %d%s",
	SCANNING = "（掃描中...）",
	STATS_LINE = "成就 %d (%s): 條件數 %s, 已收錄 %d",
	ITEM_NOT_FOUND = "物品 %d 不在資料庫中",
	ITEM_INFO = "物品 %d -> 成就 %d / 條件 %d，已完成: %s",
	CRITERIA_DEBUG = "  %d #%d: %s | asset=%s type=%s uid=%s done=%s",
}

setmetatable(LOCALES, { __index = function() return LOCALES.enUS end })

-- 同一个插件的所有文件共享第二个参数（私有命名空间），这里把语言表挂上去供主文件使用。
ns.L = LOCALES[_G.GetLocale()]
