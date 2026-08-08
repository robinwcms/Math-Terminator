if (obj_game_manager.curr_game_state != GAME_STATE.PLAYING) exit;

pulse_phase += 4;
lifetime--;
if (fire_cooldown > 0) fire_cooldown--;

// Acquire / re-acquire the nearest valid target
var _best_d = fire_range;
var _best = noone;
with (obj_enemy)
{
	if (is_spawning) continue;
	var _d = point_distance(x, y, other.x, other.y);
	if (_d < _best_d)
	{
		_best_d = _d;
		_best = id;
	}
}
target_id = _best;

if (instance_exists(target_id))
{
	// Aim
	gun_angle = point_direction(x, y, target_id.x, target_id.y);
	
	// Fire if cooldown ready
	if (fire_cooldown <= 0)
	{
		fire_cooldown = fire_interval;
		// Damage one HP off the zombie and apply a slowdown.
		// We don't use a projectile object — just hit immediately for clarity.
		with (target_id)
		{
			curr_health = max(0, curr_health - 1);
			// Slow effect: temporarily reduce max_speed to 40% for ~90 frames.
			// If already slowed, refresh the timer.
			if (!variable_instance_exists(self, "turret_slow_timer"))
				turret_slow_timer = 0;
			if (turret_slow_timer <= 0)
			{
				turret_pre_slow_speed = max_speed;
			}
			max_speed = base_max_speed * 0.4;
			turret_slow_timer = 90;
			// Visual chip popup
			var _pop = instance_create_layer(x, y - 60, "Enemies", obj_score_popup);
			_pop.popup_text = "-1";
			_pop.popup_color = make_color_rgb(180, 220, 255);
			// Tick: if HP reaches 0, finish-kill so it dies cleanly
			if (curr_health <= 0)
			{
				math_finish_kill();
			}
		}
	}
}

if (lifetime <= 0) instance_destroy();
