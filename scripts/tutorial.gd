extends planet_level

# Called when the node enters the scene tree for the first time.

	# Replace with function body.
	#following function was given by AI
func ready():
	super._ready()
func play(start_time=0):
	#set_flip()
	level_duration=50
	print("begin tutorial")
	var saturn=self.planet_scene.instantiate()
	saturn.setplanet("saturn")
	saturn.reshape(1.7)
	generate_field(comet_scene,$up,PI/2,100,1,4,2,1)
	generate_field(comet_scene,$left,PI/8,100,1,8,8,1)
	generate_field(comet_scene,$right,PI,200,0.5,8,21,1)
	generate_field(asteroid_scene,Vector2(500+self.screen_size.x,self.screen_size.y/3),PI,75,8,30,19,1,Vector2(0,400))
	#generate_field(saturn,Vector2(50,-self.screen_size.y),PI/2,30,0,0,5,1,Vector2(100,0),Vector2(0.9,1.1))
	generate_field(self.comet_scene,$up,PI/2,300,0.5,8,31,3)
	generate_field(self.comet_scene,Vector2.ZERO,PI/4,300,0.5,8,37,4,Vector2(300,0))
	#add_child(self.field_scene.instantiate().init(self.comet_scene,Vector2(self.screen_size.x/2,0),PI-PI/4,300,0.5,8,45,4,Vector2(1000,0)))
	#add_child(self.field_scene.instantiate().init(self.comet_scene,Vector2(self.screen_size.x,self.screen_size.y/2),PI-PI/4,300,0.5,8,45,4,Vector2(0,1000)))
	
	#add_child(field_scene.instantiate().init(asteroid_scene,$right,0,80,3,4,8,1))
	#add_child(field_scene.instantiate().init(comet_scene,$left,PI,200,0.5,6,18,1))

	return 0
