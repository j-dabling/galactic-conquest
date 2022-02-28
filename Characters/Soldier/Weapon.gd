extends Node

export var fire_rate = 0.5
export var clip_size = 10
export var reload_rate = 1

onready var raycast = $"../Head/Camera/RayCast"

onready var Bullet = load("res://Bullet.tscn")
onready var Head = $"../Head"
onready var Muzzle = $"../Muzzle"

var current_ammo = clip_size
var can_fire = true
var reloading = false

func _process(delta):
	if Input.is_action_just_pressed("primary_fire") and can_fire:
		if current_ammo > 0 and not reloading:
			# Fire the weapon
			print("fire!")
			current_ammo -= 1
			can_fire = false
			#check_collision()
			shoot_laser()
			yield(get_tree().create_timer(fire_rate), "timeout")
			can_fire = true
			
		elif not reloading:
			reloading = true
			print("reloading")
			yield(get_tree().create_timer(reload_rate), "timeout")
			current_ammo = clip_size
			reloading = false
			
func check_collision():
	if raycast.is_colliding():
		
		var collider = raycast.get_collider()
		if collider.is_in_group("Enemies"):
			print("colliding raycast")
			collider.queue_free()
			print("killed " + collider.name)
			
func shoot_laser():
	var b = Bullet.instance()
	owner.add_child(b)
	b.global_transform = Muzzle.global_transform
	b.rotation = Head.rotation
	b.speed += $"..".velocity.length()
