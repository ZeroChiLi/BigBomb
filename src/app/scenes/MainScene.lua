
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

EFFECT_FILE = "setting/gear.wav"
MUSIC_FILE = "setting/magic_waltz.mp3"
EFFECT_KEY = "sound_key"
MUSIC_KEY = "music_key"
NIGHT_KEY = "night_key"
size = cc.Director:getInstance():getWinSize()
local defaults = cc.UserDefault:getInstance()

function MainScene:ctor()
    self:initUI()
    if (defaults:getBoolForKey(NIGHT_KEY)) then 
        local blackLayer = cc.LayerColor:create(cc.c4b(0,0,0,120),size.width,size.height)
        blackLayer:addTo(self)
    end
end

function MainScene:initUI()
--    display.newSprite("grey.png")
--        :pos(display.cx,display.cy)
--        :addTo(self)
    local bg = cc.Sprite:create("grey.png"):center()
    bg:setScale(size.width/bg:getTextureRect().width,size.height/bg:getTextureRect().height)
    bg:addTo(self)
    local startBtnImages = {
        normal = "startgame_up.png",
        pressed = "startgame_down.png"
    }
    cc.ui.UIPushButton.new(startBtnImages,{scale9 = false})
        :onButtonClicked(function(event)
            if defaults:getBoolForKey(EFFECT_KEY) then 
                AudioEngine.playEffect(EFFECT_FILE)
            end
--           local playScene = import("app.scenes.playScene"):new()
--           display.replaceScene(playScene,0.5)
            local PlayScene = require("src/app/scenes/PlayScene")
            playScene = PlayScene:new()
            local ts = cc.TransitionSlideInR:create(1,playScene)
            cc.Director:getInstance():replaceScene(ts)
        end)
        :align(display.CENTER,display.cx,display.cy+50)
        :addTo(self)
        
    local settingBtnImages={
        normal = "setting/setting_up.png",
        pressed = "setting/setting_down.png"
    }
    cc.ui.UIPushButton.new(settingBtnImages,{scale9 = false})
        :onButtonClicked(function(event)
            if (defaults:getBoolForKey(EFFECT_KEY)) then 
                AudioEngine.playEffect(EFFECT_FILE)
            end
            local SettingScene = require("src/app/scenes/SettingScene")
            settingScene = SettingScene:new()
            local ts = cc.TransitionSlideInL:create(1,settingScene)
            cc.Director:getInstance():replaceScene(ts)
        end)
        :align(display.CENTER,display.cx,display.cy-50)
        :addTo(self)
    
    if (defaults:getBoolForKey(MUSIC_KEY)) then 
        AudioEngine.playMusic(MUSIC_FILE,true)
    end
--    local slider_blank = cc.Sprite:create("Slider_blank.png"):addTo(self)
--    slider_blank:setPosition(display.width/2,100)
--    slider_blank:setScale(display.width/slider_blank:getContentSize().width,1)
--    
--    local slider = cc.Sprite:create("Slider_full.png")
--    local ct = cc.ProgressTimer:create(slider)
--    ct:setPosition(display.width/2,100)
--    ct:setType(cc.PROGRESS_TIMER_TYPE_BAR)
--    ct:setTag(10)
--    ct:setScale(display.width/slider:getContentSize().width,1)
--    ct:addTo(self)
--    ct:setPercentage(90)
--    ct:setMidpoint(cc.p(0,0.5))
--    ct:setBarChangeRate(cc.p(1,0))
    
--    self:getScheduler():scheduleScriptFunc(function(f)
--        local num = ct:getPercentage()
--        num = num +1
--        if num >= 100 then
--            ct:setPercentage(0)
--            num = 0
--        end
--        ct:setPercentage(num)
--    end,0,false)

    self:addNodeEventListener(cc.KEYPAD_EVENT, function (event)
        if event.key == "back" or event.key == "menu" then
            device.showAlert("喂","你他妈不玩了？",{"YES","NO"},function (event)
                if event.buttonIndex == 1 then
                    cc.Director:getInstance():endToLua()
                else
                    device.cancelAlert()
                end
            end)
        end
    end)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
