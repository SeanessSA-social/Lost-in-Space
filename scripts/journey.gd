class_name level_collection extends level
var planet_levels=[]
var space_levels=[]

@export var dialog_box= load("res://scene/dialogue.tscn")
@onready var b=display_dialog()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready() # Replace with function body.
	var children_array = get_children()
	for child in children_array:
		if child is planet_level:
			planet_levels.append(child)
		if child is space_level:
			space_levels.append(child)

func display_dialog():
	var box=dialog_box.instantiate()
	add_child(box)
	box.showtext()
	return box
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	
	
func level0():
	b.push_message("[color=red]Pilot, why did you take us out of the wormhole?[/color]")
	b.push_message("[color=cyan]It's the computer, Captain, it detects obstacles on our path[/color]")
	b.push_message("[color=red]Then we must be close. Take control Pilot, the future of our people is in your hands[/color]")
	await await get_tree().create_timer(2).timeout
func react_to_planet(id):
	if id=="saturn":
		b.push_message("[color=cyan]What is that?[/color]")
		b.push_message("[color=red]It is not EC218. Stay clear of its gravitational pull, we don’t have the fuel to escape it should it seize Genesis. Move too close and we will be stranded forever.[/color]")
	if id=="mercury":
		b.push_message("[color=cyan]That was…close, but the ship will not survive much longer. We have to land… now![/color]")
		b.push_message("[color=red]No, not until we reach EC218. It is our best chance at rebuilding our civilization. Our lives don't matter if the mission is unsuccessful.[/color]")
	if id=="mars":
		b.push_message("[color=cyan]That's it, we are landing here, whatever these godforsaken planets may be, one of them will have to do[/color]")
		b.push_message("[color=red]Never! Disobey me, and you will be landing with a parachute[/color]")
	if id=="earth":
		b.push_message("[color=cyan]Captain, my wife is onboard. I cannot put this ship through another asteroid field, this is madness, it is suicide. Let me land. Please.[/color]")
		b.push_message("[color=red]Pilot, the last hope of our people, are onboard. You will not doom it to an inhospitable planet out of fear, it is cowardice, it is genocide.[/color]")
	if id=="Suerza":
		b.push_message("[color=cyan]Is this… I don't believe it[/color]")
		b.push_message("[color=red]That's EC218 pilot, we are home.[/color]")
	

func play_level(level1):
	level1.play()
	await get_tree().create_timer(level1.level_duration).timeout
	return
func play_journey():
	"a sequence of levels that creates a game"
	print("begin")
	var sl=space_levels.duplicate(false)
	sl.shuffle()
	#is called first, replace with level you want to test
	#await play_level($venus_mars.make_easy())
	#await simple_level3()
	#level 0 -saturn
	var rlevel
	var custom_collection=[intro_level,simple_level1]
	await level0()
	await saturn()

	await play_level($tutorial)
	
	#level 1 -mercury
	await play_level($random_level.make_easy(1))
	await random_simple()
	await play_level($random_level2.make_easy(1))
	rlevel=sl.pop_front()
	await play_level(rlevel)
	await mercury()
	await simple_level4()
	
	#level 2 - mars & venus
	await play_level($random_level.make_easy(1))
	await simple_level1()
	await play_level($random_level2.make_easy(1))
	rlevel=sl.pop_front()
	await play_level(rlevel)
	await mars_venus()
	await simple_level3()
	
	
	#level 3 - earth
	await play_level($random_level.make_easy(2))
	rlevel=sl.pop_front()
	await play_level(rlevel)
	await play_level($random_level2.make_easy(2))
	rlevel=sl.pop_front()
	await play_level(rlevel)
	
	
	await earth()
	await intro_level()
	
	#level 4 - Suerza
	for i in range(0,1):
		await play_level($random_level2.make_normal(2))
		rlevel=space_levels.pick_random()
		await play_level(rlevel)
		await play_level($random_level.make_normal(2))
	await simple_level2()
	await Suerza()
	
	#endless mode (no one would last 30 mins of this)
	for i in range(0,10):
		await random_simple()
		await play_level($random_level2.make_normal(2))
		rlevel=space_levels.pick_random()
		await play_level(rlevel)
		await play_level($random_level.make_normal(2))
	
func random_simple(start_time=0):
	var c=randi_range(0,1)
	if c==0:
		intro_level(start_time)
	else:
		simple_level1(start_time)
func saturn(start_time=0):
	level_duration=50
	print("begin tutorial")
	var pl=self.planet_scene.instantiate()
	pl.setplanet("saturn")
	pl.on_screen.connect(react_to_planet)
	pl.reshape(1.7)
	generate_field(pl,Vector2(50,-self.screen_size.y),PI/2,30,0,0,start_time+5,1,Vector2(100,0),Vector2(0.9,1.1))
	
func mars_venus(start_time=0):
	level_duration=5
	var venus=generate_planet("venus" ,1.5,start_time+0,Vector2(100,-self.screen_size.y/2-100),PI/2,40,Vector2(100,0),Vector2(0.75,1.5))
	var mars=generate_planet("mars" ,1.6,start_time+0,Vector2(1180,-self.screen_size.y/2-100),PI/2,30,Vector2(100,0),Vector2(0.75,1.5))
	mars.on_screen.connect(react_to_planet)
	venus.on_screen.connect(react_to_planet)
	await get_tree().create_timer(level_duration).timeout
func Suerza(start_time=0):
	level_duration=50
	var s=generate_planet("Suerza" ,5,start_time+0,Vector2(X/2,-900),PI/2,20,Vector2(0,0),Vector2(0.9,1.2))
	s.on_screen.connect(react_to_planet)
	await get_tree().create_timer(level_duration).timeout

func earth(start_time=0):
	level_duration=5
	var e=generate_planet("earth" ,1.8,start_time+0,Vector2(100,-self.screen_size.y/2-100),PI/3,50,Vector2(100,0),Vector2(0.9,1.2))
	e.on_screen.connect(react_to_planet)
	await get_tree().create_timer(level_duration).timeout
func simple_level2(start_time=0):
	set_flip()
	level_duration=30
	var huge_asteroid=self.asteroid_scene.instantiate()
	huge_asteroid.reshape(2)
	huge_asteroid.rotation+=0
	huge_asteroid.change_collision()
	generate_field(comet_scene,Vector2(-100,Y/2),0,120,0.6,25,start_time+0,2,Vector2(0,Y/2))
	generate_field(comet_scene,Vector2(-100,Y+100),-PI/7,150,0.6,1,start_time+7,3,Vector2(25,25))
	generate_field(comet_scene,Vector2(-100,Y+100),-PI/7,400,0.1,13,start_time+7.5,7,Vector2(25,25))
	
	if randi_range(0,1)==0 :
		generate_field(comet_scene,Vector2(850,-100),PI/2+PI/10,150,0.6,1,start_time+9,3,Vector2(25,0))
		generate_field(comet_scene,Vector2(850,-100),PI/2+PI/10,400,0.1,8,start_time+9.5,7,Vector2(25,0))
	
		
	generate_field(huge_asteroid,Vector2(X+200,600),PI+PI/10,160,0,0,start_time+11,1,Vector2(0,100),Vector2(0.8,1.3))
	if randi_range(0,1)==0 :
		generate_field(asteroid_scene,Vector2(300,Y+200),-PI/2,150,3,6,start_time+10,1,Vector2(200,0))
	#generate_field(comet_scene,Vector2(100,-100),PI/2,400,0.2,4,start_time+1,3,Vector2(100,0))
	await get_tree().create_timer(level_duration).timeout
	
func simple_level4(start_time=0):
	set_flip()
	level_duration=10
	var huge_asteroid=self.asteroid_scene.instantiate()
	huge_asteroid.reshape(1.5)
	huge_asteroid.rotation+=0
	huge_asteroid.change_collision()
	generate_field(comet_scene,Vector2(+100,Y+100),-PI/3,150,0.6,1,start_time+1,3,Vector2(25,0))
	generate_field(comet_scene,Vector2(+100,Y+100),-PI/3,400,0.1,4,start_time+1.5,7,Vector2(25,0))
	if randi_range(0,1)==0:
		generate_field(comet_scene,Vector2(+300,Y+100),-PI/4,150,0.6,1,start_time+4,3,Vector2(25,0))
		generate_field(comet_scene,Vector2(+300,Y+100),-PI/4,400,0.1,4,start_time+4.5,7,Vector2(25,0))
	generate_field(huge_asteroid,Vector2(-400,100),PI/5.5,170,0,0,start_time+2.5,1,Vector2(0,50),Vector2(0.8,1.3))
	if randi_range(0,1)==0:
		generate_field(comet_scene,Vector2(X+100,360),PI,85,0.6,8,0,2,Vector2(0,360))
	
	
	await get_tree().create_timer(level_duration).timeout
func mercury(start_time=0):
	level_duration=4
	var m=generate_planet("mercury" ,1.8,start_time+0,Vector2(X+400,-400),PI/2+PI/6,120,Vector2(100,100),Vector2(0.9,1.2))
	m.on_screen.connect(react_to_planet)
	await get_tree().create_timer(level_duration).timeout
	
func simple_level3(start_time=0):
	set_flip()
	level_duration=16
	generate_field(comet_scene,Vector2(-100,200),+PI/15,150,0.2,4,start_time+0,4,Vector2(0,100),Vector2(1,2))   
	generate_field(comet_scene,Vector2(X+200,450),+PI-PI/15,150,0.2,6,start_time+5.5,4,Vector2(0,100),Vector2(1,2)) 
	generate_field(comet_scene,Vector2(-100,100),0,150,0.2,6,start_time+5.5,4,Vector2(0,100),Vector2(1,2)) 
	generate_field(asteroid_scene,Vector2(600,-200),PI/2,200,2.5,7.5,start_time+8,1,Vector2(150,0),Vector2(0.8,1.8)) 
	await get_tree().create_timer(level_duration).timeout 
func simple_level1(start_time=0):
	set_flip()
	level_duration=14
	var huge_asteroid=self.asteroid_scene.instantiate()
	huge_asteroid.reshape(3)
	huge_asteroid.rotation+=0
	huge_asteroid.change_collision()
	generate_field(huge_asteroid,Vector2(0-200,720+200),-PI/4,200,0,0,start_time+0,1,Vector2(0,100),Vector2(0.8,1.3))
	generate_field(asteroid_scene,Vector2(X+100,400),PI+PI/10,300,1,3,start_time+2,1,Vector2(0,200))
	#generate_field(comet_scene,Vector2(100,-100),PI/2,400,0.2,4,start_time+1,3,Vector2(100,0))
	await get_tree().create_timer(level_duration).timeout
	


func intro_level(start_time=0):
	level_duration=25
	set_flip()
	print("begin intro level")
	#generate_field(comet_scene,$CometPath,3*PI/4,200,0.4,25,0,3)
	#generate_field(asteroid_scene,$spawnpath,0,100,6,23,6,1)
	#generate_field(asteroid_scene,$sp3,PI,80,0,0,16,1)
	var huge_asteroid=self.asteroid_scene.instantiate()
	huge_asteroid.reshape(1.1)
	huge_asteroid.rotation+=PI
	huge_asteroid.change_collision()
	generate_field(comet_scene,Vector2(730,-200),3*PI/4,200,0.6,20,0,3,Vector2(700,0))
	generate_field(comet_scene,Vector2(1280+200,280),3*PI/4,200,0.6,20,0,3,Vector2(0,370))
	generate_field(asteroid_scene,Vector2(-100,200),PI/50,120,5.5,19,6,1,Vector2(0,100))
	generate_field(huge_asteroid,Vector2(1280+200,250),PI+PI/50,100,0,0,14,1,Vector2(0,150))
	await get_tree().create_timer(level_duration).timeout
	return level_duration
