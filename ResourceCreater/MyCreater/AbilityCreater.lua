local TableUtils = require "ResourceCreater.Base.TableUtils"
local OrderManager = require "ResourceCreater.Base.OrderManager"


AbilityCreater = {}

local HeroAbilityD = require "ResourceCreater.MyCreater.MetaTable.HeroAbility.HeroAbilityD"
local HeroAbilityP = require "ResourceCreater.MyCreater.MetaTable.HeroAbility.HeroAbilityP"
local HeroAbilityQ = require "ResourceCreater.MyCreater.MetaTable.HeroAbility.HeroAbilityQ"
local HeroAbilityW = require "ResourceCreater.MyCreater.MetaTable.HeroAbility.HeroAbilityW"
local HeroAbilityE = require "ResourceCreater.MyCreater.MetaTable.HeroAbility.HeroAbilityE"
local HeroAbilityR = require "ResourceCreater.MyCreater.MetaTable.HeroAbility.HeroAbilityR"
local HeroAbilityF = require "ResourceCreater.MyCreater.MetaTable.HeroAbility.HeroAbilityF"


--#region 英雄公共魔法书相关

local CommonZ = require "ResourceCreater.MyCreater.Entity.Hero.CommonZ"
local CommonX = require "ResourceCreater.MyCreater.Entity.Hero.CommonX"

local function InitCommonHeroMagicbook()
    local mt = TableUtils.DeepCopy(HeroAbilityD)
    mt.Name = "英雄公用" .. mt.Hotkey
    mt.DataA = string.format("%s,%s", Persistent.RegistAbility(CommonZ), Persistent.RegistAbility(CommonX))
    mt.DataE = OrderManager.GetOrder()
    Persistent.RegistAbility(mt)
    return mt
end

local heroCommonBook = InitCommonHeroMagicbook()


--#endregion


AbilityCreater.KEY_Q = 1
AbilityCreater.KEY_W = 2
AbilityCreater.KEY_E = 3
AbilityCreater.KEY_R = 4
AbilityCreater.KEY_F = 5

function AbilityCreater.GetHeroAbilityID(hero, hotkey, flag, art)
    local ability
    if hotkey == AbilityCreater.KEY_Q then
        ability = TableUtils.DeepCopy(HeroAbilityQ)
    elseif hotkey == AbilityCreater.KEY_W then
        ability = TableUtils.DeepCopy(HeroAbilityW)
    elseif hotkey == AbilityCreater.KEY_E then
        ability = TableUtils.DeepCopy(HeroAbilityE)
    elseif hotkey == AbilityCreater.KEY_R then
        ability = TableUtils.DeepCopy(HeroAbilityR)
    elseif hotkey == AbilityCreater.KEY_F then
        ability = TableUtils.DeepCopy(HeroAbilityF)
    end
    ability.Name = hero.Propernames .. ability.Hotkey
    ability.Art = art
    ability.ResearchArt = art
    Persistent.RegistAbility(ability, flag)
    return ability.ID
end

function AbilityCreater.GetAbilityList(hero, flag, art)
    local ability = TableUtils.DeepCopy(HeroAbilityP)
    ability.Name = hero.Propernames .. ability.Hotkey
    ability.Art = art
    ability.ResearchArt = art
    Persistent.RegistAbility(ability, flag)

    local heroBook = TableUtils.DeepCopy(HeroAbilityD)
    heroBook.Name = hero.Propernames .. heroBook.Hotkey
    heroBook.DataA = ability.ID
    heroBook.DataE = heroCommonBook.DataE
    Persistent.RegistAbility(heroBook)


    return string.format("%s,%s,%s", "AInv", heroCommonBook.ID, heroBook.ID)
end
