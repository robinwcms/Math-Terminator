// Bullet hit a zombie body.
if (instance_exists(owner) && owner.object_index == obj_player)
{
	if (other.is_marked)
	{
		// Marked zombie — bullet hit completes the kill
		other.math_finish_kill();
		// Sniper: bullet keeps going (pierces) instead of despawning
		if (!obj_game_manager.sniper_active) spark_projectile();
		exit;
	}
	else if (instance_exists(obj_player) && obj_player.rapid_fire_timer > 0)
	{
		// Rapid Fire: instakill via the same path
		other.math_correct_answer();
		other.math_finish_kill();
		spark_projectile();
		exit;
	}
	else if (other.hit_immune_timer <= 0)
	{
		// Normal hit just flashes the zombie. Play a spark sound to give
		// the player audible feedback that the shot connected but the
		// zombie wasn't marked yet (i.e. the math hadn't been solved).
		audio_play_sound(snd_fireball_spark, 100, false, 0.01, 0, 1.0);
		if (!other.is_flashed)
		{
			other.is_flashed = true;
		}
	}
	spark_projectile();
}
