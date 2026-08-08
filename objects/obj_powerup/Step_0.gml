// Tick lifetime
lifetime--;
if (lifetime <= 0) { instance_destroy(); exit; }

// Update bob phase (visual)
bob_phase += 4;

// Pickup detection: any player within range
if (instance_exists(obj_player))
{
	with (obj_player)
	{
		if (point_distance(x, y, other.x, other.y) < 90)
		{
			var _t = other.powerup_type;
			apply_powerup(_t);
			/* SILENCED: audio_play_sound(snd_player_fire, 100, false, 0.01, 0, 1.5); */
			with (other) instance_destroy();
		}
	}
}
