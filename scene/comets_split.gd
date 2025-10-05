extends RigidBody2D

# ------------ Spawning settings ------------
@export var comet_scene: PackedScene					# Point this to the comet's own .tscn (left empty -> auto-load self)
@export var spawn_children: bool = true				# Enable radial spawning
@export var burst_count: int = 8						# Number of mini-comets per burst
@export var spawn_interval: float = 1.3				# Seconds between bursts
@export var child_scale: float = 0.35					# Scale multiplier for mini-comets
@export var child_speed: float = 650.0					# Initial speed of mini-comets
@export var inherit_parent_velocity: bool = true		# Add parent velocity to children
@export var initial_angle_deg: float = 0.0				# Starting angle (degrees) of the burst pattern
@export var max_generation: int = 1					# 0: no spawn; 1: only parent spawns; 2: children spawn once, etc.
var generation: int = 0								# Current generation (parent = 0)

# ------------ Cached nodes ------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_explode: AnimatedSprite2D = $AnimatedSprite2D/explode
@onready var col: CollisionShape2D = $CollisionShape2D
@onready var vis: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var anim: AnimationPlayer = $AnimationPlayer

var _spawn_timer: Timer

func _ready() -> void:
	# Visual setup
	z_index = -2
	if sprite:
		sprite.animation = "fall"
		sprite.play()
	if sprite_explode:
		sprite_explode.animation = "off"

	# Auto-fallback: if comet_scene not assigned in Inspector, load this scene itself
	if comet_scene == null:
		var path := scene_file_path
		if path != "":
			comet_scene = load(path)

	# Create a repeating timer only if this comet is allowed to spawn children
	if spawn_children and generation < max_generation:
		_spawn_timer = Timer.new()
		_spawn_timer.wait_time = spawn_interval
		_spawn_timer.one_shot = false
		_spawn_timer.autostart = true
		add_child(_spawn_timer)
		_spawn_timer.timeout.connect(_spawn_burst)

# Uniformly scale the root (safe even if called before _ready)
# Multiplicative: call once per instance
func reshape(scale_mult: float) -> void:
	scale *= scale_mult

# Emit a ring of mini-comets
func _spawn_burst() -> void:
	if comet_scene == null:
		return

	var base_vel: Vector2 = linear_velocity if inherit_parent_velocity else Vector2.ZERO
	var start_angle := deg_to_rad(initial_angle_deg)

	for i in range(burst_count):
		var angle := start_angle + TAU * (float(i) / float(burst_count))
		var dir := Vector2.UP.rotated(angle)

		var child_comet := comet_scene.instantiate() as RigidBody2D
		get_parent().add_child(child_comet)
		child_comet.global_position = global_position

		# Propagate spawning rules to the child
		child_comet.generation = generation + 1
		child_comet.max_generation = max_generation
		child_comet.spawn_children = (generation + 1) < max_generation

		# Scale after the child is in the tree (deferred: avoids race with _ready/onready)
		child_comet.call_deferred("reshape", child_scale)

		# Initial velocity
		child_comet.linear_velocity = dir * child_speed + base_vel

		# Prevent immediate collision between parent and child
		child_comet.add_collision_exception_with(self)
		add_collision_exception_with(child_comet)

# Despawn when leaving the screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

# Compatibility: spaceship calls this on hit (kept original misspelling to match your usage)
func collision_with_spacceship(ship) -> void:
	if ship and ship.has_method("got_hit"):
		ship.got_hit()
	explode()

# Optional correct-spelling alias
func collision_with_spaceship(ship) -> void:
	collision_with_spacceship(ship)

# Explode on rigid body impact (adjust as needed)
func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D:
		explode()

# Play explosion animation and free
func explode() -> void:
	linear_velocity = Vector2.ZERO
	if col:
		col.set_deferred("disabled", true)
	if sprite:
		sprite.animation = "off"
	if sprite_explode:
		sprite_explode.animation = "explode2"
	if anim:
		anim.play("explode")
		await anim.animation_finished
	queue_free()
