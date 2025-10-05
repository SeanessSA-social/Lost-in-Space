extends Control
var messages=[]
var c=0
@onready var ship= get_node("../../Spaceship") # Relative path
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	c=0
	$content.text=""
	$content.visible_characters = 0
	hide()
	position=Vector2(1000,200)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position=ship.position+Vector2(25,-50)
	if c==0 and $content.text=="" and not messages.is_empty():
		set_and_reveal(messages.pop_front())
	if Input.is_action_just_pressed("boost"):
		reset()
	
func showtext():
	show()

func push_message(text=""):
	messages.append(text)
		
func set_and_reveal(text="yolo"):
	c=1
	$content.text=text
	$content.visible_characters = 0
	$content.visible_characters += 1
	$Timer.start()

func reveal():
	c=1
	$content.visible_characters += 1
	$Timer.start()
func _on_timer_timeout() -> void:
	if $content.visible_characters < $content.text.length():
		$content.visible_characters += 1
	else:
		$Timer.stop() 
		$Timer2.start()# Replace with function body.
func reset():
	$content.text=""
	$content.visible_characters = 0
	$Timer.stop() 
	$Timer2.stop() 
	c=0
func _on_timer_2_timeout() -> void:
	reset() # Replace with function body.
