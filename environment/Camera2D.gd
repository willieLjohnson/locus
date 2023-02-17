extends Camera2D

var screen_shake_started = false
var shake_intensity = 0
var zoom_factor = 0.015
var velocity_factor = 1
var acceleration_factor = 0
var damp = 0.3
var shake_damp = 0.0025

onready var base_zoom = zoom

func _ready() -> void:
	Global.camera = self
	
func _exit_tree() -> void:
	Global.camera = null
	
func _process(delta: float) -> void:
	velocity_factor = lerp(velocity_factor, (1 + (Global.player.velocity.length() / Global.player.MAX_SPEED)), 0.1)
	var velocity_zoom = base_zoom * velocity_factor
	var velocity_damp = Global.player.velocity.length() / Global.player.MAX_SPEED
	zoom = lerp(zoom, velocity_zoom, 0.2 + (damp * velocity_damp))
#	rotation = lerp(rotation, 0, 0.01)


	
func screen_shake(intensity, time):
	return
#	if intensity > shake_intensity:
#		shake_intensity = intensity
#		rotation = rand_range(-shake_intensity * shake_damp, shake_intensity * shake_damp)
#		$ScreenShakeTime.wait_time = time
#		$ScreenShakeTime.start()
#		screen_shake_started = true

func _on_ScreenShakeTime_timeout() -> void:
	screen_shake_started = false
	shake_intensity = 0
