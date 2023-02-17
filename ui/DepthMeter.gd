extends Label

func _process(delta: float) -> void:
	text = "%d %d %d^" % [Global.depth.x / 100, Global.depth.y / 100, Global.depth.z]
