// Creates a new instance of a dead state of the enemy
var _dead_body = instance_create_layer(x, y, "Bodies", obj_enemy_dead);
// Sets the angle of the dead enemy to match the enemy
_dead_body.image_angle = image_angle;

// ─── MATH TERMINATOR: Clean up weakspots ───
for (var _i = 0; _i < array_length(math_weakspots); _i++)
{
	if (instance_exists(math_weakspots[_i])) instance_destroy(math_weakspots[_i]);
}
