
class_name InteractiveObject
extends Node

const OVERLAY_SHADER: Shader = preload("res://3d_scenes/overlay.gdshader")

var mesh: MeshInstance3D
var overlay_material: ShaderMaterial


func _ready() -> void:
	
	# Validate parent
	mesh = get_parent() as MeshInstance3D

	if mesh == null:
		push_error("InteractiveObject must be a child of MeshInstance3D")
		return
		

	# Create overlay material
	overlay_material = ShaderMaterial.new()
	overlay_material.shader = OVERLAY_SHADER

	# Apply overlay
	mesh.material_overlay = overlay_material
#class_name InteractiveObject
#extends Node
#
#var parent: MeshInstance3D
#var overlay_shader: ShaderMaterial
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#
	#overlay_shader = ShaderMaterial.new()
	#overlay_shader.shader = preload("res://3d_scenes/overlay.gdshader")
	#
	#if get_parent() is not MeshInstance3D:
		#push_error("Iteractive Object node must have a parent of type MeshInstance3D")
		#return
	#parent = get_parent()
	## all meshinstance 3d will have the overlay 
	#parent.material_overlay = overlay_shader
	#
	#print(overlay_shader.shader)
	#print(parent.material_overlay.shader)
