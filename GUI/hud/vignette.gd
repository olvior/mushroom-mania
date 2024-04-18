extends ColorRect

var dark = 1
var light = 0.2

func darken():
	material.set_shader_parameter("menu", true)
	material.set_shader_parameter("alpha", dark)

func lighten():
	material.set_shader_parameter("menu", false)
	material.set_shader_parameter("alpha", light)
