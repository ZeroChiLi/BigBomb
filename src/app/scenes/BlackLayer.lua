local BlackLayer = class("BlackLayer",function(width,height)
	local layer = cc.LayerColor:create(cc.c4b(0,0,0,120),width,height)
	return layer
end)

return BlackLayer