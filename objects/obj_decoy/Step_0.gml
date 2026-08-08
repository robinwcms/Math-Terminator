// Don't tick during pause
if (obj_game_manager.curr_game_state != GAME_STATE.PLAYING) exit;

pulse_phase += 8;
lifetime--;

// Keep dragging zombies' target toward us each frame (in case lock_target ran)
with (obj_enemy)
{
	if (instance_exists(target) && target != other.id
		&& !is_marked && !is_spawning)
	{
		target = other.id;
	}
}

if (lifetime <= 0)
{
	// Re-target every zombie to the player when decoy expires
	with (obj_enemy)
	{
		if (instance_exists(obj_player) && !is_marked && !is_spawning)
		{
			target = obj_player.id;
			find_path();
		}
	}
	instance_destroy();
}
