"""Manages a  shader overlay on a parent MeshInstance3D and
strictly handles visual highlight states (IDLE, HOVERED, CLICKED) without input logic."""
class_name OverlayFeedback
extends Node

# Visual states supported by the overlay.
enum State { IDLE, HOVERED, CLICKED }

# Preloaded spatial shader that renders the occluded outline/overlay.
const OVERLAY_SHADER: Shader = preload("res://3d_scenes/overlay.gdshader")

@export var idle_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var hover_color: Color = Color(0.844, 0.732, 0.0, 0.65)
@export var clicked_color: Color = Color(0.2, 0.85, 1.0, 0.85)
## If true, clicking a CLICKED object toggles it back to IDLE.
@export var toggle_on_click: bool = true

# Reference to the parent mesh receiving the material_overlay.
var mesh: MeshInstance3D
var overlay_material: ShaderMaterial
#Current visual state. automatically updates the shader color whenever modified.
var state: State = State.IDLE: set = _set_state


func _ready() -> void:
	# Ensure this component is attached directly under a MeshInstance3D
	mesh = get_parent() as MeshInstance3D
	if mesh == null:
		push_error("OverlayFeedback must be a child of MeshInstance3D")
		return

	# Create a unique ShaderMaterial instance per object so color changes don't affect shared resources
	overlay_material = ShaderMaterial.new()
	overlay_material.shader = OVERLAY_SHADER
	mesh.material_overlay = overlay_material

	# Sync the shader uniform with the initial IDLE state
	_apply_state_color()


## Updates hover state without overriding an active CLICKED selection.
func set_hovered(is_hovered: bool) -> void:
	if is_hovered:
		# Preserve CLICKED highlight if the object is already selected
		if state != State.CLICKED:
			state = State.HOVERED
	elif state == State.HOVERED:
		# Only revert to IDLE if it was currently in HOVERED state
		state = State.IDLE


## Transitions the overlay to CLICKED, or toggles back to IDLE if toggle_on_click is enabled.
func trigger_click() -> void:
	if toggle_on_click:
		state = State.HOVERED if state == State.CLICKED else State.CLICKED
	else:
		state = State.CLICKED


## Resets the visual state back to IDLE .
func reset_state() -> void:
	state = State.IDLE


## Setter for state that guarantees the shader stays in sync with state changes.
func _set_state(new_state: State) -> void:
	state = new_state
	_apply_state_color()


## Pushes the color matching the current State into the shader's `color` uniform.
func _apply_state_color() -> void:
	# Guard against state changes occurring before _ready() initializes the material
	if overlay_material == null:
		return

	match state:
		State.IDLE:
			overlay_material.set_shader_parameter("color", idle_color)
		State.HOVERED:
			overlay_material.set_shader_parameter("color", hover_color)
		State.CLICKED:
			overlay_material.set_shader_parameter("color", clicked_color)
