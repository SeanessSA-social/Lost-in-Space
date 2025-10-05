extends Node
@export var comet_scene: PackedScene
@export var asteroid_scene: PackedScene
@export var field_scene: PackedScene
@export var planet_scene= load("res://scene/planet.tscn")


# XX
@onready var hud = $HUD
@onready var ship = $Spaceship
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer

const CUT_DIR := "res://assets/CutScenes/"
const DEFAULT_CUT := "P1_P2_P4_3_2_1.ogv"

var planet_levels=[]
var space_levels=[]
var score
signal reset
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var children_array = get_children()
	for child in children_array:
		if child is planet_level:
			planet_levels.append(child)
		if child is space_level:
			space_levels.append(child)
	$TextureRect.z_index=-11
	ship.connect("land", Callable(self, "_on_ship_landed"))
	new_game() # Replace with function body.


	#hud.init_lives(ship.lives)
	
	# Initialize HUD text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	#reset.emit()
func play_level(level1):
	level1.play()
	await get_tree().create_timer(level1.level_duration).timeout
	return
func play_game_1():
	"a sequence of levels that creates a game"
	print("begin")
	#is called first, replace with level you want to test
	#await play_level($venus_mars.make_easy())
	await play_level($level4.make_easy())
	var rlevel
	for i in range(0,10):
		rlevel=space_levels.pick_random()
		await play_level(rlevel)
		#await play_level($random_level2.make_easy())
		#await play_level($random_level.make_easy())

func new_game():
	score=0
	$Spaceship.start($StartPosition.position)
	$StartTimer.start()
	$journey.play_journey()

#func _on_spaceship_hit() -> void:
	#print("11111111")
	#reset.emit()
	#score=0
	#$Spaceship.haha()
	#$Spaceship.start($StartPosition.position) 
	#get_tree().call_group("comets2", "queue_free")


func _on_score_timer_timeout() -> void:
	score+=1 # Replace with function body.

func _on_start_timer_timeout() -> void:
	$ScoreTimer.start()

func _on_spaceship_crash() -> void:
	get_tree().call_deferred("change_scene_to_file","res://scene/game_over.tscn")
	print("death") # Replace with function body.


func _cutscene_path(planet_id: String, current_lives: int) -> String:
	var id := planet_id.to_lower()
	var life := clampi(current_lives, 1, 3)
	match id:
		"earth", "earth2":
			return CUT_DIR + "P3_%d.ogv" % life
		"Suerza":
			return CUT_DIR + "P5_%d.ogv" % life
		_:
			return CUT_DIR + DEFAULT_CUT

func _on_spaceship_landing(current_lives: int, planet_id: String) -> void:
	print("successful landing on planet ", planet_id, " with ", current_lives, " current lives")

	# Load and play the appropriate cutscene
	var cut_path := _cutscene_path(planet_id, current_lives)
	var stream := load(cut_path)
	if is_instance_valid(video_stream_player) and stream:
		video_stream_player.loop = false
		video_stream_player.stream = stream
		video_stream_player.play()
		await video_stream_player.finished

	# Proceed based on lives after the video finishes (or immediately if no stream)
	if current_lives == 2:
		get_tree().call_deferred("change_scene_to_file", "res://scene/intro_scene.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://scene/game_over.tscn")
