class_name level extends Node2D
@export var comet_scene= load("res://scene/comets.tscn")
@export var asteroid_scene= load("res://scene/asteroid.tscn")
@export var field_scene= load("res://scene/spaceobjectsingle.tscn")
@export var planet_scene= load("res://scene/planet.tscn")
#https://nineplanets.org/planets-transparent-background/
@export var screen_size=Vector2.ZERO
var flip_b=0
var X
var Y
var level_duration=35
var dif_level=2
var asteroid_preset={
	#"path":$asteroid_spawn,
	"pathc_min":0,"pathc_max":1,"pathl_min":0.04,"pathl_max":0.2,
							"speed_min":90,"speed_max":180,"refire_min":1,"refire_max":4,
							"duration_min":5,"duration_max":20,
							"num_min":1,"num_max":1,"Svar":Vector2(0.5,2)
	
}

var comet_preset={
	#"path":$comet_spawn,
	"pathc_min":0,"pathc_max":1,"pathl_min":0.01,"pathl_max":0.1,
							"speed_min":200,"speed_max":400,"refire_min":0.1,"refire_max":0.5,
							"duration_min":2,"duration_max":8,
							"num_min":2,"num_max":5,"Svar":Vector2(0.5,2)
	
}
var comet_preset_narrow={
	#"path":$comet_spawn,
	"pathc_min":0,"pathc_max":1,"pathl_min":0.01,"pathl_max":0.03,
							"speed_min":300,"speed_max":400,"refire_min":0.1,"refire_max":0.5,
							"duration_min":2,"duration_max":8,
							"num_min":3,"num_max":5,"Svar":Vector2(0.5,2)
	
}
var comet_preset_wide={
	#"path":$comet_spawn,
	"pathc_min":0,"pathc_max":1,"pathl_min":0.05,"pathl_max":0.15,
							"speed_min":100,"speed_max":180,"refire_min":0.2,"refire_max":0.6,
							"duration_min":5,"duration_max":8,
							"num_min":1,"num_max":3,"Svar":Vector2(0.5,2)
	
}

func make_easy(dif=2):
	dif_level=dif
	asteroid_preset={
	"path":$asteroid_spawn,
	"pathc_min":0,"pathc_max":1,"pathl_min":0.04,"pathl_max":0.2,
							"speed_min":90,"speed_max":150,"refire_min":1.5,"refire_max":4,
							"duration_min":5,"duration_max":18,
							"num_min":1,"num_max":1,"Svar":Vector2(0.5,2)
	
	}

	comet_preset={
	"path":$comet_spawn,
	"pathc_min":0,"pathc_max":1,"pathl_min":0.01,"pathl_max":0.1,
							"speed_min":180,"speed_max":280,"refire_min":0.2,"refire_max":0.6,
							"duration_min":2,"duration_max":8,
							"num_min":2,"num_max":5,"Svar":Vector2(0.7,1.4)
	
	}	
	comet_preset_narrow={
	"path":$comet_spawn,
	"pathc_min":0,"pathc_max":1,"pathl_min":0.01,"pathl_max":0.04,
							"speed_min":280,"speed_max":350,"refire_min":0.1,"refire_max":0.5,
							"duration_min":2,"duration_max":8,
							"num_min":3,"num_max":5,"Svar":Vector2(0.7,1.4)
	
		}
	comet_preset_wide={
	"path":$comet_spawn,
	"pathc_min":0,"pathc_max":1,"pathl_min":0.03,"pathl_max":0.15,
							"speed_min":75,"speed_max":120,"refire_min":0.2,"refire_max":0.6,
							"duration_min":5,"duration_max":10,
							"num_min":1,"num_max":3,"Svar":Vector2(0.7,1.4)
	}
	print("make easy")
	return self
func make_normal(dif=2):
	dif_level=dif
	asteroid_preset={
	"path":$asteroid_spawn,
	"pathc_min":0,"pathc_max":1,"pathl_min":0.04,"pathl_max":0.2,
							"speed_min":90,"speed_max":180,"refire_min":1,"refire_max":4,
							"duration_min":5,"duration_max":18,
							"num_min":1,"num_max":1,"Svar":Vector2(0.5,2)
	
	}

	comet_preset={
	"path":$comet_spawn,
	"pathc_min":0,"pathc_max":1,"pathl_min":0.01,"pathl_max":0.1,
							"speed_min":200,"speed_max":400,"refire_min":0.1,"refire_max":0.5,
							"duration_min":2,"duration_max":8,
							"num_min":2,"num_max":5,"Svar":Vector2(0.5,2)
	
	}
	comet_preset_narrow={
	"path":$comet_spawn,
	"pathc_min":0,"pathc_max":1,"pathl_min":0.01,"pathl_max":0.03,
							"speed_min":300,"speed_max":400,"refire_min":0.1,"refire_max":0.5,
							"duration_min":2,"duration_max":8,
							"num_min":3,"num_max":5,"Svar":Vector2(0.5,2)
	
	}
	comet_preset_wide={
	"path":$comet_spawn,
	"pathc_min":0,"pathc_max":1,"pathl_min":0.05,"pathl_max":0.2,
							"speed_min":100,"speed_max":180,"refire_min":0.2,"refire_max":0.6,
							"duration_min":5,"duration_max":8,
							"num_min":1,"num_max":3,"Svar":Vector2(0.5,2)
	
	}
	return self
	
#create levels using generate_field and generate_random_field
func flip(v):
	var r=v
	if flip_b % 2==1:
		r=flipx(r)
	if flip_b>1:
		r=flipy(r)	
	print(r," ",flip_b)
	return r
func flipx(v):
	if v is Vector2:
		return Vector2(screen_size.x-v.x,v.y)
	elif v is Path2D:
		flip_path2d_horizontally(v)
	else: 
		return PI-v
func flipy(v):
	if v is Vector2:
		return Vector2(v.x,screen_size.y-v.y)
	elif v is Path2D:
		flip_path2d_vertically(v)
	else: 
		return -v
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	comet_preset["path"]=$comet_spawn
	comet_preset_wide["path"]=$comet_spawn
	asteroid_preset["path"]=$asteroid_spawn
	comet_preset_narrow["path"]=$comet_spawn
	screen_size= get_viewport_rect().size
	X=screen_size.x
	Y=screen_size.y
	# Replace with function body.
#following function was given to me by AI 
func circular_slice(array_to_slice: Array, start_index: int, end_index: int) -> Array:
	var array_size = array_to_slice.size()
	
	# Handle negative indices by converting them to positive equivalents
	start_index = (start_index % array_size + array_size) % array_size
	end_index = (end_index % array_size + array_size) % array_size
	
	var result_array = []
	
	if start_index <= end_index:
		# Standard slice when the range doesn't wrap around
		result_array = array_to_slice.slice(start_index, end_index + 1)
	else:
		# When the slice wraps around, combine two slices
		# Slice from start_index to the end of the array
		var first_part = array_to_slice.slice(start_index, array_size)
		# Slice from the beginning of the array to end_index
		var second_part = array_to_slice.slice(0, end_index + 1)
		result_array = first_part + second_part
		
	return result_array
#following function was given to me by AI and then edited
func flip_path2d_horizontally(path_node: Path2D):
	var curve: Curve2D = path_node.curve
	var new_curve = Curve2D.new()

	for i in range(curve.point_count):
		var point_position = curve.get_point_position(i)
		var in_tangent = curve.get_point_in(i)
		var out_tangent = curve.get_point_out(i)

		# Negate the x-coordinate of the position and tangents
		new_curve.add_point(
			Vector2(screen_size.x-point_position.x, point_position.y),
			Vector2(screen_size.x-in_tangent.x, in_tangent.y),
			Vector2(screen_size.x-out_tangent.x, out_tangent.y)
		)
	path_node.curve = new_curve

#following function was given to me by AI and then edited
func flip_path2d_vertically(path_node: Path2D):
	var curve: Curve2D = path_node.curve
	var new_curve = Curve2D.new()

	for i in range(curve.point_count):
		var point_position = curve.get_point_position(i)
		var in_tangent = curve.get_point_in(i)
		var out_tangent = curve.get_point_out(i)

		# Negate the y-coordinate of the position and tangents
		new_curve.add_point(
			Vector2(point_position.x, screen_size.y-point_position.y),
			Vector2(in_tangent.x, screen_size.y-in_tangent.y),
			Vector2(out_tangent.x,screen_size.y -out_tangent.y)
		)
	path_node.curve = new_curve

func slice_path(path,centre,length):
	var newp
	if length>=0.5:
		newp=path
	else:
		var baked_points = path.curve.get_baked_points()
		var L=baked_points.size()
		var start_index = int(L*centre)-int(L*length)  # Example start index
		var end_index = int(L*centre)+int(L*length)  
		print(start_index," ",end_index," ",L)  # Example end index
		var portion_points =circular_slice(baked_points,start_index, end_index)
		var new_curve = Curve2D.new()
		for point in portion_points:
			new_curve.add_point(point)
		var new_path2d = Path2D.new()
		new_path2d.curve = new_curve
		#add_child(new_path2d)
		newp=new_path2d
		return newp
		
func pick_random_fva(va):
	var L=va.size()
	return va.get(randi_range(0, L-1))
func get_random_direction(path,variance=PI/12):
	var baked_points = path.curve.get_baked_points()
	var point=pick_random_fva(baked_points)
	var centre=screen_size/2
	var angle=(centre-point).angle()
	return randf_range(angle-variance,angle+variance)
	
func generate_field(object,spawn_path,direction,speed,refire_speed,fire_duration,start_time,objects_perfire,variance=Vector2.ZERO,Svar=Vector2(0.5,2)):
	if spawn_path is Vector2:
		spawn_path=flip(spawn_path)
		direction=flip(direction)
	if spawn_path is Path2D and not spawn_path.is_inside_tree():
		add_child(spawn_path)
	add_child(field_scene.instantiate().init(object,spawn_path,direction,speed,refire_speed,fire_duration,start_time,objects_perfire,variance,Svar))
	
func generate_random_field(object,start_time,param_preset=comet_preset):
	var path = param_preset["path"]
	if path==null:
		path=$comet_spawn
	path=slice_path(path,randf_range(param_preset["pathc_min"],param_preset["pathc_max"]),randf_range(param_preset["pathl_min"],param_preset["pathl_max"]))
	var dir=get_random_direction(path)
	var speed=randi_range(param_preset["speed_min"],param_preset["speed_max"])
	var refire=randf_range(param_preset["refire_min"],param_preset["refire_max"])
	var duration=randi_range(param_preset["duration_min"],param_preset["duration_max"])
	var num=randi_range(param_preset["num_min"],param_preset["num_max"])
	var Svar=param_preset["Svar"]
	generate_field(object,path,dir,speed,refire,duration ,start_time,num)
	return 0
	
func generate_planet(name,scale,start_time,pos=Vector2(50,-self.screen_size.y),dir=PI/2,speed=25,variance=Vector2(100,0),Svar=Vector2(0.5,2)):
	var saturn=self.planet_scene.instantiate()
	saturn.setplanet(name)
	saturn.reshape(scale)
	add_child(self.field_scene.instantiate().init(saturn,pos,dir,speed,0,0,start_time,1,variance,Svar))
	return saturn
	#add_child(field_scene.instantiate().init(comet_scene,newp,PI/4,100,0.1,8,0,3))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func set_flip():
	flip_b=randi_range(0,3)
func play(start_time=0):
	print("begin level")
	
	
	
	#add_child(field_scene.instantiate().init(asteroid_scene,$right,0,80,3,4,8,1))
	#add_child(field_scene.instantiate().init(comet_scene,$left,PI,200,0.5,6,18,1))

	return level_duration 
