// Bullet hit the boss
if (instance_exists(owner) && owner.object_index == obj_player)
{
	if (other.is_marked)
	{
		// Marked boss — bullet hit completes the kill
		other.math_finish_kill();
	}
	else if (instance_exists(obj_player) && obj_player.rapid_fire_timer > 0)
	{
		// Rapid Fire: damage boss instantly (one HP per shot)
		other.math_correct_answer();
		other.math_finish_kill();
	}
	else if (other.hit_immune_timer <= 0)
	{
		// Normal flash — bullet hit the boss but the math wasn't solved.
		// Same "hit but not killed" spark cue as zombies.
		audio_play_sound(snd_fireball_spark, 100, false, 0.01, 0, 1.0);
		if (!other.is_flashed)
		{
			other.is_flashed = true;
		}
	}
	spark_projectile();
}
