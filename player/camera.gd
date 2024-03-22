extends Camera2D

@onready var block_size = Global.block_size

func set_limits(room : Room):
	print(room.extent, room.pos)
	var origin = room.pos * block_size
	
	var extent = room.extent * block_size / 4
	
	self.limit_left = origin.x - extent.x
	self.limit_right = origin.x + extent.x
	self.limit_top = origin.y - extent.y
	self.limit_bottom = origin.y + extent.y
	
