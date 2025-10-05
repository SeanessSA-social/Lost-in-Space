extends Node2D

# ===== 可调参数 =====
@export var debug = false;

@export var thrust_accel: float = 500.0      # 推进加速度（W）
@export var brake_accel: float = 600.0       # 减速/反推（S）
@export var turn_speed_deg: float = 180.0    # A/D 旋转角速度（度/秒）
@export var max_speed: float = 600.0         # 最高速度（像素/秒）
@export var drift_damping: float = 0.0       # 漂移阻尼（0 = 纯真空；0.5~1 有轻微阻力）

# ===== 运行时变量 =====
var velocity: Vector2 = Vector2.ZERO
var ship_radius := 14.0                      # 用于屏幕环绕与绘制尺度

func _ready() -> void:
	# 初始朝向向上（Godot 的 up 是 -Y）
	rotation = 0.0

func _physics_process(delta: float) -> void:
	_handle_input(delta)
	_integrate_motion(delta)
	#_wrap_around_screen()

	queue_redraw()

func _handle_input(delta: float) -> void:
	# 转向
	var turn_input := 0.0
	if Input.is_action_pressed("turn_left"):
		turn_input -= 1.0
	if Input.is_action_pressed("turn_right"):
		turn_input += 1.0
	rotation_degrees += turn_input * turn_speed_deg * delta

	# 前向单位向量（船头方向）
	var forward := Vector2.UP.rotated(rotation)

	# 推进（W）
	if Input.is_action_pressed("thrust"):
		velocity += forward * thrust_accel * delta

	# 刹车/反推（S）：沿当前速度方向施加相反加速度
	if Input.is_action_pressed("brake") and velocity.length() > 0.0:
		var vdir := velocity.normalized()
		# 既可以纯“粘性刹车”，也可以带一点反向推力感
		velocity -= vdir * brake_accel * delta
		# 防止超反向导致抖动
		if velocity.dot(vdir) < 0.0:
			velocity = Vector2.ZERO

	# 最高速度限制
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	# 轻微空间阻尼（非物理真空，为了更好手感）
	if drift_damping > 0.0:
		velocity = velocity.lerp(Vector2.ZERO, clamp(drift_damping * delta, 0.0, 1.0))

func _integrate_motion(delta: float) -> void:
	position += velocity * delta

func _wrap_around_screen() -> void:
	# 简易屏幕环绕（越界从另一侧出现）
	var viewport := get_viewport_rect().size
	var x := position.x
	var y := position.y
	if x < -ship_radius: x = viewport.x + ship_radius
	if x > viewport.x + ship_radius: x = -ship_radius
	if y < -ship_radius: y = viewport.y + ship_radius
	if y > viewport.y + ship_radius: y = -ship_radius
	position = Vector2(x, y)

func _draw() -> void:
	# 画一个指向“上方”的小三角形作为飞船
	# 局部坐标系中，正上方是 -Y
	var tip    := Vector2(0, -ship_radius)
	var left   := Vector2(-ship_radius * 0.6,  ship_radius * 0.7)
	var right  := Vector2(ship_radius * 0.6,   ship_radius * 0.7)
	draw_colored_polygon([tip, left, right], Color(1, 1, 1, 1))

	# 速度矢量（可视化，便于调试）
	if velocity.length() > 1.0 && debug:
		draw_line(Vector2.ZERO, velocity * 0.1, Color(0.4, 0.8, 1.0, 0.8), 2.0)

	# 推进火焰（按 W 时闪一下）
	if Input.is_action_pressed("thrust"):
		var flame_len: float = clamp(velocity.length() / max_speed, 0.15, 1.0) * ship_radius * 0.9
		var base_left  := (left + tip) * 0.5
		var base_right := (right + tip) * 0.5
		var back       := Vector2(0, ship_radius * 0.9 + flame_len)
		draw_colored_polygon([base_left, base_right, back], Color(1.0, 0.6, 0.2, 0.9))
