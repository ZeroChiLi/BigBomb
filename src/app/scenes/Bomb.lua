STATE_NORMAL = -1
STATE_HOR = 3
STATE_VER = 4
STATE_BOOM = 5
STATE_KING = 10

local Bomb = class("Bomb",function(x,y,bombIndex)
    bombIndex = bombIndex or math.round(math.random()*1000)%5+1
	local sprite = display.newSprite("#BOMB"..bombIndex..'_1.png')
	sprite.bombIndex = bombIndex
	sprite.x = x
	sprite.y = y
	sprite.isActive = false
	sprite.isOnclick = false
	sprite.state = STATE_NORMAL
	sprite.life = 1
	return sprite
end)

function Bomb:onClick(isOnclick,scale_x,scale_y)
	self:setScale(scale_x,scale_y)
	self.isOnclick = isOnclick
	local frame 
	if (self.state == STATE_NORMAL) then
		if (isOnclick) then
	        frame = display.newSpriteFrame("BOMB"..self.bombIndex..'_2.png')
		else
	        frame = display.newSpriteFrame("BOMB"..self.bombIndex..'_1.png')
		end
		self:setSpriteFrame(frame)
	end
	if isOnclick then
		self:stopAllActions()
		local scaleTo1 = cc.ScaleTo:create(0.1,1.1)
		local scaleTo2 = cc.ScaleTo:create(0.05,1.0)
		self:runAction(cc.Sequence:create(scaleTo1,scaleTo2))
	end
end

function Bomb:setActive()
	if not self.isActive then
		self.isActive = true
		self.life = self.life - 1
	end
end

function Bomb:setState(state)
	self.state = state
	self.life = 2
	local frame
	if state == STATE_KING then
		frame = display.newSpriteFrame("BOMB0.png")
		self.bombIndex = 10
	else
	    frame = display.newSpriteFrame("BOMB"..self.bombIndex..'_'..state..'.png')
	end
	self:setSpriteFrame(frame)
end


function Bomb.getWidth()
	g_bombWidth = 0
	if 0 == g_bombWidth then
		local sprite = display.newSprite("bomb/BOMB1_1.png")
		g_bombWidth = sprite:getContentSize().width
	end
	return g_bombWidth
end


return Bomb