if (obj_game_manager.curr_game_state != GAME_STATE.PLAYING) exit;

pulse_phase += 4;
lifetime--;

// Push zombies that enter the sanctuary OUTWARD with a smooth velocity
// override. The push strength scales with how deep into the sanctuary the
// zombie has penetrated, so they always end up just outside the boundary
// without snapping or jittering. Their normal path-follow lerp resumes
// once they're outside again.
with (obj_enemy)
{
	if (is_marked || is_spawning) continue;
	var _d = point_distance(x, y, other.x, other.y);
	if (_d < other.sanctuary_radius)
	{
		// How deep are we? 0 at boundary, 1 at center.
		var _depth = 1 - (_d / other.sanctuary_radius);
		var _dir_out = point_direction(other.x, other.y, x, y);
		// Push strength scales with depth — strong push near center,
		// gentle nudge near the boundary so the transition is smooth.
		var _push_speed = max_speed * (1.5 + _depth * 2.5);
		var _new_vx = lengthdir_x(_push_speed, _dir_out);
		var _new_vy = lengthdir_y(_push_speed, _dir_out);
		// Overwrite the path-follow velocity entirely while inside.
		// No snapping, no zeroing — just steady outward motion.
		hspeed = _new_vx;
		vspeed = _new_vy;
		// Face the direction of motion (otherwise the sprite faces the
		// player while moving away, which looks wrong)
		image_angle = _dir_out - 180;
	}
}

if (lifetime <= 0) instance_destroy();
