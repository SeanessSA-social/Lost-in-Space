extends Area2D
#<a href="https://www.nicepng.com/ourpic/u2q8a9w7w7o0w7q8_explosion-debris-png-visual-arts/" target="_blank">Explosion Debris Png - Visual Arts @nicepng.com</a>
signal lives_changed(current_lives: int)
signal crash
signal hit
signal landing(current_lives: int, planet_id: String)
signal land
@export var speed=400
@export var max_speed=500
@export var impulse=1000
@export var boostspeed=2
@export var max_lives: int = 3
@export var break_acce_mult= 3
@export var inertia=false
@export var auto_break_mult=0.0
@export var break_acce_mult_angle=-0.5
var boost_state=0 #0 = ready, 1=active, 2=cooldown
var lives: int = 3
var invulnerable := false
var screen_size
#https://www.seekpng.com/ima/u2q8a9i1r5r5e6a9/
var boostvel=Vector2.ZERO
var current_velocity=Vector2.ZERO
var in_intro=false

@onready var anim: AnimationPlayer = $AnimationPlayer
var has_landed := false
var planet_landed_on 
var manual_shield=false
var hit_shield=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.z_index=-3
	$AnimatedSprite2D.animation="fly"
	$AnimatedSprite2D/shield.animation="off"
	$AnimatedSprite2D/explosion.animation="off"
	lives = max_lives
	emit_signal("lives_changed", lives)
	hide()
	screen_size= get_viewport_rect().size # Replace with function body.


func controls_simple(delta):
	var velocity =Vector2.ZERO
	if Input.is_action_pressed("move_down"):
		velocity.y+=1
	if Input.is_action_pressed("move_up"):
		velocity.y-=1
	if Input.is_action_pressed("move_left"):
		velocity.x-=1
	if Input.is_action_pressed("move_right"):
		velocity.x+=1
	if velocity.length() > 0:
		velocity=velocity.normalized() *speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	velocity+=boost(velocity)
	return velocity*delta
func control_shield():
	if manual_shield or hit_shield:
		$AnimatedSprite2D/shield.animation="on"
		$AnimatedSprite2D.play()
		invulnerable=true
	else:
		invulnerable=false
		$AnimatedSprite2D/shield.animation="off"
		$AnimatedSprite2D.play()
func check_shield():
	if Input.is_action_pressed("shield"):
		manual_shield=true
	else:
		manual_shield=false
	control_shield()
		
func control_intertia(delta):
	var acccel =Vector2.ZERO
	check_shield()
	if Input.is_action_pressed("move_down"):
		acccel.y+=1
	if Input.is_action_pressed("move_up"):
		acccel.y-=1
	if Input.is_action_pressed("move_left"):
		acccel.x-=1
	if Input.is_action_pressed("move_right"):
		acccel.x+=1
	if acccel.length() > 0:
		acccel=acccel.normalized() *impulse
		$AnimatedSprite2D.play()
	else:
		current_velocity*=(1-auto_break_mult)
		$AnimatedSprite2D.stop()
	if (current_velocity.normalized()).dot(acccel.normalized())<-break_acce_mult_angle:
		acccel*=break_acce_mult
		#greater acceleration when it is oposite to current velocity. Tun faster
	current_velocity+=acccel*delta
	if current_velocity.length() > max_speed:
		current_velocity = current_velocity.normalized() * max_speed
	current_velocity = boost(acccel)/3+current_velocity
	return current_velocity*delta
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if in_intro:
		var acccel=Vector2(0,250)
		current_velocity+=acccel*delta
		position+=current_velocity*delta
	elif has_landed:
		var velocity
		if is_instance_valid(planet_landed_on):
			velocity=planet_landed_on.position-position
		else:
			velocity=Vector2.ZERO
		velocity=velocity.normalized() *speed/2
		position+=velocity*delta
		position=position.clamp(Vector2.ZERO,screen_size)
	else:
		var newp
		if inertia:
			newp=control_intertia(delta)
		else:
			newp=controls_simple(delta)
		position+=newp
		position=position.clamp(Vector2.ZERO,screen_size)

func boost(velocity):
	if boost_state==0:
		if Input.is_action_pressed("boost") and velocity!=Vector2.ZERO:
			$boostactive.start()
			boostvel=velocity*boostspeed
			boost_state=1
			return boostvel
	if boost_state==1:
		return boostvel
	if boost_state==2:
		boostvel=Vector2.ZERO
		return boostvel
	return boostvel
	
func _on_body_entered(body: Node2D) -> void:
	
	
	# body: the object that hits the spaceship
	#print(body.get_name()) # prints the name of the class!
	body.collision_with_spacceship(self)
	#print(position)
	#position=position.clamp(position-Vector2(0,150),screen_size)

	#print(position)
	#hide()
	#hit.emit()
	#$CollisionShape2D.set_deferred("disabled",true)	
	
	
func recoil():
	$AnimatedSprite2D/shield.animation="on"
	$AnimatedSprite2D.play()
	hit_shield=true
	invulnerable=true
	print("recoil!!!!!")
	position=position+Vector2(0,5) # recoil after hit
	position=position.clamp(Vector2.ZERO,screen_size)
	await get_tree().create_timer(0.6).timeout
	hit_shield=false
	invulnerable=false
	$AnimatedSprite2D/shield.animation="off"
	$AnimatedSprite2D.play()
	
	
func	 start(pos):
	position =pos
	invulnerable=true
	show()
	$CollisionShape2D.disabled=false 
	in_intro=true
	current_velocity=Vector2(0,-500)
	await get_tree().create_timer(2).timeout
	invulnerable=false
	in_intro=false
	
func got_hit():

	if invulnerable:
		print("shield block")
		return
	
	lives -= 1
	emit_signal("lives_changed", lives)
	_say_health_lost()
	print("lives Left: ", lives)
		
	if lives <= 0:
		crashed()
	else:
		#recoil()
		hit.emit()
		recoil()


func _say_health_lost() -> void:
	var dlg := load("res://Dialogue/health_loss.dialogue")
	if dlg == null:
		push_error("could not load dialogue:res://Dialogue/health_loss.dialogue ")
		
	var balloon := DialogueManager.show_dialogue_balloon(dlg, "start")


	
func crashed():
	
	
	if invulnerable:
		print("shield block")
		return
	lives = 0
	emit_signal("lives_changed", lives)
	await explode()
	crash.emit()
func explode():
	set_process(false)
	set_physics_process(false)
	$AnimatedSprite2D.animation="off"
	$AnimatedSprite2D/shield.animation="off"
	$AnimatedSprite2D/explosion.animation="explode2"
	anim.play("explosion")
	await  anim.animation_finished
	
	
	
func landed(planet_id,planet):
	planet_landed_on=planet
	if has_landed:
		return
	has_landed = true
	
	#freeze control while anim plays
	#set_process(false)
	set_physics_process(false)
	
	anim.play("planet_bump")
	await  anim.animation_finished
	
	landing.emit(lives,planet_id)
	print("landing on ",planet_id,"with ",lives,"lives")

	
func haha():
	show()
	$CollisionShape2D.disabled=false 
	


func _on_boostactive_timeout() -> void:
	boostvel=Vector2.ZERO
	boost_state=2 
	$boostcooldown.start()# Replace with function body.


func _on_boostcooldown_timeout() -> void:
	boost_state=0  # Replace with function body.
