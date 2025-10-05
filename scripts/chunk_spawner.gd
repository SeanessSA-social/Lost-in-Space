extends Node2D

@export var chunk_height: float = 720.0        # 每段统一高度
@export var spawn_ahead: int = 4                # 相机前方预铺段数
@export var cull_behind: int = 3                # 相机后方保留段数
@export var chunk_scenes: Array[PackedScene]    # 可随机选择的分段
@export var use_fixed_length: bool = false      # 是否自定义尽头
@export var total_chunks: int = 30              # 自定义尽头总段数（含起始）
@export var goal_scene: PackedScene             # 终点段（可选）

var _camera: Camera2D
var _active: Array[Node2D] = []
var _next_top_y: float
var _spawned: int = 0

func _ready():
	_camera = get_viewport().get_camera_2d()
	if _camera == null:
		push_warning("No Camera2D set to Current.")
	_next_top_y = global_position.y
	_fill_front(true)

func _process(_dt):
	if _camera == null:
		return
	_fill_front()
	_cull_back()

func _fill_front(initial := false) -> void:
	var cam_y := _camera.global_position.y
	var target := cam_y - float(spawn_ahead) * chunk_height
	while _next_top_y - chunk_height > target:
		if use_fixed_length and _spawned >= total_chunks - 1:
			if goal_scene:
				_spawn_goal()
			break
		_spawn_one()
	if initial:
		while _active.size() < (spawn_ahead + cull_behind + 1):
			_spawn_one()

func _spawn_one() -> void:
	if chunk_scenes.is_empty():
		push_error("chunk_scenes is empty")
		return
	var ps := chunk_scenes[randi() % chunk_scenes.size()]
	var inst := ps.instantiate() as Node2D
	add_child(inst)
	_next_top_y -= chunk_height
	inst.global_position = Vector2(global_position.x, _next_top_y + chunk_height * 0.5)
	_active.append(inst)
	_spawned += 1

func _spawn_goal() -> void:
	var inst := goal_scene.instantiate() as Node2D
	add_child(inst)
	_next_top_y -= chunk_height
	inst.global_position = Vector2(global_position.x, _next_top_y + chunk_height * 0.5)
	_active.append(inst)
	_spawned += 1
	use_fixed_length = false   # 放完终点就停

func _cull_back() -> void:
	var cam_y := _camera.global_position.y
	var line := cam_y + float(cull_behind) * chunk_height
	var i := 0
	while i < _active.size():
		var c := _active[i]
		var bottom := c.global_position.y + chunk_height * 0.5
		if bottom > line:
			c.queue_free()
			_active.remove_at(i)
			continue
		i += 1
