extends RigidBody2D
@export var id="null"
signal on_screen(planet_id: String)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.z_index=-10
	setplanet(id)
	$AnimatedSprite2D.play() # Replace with function body.

func setplanet(name):
	if name == "null":
		var comet_types =Array($AnimatedSprite2D.sprite_frames.get_animation_names())
		id=comet_types.pick_random()
	else:
		id=name
	$AnimatedSprite2D.animation=id


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reshape(scale):
	$VisibleOnScreenNotifier2D.scale*=scale
	$AnimatedSprite2D.scale*=scale
	$CollisionShape2D.scale*=scale

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() # Replace with function body.

func collision_with_spacceship(ship) -> void:
	print("landing")
	ship.landed(id,self)
	#hide()
	#queue_free()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	print("planet ",id," is on screen")
	on_screen.emit(id) # Replace with function body.
