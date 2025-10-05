extends CanvasLayer
#HUD only controls life display not life logic. removed death check and ending control.

#@onready var lives_label: Label = $LivesLabel
@onready var cards: Array[LifeCard] = [
	$Cards/Card1 as LifeCard,
	$Cards/Card2 as LifeCard,
	$Cards/Card3 as LifeCard
]

# optional: placeholder textures (all same for now)
var placeholder_icon: Texture2D

func _ready() -> void:
	print("+++++++++++++++++")
	placeholder_icon = load("res://assets/Textures/processor.png") as Texture2D # replace later with real PNGs
 
	
	#initialize captions and icons
	cards[0].set_caption("Terraform")
	cards[1].set_caption("Life Support")
	cards[2].set_caption("Provisions")
	for c in cards:
		c.set_icon(placeholder_icon)
		c.visible = true
		c.scale = Vector2.ONE
		c.modulate = Color(1,1,1,1)

func update_lives(current: int) -> void:
	#lives_label.text = "Lives: %d" % current
	print("!!!!!!!!!!!!!!!!")
	
	for i in range(cards.size()):
		var should_show := i < current
		var card := cards[i]
		if card.visible and not should_show:
			card.play_hit_feedback()
			await get_tree().create_timer(0.05).timeout
			card.play_lost_feedback()
		elif not card.visible and should_show:
			card.visible = true
			card.scale = Vector2.ONE
			card.modulate = Color(1,1,1,1)
			

func _on_spaceship_lives_changed(current_lives: int) -> void:
	update_lives(current_lives) # Replace with function body.
