 --
-- Author: lcl
-- Date: 2015- 12- 24 14: 23: 19
--

Bomb = import("app.scenes.Bomb")
Toast = import("app.scenes.Toast")
BlackLayer = import("app.scenes.BlackLayer")
EFFECT_AWFUL_FILE = "setting/awful.wav"
EFFECT_BOOM_1_FILE = "setting/boom.wav"
EFFECT_BOOM_2_FILE = "setting/diao.wav"
EFFECT_BOOM_3_FILE = "setting/niubi.wav"
EFFECT_BOOM_4_FILE = "setting/haolihai.wav"
EFFECT_BOOM_5_FILE = "setting/imyourfather.wav"
EFFECT_TIME_OUT_FILE = "setting/time_out.wav"

local defaults = cc.UserDefault:getInstance()

local PlayScene = class("PlayScene", function()
    return display.newScene("PlayScene")
    end)

function PlayScene:initUI()
    cc.ui.UILabel.new({
        UILabelType = 2, text = "BestScore:", font="fonts/STENCILSTD.OTF",size = 38})
        :align(display.LEFT_TOP, display.left+10, display.top-20)
        :addTo(self) 
    self.highScoreLabel = cc.ui.UILabel.new({
        UILabelType = 2, text = tostring(self.highScore), font="fonts/STENCILSTD.OTF",size = 38})
        :align(display.LEFT_TOP, display.left+280, display.top-20)
        :addTo(self)
    cc.ui.UILabel.new({
        UILabelType = 2, text = "Score:", font="fonts/STENCILSTD.OTF",size = 38})
        :align(display.LEFT_TOP, display.left+10, display.top-65)
        :addTo(self)
    self.curScoreLabel = cc.ui.UILabel.new({
        UILabelType = 2, text = "0", font="fonts/STENCILSTD.OTF",size = 38})
        :align(display.LEFT_TOP, display.left+170, display.top-65)
        :addTo(self)
    self.timeFontLabel = cc.ui.UILabel.new({
        UILabelType = 2, text = "Time:", font="fonts/STENCILSTD.OTF",size = 38})
        :align(display.LEFT_TOP, display.left+10, display.top-110)
        :addTo(self)
    self.timeLabel = cc.ui.UILabel.new({
        UILabelType = 2, text = "60", font="fonts/STENCILSTD.OTF",size = 38})
        :align(display.LEFT_TOP, display.left+150, display.top-110)
        :addTo(self)
    self.activeScoreLabel = display.newTTFLabel({text = "",size =30})
        :pos(display.width/2,120)
        :addTo(self)
    self.activeScoreLabel:setColor(display.COLOR_WHITE)

    local slider_blank = cc.Sprite:create("Slider_blank.png")
    -- :addTo(self)
    slider_blank:setPosition(0,0)
    slider_blank:setAnchorPoint(0,0)
    slider_blank:setScale(display.width/slider_blank:getContentSize().width,1)

    local slider = cc.Sprite:create("Slider_full.png")
    self.ct = cc.ProgressTimer:create(slider)
    self.ct:setPosition(0,0)
    self.ct:setAnchorPoint(0,0)
    self.ct:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.ct:setTag(10)
    self.ct:setScale(display.width/slider:getContentSize().width,1)
    -- self.ct:addTo(self)
    self.ct:setPercentage(0)
    self.ct:setMidpoint(cc.p(0,0.5))
    self.ct:setBarChangeRate(cc.p(1,0))
    
    self.percentageLable = cc.ui.UILabel.new({
        UILabelType = 2, text = "0%", font="fonts/STENCILSTD.OTF",size = 38})
        :align(display.CENTER_BOTTOM, display.cx, 15)
        -- :addTo(self)

    local im_stop = {
        off = "stop_up.png",
        off_pressed = "stop_down.png",
        off_disabled = "stop_disabled.png",
        on = "continue_up.png",
        on_pressed = "continue_down.png",
        on_disabled = "continue_disabled.png"
    }
    
    self.stopBtn = cc.ui.UICheckBoxButton.new(im_stop)
        :onButtonClicked(function(event) 
            self:readyToStop(event.target)
        end)
        :align(display.TOP_RIGHT,display.width,display.height-20)
        :addTo(self)
        -- :setButtonEnabled(false)
end

function PlayScene:showGridGround()
    self.gridLayer = cc.Layer:create()
    self.gridLayer:addTo(self)
    self.gridLayer:setTouchEnabled(false)
    local sprite = display.newSprite("grid_ground.png")
    local source_gridWidth = sprite:getContentSize().width
    local gridWidth = size.width/self.xCount
    local gridWidthScale = gridWidth/source_gridWidth
    for y=1, self.yCount do
        for x=1, self.xCount do
            local gridPosition = self:positionOfBomb(x,y)
            local gridGround = display.newSprite("grid_ground_clear.png")
            gridGround:setScale(gridWidthScale,gridWidthScale)
            gridGround:setPosition(gridPosition)
            gridGround:addTo(self.gridLayer)
        end
    end
end

function PlayScene:showGameLayout()
    self.layer = cc.Layer:create()
    self.layer:addTo(self)
    self.layer:setTouchCaptureEnabled(false)
end

function PlayScene:readyToStop(checkbox)
    if (defaults:getBoolForKey(EFFECT_KEY)) then
        AudioEngine.playEffect(EFFECT_FILE)
    end
    -- self.stopSure = true
    self.stopBtn:setButtonEnabled(false)
    self.wantStop = true
    if checkbox:isButtonSelected() then
        self.stopGame = true
        -- display.pause()
    else
        self.stopGame = false
        -- display.resume()
    end
end

function PlayScene:showStopLayer(show)
    if show then
        self.isStop = true
        self.layer:setVisible(false)
        -- cc.Director:getInstance():pause()
        self.stopLayer = cc.LayerColor:create(cc.c4b(100,100,100,0),size.width/8*5,size.height/2)
        self.stopLayer:ignoreAnchorPointForPosition(false)
        self.stopLayer:setAnchorPoint(0.5,0.5)
        self.stopLayer:setPosition(size.width/2,-size.height/8)
        self.stopLayer:addTo(self)
        self.stopLayer:setTouchEnabled(true)
        self.stopLayer:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.MoveTo:create(1,cc.p(size.width/2,size.height/2))),
            cc.CallFunc:create(function ()
                self.stopBtn:setButtonEnabled(true)
            end)))
        local restartBtnImg = {
            normal = "restart_up.png",
            pressed = "restart_down.png"
        }
        cc.ui.UIPushButton.new(restartBtnImg,{scale9 = false})
            :onButtonClicked(function(event)
                if defaults:getBoolForKey(EFFECT_KEY) then 
                    AudioEngine.playEffect(EFFECT_FILE)
                end
                local PlayScene = require("src/app/scenes/PlayScene")
                playScene = PlayScene:new()
                local ts = cc.TransitionFade:create(1,playScene)
                cc.Director:getInstance():replaceScene(ts)
            end)
            :align(display.CENTER, size.width/16*5, size.height/32*16)
            :addTo(self.stopLayer)
            
        local im_effect = {
            off = "effect_open_up.png",
            off_pressed = "effect_open_down.png",
            off_disabled = "effect_open_disabled.png",
            on = "effect_close_on.png",
            on_pressed = "effect_close_down.png",
            on_disabled = "effect_close_disabled.png"
        }
        local effect_power = cc.ui.UICheckBoxButton.new(im_effect)
            :onButtonClicked(function(event) 
                if (defaults:getBoolForKey(EFFECT_KEY)) then
                    defaults:setBoolForKey(EFFECT_KEY,false)
                else
                    defaults:setBoolForKey(EFFECT_KEY,true)
                    AudioEngine.playEffect(EFFECT_FILE)
                end
            end)
            :align(display.CENTER, size.width/16*5, size.height/32*12)
            :addTo(self.stopLayer)
        if defaults:getBoolForKey(EFFECT_KEY) then 
            effect_power:setButtonSelected(true)
        else
            effect_power:setButtonSelected(false)
        end
        local im_music = {
            off = "music_off_2.png",
            off_pressed = "music_off_pressed_2.png",
            off_disabled = "music_off_disabled_2.png",
            on = "music_on_2.png",
            on_pressed = "music_on_pressed_2.png",
            on_disabled = "music_on_disabled_2.png"
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
            :align(display.CENTER, size.width/16*5, size.height/32*8)
            :addTo(self.stopLayer)
        if defaults:getBoolForKey(MUSIC_KEY) then 
            music_power:setButtonSelected(true)
        else
            music_power:setButtonSelected(false)
        end

        local im_music = {
            off = "night_up.png",
            off_pressed = "night_down.png",
            off_disabled = "night_disabled.png",
            on = "day_up.png",
            on_pressed = "day_down.png",
            on_disabled = "day_disabled.png"
        }
        local night_power = cc.ui.UICheckBoxButton.new(im_music)
            :onButtonClicked(function(event) 
                if (defaults:getBoolForKey(EFFECT_KEY)) then 
                    AudioEngine.playEffect(EFFECT_FILE)
                end
                if (defaults:getBoolForKey(NIGHT_KEY)) then 
                    defaults:setBoolForKey(NIGHT_KEY,false)
                    self:removeChild(self.blackLayer, false)
                else
                    defaults:setBoolForKey(NIGHT_KEY,true)
                    self.blackLayer = cc.LayerColor:create(cc.c4b(0,0,0,120),size.width,size.height)
                    self.blackLayer:addTo(self)
                end
            end)
            :align(display.CENTER, size.width/16*5, size.height/32*4)
            :addTo(self.stopLayer)
        if defaults:getBoolForKey(NIGHT_KEY) then 
            night_power:setButtonSelected(true)
        else
            night_power:setButtonSelected(false)
        end

        local menuBtnImg = {
            normal = "menu_up.png",
            pressed = "menu_down.png"
        }
        cc.ui.UIPushButton.new(menuBtnImg,{scale9 = false})
            :onButtonClicked(function(event)
                if defaults:getBoolForKey(EFFECT_KEY) then 
                    AudioEngine.playEffect(EFFECT_FILE)
                end
                self.stopLayer:runAction(cc.Sequence:create(cc.EaseBackIn:create(cc.MoveTo:create(1,cc.p(size.width,size.height/2))),
                    cc.CallFunc:create(function ()
                       local mainScene = import("app.scenes.MainScene"):new()
                       display.replaceScene(mainScene,"SlideInL",0.5)
                    end)))
            end)
            :align(display.CENTER, size.width/16*5, 0)
            :addTo(self.stopLayer)
    else
        self.stopLayer:runAction(cc.Sequence:create(cc.EaseBackIn:create(cc.MoveTo:create(1,cc.p(size.width/2,size.height/8*9))),
            cc.CallFunc:create(function ()
                self.stopBtn:setButtonEnabled(true)
                self.isStop = false
                self.layer:setVisible(true)
                self:removeChild(self.stopLayer, true)    
                self.stopLayer = nil
            end)))
    end
end

function PlayScene:ctor()
    math.randomseed(os.time())
    display.addSpriteFrames("bomb/bomb.plist","bomb/bomb.png")
    local bg = cc.Sprite:create("grey.png"):center()
    bg:setScale(size.width/bg:getTextureRect().width,size.height/bg:getTextureRect().height)
    bg:addTo(self)

    self.scoreStart = 5
    self.scoreStep = 10
    self.activeScore = 0
     
    self.highScore = 0
    self.stage = 1
    self.target = 123
    self.curScore = 0

    self.xCount = 9
    self.yCount = 9
    self.bombGap = 0
    
    self.bombWidth = cc.Director:getInstance():getWinSize().width/self.xCount
    self.bombWidthScale = self.bombWidth/Bomb:getWidth()

    self.start_x = nil
    self.start_y = nil
    self.end_x = nil
    self.end_y = nil
    self.lock = true

    self.lastClickBomb = nil

    self.actionTime = 0.15
    self.matrixLBX = (display.width - self.bombWidth*self.xCount -(self.yCount -1 )*self.bombGap)/2
    self.matrixLBY = (display.height - self.bombWidth*self.yCount -(self.xCount -1 )*self.bombGap)/2

    self:showGridGround()    
    self:showGameLayout()

    self:addNodeEventListener(cc.NODE_EVENT, function(event)
        if event =="enterTransitionFinish" then
            -- self:initMatrix()
        end
    end)

    self.highScore = cc.UserDefault:getInstance():getIntegerForKey("HighScore")
    self.stage =cc.UserDefault:getInstance():getIntegerForKey("Stage")
    if self.stage == 0  then
        self.stage = 1    	
    end
    self.target = self.stage * 200

    self.isworking = false

    self:initUI()

    self.isTimeOut = false
    self.time = 60

    self.isWorking = true

    self.stopGame = false
    self.isStop = false
    self.wantStop = false

    self.effect_level = 1

    self.blackLayer = cc.LayerColor:create(cc.c4b(0,0,0,120),size.width,size.height)
    if (defaults:getBoolForKey(NIGHT_KEY)) then 
        self.blackLayer:addTo(self)
    end
end

function PlayScene:initMatrix()
    self.matrix={}
    self.actives={}
    for y=1, self.yCount do
        for x=1,self.xCount do
            if self.yCount  == y and self.xCount ==x then
                self:createAndDropBomb(x,y,nil,true)
            else
                self:createAndDropBomb(x,y)
            end
        end
    end
        -- self.matrix[2]:setState(3)
        -- self.matrix[3]:setState(4)
        -- self.matrix[4]:setState(10)
        -- self.matrix[12]:setState(5)
end

function PlayScene:createAndDropBomb(x,y,bombIndex,last)
    local newBomb = Bomb.new(x,y,bombIndex)
    local endPosition = self:positionOfBomb(x,y)
    local startPosition = cc.p(endPosition.x,endPosition.y+display.height/2)
    newBomb:setScale(self.bombWidthScale,self.bombWidthScale)
    newBomb:setPosition(startPosition)
    local speed = startPosition.y/(2*display.height)

    self.isworking = true
    newBomb:runAction(cc.Sequence:create(cc.EaseSineIn:create(cc.MoveTo:create(speed,endPosition)),cc.CallFunc:create(function ()
    if last then
        self:flush(true)
        last = false
    end
    end)))

    self.matrix[(y-1)*self.xCount + x]=newBomb
    self.layer:addChild(newBomb)

    newBomb:setTouchEnabled(true)
    newBomb:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
        if event.name == "began" then
            self.start_x = event.x
            self.start_y = event.y
            newBomb:onClick(true, self.bombWidthScale, self.bombWidthScale)
            if self:checkNeighbor(newBomb,event) == false then 
                return false
            end
            return true
        end

        if event.name == "moved" then
            if self.lock and (math.abs(event.x - self.start_x) > self.bombWidth/2 or math.abs(event.y - self.start_y) > self.bombWidth/2) then
                self.lastClickBomb = nil
                self.lock = false
                self.layer:setTouchCaptureEnabled(false)
                self.isworking = true
                if not self:moveBomb(newBomb,event) then
                    self.layer:setTouchCaptureEnabled(true)
                    self.isworking = false
                end
            end
        end

        if event.name == "ended" then
            self.lock = true 
        end

    end)
end

function PlayScene:checkNeighbor(newBomb,event)
    local rightNeighbor = self.matrix[(newBomb.y-1)*self.xCount + newBomb.x + 1]
    local leftNeighbor = self.matrix[(newBomb.y-1)*self.xCount + newBomb.x - 1]
    local upNeighbor = self.matrix[(newBomb.y)*self.xCount + newBomb.x]
    local downNeighbor = self.matrix[(newBomb.y-2)*self.xCount + newBomb.x]
    if rightNeighbor and rightNeighbor.isOnclick then
        self.lastClickBomb = nil
        self:inClick()
        self.layer:setTouchCaptureEnabled(false)
        self.isworking = true
        if not self:moveBomb(newBomb,event,1) then
            self.layer:setTouchCaptureEnabled(true)
            self.isworking = false
        else
            return false
        end
    elseif leftNeighbor and leftNeighbor.isOnclick then
            self.lastClickBomb = nil
        self:inClick()
        self.layer:setTouchCaptureEnabled(false)
        self.isworking = true
        if not self:moveBomb(newBomb,event,2) then
            self.layer:setTouchCaptureEnabled(true)
            self.isworking = false
        else
            return false
        end
    elseif upNeighbor and upNeighbor.isOnclick then
            self.lastClickBomb = nil
        self:inClick()
        self.layer:setTouchCaptureEnabled(false)
        self.isworking = true
        if not self:moveBomb(newBomb,event,3) then
            self.layer:setTouchCaptureEnabled(true)
            self.isworking = false
        else
            return false
        end
    elseif downNeighbor and downNeighbor.isOnclick then
            self.lastClickBomb = nil
        self:inClick()
        self.layer:setTouchCaptureEnabled(false)
        self.isworking = true
        if not self:moveBomb(newBomb,event,4) then
            self.layer:setTouchCaptureEnabled(true)
            self.isworking = false
        else
            return false
        end
    elseif self.lastClickBomb ~= nil then
        self.lastClickBomb:onClick(false,self.bombWidthScale,self.bombWidthScale)
        self.lastClickBomb = newBomb
    elseif self.lastClickBomb == nil then
        self.lastClickBomb = newBomb
    end
    return true
end

function PlayScene:flush(Touchable)
    self:inActive()
    self:inClick()
    self:findAllSpecialBomb()
    if not self:checkAll(false) then
        if Touchable then
            self.layer:setTouchCaptureEnabled(true)
            self.isworking = false
            self.effect_level = 1
        end
        return 
    end   
    self:cleanAll()
    self:showActivesScore()
    self:removeActivedBombs()
    self:dropBombs()
    -- self:checkNextStage()
end

function PlayScene:flushAfterFire()
    self:showActivesScore()
    self:removeActivedBombs()
    self:dropBombs()
    -- self:checkNextStage()
end

function PlayScene:checkAll(only_check)
    local needClean = false
    for y=1, self.yCount do
        for x=1, self.xCount do
            local lifeIsZero = self.matrix[(y-1)*self.xCount + x]
            if lifeIsZero.life == 0 then
                needClean = true 
            end
            if (x <= self.xCount - 2 ) then
                local x_1 = self.matrix[(y-1)*self.xCount + x]
                local x_2 = self.matrix[(y-1)*self.xCount + x + 1]
                local x_3 = self.matrix[(y-1)*self.xCount + x + 2]
                if (x_1 ~= nil and x_1.bombIndex ~= 0) 
                    and (x_1.bombIndex == x_2.bombIndex) 
                    and (x_1.bombIndex == x_3.bombIndex) then
                    needClean = true
                    if only_check then
                        return true
                    end
                    x_1:setActive()
                    x_2:setActive()
                    x_3:setActive()
                end
            end
            if (y <= self.yCount - 2 ) then
                local y_1 = self.matrix[(y-1)*self.xCount + x]
                local y_2 = self.matrix[(y)*self.xCount + x]
                local y_3 = self.matrix[(y+1)*self.xCount + x]
                if (y_1 ~= nil and y_1.bombIndex ~= 0) 
                    and (y_1.bombIndex == y_2.bombIndex) 
                    and (y_1.bombIndex == y_3.bombIndex) then
                    needClean = true
                    if only_check then
                        return true
                    end
                    y_1:setActive()
                    y_2:setActive()
                    y_3:setActive()
                end
            end
        end
    end
    return needClean
end

function PlayScene:cleanAll()
    for y=1, self.yCount do
        for x=1, self.xCount do
            if (self.matrix[(y-1)*self.xCount + x].life <= 0) then
                -- print(x.."···"..y)
                table.insert(self.actives,self.matrix[(y-1)*self.xCount + x])
                -- print("cleanAll-*--"..x.."--"..y)
            end
        end
    end
end

function PlayScene:positionOfBomb(x,y)
    local px = self.matrixLBX +(self.bombWidth+self.bombGap)* (x-1)+self.bombWidth/2
    local py = self.matrixLBY +(self.bombWidth+self.bombGap)* (y-1)+self.bombWidth/2
    return cc.p(px,py)
end

function PlayScene:removeActivedBombs()
    local bombScore = self.scoreStart
    local newTable = {}
    for k,v in pairs(self.actives) do
        newTable[v] = true
    end
    self.actives = {}
    for k,v in pairs(newTable) do
        table.insert(self.actives,k)
    end
    for _,bomb  in pairs(self.actives) do
    	if bomb then
            if bomb.state ~= STATE_NORMAL and bomb.state ~= STATE_KING then
                self:fireSpecialBomb(bomb)
            end
            -- print(bomb.x.."-----"..bomb.y)
            self.matrix[(bomb.y-1)*self.xCount + bomb.x] = nil
            self:scorePopupEffect(bombScore,bomb.bombIndex,bomb:getPosition())
            --下面这段粒子效果
            -- self:showParticle("stars.plist", bomb)
            --
            bombScore = bombScore + self.scoreStep
    		bomb:removeFromParent()
    	end
    end
    if (defaults:getBoolForKey(EFFECT_KEY)) then
        if self.effect_level == 1 then
            AudioEngine.playEffect(EFFECT_BOOM_1_FILE)
        elseif self.effect_level == 2 then
            AudioEngine.playEffect(EFFECT_BOOM_2_FILE)
        elseif self.effect_level == 3 then
            AudioEngine.playEffect(EFFECT_BOOM_3_FILE)
        elseif self.effect_level == 4 then
            AudioEngine.playEffect(EFFECT_BOOM_4_FILE)
        elseif self.effect_level == 7 then
            AudioEngine.playEffect(EFFECT_BOOM_5_FILE)
        elseif self.effect_level >= 10 then
            AudioEngine.playEffect(EFFECT_BOOM_1_FILE)
        end
    end
    self.effect_level = self.effect_level + 1
    self.actives = {}
    self.curScore = self.curScore +self.activeScore
    self.curScoreLabel:setString(tostring(self.curScore))	
    self.activeScoreLabel:setString("")
    self.activeScore = 0
    
 --    local sliderValue = self.curScore*100/self.target
 --    if sliderValue <0 then
 --        sliderValue = 0
 --    elseif sliderValue >100 then
 --        sliderValue = 100
 --    end
 -- --    self.sliderBar:setSliderValue(sliderValue)
 --    self.ct:setPercentage(sliderValue)
 --    self.percentageLable:setString(string.format("%d%%",sliderValue))
end

function PlayScene:fireSpecialBomb(bomb,combine_bomb)
    if bomb then
        if bomb.life ~= 0 then
            bomb.life = 0
            table.insert(self.actives,bomb)
        end
        if bomb.state == STATE_HOR then
            self:fireHorBomb(bomb, combine_bomb)
        elseif bomb.state == STATE_VER then
            self:fireVerBomb(bomb, combine_bomb)
        elseif bomb.state == STATE_BOOM then
            self:fireBigBomb(bomb, combine_bomb)
        elseif bomb.state == STATE_KING then
            self:fireKingBomb(bomb, combine_bomb)
        end
    end
end

function PlayScene:fireHorBomb(bomb,combine_bomb)
    self:showSpricalBombEffect(STATE_HOR,nil,bomb:getPosition())
    if combine_bomb then
            -- combine_bomb.life = 0
            -- table.insert(self.actives,aBomb)
        if combine_bomb.state == STATE_HOR or combine_bomb.state == STATE_VER then
            self:fireSpecialBomb(combine_bomb)
        elseif combine_bomb.state == STATE_BOOM then
            -- combine_bomb.setState(3)
            combine_bomb.state = STATE_HOR
            self:fireSpecialBomb(combine_bomb)
            if bomb.y == combine_bomb.y then
                local joinBomb
                if (math.random()*1000)%2 == 0 then
                    joinBomb = self.matrix[(bomb.y + 1)*self.xCount + bomb.x]
                else
                    joinBomb = self.matrix[(bomb.y - 3)*self.xCount + bomb.x]
                end
                if joinBomb then
                    joinBomb.state = STATE_HOR
                    self:fireSpecialBomb(joinBomb)
                end
                local upBomb = self.matrix[(bomb.y)*self.xCount + bomb.x]
                local downBomb = self.matrix[(bomb.y - 2)*self.xCount + bomb.x]
                if upBomb then
                    upBomb.state = STATE_HOR
                    self:fireSpecialBomb(upBomb)
                end
                if downBomb then
                    downBomb.state = STATE_HOR
                    self:fireSpecialBomb(downBomb)
                end
            else
                local agentY
                if bomb.y > combine_bomb.y then
                    agentY = bomb.y
                else
                    agentY = combine_bomb.y
                end
                local upBomb = self.matrix[(agentY)*self.xCount + bomb.x]
                local downBomb = self.matrix[(agentY - 3)*self.xCount + bomb.x]
                if upBomb then
                    upBomb.state = STATE_HOR
                    self:fireSpecialBomb(upBomb)
                end
                if downBomb then
                    downBomb.state = STATE_HOR
                    self:fireSpecialBomb(downBomb)
                end
            end
        end
    end
    for x = 1, self.xCount do
        local aBomb = self.matrix[(bomb.y - 1)*self.xCount + x]
        if aBomb ~= nil and aBomb.life ~= 0 and x ~= bomb.x then
            if aBomb.state ~= STATE_NORMAL then
                self:fireSpecialBomb(aBomb)
            else
            -- print("fire-3-*--"..aBomb.x.."--"..aBomb.y)
                aBomb.life = 0
                table.insert(self.actives,aBomb)
            end
        end
    end
end

function PlayScene:fireVerBomb(bomb,combine_bomb)
    self:showSpricalBombEffect(STATE_VER,nil,bomb:getPosition())
    if combine_bomb then
        if combine_bomb.state == STATE_HOR or combine_bomb.state == STATE_VER then
            self:fireSpecialBomb(combine_bomb)
        elseif combine_bomb.state == STATE_BOOM then
            combine_bomb.state = STATE_VER
            self:fireSpecialBomb(combine_bomb)
            if bomb.x == combine_bomb.x then
                local joinBomb
                if (math.round(math.random()*1000)%2 == 0) then
                    joinBomb = self.matrix[(bomb.y - 1)*self.xCount + bomb.x + 2]
                else
                    joinBomb = self.matrix[(bomb.y - 1)*self.xCount + bomb.x - 2]
                end
                if joinBomb then
                    joinBomb.state = STATE_VER
                    self:fireSpecialBomb(joinBomb)
                end
                local leftBomb = self.matrix[(bomb.y - 1)*self.xCount + bomb.x + 1]
                local rightBomb = self.matrix[(bomb.y - 1)*self.xCount + bomb.x - 1]
                if leftBomb then
                    leftBomb.state = STATE_VER
                    self:fireSpecialBomb(leftBomb)
                end
                if rightBomb then
                    rightBomb.state = STATE_VER
                    self:fireSpecialBomb(rightBomb)
                end
            else
                local agentX
                if bomb.x > combine_bomb.x then
                    agentX = bomb.x
                else
                    agentX = combine_bomb.x
                end
                local leftBomb = self.matrix[(bomb.y - 1)*self.xCount + agentX - 2]
                local rightBomb = self.matrix[(bomb.y - 1)*self.xCount + agentX + 1]
                if leftBomb then
                    leftBomb.state = STATE_VER
                    self:fireSpecialBomb(leftBomb)
                end
                if rightBomb then
                    rightBomb.state = STATE_VER
                    self:fireSpecialBomb(rightBomb)
                end
            end
        end
    end
    for y = 1, self.yCount do
        local bBomb = self.matrix[(y - 1)*self.xCount + bomb.x]
        if  bBomb ~= nil and bBomb.life ~= 0 and y ~= bomb.y then
            if bBomb.state ~= STATE_NORMAL and bBomb.life ~= 0 then
                self:fireSpecialBomb(bBomb) 
            else
            -- print("fire-4-*--"..bBomb.x.."--"..bBomb.y)
                bBomb.life = 0
                table.insert(self.actives,bBomb)
            end
        end
    end
end

function PlayScene:fireBigBomb(bomb,combine_bomb)
    if combine_bomb then
        if combine_bomb.state == STATE_HOR or combine_bomb.state == STATE_VER then
            self:fireSpecialBomb(combine_bomb, bomb)
        elseif combine_bomb.state == STATE_BOOM then
           self:showParticle("bigbigBOOM.plist",bomb)
            local bigbigBomb = {}
            for i = -4,4 do
                for j = -4,4 do
                    local dbomb = self.matrix[(bomb.y - 1 + i)*self.xCount + bomb.x + j]
                    if dbomb and math.abs(i) + math.abs(j) <= 4 and (bomb.x + j) >= 1 and (bomb.x + j) <= self.xCount then
                        if not (i == 0 and j == 0) then
                            table.insert(bigbigBomb,dbomb)
                        end
                    end
                end
            end
            for _,cbomb in pairs(bigbigBomb) do
                if cbomb.life ~= 0 then 
                    if bomb.state ~= STATE_NORMAL and bomb.life ~= 0 then
                        self:fireSpecialBomb(cbomb) 
                    else
                        cbomb.life = 0
                        table.insert(self.actives,cbomb)
                    end
                end
            end 
        end
    else
        self:showParticle("bigBOOM.plist",bomb)
        local bigBomb = {}
        for i = -2,2 do
            for j = -2,2 do
                local dbomb = self.matrix[(bomb.y - 1 + i)*self.xCount + bomb.x + j]
                if dbomb and math.abs(i) + math.abs(j) <= 2 and (bomb.x + j) >= 1 and (bomb.x + j) <= self.xCount then
                    if not (i == 0 and j == 0) then
                        table.insert(bigBomb,dbomb)
                    end
                end
            end
        end
        for _,cbomb in pairs(bigBomb) do
            if cbomb.life ~= 0 then 
                if cbomb.state ~= STATE_NORMAL and cbomb.life ~= 0 then
                    self:fireSpecialBomb(cbomb) 
                else
                -- print("fire-5-*--"..cbomb.x.."--"..cbomb.y)
                    cbomb.life = 0
                    table.insert(self.actives,cbomb)
                end
            end
        end
    end
end

function PlayScene:fireKingBomb(bomb,combine_bomb)
    if combine_bomb and combine_bomb.state == STATE_KING then
        self:showParticle("big_black_hole.plist",bomb)
        for y=1, self.yCount do
            for x=1, self.xCount do
                local killBomb = self.matrix[(y - 1)*self.xCount + x]
                if killBomb and killBomb.life ~= 0 then
                    killBomb:runAction(cc.Sequence:create(
                        cc.Spawn:create(cc.ScaleBy:create(0.5,0.5),cc.RotateBy:create(0.5,720),cc.MoveTo:create(0.5,self:positionOfBomb(bomb.x, bomb.y))),
                        cc.CallFunc:create(function ()
                                killBomb.life = 0
                                killBomb.state = STATE_NORMAL
                                table.insert(self.actives,killBomb)
                        end)))
                end
            end
        end
    elseif combine_bomb and (combine_bomb.state == STATE_HOR or combine_bomb.state == STATE_VER or combine_bomb.state == STATE_BOOM) then
        local killType = combine_bomb.bombIndex
        local killState = combine_bomb.state
        for y=1, self.yCount do
            for x=1, self.xCount do
                local killBomb = self.matrix[(y - 1)*self.xCount + x]
                if killBomb and killBomb.bombIndex == killType then
                    if killState == STATE_VER or killState == STATE_HOR then
                        if math.round(math.random()*1000)%2 == 0 then
                            killState = STATE_HOR
                        else
                            killState = STATE_VER
                        end 
                    end
                    killBomb:setState(killState)
                    killBomb:runAction(cc.Sequence:create(cc.ScaleBy:create(0.26,0.7),cc.ScaleBy:create(0.26,1.3),
                        cc.CallFunc:create(function ()
                            if killBomb ~= nil  and killBomb.life ~= 0 then
                                self:fireSpecialBomb(killBomb)
                            end
                    end)))
                end
            end
        end
    else
        local killType
        -- local haveFlush = false
        -- print("what the hell.."..bomb.x.."----"..bomb.y)
        if combine_bomb and combine_bomb.state ~= STATE_KING then
            killType = combine_bomb.bombIndex
            -- print("i have friend~  "..killType)
        else
            killType = math.round(math.random()*1000)%5+1
            -- print("i kill random~  "..killType)
        end
        for y=1, self.yCount do
            for x=1, self.xCount do
                local killBomb = self.matrix[(y - 1)*self.xCount + x]
                if killBomb and killBomb.bombIndex == killType then
                        self:showParticle("black_hole.plist",killBomb)
                        -- killBomb:runAction(cc.Sequence:create(
                            -- cc.Spawn:create(cc.ScaleBy:create(0 .28,0.5),cc.RotateBy:create(0.28,720),
                            -- cc.CallFunc:create(function ()
                            if killBomb ~= nil and killBomb.life ~= 0 then
                                if killBomb.state ~= STATE_NORMAL then
                                    self:fireSpecialBomb(killBomb)
                                else
                                -- print("fire-0-*--"..killBomb.x.."--"..killBomb.y)
                                    killBomb.life = 0
                                    table.insert(self.actives,killBomb)
                                end
                            end
                            -- print("asfioa")
                    -- end),cc.DelayTime:create(0.35),cc.CallFunc:create(function()
                    --     -- if not haveFlush then
                    --         self:flushAfterFire()
                    --         haveFlush = true
                    --     -- end
                    -- end)))
                end
            end
        end
    end
end

function PlayScene:scorePopupEffect(bombScore,bombIndex,x,y)
    local toast = Toast.new(bombIndex)
    toast:setPosition(x,y)
    toast:setScale(self.bombWidthScale,self.bombWidthScale)
    toast:addToast(string.format("%d",bombScore))
    self:addChild(toast)
    local allAction = {cc.EaseSineOut:create(cc.Spawn:create(cc.FadeTo:create(1,125),cc.MoveBy:create(1,cc.p(0,self.bombWidth)))),
        cc.CallFunc:create(function ()
            toast:removeFromParent(true)
        end)}
    toast:runAction(cc.Sequence:create(allAction))
end

function PlayScene:showSpricalBombEffect(bombID,bombIndex,x,y)
    local middle_x = (self.matrixLBX +(self.bombWidth+self.bombGap)* (self.xCount -1)+self.bombWidth/2)/2
    local middle_y = (self.matrixLBY +(self.bombWidth+self.bombGap)* (self.yCount +2)+self.bombWidth/2)/2
    local toast = Toast.new(bombID*10)
    if bombID == STATE_HOR then
        toast:setScale(1,self.bombWidthScale)
        toast:setPosition(size.width/2,y)
    elseif bombID == STATE_VER then
        toast:setScale(self.bombWidthScale,1)
        toast:setPosition(x,size.height/2)
    end
    self:addChild(toast)
    local allAction = {cc.EaseSineOut:create(cc.FadeIn:create(0.2)),cc.DelayTime:create(0.3),cc.FadeOut:create(0.3),
        cc.CallFunc:create(function ()
            toast:removeFromParent(true)
        end)}
    toast:runAction(cc.Sequence:create(allAction))
end

function PlayScene:showParticle(plist,bomb)
    local emitter = cc.ParticleSystemQuad:create(plist)
    emitter:setPosition(bomb:getPosition())
    emitter:setAutoRemoveOnFinish(true)
    local batch = cc.ParticleBatchNode:createWithTexture(emitter:getTexture())
    batch:addChild(emitter)
    self:addChild(batch)
end

function PlayScene:dropBombs()
    local all_remove = 0
    
    self.layer:setTouchCaptureEnabled(false)
    self.isworking = true

    local emptyInfo={}
    for x= 1, self.xCount do
    	local removedBombs = 0
    	local newY = 0
    	for y = 1,self.yCount do
    		local temp = self.matrix[(y-1)*self.xCount + x]
    		if temp ==nil then                
                removedBombs = removedBombs + 1
                all_remove = all_remove + 1
            else
                if removedBombs>0 then
                    newY = y - removedBombs
                    self.matrix[(newY-1)*self.xCount +x ] = temp
                    temp.y =newY
                    self.matrix[(y-1)*self.xCount +x ]= nil

    		    	local endPosition = self:positionOfBomb(x,newY)
    		    	local speed = (temp:getPositionY()-endPosition.y)/display.height
    		    	temp:stopAllActions()
    		    	temp:runAction(cc.Sequence:create(cc.DelayTime:create(self.actionTime),cc.EaseExponentialIn:create(cc.MoveTo:create(speed,endPosition))))
    		    	
    		    end
    		end
    	end
    		emptyInfo[x] = removedBombs
    end
    
	for x=1,self.xCount do
	   for y=self.yCount - emptyInfo[x] + 1,self.yCount do
	       all_remove = all_remove - 1
	       if all_remove == 0 then
    	   	   self:createAndDropBomb(x,y,nil,true)
    	   else
    	   	   self:createAndDropBomb(x,y)
	       end
	   end
	end
end

function PlayScene:checkNextStage()
    if self.curScore < self.target then
	  return
    end
	
	local resultLayer = display.newColorLayer(cc.c4b(0,50,0,150))
	resultLayer:addTo(self)
	resultLayer:setTouchEnabled(true)
	resultLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
	   if event.name =="began" then
	   	   return true
	   end
	end)
	
	if self.curScore>=self.highScore then
        self.highScore =self.curScore
    end

    self.stage = self.stage + 1
    self.target = self.stage * 200
	cc.UserDefault:getInstance():setIntegerForKey("HighScore",self.highScore)
	cc.UserDefault:getInstance():setIntegerForKey("Stage",self.stage)
	
	display.newTTFLabel({text = string.format("恭喜过关！\n最高分：%d",self.highScore),size = 60})
	   :pos(display.cx,display.cy+140)
	   :addTo(resultLayer)
	
	local startBtnImages = {
	   normal = "startgame_up.png",
	   pressed = "startgame_down.png"
	}
	cc.ui.UIPushButton.new(startBtnImages,{scale9 = false})
	   :onButtonClicked(function(event)
	       local mainScene = import("app.scenes.MainScene"):new()
           display.replaceScene(mainScene,"SlideInL",0.5)
	   end)
	   :align(display.CENTER,display.cx,display.cy -80)
	   :addTo(resultLayer)
end

function PlayScene:inClick()
    for y=1, self.yCount do
        for x=1, self.xCount do
            if(self.matrix[(y-1)*self.xCount + x]) then
                self.matrix[(y-1)*self.xCount + x]:onClick(false,self.bombWidthScale,self.bombWidthScale)
                self.matrix[(y-1)*self.xCount + x].isActive = false
            end
        end
    end
end

function PlayScene:inActive()
	for _,bomb in pairs(self.actives) do
	   if(bomb) then
            bomb:setActive(false)
	   end
	end
	self.actives={}
end

function PlayScene:findAllSpecialBomb()
    for y=1, self.yCount do
        for x=1, self.xCount do
            self:specialBomb(self.matrix[(y-1)*self.xCount + x],nil)
        end
    end
end

function PlayScene:specialBomb(bomb,dir)
    local hor_left = 0
    local hor_right = 0
    local ver_up = 0
    local ver_down = 0

    if bomb == nil then
        return 0
    end
    if bomb.state ~= STATE_NORMAL or bomb.life == 0 then
        if dir == nil or bomb.life == 2 then
           return -100
        end
    end

    if ((bomb.x - 1) >= 1) and ((dir == 1) or (dir == nil)) then
        local leftNeighbor = self.matrix[(bomb.y -1 )*self.xCount + bomb.x-1]
        if leftNeighbor.bombIndex == bomb.bombIndex then
            hor_left = 1 + self:specialBomb(leftNeighbor,1)
            if dir ~= nil then
                return hor_left
            end            
        end
    end 
    if ((bomb.x + 1) <= self.xCount) and ((dir == 2) or (dir == nil)) then
        local rightNeighbor = self.matrix[(bomb.y -1 )*self.xCount + bomb.x+1]
        if rightNeighbor.bombIndex == bomb.bombIndex then
            hor_right = 1 + self:specialBomb(rightNeighbor,2)
            if dir ~= nil then
                return hor_right
            end 
        end
    end 
    if ((bomb.y + 1) <= self.yCount) and ((dir == 3) or (dir == nil)) then
        local upNeighbor = self.matrix[(bomb.y )*self.xCount + bomb.x]
        if upNeighbor.bombIndex == bomb.bombIndex then
            ver_up = 1 + self:specialBomb(upNeighbor,3)
            if dir ~= nil then
                return ver_up
            end 
        end
    end 
    if ((bomb.y - 1) >= 1) and ((dir == 4) or (dir == nil)) then
        local downNeighbor = self.matrix[(bomb.y -2 )*self.xCount + bomb.x]
        if downNeighbor.bombIndex == bomb.bombIndex then
            ver_down = 1 + self:specialBomb(downNeighbor,4)
            if dir ~= nil then
                return ver_down
            end 
        end
    end
    if dir == nil then
        local ver = ver_down + ver_up
        local hor = hor_right + hor_left
        if hor < 0 or ver < 0 then
            return -100 
        else
            if ver >= 2 or hor >= 2 then
                if ver >= 2 then
                    if ver >= 3 then
                        bomb:setState(STATE_HOR)
                        if ver >= 4 then
                            bomb:setState(STATE_KING)
                            for i = 1,ver_up do
                                self.matrix[(bomb.y - 1 + i)*self.xCount + bomb.x]:setActive()
                            end
                            for i = 1,ver_down do
                                self.matrix[(bomb.y - 1 - i)*self.xCount + bomb.x]:setActive()
                            end
                            if hor >= 2 then
                                for i = 1,hor_right do
                                    self.matrix[(bomb.y - 1)*self.xCount + bomb.x + i]:setActive()
                                end
                                for i = 1,hor_left do
                                    self.matrix[(bomb.y - 1)*self.xCount + bomb.x - i]:setActive()
                                end
                            end
                        end
                    end
                end
                if hor >= 2 then
                    if hor >= 3 then
                        bomb:setState(STATE_VER)
                        if hor >= 4 then
                            bomb:setState(STATE_KING)
                            for i = 1,hor_right do
                                self.matrix[(bomb.y - 1)*self.xCount + bomb.x + i]:setActive()
                            end
                            for i = 1,hor_left do
                                self.matrix[(bomb.y - 1)*self.xCount + bomb.x - i]:setActive()
                            end
                            if ver >= 2 then
                                for i = 1,ver_up do
                                    self.matrix[(bomb.y - 1 + i)*self.xCount + bomb.x]:setActive()
                                end
                                for i = 1,ver_down do
                                    self.matrix[(bomb.y - 1 - i)*self.xCount + bomb.x]:setActive()
                                end
                            end
                        end
                    end
                    if ver >= 2 and bomb.state ~= STATE_KING then
                        bomb:setState(STATE_BOOM)
                    end
                end
                if bomb.state == STATE_HOR then
                    self:showParticle("horizontal.plist", bomb)
                elseif bomb.state == STATE_VER then
                    self:showParticle("vertical.plist", bomb)
                elseif bomb.state == STATE_BOOM then
                    self:showParticle("createBigBomb.plist", bomb)
                elseif bomb.state == STATE_KING then
                    self:showParticle("kingBomb.plist", bomb)
                end
            end
        end
    else
        return 0
    end
end

function PlayScene:showActivesScore()
    if 1 == #self.actives then 
        self:inActive()
        self.activeScoreLabel:setString("")
        self.activeSocre = 0
        return
    end
    self.activeScore = (self.scoreStart * 2 +self.scoreStep * (#self.actives -1))* #self.actives/2
    -- self.activeScoreLabel:setString(string.format("%d连消，得分%d",#self.actives,self.activeScore))
end

function PlayScene:moveBomb(bomb,event,direction)
    self.end_x = event.x
    self.end_y = event.y
    local move_x = self.end_x - self.start_x
    local move_y = self.end_y - self.start_y

    if (math.abs(move_x) > math.abs(move_y)) or direction then
        if move_x >= (self.bombWidth/2) or direction == 1 then
            if self:toRight(bomb,false) then
                return true
            end 
        elseif move_x <= (self.bombWidth/-2) or direction == 2 then
            if self:toLeft(bomb,false) then
                return true
            end 
        end
    end
    if (math.abs(move_x) < math.abs(move_y)) or direction then
        if move_y > (self.bombWidth/2) or direction == 3 then
            if self:toUp(bomb,false) then
                return true
            end 
        elseif move_y < (self.bombWidth/-2) or direction == 4 then
            if self:toDown(bomb,false) then
                return true
            end 
        end
    end
    return false
end

function PlayScene:checkOrFire(bomb,nextBomb,again,again_dir)
    local isChange = false
    if bomb.state == STATE_KING or nextBomb.state == STATE_KING or 
        ((bomb.state == STATE_HOR or bomb.state == STATE_VER or bomb.state == STATE_BOOM)
            and (nextBomb.state == STATE_HOR or nextBomb.state == STATE_VER or nextBomb.state == STATE_BOOM)) then
        if bomb.state == STATE_KING and (nextBomb.state == STATE_KING or 
            ((nextBomb.state == STATE_HOR or nextBomb.state == STATE_VER or nextBomb.state == STATE_BOOM))) then
            self:fireSpecialBomb(bomb, nextBomb)
            return 2
        elseif ((bomb.state == STATE_HOR or bomb.state == STATE_VER or bomb.state == STATE_BOOM)) and nextBomb.state == STATE_KING then
            self:fireSpecialBomb(nextBomb, bomb)
            return 2
        elseif bomb.state == STATE_KING and nextBomb.state == STATE_NORMAL then
            self:fireSpecialBomb(bomb, nextBomb)
            return 1
        elseif bomb.state == STATE_NORMAL and nextBomb.state == STATE_KING then
            self:fireSpecialBomb(nextBomb, bomb)
            return 1
        else 
            self:fireSpecialBomb(bomb, nextBomb)
            self:fireSpecialBomb(nextBomb, bomb)
            self:flushAfterFire()
        end
        return 3
    end
    self:specialBomb(bomb,nil)
    self:specialBomb(nextBomb,nil)
    isChange = self:checkAll(true)
    if isChange then
        self:flush(false)
    else
        if again == false then
            if again_dir == 1 then
                self:toLeft(bomb,true)
            elseif again_dir == 2 then
                self:toRight(bomb,true)
            elseif again_dir == 3 then
                self:toDown(bomb,true)
            elseif again_dir == 4 then
                self:toUp(bomb,true)
            end
        end
    end
    return -1
end

function PlayScene:toRight(bomb,again)
    local toDo = 0
    if bomb then
        if bomb.x < self.xCount  then
            local rightBomb = self.matrix[(bomb.y - 1)*self.xCount + bomb.x + 1]
            bomb:runAction(cc.MoveTo:create(self.actionTime,self:positionOfBomb(rightBomb.x,bomb.y)))
            rightBomb:runAction(cc.Sequence:create(cc.MoveTo:create(self.actionTime,self:positionOfBomb(bomb.x,bomb.y)),
                cc.DelayTime:create(self.actionTime),cc.CallFunc:create(function ()
                    self.matrix[(bomb.y -1 )*self.xCount + bomb.x + 1] = bomb
                    self.matrix[(bomb.y -1 )*self.xCount + bomb.x] = rightBomb
                    bomb.x = bomb.x + 1
                    rightBomb.x = rightBomb.x -1
                    toDo = self:checkOrFire(bomb, rightBomb, again, 1) 
                    if toDo > 0 then
                        return 
                    end
                end),cc.DelayTime:create(self.actionTime),cc.CallFunc:create(function ()
                    if again then
                        bomb:onClick(false,self.bombWidthScale,self.bombWidthScale)
                        self:inClick()
                        self.layer:setTouchCaptureEnabled(true)
                        self.isworking = false
                    end
                end),cc.DelayTime:create(self.actionTime + 0.2),cc.CallFunc:create(function()
                    if toDo == 1 then
                        self:flushAfterFire()
                    end
                end),cc.DelayTime:create(0.4 - self.actionTime),cc.CallFunc:create(function()
                    if toDo == 2 then
                        self:flushAfterFire()
                    end
                end)))
        else
            return false
        end
    end
    return true
end

function PlayScene:toLeft(bomb,again)
    local toDo = 0
    if bomb then
        if bomb.x > 1  then
            local leftBomb = self.matrix[(bomb.y - 1)*self.xCount + bomb.x - 1]
            bomb:runAction(cc.MoveTo:create(self.actionTime,self:positionOfBomb(leftBomb.x,bomb.y)))
            leftBomb:runAction(cc.Sequence:create(cc.MoveTo:create(self.actionTime,self:positionOfBomb(bomb.x,bomb.y)),
                cc.DelayTime:create(self.actionTime),cc.CallFunc:create(function ()
                    self.matrix[(bomb.y -1 )*self.xCount + bomb.x - 1] = bomb
                    self.matrix[(bomb.y -1 )*self.xCount + bomb.x] = leftBomb
                    bomb.x = bomb.x - 1
                    leftBomb.x = leftBomb.x + 1
                    toDo = self:checkOrFire(bomb, leftBomb, again, 2) 
                    if toDo > 0 then
                        return 
                    end
                end),cc.DelayTime:create(self.actionTime),cc.CallFunc:create(function ()
                    if again then
                        bomb:onClick(false,self.bombWidthScale,self.bombWidthScale)
                        self:inClick()
                        self.layer:setTouchCaptureEnabled(true)
                        self.isworking = false
                    end
                end),cc.DelayTime:create(self.actionTime + 0.2),cc.CallFunc:create(function()
                    if toDo == 1 then
                        self:flushAfterFire()
                    end
                end),cc.DelayTime:create(0.4 - self.actionTime),cc.CallFunc:create(function()
                    if toDo == 2 then
                        self:flushAfterFire()
                    end
                end)))
        else
            return false
        end
    end
    return true
end

function PlayScene:toUp(bomb,again)
    local toDo = 0
    if bomb then
        if bomb.y < self.yCount  then
            local upBomb = self.matrix[(bomb.y)*self.xCount + bomb.x]
            bomb:runAction(cc.MoveTo:create(self.actionTime,self:positionOfBomb(upBomb.x,upBomb.y)))
            upBomb:runAction(cc.Sequence:create(cc.MoveTo:create(self.actionTime,self:positionOfBomb(bomb.x,bomb.y)),
                cc.DelayTime:create(self.actionTime),cc.CallFunc:create(function ()
                    self.matrix[(bomb.y)*self.xCount + bomb.x] = bomb
                    self.matrix[(bomb.y - 1)*self.xCount + bomb.x] = upBomb
                    bomb.y = bomb.y + 1
                    upBomb.y = upBomb.y - 1
                    toDo = self:checkOrFire(bomb, upBomb, again, 3) 
                    if toDo > 0 then
                        return 
                    end
                end),cc.DelayTime:create(self.actionTime),cc.CallFunc:create(function ()
                    if again then
                        bomb:onClick(false,self.bombWidthScale,self.bombWidthScale)
                        self:inClick()
                        self.layer:setTouchCaptureEnabled(true)
                        self.isworking = false
                    end
                end),cc.DelayTime:create(self.actionTime + 0.2),cc.CallFunc:create(function()
                    if toDo == 1 then
                        self:flushAfterFire()
                    end
                end),cc.DelayTime:create(0.4 - self.actionTime),cc.CallFunc:create(function()
                    if toDo == 2 then
                        self:flushAfterFire()
                    end
                end)))
        else
            return false
        end
    end 
    return true
end

function PlayScene:toDown(bomb,again)
    local toDo = 0
    if bomb then
        if bomb.y > 1 then
            local downBomb = self.matrix[(bomb.y - 2)*self.xCount + bomb.x]
            bomb:runAction(cc.MoveTo:create(self.actionTime,self:positionOfBomb(downBomb.x,downBomb.y)))
            downBomb:runAction(cc.Sequence:create(cc.MoveTo:create(self.actionTime,self:positionOfBomb(bomb.x,bomb.y)),
                cc.DelayTime:create(self.actionTime),cc.CallFunc:create(function ()
                    self.matrix[(bomb.y - 2)*self.xCount + bomb.x] = bomb
                    self.matrix[(bomb.y - 1)*self.xCount + bomb.x] = downBomb
                    bomb.y = bomb.y - 1
                    downBomb.y = downBomb.y + 1
                    toDo = self:checkOrFire(bomb, downBomb, again, 4) 
                    if toDo > 0 then
                        return 
                    end
                end),cc.DelayTime:create(self.actionTime),cc.CallFunc:create(function ()
                    if again then
                        bomb:onClick(false,self.bombWidthScale,self.bombWidthScale)
                        self:inClick()
                        self.layer:setTouchCaptureEnabled(true)
                        self.isworking = false
                    end
                end),cc.DelayTime:create(self.actionTime + 0.2),cc.CallFunc:create(function()
                    if toDo == 1 then
                        self:flushAfterFire()
                    end
                end),cc.DelayTime:create(0.4 - self.actionTime),cc.CallFunc:create(function()
                    if toDo == 2 then
                        self:flushAfterFire()
                    end
                end)))
        else
            return false
        end
    end 
    return true
end

function PlayScene:timeOut()
   self.layer:setTouchCaptureEnabled(false)
    local resultLayer = cc.LayerColor:create(cc.c4b(90,90,90,200),size.width/4*3,size.height/2)
    resultLayer:setTouchCaptureEnabled(true)
    resultLayer:ignoreAnchorPointForPosition(false)
    resultLayer:setAnchorPoint(0.5,0.5)
    resultLayer:setPosition(size.width,size.height/2)
    resultLayer:addTo(self)
    resultLayer:setTouchEnabled(true)
    resultLayer:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.MoveTo:create(1,cc.p(size.width/2,size.height/2))),
        cc.CallFunc:create(function ()
            resultLayer:setTouchCaptureEnabled(true)
        end)))
    resultLayer:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.TintTo:create(3,10,68,88),cc.TintTo:create(3,0,90,40),cc.TintTo:create(3,70,70,10))))

    if self.curScore>self.highScore then
        if (defaults:getBoolForKey(EFFECT_KEY)) then
            AudioEngine.playEffect(EFFECT_AWFUL_FILE)
        end
        self.highScore = self.curScore
        cc.UserDefault:getInstance():setIntegerForKey("HighScore",self.highScore)

        local newRecord = cc.ui.UILabel.new({
            UILabelType = 2, text = "NEW RECORD!!", font="fonts/STENCILSTD.OTF",size = 40})
            :align(display.CENTER, size.width/8*3, size.height/32*9)
            :addTo(resultLayer)
            :runAction(cc.RepeatForever:create(cc.Spawn:create(cc.Sequence:create(cc.TintTo:create(0.5,250,20,20),cc.TintTo:create(0.5,250,200,120)),cc.Blink:create(1, 1))))
        local newHighScore = cc.ui.UILabel.new({
            UILabelType = 2, text = "", font="fonts/STENCILSTD.OTF",size = 40})
            :align(display.CENTER, size.width/8*3, size.height/32*7)
            :addTo(resultLayer)
        newHighScore:setString(string.format("%d Point",self.curScore))
        newHighScore:runAction(cc.RepeatForever:create(cc.Spawn:create(cc.Sequence:create(cc.TintTo:create(0.5,250,20,20),cc.TintTo:create(0.5,250,200,120)),cc.Blink:create(1, 1))))
    else
        if (defaults:getBoolForKey(EFFECT_KEY)) then
            AudioEngine.playEffect(EFFECT_TIME_OUT_FILE)
        end
        cc.ui.UILabel.new({
            UILabelType = 2, text = "", font="fonts/STENCILSTD.OTF",size = 40})
            :align(display.CENTER, size.width/8*3, size.height/4)
            :addTo(resultLayer)
            :setString(string.format("%d Point",self.curScore))
    end

    local timeOutLabel = cc.ui.UILabel.new({
        UILabelType = 2, text = "TIME OUT!", font="fonts/STENCILSTD.OTF",size = 60})
        :align(display.CENTER, size.width/8*3, size.height/8*3)
        :addTo(resultLayer)
    timeOutLabel:setColor(cc.c3b(250, 0, 0))

    local reStartBtnImages = {
       normal = "back_up_2.png",
       pressed = "back_down_2.png"
    }
    cc.ui.UIPushButton.new(reStartBtnImages,{scale9 = false})
       :onButtonClicked(function(event)
           resultLayer:runAction(cc.Sequence:create(cc.EaseBackIn:create(cc.MoveTo:create(1,cc.p(size.width,size.height/2))),
            cc.CallFunc:create(function ()
                if (defaults:getBoolForKey(EFFECT_KEY)) then
                    AudioEngine.playEffect(EFFECT_FILE)
                end
               local mainScene = import("app.scenes.MainScene"):new()
               display.replaceScene(mainScene,"SlideInL",0.5)
            end)))
       end)
       :align(display.CENTER,size.width/8*3,size.height/8)
       :addTo(resultLayer)
end

function PlayScene:onEnterTransitionFinish()
    self:initMatrix()
    self.layer:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT,function (dt)
    end)
    self.layer:scheduleUpdate()
    self.layer:schedule(function ()
        if self.wantStop then
            if not self.isworking and not self.isTimeOut then
                self.wantStop = false
                self:showStopLayer(self.stopGame)
            end
        end
        if not self.isStop then
            if self.time > 10.2 then
                self.time = self.time - 0.1
                self.timeLabel:setString(string.format("%d",self.time))
            elseif self.time <= 10.2 and self.time > 0 then 
                self.time = self.time - 0.1
                if self.time < 0 then
                    self.time = 0
                end
                self.timeLabel:setString(string.format("%.1f",self.time))
                self.timeLabel:setColor(cc.c3b(250, 0, 0))
                self.timeFontLabel:runAction(cc.TintTo:create(0.5,250,0,0))
            else
                if not self.isTimeOut and not self.isworking then
                    self.stopBtn:setButtonEnabled(false)
                    self.isTimeOut = true
                    self:timeOut()
                    -- 没卵用， 停不了
                    -- self.layer:unscheduleUpdate()
                end
            end
        end
        if self.isTimeOut then
            self.stopBtn:setButtonEnabled(false)
        end
    end,0.1,true)
end

function PlayScene:onEnter()
end

function PlayScene:onExit()
end

return PlayScene
