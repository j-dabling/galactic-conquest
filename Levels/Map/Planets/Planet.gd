extends MeshInstance

var resources = [] # List of resources the planet produces.
var locations = {} # Dictionary of battlefields with which team controlls them.
export var Name = '' # Name of the planet
export var description = '' # Description of the planet, 

var controlling_team = null
export var battlefields = [] # List of scenes where players can fight on the surface.

onready var menu_sprite = $Spatial/Sprite3D
onready var menu_arm = $Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	menu_sprite.visible = false

func _on_StaticBody_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		menu_sprite.visible = true
		menu_sprite.billboard = true
#		menu_arm.rotation = look_at($"../Camera".global_transform.origin, Vector3.UP)
		
		get_tree().change_scene(battlefields[0])

func _on_StaticBody_mouse_exited():
	menu_sprite.visible = false

func _process(delta):
	if menu_sprite.visible:
		menu_arm.rotation = menu_sprite.rotation
		menu_sprite.billboard



