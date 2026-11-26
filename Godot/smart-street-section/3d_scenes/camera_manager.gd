extends Node
class_name CameraManager

enum TweenMode {
	LINEAR,
	EASE_IN,
	EASE_OUT,
	EASE_IN_OUT
}

@export_group("Cameras")
@export var cameras: Array[PhantomCamera3D] = []

@export_group("Transition")
@export var tween_mode: TweenMode = TweenMode.EASE_IN_OUT
@export var tween_duration: float = 0.9

# Main camera is the default at index 0.
var current_camera: int = 0


func _ready() -> void:
	cameras[current_camera].set_priority(10)
	
	for camera in cameras.slice(1,4): #lowering priority of all other cameras except main
		camera.set_priority(0)



func switch_camera() -> void:
	cameras[current_camera].set_priority(0)
	current_camera += 1
	if current_camera > 3:
		current_camera = 0

	
	cameras[current_camera].set_priority(10)
