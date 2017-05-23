
local SettingScene= class("SettingScene",function()
    return display.newScene("SettingScene")
end)

local defaults = cc.UserDefault:getInstance()

function SettingScene:ctor()

    self:initUI()
    self:addNodeEventListener(cc.KEYPAD_EVENT, function (event)
        if event.key == "back"  then
            device.showAlert("喂","你他妈不玩了？",{"YES","NO"},function (event)
                if event.buttonIndex == 1 then
                    cc.Director:getInstance():endToLua()
                else
                    device.cancelAlert()
                end
            end)
        end
    end)
    if (defaults:getBoolForKey(NIGHT_KEY)) then 
        local blackLayer = cc.LayerColor:create(cc.c4b(0,0,0,120),size.width,size.height)
        blackLayer:addTo(self)
    end
--
--    if defaults:getBoolForKey(EFFECT_KEY) then 
--        soundToggleMenuItem:setSelectedIndex(0)
--    else
--        soundToggleMenuItem:setSelectedIndex(1)
--    end
--    
end

function SettingScene:initUI()
    local bg = cc.Sprite:create("grey.png"):center()
    bg:setScale(size.width/bg:getTextureRect().width,size.height/bg:getTextureRect().height)
    bg:addTo(self)
    
    local im_effect = {
        off = "setting/effect_off.png",
        off_pressed = "setting/effect_off_pressed.png",
        off_disabled = "setting/effect_off_disabled.png",
        on = "setting/effect_on.png",
        on_pressed = "setting/effect_on_pressed.png",
        on_disabled = "setting/effect_on_disabled.png"
    }
    local function updateCheckBoxButtonLabel(checkbox)    
        if (defaults:getBoolForKey(EFFECT_KEY)) then
            defaults:setBoolForKey(EFFECT_KEY,false)
        else
            defaults:setBoolForKey(EFFECT_KEY,true)
            AudioEngine.playEffect(EFFECT_FILE)
        end
    end
    
    local effect_power = cc.ui.UICheckBoxButton.new(im_effect)
        :onButtonClicked(function(event) 
            updateCheckBoxButtonLabel()
        end)
        :align(display.CENTER, display.cx, display.cy+50)
        :addTo(self)
    
    local im_music = {
        off = "setting/music_off.png",
        off_pressed = "setting/music_off_pressed.png",
        off_disabled = "setting/music_off_disabled.png",
        on = "setting/music_on.png",
        on_pressed = "setting/music_on_pressed.png",
        on_disabled = "setting/music_on_disabled.png"
    }
    local music_power = cc.ui.UICheckBoxButton.new(im_music)
        :onButtonClicked(function(event) 
            if (defaults:getBoolForKey(EFFECT_KEY)) then 
                AudioEngine.playEffect(EFFECT_FILE)
            end
            if (defaults:getBoolForKey(MUSIC_KEY)) then 
                defaults:setBoolForKey(MUSIC_KEY,false)
                AudioEngine.stopMusic()
            else
                defaults:setBoolForKey(MUSIC_KEY,true)
                AudioEngine.playMusic(MUSIC_FILE,true)
            end
        end)
        :align(display.CENTER, display.cx, display.cy-50)
        :addTo(self)
    
    local sureBtnImages={
        normal = "setting/sure_up.png",
        pressed = "setting/sure_down.png"
    }
        
    if defaults:getBoolForKey(EFFECT_KEY) then 
        effect_power:setButtonSelected(true)
    else
        effect_power:setButtonSelected(false)
    end
    if defaults:getBoolForKey(MUSIC_KEY) then 
        music_power:setButtonSelected(true)
        print(defaults:getBoolForKey(MUSIC_KEY))
    else
        music_power:setButtonSelected(false)
        print(defaults:getBoolForKey(MUSIC_KEY))
    end

    cc.ui.UIPushButton.new(sureBtnImages)
        :onButtonClicked(function(event)
            if (defaults:getBoolForKey(EFFECT_KEY)) then 
                AudioEngine.playEffect(EFFECT_FILE)
            end
            local MainScene = require("src/app/scenes/MainScene")
            mainscene = MainScene:new()
            local ts = cc.TransitionSlideInR:create(1,mainscene)
            cc.Director:getInstance():replaceScene(ts)
        end)
        :align(display.CENTER,display.cx,80)
        :addTo(self)
end

function SettingScene:onEnter()
end

function SettingScene:onEnterTransitionFinish()
--    if (defaults:getBoolForKey(MUSIC_KEY)) then 
--        AudioEngine.playMusic(MUSIC_FILE,true)
--    end
end

function SettingScene:onExit()
end

function SettingScene:onExitTransitionStart()
end

function SettingScene:cleanup()
end

return SettingScene