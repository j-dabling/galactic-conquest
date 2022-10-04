extends CSGMesh


# Keeps track of all bodies inside of Influence Area.
#var bodies := Array()

# Keeps track of number of bodies in Influence Area, sorted by team.
#			Red Team, Blue Team, Green Team
var presence = Color(0,0,0)
var mat = SpatialMaterial.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Make sure the material starts blank.
	mat.albedo_color = Color(0, 0, 0, 1.0)
	self.material_override = mat


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if presence:
		# Red team's presence will increase r value, while also 
		# reducing g and b at the same rate.
		mat.albedo_color.r += presence.r * delta
		mat.albedo_color.g -= presence.r * delta
		mat.albedo_color.b -= presence.r * delta
		
		# The same method is applied to each color value.
		mat.albedo_color.r -= presence.g * delta
		mat.albedo_color.g += presence.g * delta
		mat.albedo_color.b -= presence.g * delta
		
		mat.albedo_color.r -= presence.b * delta
		mat.albedo_color.g -= presence.b * delta
		mat.albedo_color.b += presence.b * delta
		
		# Check to make sure none of the values go unreasonably high or low.
		if mat.albedo_color.r > 1:
			mat.albedo_color.r = 1
		elif mat.albedo_color.r < 0:
			mat.albedo_color.r = 0
			
		if mat.albedo_color.g > 1:
			mat.albedo_color.g = 1
		elif mat.albedo_color.g < 0:
			mat.albedo_color.g = 0
			
		if mat.albedo_color.b > 1:
			mat.albedo_color.b = 1
		elif mat.albedo_color.b < 0:
			mat.albedo_color.b = 0
	
	# Debug statement for Control point posession.
	#print(mat.albedo_color)


func _on_Influence_Area_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("bot"):
		if body.is_in_group("red"):
			presence.r += 1
		elif body.is_in_group("blue"):
			presence.b += 1
		elif body.is_in_group("green"):
			presence.g += 1


func _on_Influence_Area_body_exited(body):
	if body.is_in_group("player") or body.is_in_group("bot"):
		if body.is_in_group("red"):
			presence.r -= 1
		elif body.is_in_group("blue"):
			presence.b -= 1
		elif body.is_in_group("green"):
			presence.g -= 1
