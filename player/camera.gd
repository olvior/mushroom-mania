extends Camera2D

func set_limits(room : Room):
	print(room.extent, room.pos, room.name, room.pos)
	var origin = room.pos * room.block_size
	
	var extent = room.extent * room.block_size / 2
	
	self.limit_left = origin.x - extent.x
	self.limit_right = origin.x + extent.x
	self.limit_top = origin.y - extent.y
	self.limit_bottom = origin.y + extent.y
	
