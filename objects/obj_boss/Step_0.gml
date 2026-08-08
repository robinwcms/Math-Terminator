// ─── BOSS STEP ─────────────────────────────────────────────────────
if (obj_game_manager.curr_game_state != GAME_STATE.PLAYING) exit;

// Tick down timers
if (hit_immune_timer > 0) hit_immune_timer--;
if (wrong_lockout_timer > 0) wrong_lockout_timer--;
if (speed_boost_timer > 0) speed_boost_timer--;
if (summon_cooldown > 0) summon_cooldown--;
if (mark_timer < 1000000) mark_timer++;

// Tick flash
if (is_flashed)
{
	flash_cooldown -= delta_time * 0.000001;
	if (flash_cooldown <= 0)
	{
		is_flashed = false;
		flash_cooldown = flash_time;
	}
}

// Freeze powerup affects boss too (but less so)
var _frozen = (instance_exists(obj_player) && obj_player.freeze_timer > 0);

// If marked, freeze in place awaiting bullet
if (is_marked)
{
	mark_pulse += 8;
	speed *= 0.6;
	// Auto-finish if not shot within 5 seconds
	if (mark_timer > 300) math_finish_kill();
}
else
{
	// Phase-based speed
	var _phase_speed_mult = 1.0;
	if (phase == 3) _phase_speed_mult = 1.5;
	else if (phase == 2) _phase_speed_mult = 1.2;
	
	var _boost = 1.0;
	if (speed_boost_timer > 0) _boost = 1.4;
	
	max_speed = base_max_speed * _phase_speed_mult * _boost;
	if (_frozen) max_speed *= 0.5;

	// Chase the player
	if (instance_exists(target))
	{
		var _angle = point_direction(x, y, target.x, target.y);
		var _vx = lengthdir_x(max_speed, _angle);
		var _vy = lengthdir_y(max_speed, _angle);
		x += _vx;
		y += _vy;
	}
	else
	{
		lock_target();
	}
}

// ─── HARD BODY-vs-PLAYER COLLISION (boss is huge) ──────────────────
if (instance_exists(obj_player))
{
	var _pl_radius = 67;
	var _min_dist = _pl_radius + body_radius;   // body_radius = 140
	var _dx = x - obj_player.x;
	var _dy = y - obj_player.y;
	var _d = sqrt(_dx * _dx + _dy * _dy);
	if (_d < _min_dist && _d > 0.001)
	{
		var _ux = _dx / _d;
		var _uy = _dy / _d;
		x = obj_player.x + _ux * _min_dist;
		y = obj_player.y + _uy * _min_dist;
	}
}

// ─── FIST POSITIONING & PUNCHING ───────────────────────────────────
if (instance_exists(target))
{
	var _facing = point_direction(x, y, target.x, target.y);
	var _target_distance = point_distance(x, y, target.x, target.y);
	var _fists = [fist_left, fist_right];
	
	for (var _fi = 0; _fi < 2; _fi++)
	{
		var _f = _fists[_fi];
		if (_f.cooldown > 0) _f.cooldown--;
		
		// Trigger punch when in range and not marked
		if (!_f.is_punching && _f.cooldown <= 0 && _target_distance <= punch_range && !is_marked)
		{
			_f.is_punching = true;
			_f.extend = 0;
			_f.has_hit = false;
		}
		
		// Animate
		if (_f.is_punching)
		{
			_f.extend += _f.extend_speed;
			if (_f.extend >= 1)
			{
				_f.extend = 1;
				_f.is_punching = false;
				// Phase-based cooldown
				var _cd = punch_cooldown_frames - (phase - 1) * 20;
				_f.cooldown = _cd + irandom(20);
			}
		} else if (_f.extend > 0) {
			_f.extend = max(0, _f.extend - _f.extend_speed * 0.5);
		}
		
		// Position
		var _fwd_x = lengthdir_x(_f.offset_x, _facing);
		var _fwd_y = lengthdir_y(_f.offset_x, _facing);
		var _side_x = lengthdir_x(_f.offset_y, _facing + 90);
		var _side_y = lengthdir_y(_f.offset_y, _facing + 90);
		var _ext_x = lengthdir_x(punch_reach * _f.extend, _facing);
		var _ext_y = lengthdir_y(punch_reach * _f.extend, _facing);
		_f.x = x + _fwd_x + _side_x + _ext_x;
		_f.y = y + _fwd_y + _side_y + _ext_y;
		
		// Damage check at peak extension
		if (_f.is_punching && _f.extend >= 0.7 && !_f.has_hit)
		{
			var _hit_d = point_distance(_f.x, _f.y, target.x, target.y);
			if (_hit_d < _f.radius + 58)
			{
				_f.has_hit = true;
				with (target)
				{
					if (damage_cooldown <= 0 && shield_timer <= 0)
					{
						player_health -= other.punch_damage;
						damage_cooldown = 35;
						is_flashed = true;
						flash_cooldown = flash_time;
						hud_health_alpha = 1.0;
						// Only flash the vignette if the player survived
						if (player_health > 0)
						{
							obj_game_manager.damage_vignette_timer = obj_game_manager.damage_vignette_max;
							audio_play_sound(snd_player_hit, 100, false, 0.01, 0, 1.0);
						}
						obj_game_manager.run_damage_taken_wave++;
					}
					else if (shield_timer > 0)
					{
						damage_cooldown = 20;
					}
				}
			}
		}
	}
}

// Update weakspot positions
for (var _i = 0; _i < array_length(math_weakspots); _i++)
{
	var _ws = math_weakspots[_i];
	if (instance_exists(_ws))
	{
		_ws.x = x + _ws.offset_x;
		_ws.y = y + _ws.offset_y;
	}
}

// ─── MINION SUMMONING ──────────────────────────────────────────────
if (!is_marked && summon_cooldown <= 0)
{
	var _rate = summon_rate_p1;
	var _count = 1;
	if (phase == 2) { _rate = summon_rate_p2; _count = 2; }
	if (phase == 3) { _rate = summon_rate_p3; _count = 3; }
	boss_summon_minions(_count);
	summon_cooldown = _rate;
}

// ─── HARD COLLISION vs OBSTACLES (rocks) ───────────────────────────
with (obj_obstacle)
{
	var _obs_r = 80;   // approximate radius of an obstacle
	var _dx = other.x - x;
	var _dy = other.y - y;
	var _d = sqrt(_dx * _dx + _dy * _dy);
	var _min_dist = other.body_radius + _obs_r;
	if (_d < _min_dist && _d > 0.001)
	{
		var _ux = _dx / _d;
		var _uy = _dy / _d;
		other.x = x + _ux * _min_dist;
		other.y = y + _uy * _min_dist;
	}
}

// ─── HARD COLLISION vs ZOMBIES (boss pushes them away) ─────────────
with (obj_enemy)
{
	if (is_spawning) continue;
	var _en_r = 50;   // approximate zombie body radius
	var _dx = x - other.x;
	var _dy = y - other.y;
	var _d = sqrt(_dx * _dx + _dy * _dy);
	var _min_dist = other.body_radius + _en_r;
	if (_d < _min_dist && _d > 0.001)
	{
		var _ux = _dx / _d;
		var _uy = _dy / _d;
		// Push the zombie outward (boss is too big to push)
		x = other.x + _ux * _min_dist;
		y = other.y + _uy * _min_dist;
	}
}
