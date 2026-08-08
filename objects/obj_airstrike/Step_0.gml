if (flash_timer > 0) flash_timer--;

// Force game state to PAUSED every frame so the player and game manager
// reliably gate their own Step logic. (Without this, anything that flips
// state during the airstrike — e.g. the popup that launched it — could
// let the player keep moving.)
obj_game_manager.curr_game_state = GAME_STATE.PAUSED;

// Keep the PLAYER strictly still every frame. Zombies/boss/projectiles were
// already zeroed once in Create — don't keep zeroing them, or their path-
// follow lerp will be stuck at 0 and they'll stay frozen for ~1s after the
// airstrike ends (speed_rate is 0.05).
if (instance_exists(obj_player))
{
	obj_player.hspeed = 0;
	obj_player.vspeed = 0;
	obj_player.speed = 0;
}

if (phase == "math")
{
	// Wait for flash to clear before next question
	if (flash_timer > 0) exit;
	
	// If we just answered correctly, advance
	if (questions_left == 0) {
		phase = "select";
		exit;
	}
	
	if (!mouse_check_button_pressed(mb_left)) exit;
	var _mx = device_mouse_x_to_gui(0);
	var _my = device_mouse_y_to_gui(0);
	var _cx = display_get_gui_width() / 2;
	var _cy = display_get_gui_height() / 2;
	
	// Cancel button top-left
	if (point_in_box(_mx, _my, 30, 30, 100, 40)) {
		// Refund the airstrike
		global.inv_airstrike++;
		obj_game_manager.curr_game_state = prev_state;
		if (instance_exists(obj_player))
		{
			obj_player.hspeed = 0;
			obj_player.vspeed = 0;
			obj_player.speed = 0;
		}
		instance_destroy();
		return;
	}
	
	// 2x2 grid of answers
	var _btn_w = 220;
	var _btn_h = 100;
	var _gap = 30;
	var _grid_w = _btn_w * 2 + _gap;
	var _grid_h = _btn_h * 2 + _gap;
	var _gx0 = _cx - _grid_w / 2;
	var _gy0 = _cy - 40;
	for (var _i = 0; _i < 4; _i++) {
		var _col = _i mod 2;
		var _row = _i div 2;
		var _bx = _gx0 + _col * (_btn_w + _gap);
		var _by = _gy0 + _row * (_btn_h + _gap);
		if (point_in_box(_mx, _my, _bx, _by, _btn_w, _btn_h)) {
			if (choices[_i] == question_answer) {
				flash_correct = true;
				flash_timer = 30;
				questions_left--;
				if (questions_left > 0) gen_question();
			} else {
				// Wrong: fail, refund, exit
				global.inv_airstrike++;
				obj_game_manager.curr_game_state = prev_state;
				if (instance_exists(obj_player))
		{
			obj_player.hspeed = 0;
			obj_player.vspeed = 0;
			obj_player.speed = 0;
		}
		instance_destroy();
				return;
			}
			return;
		}
	}
}
else if (phase == "select")
{
	// Allow WASD to pan the camera around the map during target selection
	var _pan_speed = 18;
	var _cam_x = camera_get_view_x(view_camera[0]);
	var _cam_y = camera_get_view_y(view_camera[0]);
	var _cam_w = camera_get_view_width(view_camera[0]);
	var _cam_h = camera_get_view_height(view_camera[0]);
	var _world_w = obj_game_manager.arena_grid_width * obj_game_manager.cell_width;
	var _world_h = obj_game_manager.arena_grid_height * obj_game_manager.cell_height;
	
	if (keyboard_check(ord("A"))) _cam_x -= _pan_speed;
	if (keyboard_check(ord("D"))) _cam_x += _pan_speed;
	if (keyboard_check(ord("W"))) _cam_y -= _pan_speed;
	if (keyboard_check(ord("S"))) _cam_y += _pan_speed;
	
	// Clamp camera to inside the world bounds. Small inset just to hide
	// the very edge of the wall texture.
	var _inset = 100;
	_cam_x = clamp(_cam_x, _inset, max(_inset, _world_w - _cam_w - _inset));
	_cam_y = clamp(_cam_y, _inset, max(_inset, _world_h - _cam_h - _inset));
	camera_set_view_pos(view_camera[0], _cam_x, _cam_y);
	
	if (!mouse_check_button_pressed(mb_left)) exit;
	
	// Cancel button (GUI coords)
	var _mx_gui = device_mouse_x_to_gui(0);
	var _my_gui = device_mouse_y_to_gui(0);
	if (point_in_box(_mx_gui, _my_gui, 30, 30, 100, 40)) {
		global.inv_airstrike++;
		obj_game_manager.curr_game_state = prev_state;
		if (instance_exists(obj_player))
		{
			obj_player.hspeed = 0;
			obj_player.vspeed = 0;
			obj_player.speed = 0;
		}
		instance_destroy();
		return;
	}
	
	// Use WORLD mouse coords (mouse_x / mouse_y) for strike target
	var _wx = mouse_x;
	var _wy = mouse_y;
	
	// Strike radius (world units)
	var _strike_r = 400;
	// Kill all zombies within radius
	with (obj_enemy) {
		if (point_distance(x, y, _wx, _wy) < _strike_r) {
			curr_health = 0;
			instance_destroy();
		}
	}
	// Boss takes 2 HP from a direct strike
	with (obj_boss) {
		if (point_distance(x, y, _wx, _wy) < _strike_r) {
			curr_health = max(0, curr_health - 2);
			is_flashed = true;
			flash_cooldown = flash_time;
		}
	}
	
	// Resume game
	obj_game_manager.curr_game_state = prev_state;
	with (obj_game_manager) screen_shake = 20;
	if (instance_exists(obj_player))
	{
		obj_player.hspeed = 0;
		obj_player.vspeed = 0;
		obj_player.speed = 0;
		obj_player.input_lockout = 10;
	}
	// Snap zombies' velocity to their current path direction so they don't
	// have to ramp up from 0 (which takes ~1 second with speed_rate 0.05).
	with (obj_enemy)
	{
		if (instance_exists(target) && !is_spawning)
		{
			var _dir = point_direction(x, y, target.x, target.y);
			hspeed = lengthdir_x(max_speed, _dir);
			vspeed = lengthdir_y(max_speed, _dir);
		}
	}
	instance_destroy();
}
