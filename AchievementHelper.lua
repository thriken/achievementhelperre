local toggleTradeskill = false;
local tradeskillList = C_TradeSkillUI.GetFilteredRecipeIDs

function AchievementHelper_OnLoad(self)
	GameTooltip:HookScript("OnTooltipSetItem", ItemShoww)    
    ItemRefTooltip:HookScript("OnTooltipSetItem", ItemShoww)    
    CreateDatabase()
	self:RegisterEvent("TRADE_SKILL_SHOW");
end

function AchievementHelper_OnEvent(self)
	if not FilterDropDown then
		local button = CreateFrame("CheckButton", "FilterDropDown", _G.TradeSkillFrame,"UICheckButtonTemplate")
		_G[button:GetName() .. "Text"]:SetText("only unconsumed")
		button:SetScript("OnClick", AcmHelper_Checkbox_OnClick)
	end
	FilterDropDown:ClearAllPoints()
	FilterDropDown:SetParent(_G.TradeSkillFrame)
	FilterDropDown:SetPoint("TOPRIGHT", _G.TradeSkillFrame, "TOPRIGHT", -200, -50)
	FilterDropDown:Show()
end

function AcmHelper_Checkbox_OnClick(self)
	toggleTradeskill = self:GetChecked()
	C_TradeSkillUI.SetOnlyShowSkillUpRecipes(not C_TradeSkillUI.GetOnlyShowSkillUpRecipes())
	C_TradeSkillUI.SetOnlyShowSkillUpRecipes(not C_TradeSkillUI.GetOnlyShowSkillUpRecipes())
end

function filterList()
	local newList = {}
	local id
	local i = 1

	for key,value in pairs(tradeskillList()) do
		id = string.match(C_TradeSkillUI.GetRecipeItemLink(value), 'item:(.-):')
		if id ~= nil then
			iid = tonumber(id)
			if AcmHelper_Database[iid] ~= nil then  
				local _,_,completed = GetAchievementCriteriaInfoByID(AcmHelper_Database[iid][1],AcmHelper_Database[iid][0])
				if not completed then      
					newList[i] = value
					i = i + 1
				end       				
			end
		end
	end
	return newList
end

function C_TradeSkillUI.GetFilteredRecipeIDs()
	if toggleTradeskill then
		return filterList()
	end
	return tradeskillList()
end

function GetServerData(achievementID, maxCriterias) 
  --j = 0;
	for i=1,maxCriterias do 
		--_,_,_,_,_,_,_,_,_,criteriaID = GetAchievementCriteriaInfo(achievementID,i)
		--_,_,_,_,_,_,_,itemID = GetAchievementCriteriaInfoByID(achievementID,criteriaID)
		_,_,_,_,_,_,_,itemID = GetAchievementCriteriaInfoByID(achievementID,i)
		if itemID ~= nil then 
			AcmHelper_Database[itemID]={}
			AcmHelper_Database[itemID][0]=i
			AcmHelper_Database[itemID][1]=achievementID
		end
	end
	--DEFAULT_CHAT_FRAME:AddMessage(j, 1.0, 0.5, 0.25)
end

function CreateDatabase()
	AcmHelper_Database={}
	Strings={}
	Strings[1775]={}
	Strings[1775][0]="already eaten"
	Strings[1775][1]="EAT ME"
	Strings[1774]={}
	Strings[1774][0]="already consumed"
	Strings[1774][1]="DRINK ME"
	Strings[621]={}
	Strings[621][0]="already equipped"
	Strings[621][1]="EQUIP ME"
	Strings[9502]={}
	Strings[9502][0]="already eaten"
	Strings[9502][1]="EAT ME"
	Strings[7330]={}
	Strings[7330][0]="already eaten"
	Strings[7330][1]="EAT ME"
	Strings[7329]={}
	Strings[7329][0]="already eaten"
	Strings[7329][1]="EAT ME"
	-- Info TOC ## SavedVariablesPerCharacter: AcmHelper_Database
	GetServerData(1775,30000)
	GetServerData(621,30000)
	GetServerData(1774,30000)
	GetServerData(9502,30000)
	GetServerData(7330,30000)
	GetServerData(7329,30000)
end

function ItemShoww(tooltip)
    _,itemLink=tooltip:GetItem()
	if itemLink ~= nil then   
		local  _,_,_,_,Id = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+)")
		Id = tonumber(Id)
		if AcmHelper_Database[Id] ~= nil then  
			_,_,completed = GetAchievementCriteriaInfoByID(AcmHelper_Database[Id][1],AcmHelper_Database[Id][0])
			text = Strings[AcmHelper_Database[Id][1]]
			if completed then      
				tooltip:AddLine(text[0], 0, 225, 225)
			else
				tooltip:AddLine(text[1], 255, 0, 0)
			end              
		end    
	end
end
