extends Light2D

var amplitude = 100  # The maximum distance the object will move from its initial position.
var speed = 1.0  # The speed at which the object moves.
var off = 0.0  # The offset value to control the phase of the movement.

var initialPosition  # The initial position of the object.

func _ready():
	initialPosition = position  # Store the initial position of the object.

func _process(delta):
	var sinValue = sin(off)  # Calculate the sine value based on the offset.
	var newPosition = initialPosition + Vector2(0, sinValue * amplitude)  # Calculate the new position based on the sine value.
	
	position = newPosition  # Set the object's position to the new calculated position.
	
	off += speed * delta  # Update the offset based on the speed and delta time.
