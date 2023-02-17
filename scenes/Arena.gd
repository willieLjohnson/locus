extends Node2D

export(Array, PackedScene) var enemies
export(Array, PackedScene) var bosses
export(Array, PackedScene) var powerups


onready var topLeft = $Camera2D/Limits/TopLeft
onready var bottomRight = $Camera2D/Limits/BottomRight

const boss_wave = 5
var current_wave: int = 1
var wave_max_enemies: int = 8
var boss_wave_max_enemies: int  = 1
var wave_enemies_spawned: int  = 0
var wave_enemies_left: int = wave_max_enemies
var is_boss_wave = false

signal update_wave

func _ready() -> void:
	randomize()
	Global.node_creation_parent = self
	Global.score = 0
	Global.is_player_dead = false
	var wave_label = $UI/Container/CanvasLayer/Labels/WaveContainer/CurrentWave
	self.connect("update_wave", wave_label, "update_wave")
	
	var canvas = get_canvas_transform()
	var top_left = -canvas.origin / canvas.get_scale()
	var size = get_viewport_rect().size / canvas.get_scale()
	var move_joystick = $UI/Container/Joysticks/MoveJoystick
	var shoot_joystick = $UI/Container/Joysticks/ShootJoystick
	move_joystick.position = Vector2(130, size.y - 100)
	shoot_joystick.position = Vector2(size.x - 130, size.y - 100)
	
func _process(_delta: float) -> void:
#	if Global.is_player_dead:
#		$UI/Container/CanvasLayer/Labels/HighScore.visible = true
	Global.depth.z = current_wave
	
func _exit_tree() -> void:
	Global.node_creation_parent = null


func _get_distance_from_player(position) -> float:
	return (position - global_position).length()
	
func _get_position_near_player(max_range) -> Vector2:
	var player_position = Global.player.global_position
	return Vector2(rand_range(player_position.x - max_range, player_position.x + max_range),
									rand_range(player_position.y - max_range, player_position.y + max_range))
				
func _spawn_random_enemy_at(position):
	var rand_enemy_index = round(rand_range(0, enemies.size() - 1))
	rand_enemy_index = clamp(rand_enemy_index, 0, current_wave - 1)
	Global.instance_node(enemies[rand_enemy_index], position, self)
	wave_enemies_spawned += 1

func _spawn_random_boss_at(position):
	var rand_boss_index = round(rand_range(0, bosses.size() - 1))
	var boss = Global.instance_node(bosses[rand_boss_index], position, self)
	boss.health *= current_wave / 5
	boss.score_value *= current_wave / 5
	$EnemySpawnTimer.paused = true
	wave_enemies_spawned += 1
							
func _on_EnemySpawnTimer_timeout() -> void:
	var max_range = 1000
	var min_distance = 20
	
	var enemy_position = _get_position_near_player(max_range)
	if _get_distance_from_player(enemy_position) <= 20:
		enemy_position += Vector2(min_distance, min_distance)
		
	# NORMAL ENEMY SPAWN
	if wave_enemies_spawned < wave_max_enemies and !is_boss_wave:
		_spawn_random_enemy_at(enemy_position)
	# BOSS SPAWN
	elif is_boss_wave and wave_enemies_spawned < wave_max_enemies:
		_spawn_random_boss_at(enemy_position)
	else:
		$DifficultyTimer.paused = true

func enemy_died(position) -> void:
	wave_enemies_left -= 1
	
	if wave_enemies_left == 0:
		new_wave()
	else:
		var enemies_left_label = Global.instance_popup_label(Vector2.ZERO,
								 str(wave_enemies_left), Color.whitesmoke, 15, Global.player)
		enemies_left_label.scale = Vector2(4, 4)
func new_wave() -> void:
	var new_wave_label = Global.instance_popup_label(Global.player.global_position, "NEW WAVE", Color.yellowgreen, 30)
	new_wave_label.scale = Vector2(5, 5)
	current_wave += 1
	is_boss_wave = current_wave % boss_wave == 0
	if is_boss_wave:
		wave_max_enemies = boss_wave_max_enemies
		new_wave_label.text = "BOSS WAVE"
		new_wave_label.scale = Vector2(7, 7)
		new_wave_label.modulate = Color.crimson
	else: 
		wave_max_enemies += 5 + (1.2 * current_wave)
	wave_enemies_spawned = 0
	wave_enemies_left = wave_max_enemies
	emit_signal("update_wave", current_wave, is_boss_wave)
	$DifficultyTimer.paused = false
	$EnemySpawnTimer.paused = false
	
func _on_DifficultyTimer_timeout() -> void:
	if 	$EnemySpawnTimer.wait_time > 1 - (current_wave * 0.02):
		$EnemySpawnTimer.wait_time -= 0.010


func _on_PowerupSpawnTimer_timeout() -> void:
	var powerup_position = _get_position_near_player(100)
	if _get_distance_from_player(powerup_position) < 10:
		powerup_position += Vector2(10,10)
		
	var rand_powerup_index = round(rand_range(0, powerups.size() - 1))
	Global.instance_node(powerups[rand_powerup_index], powerup_position, self)

func _notification(what) -> void:
#	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
#		$UI/Control/Pause.hide()
#		get_tree().paused = false

	if what == MainLoop.NOTIFICATION_APP_PAUSED:
		Global.save_game()
		get_tree().paused = true
		$UI/Container/PauseLayer/Pause.show()
		
	if what == MainLoop.NOTIFICATION_APP_RESUMED:
		get_tree().paused = false

	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT or what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		Global.save_game()
		$UI/Container/PauseLayer/Pause.show()
		get_tree().paused = true
	
