
Bomb = import("app.scenes.Bomb")

local Toast= class("Toast",function(id)
	id = id or 1
    local bg = display.newSprite("bomb/Score_background_0.png")
    bg.id = id 
    if bg.id < 10 then
        bg = display.newSprite("bomb/Score_background_"..id..".png")
    elseif bg.id == 10 then
        bg = display.newSprite("bomb/Score_background_0.png")
    elseif bg.id == 30 then
    	bg = display.newSprite("line_hor_3.png")
	elseif bg.id == 40 then
    	bg = display.newSprite("line_ver_3.png")
    end 
    return bg
end)

function Toast:ctor()
    local width = Bomb.getWidth()
    self.show_score = cc.ui.UILabel.new({
        UILabelType = 2, text = "", font="fonts/STENCILSTD.OTF",size = 30})
        :align(display.CENTER, width/2, width/2)
        :addTo(self)
end

function Toast:addToast(str)
    self.show_score:setString(str)
end

return Toast