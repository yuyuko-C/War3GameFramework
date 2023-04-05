-- 加载Persistent
require "ResourceCreater.Base.Persistent"

-- 加载AbilityCreater
require "ResourceCreater.MyCreater.AbilityCreater"

-- 读取实体配置信息
require "ResourceCreater.MyCreater.Entity.init"


Persistent.Persist()
