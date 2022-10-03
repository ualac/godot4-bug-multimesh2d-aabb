extends Node2D

@export_range(1,100) var NumInstances : int = 50 :
	set( val ) :
		NumInstances = val
		if self.is_inside_tree() :
			randomize_instances(2.0)
		
@onready var TheMultimesh2D : MultiMeshInstance2D = $MultiMeshInstance2d
@onready var TheCamera2D : Camera2D = $Camera2d

var is_click_drag : bool = false
var click_drag_last : Vector2 = Vector2.ZERO

func _ready() -> void:
	# on startup generate a tight cluster of instances
	randomize_instances(0.5)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.pressed and event.keycode == KEY_SPACE :
		print("randomizing instances")
		randomize_instances(2.0)
	elif event.pressed and event.keycode == KEY_A :
		print("updating aabb")
		update_aabb()
	elif event.pressed and event.keycode == KEY_R :
		print("resetting")
		randomize_instances(0.5)
		update_aabb()
		TheCamera2D.transform.origin = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton :
		var mouse_button_event : InputEventMouseButton = event as InputEventMouseButton
		if mouse_button_event.button_index == MOUSE_BUTTON_LEFT :
			if mouse_button_event.pressed :
				click_drag_last = event.position
				is_click_drag = true
			else :
				is_click_drag = false
	if event is InputEventMouseMotion and is_click_drag :
		# move camera to this location
		TheCamera2D.transform.origin -= (event.position - click_drag_last)
		click_drag_last = event.position

# randomly position each instance.
# scaling is used to control how large 
# the overall group of instances are
func randomize_instances( scaling : float ) -> void:
	TheMultimesh2D.multimesh.instance_count = NumInstances
	var target_size : Vector2 = get_viewport().size * (randf()+0.5)*scaling
	for i in range(NumInstances):
		var rand_xform : Transform2D = Transform2D( deg_to_rad(randf()*360.0), Vector2( randf()*target_size.x, randf()*target_size.y ) - (target_size/2.0) )
		TheMultimesh2D.multimesh.set_instance_transform_2d( i, rand_xform )

# function to force update the aabb from: 
#   https://github.com/godotengine/godot/issues/54854 
func update_aabb() -> void:
	var aabb: AABB = TheMultimesh2D.multimesh.get_aabb()
	var rect := Rect2(aabb.position.x, aabb.position.y, aabb.size.x, aabb.size.y)
	RenderingServer.canvas_item_set_custom_rect(TheMultimesh2D.get_canvas_item(), true, rect)

