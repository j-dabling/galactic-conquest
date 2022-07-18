extends Spatial

#-----------------SCENE--SCRIPT------------------#
#    Close your game faster by clicking 'Esc'    #
#   Change mouse mode by clicking 'Shift + F1'   #
#------------------------------------------------#

export var fast_close := true


func _ready() -> void:
	if !OS.is_debug_build():
		fast_close = false
	
	if fast_close:
		print("** Fast Close enabled in the 'L_Main.gd' script **")
		print("** 'Esc' to close 'Shift + F1' to release mouse **")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and fast_close:
		get_tree().quit() # Quits the game
	
	if event.is_action_pressed("primary_fire") and fast_close:
		var player_pos = get_node("Player").translation
		get_node("Soldier/States").objective_pos = player_pos
#		match Input.get_mouse_mode():
#			Input.MOUSE_MODE_CAPTURED:
#				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#			Input.MOUSE_MODE_VISIBLE:
#				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
