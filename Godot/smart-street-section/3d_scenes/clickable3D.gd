"""Detects 3D mouse hover and click events on a parent Area3D and
 emits interaction signals and forwards state changes to an OverlayFeedback node."""
class_name Clickable3D
extends Node

#Emitted when the mouse cursor enters the Area3D collider.
signal hovered
#Emitted when the mouse cursor leaves the Area3D collider.
signal unhovered
#Emitted when the user left-clicks inside the Area3D collider.
signal clicked

# Optional visual feedback component to drive on hover/click.
@export var feedback: OverlayFeedback
@export var enabled: bool = true

# Reference to the parent CollisionObject3D responsible for physics ray-picking.
var _area: CollisionObject3D


func _ready() -> void:
	# Validate that this node is placed under an CollisionObject3D to receive mouse signals
	_area = get_parent() as CollisionObject3D
	if _area == null:
		push_error("Clickable3D must be a child of CollisionObject3D")
		return

	# Ensure the Area3D can be detected by Godot's camera mouse ray-picking
	_area.input_ray_pickable = true

	# Connect Area3D pointer signals to local handlers
	_area.mouse_entered.connect(_on_mouse_entered)
	_area.mouse_exited.connect(_on_mouse_exited)
	_area.input_event.connect(_on_input_event)


## Handles pointer enter: notifies listeners and activates hover highlight if enabled.
func _on_mouse_entered() -> void:
	if not enabled:
		return
	hovered.emit()
	if feedback != null:
		feedback.set_hovered(true)


## Handles pointer exit: always clears hover state even if disabled mid-hover.
func _on_mouse_exited() -> void:
	unhovered.emit()
	if feedback != null:
		feedback.set_hovered(false)


## Filters raw Area3D input events for a fresh left mouse button press.
func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not enabled:
		return

	# Trigger only on initial button press (ignore release or mouse motion events)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit()
		if feedback != null:
			feedback.trigger_click()
