// F11 toggles fullscreen
if (keyboard_check_pressed(vk_f11))
{
	window_set_fullscreen(!window_get_fullscreen());
}

// Tick the E-open suppression timer (set when inventory popup closes)
if (suppress_e_timer > 0)
{
	suppress_e_timer--;
	if (suppress_e_timer <= 0) global.suppress_e_open = false;
}
// M exits fullscreen (ESC no longer exits fullscreen - it pauses instead)
if (keyboard_check_pressed(ord("M")) && window_get_fullscreen())
{
	window_set_fullscreen(false);
}

// Gamepad Y (gp_face4) toggles the debug overlay
if (gamepad_button_check_pressed(0, gp_face4))
{
	show_debug = !show_debug;
}

// Admin: lowercase 'p' instakills all current zombies in the wave
if (keyboard_check_pressed(ord("P")) && !keyboard_check(vk_shift))
{
	with (obj_enemy)
	{
		curr_health = 0;
		instance_destroy();
	}
	with (obj_boss)
	{
		curr_health = 0;
		instance_destroy();
	}
	with (obj_enemy_spawner) spawn_queue = 0;
}

// Admin: lowercase 'u' resets all achievements (sets every achievement to
// unlocked=false, clears popups queue, saves to disk)
if (keyboard_check_pressed(ord("U")) && !keyboard_check(vk_shift))
{
	if (variable_global_exists("achievements"))
	{
		for (var _ai = 0; _ai < array_length(global.achievements); _ai++)
		{
			global.achievements[_ai].unlocked = false;
		}
		var _f = file_text_open_write("achievements.sav");
		file_text_write_string(_f, json_stringify(global.achievements));
		file_text_close(_f);
	}
	if (variable_global_exists("achievement_popups")) global.achievement_popups = [];
}

// Checks to see if the game is playing
if(curr_game_state == GAME_STATE.PLAYING)
{
	// ─── TIMED MODE: countdown timer + continuous spawning ──────────
	if (is_timed_mode)
	{
		// Countdown timer using delta_time
		timed_time_left -= delta_time * 0.000001;
		
		if (timed_time_left <= 0)
		{
			timed_time_left = 0;
			lose_game();
			return;
		}
		
		// Spawn zombies up to 10 concurrent
		if (timed_spawn_cooldown > 0) timed_spawn_cooldown--;
		if (timed_spawn_cooldown <= 0 && instance_number(obj_enemy) < timed_max_concurrent)
		{
			timed_spawn_cooldown = timed_spawn_rate;
			// Pick a random spawner and push one to its queue
			var _spawners = [];
			with (obj_enemy_spawner) array_push(_spawners, id);
			if (array_length(_spawners) > 0)
			{
				var _s = _spawners[irandom(array_length(_spawners) - 1)];
				_s.spawn_queue++;
			}
		}
		// Skip the wave logic entirely below
	}
	else
	{
	// Checks for when new wave of enemies should be spawned
	// condition depends of if there are no enimes in the room
	// the current wave is not 0
	// and there are no banners present witin the room either
	if (instance_number(obj_enemy) <= 0 && instance_number(obj_boss) <= 0 && curr_wave != 0 && !instance_exists(obj_banner_wave_clear) && !instance_exists(obj_banner_wave_incoming))
	{
		// Check for if a new wave is called
		if (was_new_wave)
		{
			// Variable that is used to check spawner queues are empty
			var _is_queue_empty = true
			
			// Loops through all the spawners
			with (obj_enemy_spawner)
			{
				// Checks if queue has more spawns to come
				if (spawn_queue > 0)
				{
					// Sets variable to false indicating queue is not empty
					_is_queue_empty = false;	
				}
			}
			
			// Checks if queue's were empty
			if (_is_queue_empty)
			{
				// No max wave cap - keep incrementing forever
				curr_wave++;
				wave_cleared();
				was_new_wave = false;
			}
		}
		else
		{
			// Sets the check for new wave to true
			was_new_wave = true;
		}
	}
	// Checks if the current wave is 0 (game start)
	else if (curr_wave == 0)
	{
		// Skip wave start in tutorial mode - the overlay drives spawning
		if (is_tutorial_mode) { /* nothing */ }
		// Checks if the start timer has run down yet
		else if (start_time <= 0)
		{
			// Increments the current wave
			curr_wave++;
			// Runs the wave incoming function
			wave_incoming();
		}
		else
		{
			// Decreases the start time variable by 1 frame
			start_time -= delta_time * 0.000001;	
		}
	}
	}    // ← end of "not timed mode" branch
	
	// ─── SMOOTH SNIPER ZOOM ─────────────────────────────────────────
	var _base_vw = 1920;
	var _base_vh = 1080;
	// Sniper is "active for this wave" via sniper_active; the player can
	// freeze the zoom temporarily by pressing "1" (sniper_toggle_disabled)
	// without losing the wave-scoped power.
	var _effective_sniper = sniper_active && !sniper_toggle_disabled;
	var _target_zoom = _effective_sniper ? 1.5 : 1.0;
	// Faster lerp rate gives a more deliberate, less drifty transition;
	// snap more aggressively when very close to target to avoid the long
	// floating-point tail that can look choppy near the end.
	view_zoom_current = lerp(view_zoom_current, _target_zoom, 0.15);
	if (abs(view_zoom_current - _target_zoom) < 0.02) view_zoom_current = _target_zoom;
	var _cur_vw = _base_vw * view_zoom_current;
	var _cur_vh = _base_vh * view_zoom_current;
	camera_set_view_size(view_camera[0], _cur_vw, _cur_vh);
	_prev_sniper_active = sniper_active;
	
	// Use the freshly computed view dimensions (not querying GameMaker
	// in case the set hasn't yet propagated) to center on the player.
	var _x_adjust = _cur_vw / 2;
	var _y_adjust = _cur_vh / 2;
	
	// Sets the cameras intial position variables
	var _cam_x = 0;
	var _cam_y = 0;
	
	if (instance_exists(obj_player))
	{
		with (obj_player)
		{
			_cam_x += obj_player.x;
			_cam_y += obj_player.y;
		}
	}
	else
	{
		_cam_x = camera_get_view_x(view_camera[0]) + _x_adjust;
		_cam_y = camera_get_view_y(view_camera[0]) + _y_adjust;
	}
	
	// Clamp camera CENTER to keep view inside the 4096x4096 arena
	_cam_x = clamp(_cam_x, _x_adjust, (arena_grid_width * cell_width) - _x_adjust);
	_cam_y = clamp(_cam_y, _y_adjust, (arena_grid_height * cell_height) - _y_adjust);
	
	// Convert center to top-left for the view
	_cam_x -= _x_adjust;
	_cam_y -= _y_adjust;
	
	// Sets the camera view position
	camera_set_view_pos(view_camera[0], _cam_x, _cam_y);
	
	// Moves the game manager position to the cameras x and y position
	x = _cam_x;
	y = _cam_y;
}

// ─── COMBO TIMER TICK ────────────────────────────────────────────────
if (combo_timer > 0)
{
	combo_timer--;
	if (combo_timer <= 0)
	{
		combo_count = 0;
	}
}
if (screen_shake > 0) screen_shake = max(0, screen_shake - 0.5);

// Tick the damage vignette
if (damage_vignette_timer > 0) damage_vignette_timer--;
