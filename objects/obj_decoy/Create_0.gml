// Decoy lifetime in frames (8 sec)
lifetime = 480;
max_lifetime = 480;
pulse_phase = 0;
// Tell all current zombies to retarget us
with (obj_enemy)
{
	if (instance_exists(target))
	{
		target = other.id;
		find_path();
	}
}
