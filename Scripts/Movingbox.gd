extends CSGBox3D

var distance = 20
var base_position
var returning = false
var target_position
# Called when the node enters the scene tree for the first time.
func _ready():
	base_position = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("Target pos: ", target_position)
	print("Current pos: ", position)
	if(position == base_position):
		returning = false
	if(returning == false) :
		target_position = base_position.z - distance
	
	if(position.z != target_position ):
		if(position.z > target_position):
			position.z -= 0.1
		else:
			position.z += 0.1
	else:
		returning = true
		


func _on_area_3d_area_entered(area):
	pass


func _on_area_3d_area_exited(area):
	pass # Replace with function body.
