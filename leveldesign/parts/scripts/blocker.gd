extends StaticBody2D

@export var collision_shape : CollisionShape2D

func close():
	self.collision_layer = 1
