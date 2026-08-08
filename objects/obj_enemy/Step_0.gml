// ─── DYNAMIC SPEED CALCULATION ─────────────────────────────────────
// Tick down speed boost timer
if (speed_boost_timer > 0) speed_boost_timer--;

// HP penalty: each extra HP slows by 5% (1HP=100%, 2HP=95%, 3HP=90%)
var _hp_penalty = 1.0 - (max_health - 1) * 0.05;
_hp_penalty = max(_hp_penalty, 0.7);  // floor at 70%

// First: base speed with HP penalty. Runners are exempt from the normal
// speed cap — they're meant to outpace the player by a wide margin.
var _normal_max = base_max_speed * _hp_penalty;
if (!is_runner)
{
	_normal_max = min(_normal_max, 2.75);  // normal cap (10% faster than before)
}

// Wrong-answer speed boost: severe punishment that clearly outpaces the player
var _calculated_max;
if (speed_boost_timer > 0)
{
	_calculated_max = _normal_max + 1.6;     // even bigger boost than before
	if (!is_runner)
	{
		_calculated_max = min(_calculated_max, 3.55);  // ~27% faster than player base 2.8
	}
}
else
{
	_calculated_max = _normal_max;
}

// Freeze powerup overrides everything — but not for spawning zombies
// (otherwise they get stuck in the spawner forever)
if (instance_exists(obj_player) && obj_player.freeze_timer > 0 && !is_spawning)
{
	max_speed = 0.3;
	speed = min(speed, 0.3);
}
else
{
	max_speed = _calculated_max;
}

// Turret slow effect: while turret_slow_timer > 0, max_speed is halved
if (variable_instance_exists(self, "turret_slow_timer") && turret_slow_timer > 0)
{
	turret_slow_timer--;
	max_speed = max_speed * 0.4;
}

// Tick down post-hit immunity
if (hit_immune_timer > 0) hit_immune_timer--;

// Tick down beacon hint timer. Beacons refresh this every frame they
// have the zombie in range; once no beacon refreshes it, the highlight
// expires within 3 frames.
if (beacon_hint_timer > 0) beacon_hint_timer--;
// Tick down wrong-answer lockout
if (wrong_lockout_timer > 0) wrong_lockout_timer--;

// ─── PRE-PUNCH: position fists every frame regardless of state ────────────
// This prevents fists from being drawn at (0,0) or stale positions during spawn-in
if (instance_exists(target))
{
	var _pre_facing = point_direction(x, y, target.x, target.y);
	var _pf_list = [fist_left, fist_right];
	for (var _pi = 0; _pi < 2; _pi++)
	{
		var _pf = _pf_list[_pi];
		var _pfx = lengthdir_x(_pf.offset_x, _pre_facing);
		var _pfy = lengthdir_y(_pf.offset_x, _pre_facing);
		var _psx = lengthdir_x(_pf.offset_y, _pre_facing + 90);
		var _psy = lengthdir_y(_pf.offset_y, _pre_facing + 90);
		var _pex = lengthdir_x(punch_reach * _pf.extend, _pre_facing);
		var _pey = lengthdir_y(punch_reach * _pf.extend, _pre_facing);
		_pf.x = x + _pfx + _psx + _pex;
		_pf.y = y + _pfy + _psy + _pey;
	}
}
else
{
	// No target yet: idle fists in front of the body using image_angle
	var _pre_facing = image_angle - 180;
	var _pf_list = [fist_left, fist_right];
	for (var _pi = 0; _pi < 2; _pi++)
	{
		var _pf = _pf_list[_pi];
		var _pfx = lengthdir_x(_pf.offset_x, _pre_facing);
		var _pfy = lengthdir_y(_pf.offset_x, _pre_facing);
		var _psx = lengthdir_x(_pf.offset_y, _pre_facing + 90);
		var _psy = lengthdir_y(_pf.offset_y, _pre_facing + 90);
		_pf.x = x + _pfx + _psx;
		_pf.y = y + _pfy + _psy;
	}
}

// Case statement used to control enemy behavior based on games state
switch(obj_game_manager.curr_game_state)
{
	// Case for when the game has ended
	case GAME_STATE.ENDED:
		// Enemy speed will slow down based on dropoff rate
		speed *= speed_dropoff;
		// Enemy speed cannot exceed maximum speed
		speed = min(speed, max_speed);
		break;
	// Case for when the game is playing
	case GAME_STATE.PLAYING:
		// If our target was set but is now gone (e.g. player died), stop and skip
		// (Don't bail when target is still 'noone' — that's the normal pre-spawn state)
		if (target != noone && !instance_exists(target))
		{
			speed *= speed_dropoff;
			break;
		}
		
		// ─── HEALER BEHAVIOR ────────────────────────────────────────
		// Heal nearby zombies that are missing HP (multi-HP zombies that
		// got chipped). Tick the cooldown; when ready, find a target.
		if (is_healer)
		{
			if (heal_cooldown > 0) heal_cooldown--;
			else
			{
				var _healed = false;
				with (obj_enemy)
				{
					if (id == other.id) continue;
					if (curr_health < max_health && !is_marked
						&& point_distance(x, y, other.x, other.y) < other.heal_radius)
					{
						curr_health = min(curr_health + 1, max_health);
						// Visual feedback on the healed zombie
						var _h_pop = instance_create_layer(x, y - 70, "Enemies", obj_score_popup);
						_h_pop.popup_text = "+1";
						_h_pop.popup_color = make_color_rgb(100, 255, 150);
						_healed = true;
						break;
					}
				}
				heal_cooldown = heal_interval;
			}
		}
		
		// If marked (correct answer clicked), freeze in place — wait for bullet
		if (is_marked)
		{
			mark_pulse += 8;
			mark_timer++;
			speed *= 0.7;            // hard brake
			// Safety: if not shot within 4 seconds, finish kill anyway
			if (mark_timer > 240) math_finish_kill();
			break;
		}
		// Checks if the enemy is still spawning
		if (is_spawning)
		{
			spawn_stuck_timer--;
			// Checks if itself is within a collision rectangle created around the spawner it came from and sets itself to the variable is it still does
			var _instance = collision_rectangle(owner.x - (obj_game_manager.cell_width / 1.05), owner.y - (obj_game_manager.cell_height / 1.05), owner.x + (obj_game_manager.cell_width / 1.05) , owner.y + (obj_game_manager.cell_height / 1.05), self, true, false);
			
			// Exit spawn state if the cell is clear OR if we've been
			// stuck for 5 full seconds (safety against permanent stalls)
			if (_instance == noone || spawn_stuck_timer <= 0)
			{
				// Changes its spawning state to false
				is_spawning = false;
				// Locks the nearest player target and begins path finding
				lock_target();
				
				// Makes sure the direction it is traveling in matches its sprite facing
				direction = image_angle + 180;
			}
		}
		else
		{	
			// Checks if the next node is within threshold distance
			if (point_distance(x, y, next_node_x, next_node_y) <= node_threshold)
			{
				// Calls function to find new path
				find_path();
			}
			
			// Stores the node direction
			var _node_direction = point_direction(x, y, next_node_x, next_node_y);
	
			// Calculates the speed change to the next node position
			var _node_velo_x = lengthdir_x(max_speed, _node_direction);
			var _node_velo_y = lengthdir_y(max_speed, _node_direction);

			// Lerps the speed towards the next position
			hspeed = lerp(hspeed, _node_velo_x, speed_rate);
			vspeed = lerp(vspeed, _node_velo_y, speed_rate);
			
			// Caps the speed to the max speed
			speed = min(speed, max_speed);
			
			// Stores a tempory variable of self
			var _self = self;
			
			// Loops through obstacles witin the room
			with (obj_obstacle)
			{
				// Calculates the distance to obstacle
				var _repulse_dis = point_distance(_self.x, _self.y, x, y);
				
				// Checks distance is less than repulse distance
				if (_repulse_dis <= _self.repulse_buffer)
				{
					// Calculates strength of repulse from distance
					var _repulse_strength = _self.repulse_buffer / _repulse_dis;
					
					// Calculates direction of repulse from positions
					var _repulse_dir = point_direction(x, y, _self.x, _self.y);
				
					// Repulse speed calculated from direction, speed and strength
					var _repulse_velo_x = lengthdir_x(_self.max_speed, _repulse_dir) * _repulse_strength;
					var _repulse_velo_y = lengthdir_y(_self.max_speed, _repulse_dir) * _repulse_strength;
					
					// Lerps towards new speed
					_self.hspeed += lerp(_self.hspeed, _repulse_velo_x, _self.speed_rate);
					_self.vspeed += lerp(_self.vspeed, _repulse_velo_y, _self.speed_rate);
			
					// Limits speed by maximum speed
					_self.speed = min(_self.speed, _self.max_speed);
				}	
			}
			
			// Loops through enemies within the room
			with (obj_enemy)
			{
				// Checks enemy is not itself
				if (id != _self.id)
				{
					// Calculates the distance to enemy
					var _repulse_dis = point_distance(_self.x, _self.y, x, y);
					
					// Checks distance is less than repulse distance
					if (_repulse_dis <= _self.repulse_buffer)
					{
						// Calculates the strenght of repulse from distance
						var _repulse_strength = _self.repulse_buffer / _repulse_dis;
					
						// Calculates the direction of repulse from positions
						var _repulse_dir = point_direction(x, y, _self.x, _self.y);
				
						// Repulse speed calculated from direction speed and strength
						var _repulse_velo_x = lengthdir_x(_self.max_speed, _repulse_dir) * _repulse_strength;
						var _repulse_velo_y = lengthdir_y(_self.max_speed, _repulse_dir) * _repulse_strength;
					
						// Lerps towards new speed
						_self.hspeed += lerp(_self.hspeed, _repulse_velo_x, _self.speed_rate);
						_self.vspeed += lerp(_self.vspeed, _repulse_velo_y, _self.speed_rate);
						
						// Limits speed by maximum speed
						_self.speed = min(_self.speed, _self.max_speed);
					}
				}
			}
			
			// Calculates new angle from direction fliped because left facing
			var _new_angle = direction - 180;
			// Calculates the angle difference between the two facings
			var _angle_difference = angle_difference(_new_angle, image_angle);
			
			// Checks if colliding with something
			if (is_colliding)
			{
				// Adjusts the image angle to actual angle very slowly
				image_angle += _angle_difference * rotation_speed * speed_dropoff;
				// Sets state back to false
				is_colliding = false;
			}
			else
			{
				// Adjusts the image angle to actual angle
				image_angle += _angle_difference * rotation_speed;
			}
		
			// Calculates how far target is
			var _target_distance = point_distance(x, y, target.x, target.y);
			
			// Melee zombies don't have danger_close — they charge in at full speed.
			can_danger_close = false;
		
			// ─── PUNCH BEHAVIOR ────────────────────────────────────────
			// Aim fists at the player using actual direction to target.
			// This avoids any sprite-orientation mismatch.
			var _facing = point_direction(x, y, target.x, target.y);
			
			// Process each fist
			var _fists = [fist_left, fist_right];
			for (var _fi = 0; _fi < 2; _fi++)
			{
				var _f = _fists[_fi];
				if (_f.cooldown > 0) _f.cooldown--;
				
				// Should we trigger a punch?
				if (!_f.is_punching && _f.cooldown <= 0 && _target_distance <= punch_range)
				{
					_f.is_punching = true;
					_f.extend = 0;
					_f.has_hit = false;     // fresh punch — can land one hit
				}
				
				// Animate the punch
				if (_f.is_punching)
				{
					_f.extend += _f.extend_speed;
					if (_f.extend >= 1)
					{
						_f.extend = 1;
						_f.is_punching = false;
						_f.cooldown = punch_cooldown_frames + irandom(30);
					}
				} else if (_f.extend > 0) {
					_f.extend = max(0, _f.extend - _f.extend_speed * 0.5);
				}
				
				// Idle position: forward (offset_x) + perpendicular side offset (offset_y)
				// Forward = facing direction; perpendicular = facing + 90deg (or -90 for the other fist)
				var _fwd_x = lengthdir_x(_f.offset_x, _facing);
				var _fwd_y = lengthdir_y(_f.offset_x, _facing);
				var _side_x = lengthdir_x(_f.offset_y, _facing + 90);
				var _side_y = lengthdir_y(_f.offset_y, _facing + 90);
				
				// Extension: extra distance forward when punching
				var _ext_x = lengthdir_x(punch_reach * _f.extend, _facing);
				var _ext_y = lengthdir_y(punch_reach * _f.extend, _facing);
				
				_f.x = x + _fwd_x + _side_x + _ext_x;
				_f.y = y + _fwd_y + _side_y + _ext_y;
				
				// Damage check: only when fist is at/past peak extension AND hasn't hit yet this punch.
				// This syncs damage with the punch animation - each visible punch lands at most one hit.
				if (_f.is_punching && _f.extend >= 0.7 && !_f.has_hit && instance_exists(target))
				{
					var _hit_d = point_distance(_f.x, _f.y, target.x, target.y);
					if (_hit_d < _f.radius + 58)
					{
						_f.has_hit = true;   // lock this punch from damaging again
						// Only apply player damage logic when target IS the player.
						// Decoys lure zombies but never take damage.
						if (target.object_index == obj_player)
						{
							with (target)
							{
								if (damage_cooldown <= 0 && shield_timer <= 0)
								{
									player_health -= other.punch_damage;
									damage_cooldown = 35;
									is_flashed = true;
									flash_cooldown = flash_time;
									hud_health_alpha = 1.0;
									// Trigger vignette only if the player SURVIVED this hit
									// (skipping the flash on death so the death screen is clean)
									if (player_health > 0)
									{
										obj_game_manager.damage_vignette_timer = obj_game_manager.damage_vignette_max;
									}
									obj_game_manager.run_damage_taken_wave++;
									audio_play_sound(snd_player_hit, 100, false, 0.01, 0, 1.0);
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
		}
		break;
}

// ─── HARD BODY-vs-PLAYER COLLISION ──────────────────────────────────
// Prevent zombie body circle from overlapping the player body circle.
// Fists are NOT included here — they're allowed to extend over the player.
if (!is_spawning && instance_exists(obj_player))
{
	var _pl_radius = 67;        // player body push-out radius (15% larger than damage hitbox for no-overlap)
	var _zb_radius = 60;        // zombie body radius
	var _min_dist = _pl_radius + _zb_radius;   // = 118
	var _dx = x - obj_player.x;
	var _dy = y - obj_player.y;
	var _d = sqrt(_dx * _dx + _dy * _dy);
	if (_d < _min_dist && _d > 0.001)
	{
		// Push zombie out along the player->zombie vector
		var _ux = _dx / _d;
		var _uy = _dy / _d;
		x = obj_player.x + _ux * _min_dist;
		y = obj_player.y + _uy * _min_dist;
		// Kill momentum into the player so it doesn't keep ramming
		hspeed = 0;
		vspeed = 0;
	}
	else if (_d <= 0.001)
	{
		// Edge case: perfectly overlapping. Nudge in a random direction.
		var _ang = irandom(359);
		x = obj_player.x + lengthdir_x(_min_dist, _ang);
		y = obj_player.y + lengthdir_y(_min_dist, _ang);
	}
}

// Checks if the enemy is flashed and the game is not paused
if (is_flashed && obj_game_manager.curr_game_state != GAME_STATE.PAUSED)
{
	// Reduces the flash cooldown
	flash_cooldown -= delta_time * 0.000001;

	// Checks if the flash cooldown has finished
	if (flash_cooldown <= 0)
	{
		// Resets the flash state
		is_flashed = false;
		// Resets the flash cooldown
		flash_cooldown = flash_time;
	}
}

// Checks if the enemy is out of health
if (curr_health <= 0)
{
	// Destroys itself
	instance_destroy();
}