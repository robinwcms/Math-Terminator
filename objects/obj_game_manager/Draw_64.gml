// Checks the current game state is playing
if(curr_game_state == GAME_STATE.PLAYING)
{	
	// Loops through the player objects
	with (obj_player)
	{
		// Draws the hud sprite in the top left corner
		draw_sprite(spr_hud_background, 0, 0, 0);
			
		// Checks if the player health is above 0
		if (player_health >= 1)
		{
			// Draws the first health bar sprite at full strength
			draw_sprite_ext(spr_hud_health, 0, 86, 40, 1.0, 1.0, 0, c_white, 1.0);	
			
			// Checks the players health is above 1
			if (player_health >= 2)
			{
				// Draws the second health sprite at full strength
				draw_sprite_ext(spr_hud_health, 0, 237, 40, 1.0, 1.0, 0, c_white, 1.0);
				
				// Checks the players health is above 2
				if (player_health >= 3)
				{
					// Draws the third health sprite at full strength
					draw_sprite_ext(spr_hud_health_end, 0, 385, 40, 1.0, 1.0, 0, c_white, 1.0);
				}
				else
				{
					// Draws the third health sprite at fade out alpha
					draw_sprite_ext(spr_hud_health_end, 0, 385, 40, 1.0, 1.0, 0, c_white, hud_health_alpha);
				}
			}
			else
			{
				// Draws the second health sprite at fade out alpha
				draw_sprite_ext(spr_hud_health, 0, 237, 40, 1.0, 1.0, 0, c_white, hud_health_alpha);	
			}
		}
		else
		{
			// Draws the first health bar sprite at fade out alpha
			draw_sprite_ext(spr_hud_health, 0, 86, 40, 1.0, 1.0, 0, c_white, hud_health_alpha);	
		}

		// Ammo HUD removed — player has infinite bullets
		
		// Sets the draw options for the scores text
		draw_set_font(obj_game_manager.score_font);
		draw_set_color(obj_game_manager.score_colour);
		draw_set_alpha(obj_game_manager.score_alpha);
		draw_set_halign(obj_game_manager.score_halign);
		draw_set_valign(obj_game_manager.score_valign);
		
		// Draws the score text
		draw_text(room_width / 2, 64, string(player_score));
		
		// Returns the draw options to defaults
		draw_set_color(c_white);
		draw_set_alpha(1.0);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}
	

	// ─── COMBO DISPLAY ─────────────────────────────────────────────
	if (combo_count >= 2)
	{
		var _scale = 1.0 + min(combo_count, 10) * 0.08;
		var _hue_r = 255;
		var _hue_g = clamp(255 - combo_count * 20, 100, 255);
		var _hue_b = clamp(60 - combo_count * 10, 0, 60);
		draw_set_font(fnt_luckiest_guy_36_outline);
		draw_set_color(make_color_rgb(_hue_r, _hue_g, _hue_b));
		draw_set_halign(fa_center);
		draw_set_valign(fa_top);
		draw_text_transformed(room_width / 2, 110,
			"COMBO x" + string(combo_count) + "!",
			_scale, _scale, 0);
		// Combo timer bar
		var _bw = 200;
		var _bh = 6;
		var _bx = room_width / 2 - _bw / 2;
		var _by = 175;
		draw_set_color(c_dkgray);
		draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);
		draw_set_color(c_yellow);
		draw_rectangle(_bx, _by, _bx + _bw * (combo_timer / combo_max_window), _by + _bh, false);
		draw_set_color(c_white);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}

	// ─── CREDITS DISPLAY (below health, above powerup HUD) ──────────
	var _credits_y = 200;
	// Coin icon shadow
	draw_set_color(c_black);
	draw_set_alpha(0.35);
	draw_circle(58 + 2, _credits_y + 2, 20, false);
	draw_set_alpha(1.0);
	// Coin gold fill
	draw_set_color(make_color_rgb(255, 215, 0));
	draw_circle(58, _credits_y, 20, false);
	// Dark outline
	draw_set_color(make_color_rgb(140, 100, 0));
	draw_circle(58, _credits_y, 20, true);
	draw_circle(58, _credits_y, 21, true);
	// "$" inside the coin
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(make_color_rgb(140, 100, 0));
	draw_text(58, _credits_y + 3, "$");
	// Credit value
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_text(90, _credits_y, string(global.credits));
	// Reset
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	// ─── POWERUP STATUS HUD ────────────────────────────────────────
	if (instance_exists(obj_player))
	{
		var _pl = obj_player;
		var _hx = 60;
		var _hy = 250;
		var _spacing = 50;
		var _slot = 0;
		
		draw_set_font(fnt_luckiest_guy_24);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		
		if (_pl.shield_timer > 0) {
			draw_set_color(make_color_rgb(80, 180, 220));
			draw_circle(_hx, _hy + _slot * _spacing, 18, false);
			draw_set_color(c_white);
			draw_text(_hx + 32, _hy + _slot * _spacing, "Shield " + string(ceil(_pl.shield_timer/60)) + "s");
			_slot++;
		}
		if (_pl.speed_boost_timer > 0) {
			draw_set_color(make_color_rgb(255, 200, 0));
			draw_circle(_hx, _hy + _slot * _spacing, 18, false);
			draw_set_color(c_white);
			draw_text(_hx + 32, _hy + _slot * _spacing, "Speed " + string(ceil(_pl.speed_boost_timer/60)) + "s");
			_slot++;
		}
		if (_pl.rapid_fire_timer > 0) {
			draw_set_color(make_color_rgb(255, 100, 0));
			draw_circle(_hx, _hy + _slot * _spacing, 18, false);
			draw_set_color(c_white);
			draw_text(_hx + 32, _hy + _slot * _spacing, "Rapid " + string(ceil(_pl.rapid_fire_timer/60)) + "s");
			_slot++;
		}
		if (_pl.freeze_timer > 0) {
			draw_set_color(make_color_rgb(140, 220, 255));
			draw_circle(_hx, _hy + _slot * _spacing, 18, false);
			draw_set_color(c_white);
			draw_text(_hx + 32, _hy + _slot * _spacing, "Freeze " + string(ceil(_pl.freeze_timer/60)) + "s");
			_slot++;
		}
		
		draw_set_color(c_white);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}

	// ─── HUD: timer for timed mode (top-left, below health) ──────────
	if (is_timed_mode)
	{
		draw_set_font(fnt_luckiest_guy_36_outline);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		var _secs = max(0, ceil(timed_time_left));
		var _mins = floor(_secs / 60);
		var _ss   = _secs mod 60;
		var _str = string(_mins) + ":" + (_ss < 10 ? "0" : "") + string(_ss);
		// Flash red in last 10s
		draw_set_color(timed_time_left <= 10 ? c_red : c_yellow);
		draw_text(580, 30, "TIME  " + _str);
	}
	
	// ─── ACTIVE STATUS INDICATORS (right side) ──────────────────────
	// The full inventory list is now in the E menu instead of the HUD.
	{
		var _inv_x = display_get_gui_width() - 80;
		var _act_y = 130;
		draw_set_font(fnt_luckiest_guy_24);
		draw_set_halign(fa_right);
		draw_set_valign(fa_middle);
		if (double_points_active) {
			draw_set_color(make_color_rgb(255, 215, 0));
			draw_text(_inv_x, _act_y, "x2 POINTS ACTIVE");
			_act_y += 30;
		}
		if (sniper_active) {
			draw_set_color(make_color_rgb(150, 150, 230));
			draw_text(_inv_x, _act_y, "SNIPER ACTIVE");
		}
		// Reset
		draw_set_color(c_white);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}
	
	// ─── MINIMAP (bottom-right corner) ──────────────────────────────
	if (!is_tutorial_mode)
	{
		var _gw = display_get_gui_width();
		var _gh = display_get_gui_height();
		var _mm_w = 220;
		var _mm_h = 220;
		var _mm_pad = 20;
		var _mm_x = _gw - _mm_w - _mm_pad;
		var _mm_y = _gh - _mm_h - _mm_pad - 30;
		
		// Background
		draw_set_color(c_black);
		draw_set_alpha(0.55);
		draw_rectangle(_mm_x, _mm_y, _mm_x + _mm_w, _mm_y + _mm_h, false);
		draw_set_alpha(0.85);
		draw_set_color(c_white);
		draw_rectangle(_mm_x, _mm_y, _mm_x + _mm_w, _mm_y + _mm_h, true);
		draw_set_alpha(1.0);
		
		// World area
		var _world_w = arena_grid_width * cell_width;
		var _world_h = arena_grid_height * cell_height;
		var _scale_x = _mm_w / _world_w;
		var _scale_y = _mm_h / _world_h;
		
		// Collect zombie positions (regular) — skip spawning ones
		var _enemy_count = instance_number(obj_enemy);
		for (var _i = 0; _i < _enemy_count; _i++) {
			var _e = instance_find(obj_enemy, _i);
			if (!instance_exists(_e)) continue;
			if (_e.is_spawning) continue;     // skip enemies still in spawner
			// Clamp to room bounds to avoid drawing outside the map square
			var _ex = clamp(_e.x, 0, _world_w);
			var _ey = clamp(_e.y, 0, _world_h);
			var _dx = _mm_x + _ex * _scale_x;
			var _dy = _mm_y + _ey * _scale_y;
			draw_set_color(c_red);
			draw_circle(_dx, _dy, 3, false);
		}
		// Boss
		var _boss_count = instance_number(obj_boss);
		for (var _i = 0; _i < _boss_count; _i++) {
			var _b = instance_find(obj_boss, _i);
			if (!instance_exists(_b)) continue;
			var _dx = _mm_x + _b.x * _scale_x;
			var _dy = _mm_y + _b.y * _scale_y;
			draw_set_color(make_color_rgb(255, 80, 80));
			draw_circle(_dx, _dy, 8, false);
			draw_set_color(c_white);
			draw_circle(_dx, _dy, 8, true);
		}
		// Coins
		var _coin_count = instance_number(obj_coin);
		for (var _i = 0; _i < _coin_count; _i++) {
			var _c = instance_find(obj_coin, _i);
			if (!instance_exists(_c)) continue;
			var _dx = _mm_x + _c.x * _scale_x;
			var _dy = _mm_y + _c.y * _scale_y;
			draw_set_color(make_color_rgb(255, 215, 0));
			draw_circle(_dx, _dy, 2, false);
		}
		// Powerups
		var _pu_count = instance_number(obj_powerup);
		for (var _i = 0; _i < _pu_count; _i++) {
			var _p = instance_find(obj_powerup, _i);
			if (!instance_exists(_p)) continue;
			var _dx = _mm_x + _p.x * _scale_x;
			var _dy = _mm_y + _p.y * _scale_y;
			draw_set_color(make_color_rgb(120, 220, 220));
			draw_circle(_dx, _dy, 3, false);
		}
		// Player (drawn last)
		if (instance_exists(obj_player)) {
			var _pdx = _mm_x + obj_player.x * _scale_x;
			var _pdy = _mm_y + obj_player.y * _scale_y;
			draw_set_color(make_color_rgb(80, 255, 80));
			draw_circle(_pdx, _pdy, 5, false);
			draw_set_color(c_white);
			draw_circle(_pdx, _pdy, 5, true);
		}
		
		// "MAP" label
		draw_set_font(fnt_luckiest_guy_24);
		draw_set_color(c_white);
		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		draw_text(_mm_x + _mm_w / 2, _mm_y - 2, "MAP");
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}
	
	// Draw hint at bottom of screen (skip during tutorial to keep UI clean)
	if (!is_tutorial_mode)
	{
		draw_set_font(fnt_luckiest_guy_24);
		draw_set_color(c_white);
		draw_set_alpha(0.6);
		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		draw_text(room_width / 2, room_height - 12, "Shoot the numbered circle that answers the math problem!");
		draw_set_alpha(1.0);
	}
	
	// Reset draw settings
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	// Hides the cursor
	window_set_cursor(cr_none);
	
	// Sets the alpha to 0.5 for the crosshair
	draw_set_alpha(0.5);
	
	// Checks if the player is aiming (only if player still exists)
	if (instance_exists(obj_player))
	{
		if (obj_player.is_mouse_aiming)
		{
			// Draws the crosshair sprite at the mouse's actual screen position.
			// Must convert from world coords (mouse_x/mouse_y) to GUI coords,
			// scaling by GUI-to-view ratio so it works at any zoom (e.g. sniper).
			var _vx = camera_get_view_x(view_camera[0]);
			var _vy = camera_get_view_y(view_camera[0]);
			var _vw = camera_get_view_width(view_camera[0]);
			var _vh = camera_get_view_height(view_camera[0]);
			var _gw = display_get_gui_width();
			var _gh = display_get_gui_height();
			var _ch_gui_x = (mouse_x - _vx) / _vw * _gw;
			var _ch_gui_y = (mouse_y - _vy) / _vh * _gh;
			draw_sprite(spr_crosshair, 0, _ch_gui_x, _ch_gui_y);
		}
		else
		{
			// Crosshair position offsets (world-space units ahead of the player)
			var _offset_x = 400;
			var _offset_y = 0;
			
			// Converts angle to radians
			var _theta = degtorad(real(obj_player.gun_angle));
		
			// Calculates the world-space crosshair position ahead of the player
			var _crosshair_adjust_x = (_offset_x * cos(_theta)) - (_offset_y * sin(_theta));
			var _crosshair_adjust_y = (_offset_y * cos(_theta)) + (_offset_x * sin(_theta));
		
			// World-space crosshair position
			var _crosshair_world_x = obj_player.x + _crosshair_adjust_x;
			var _crosshair_world_y = obj_player.y - _crosshair_adjust_y;
			
			// Convert world position to GUI coordinates using the current camera/view.
			// This correctly handles sniper zoom (or any view size) because it uses
			// the actual view dimensions rather than assuming room_width == GUI width.
			var _vx = camera_get_view_x(view_camera[0]);
			var _vy = camera_get_view_y(view_camera[0]);
			var _vw = camera_get_view_width(view_camera[0]);
			var _vh = camera_get_view_height(view_camera[0]);
			var _gw = display_get_gui_width();
			var _gh = display_get_gui_height();
			
			var _crosshair_pos_x = (_crosshair_world_x - _vx) / _vw * _gw;
			var _crosshair_pos_y = (_crosshair_world_y - _vy) / _vh * _gh;
			
			// Sets buffer for crosshair to be within the GUI viewport
			var _crosshair_buffer = 60;
			
			// Clamps crosshair positions to be within the visible GUI area
			_crosshair_pos_x = clamp(_crosshair_pos_x, _crosshair_buffer, _gw - _crosshair_buffer);
			_crosshair_pos_y = clamp(_crosshair_pos_y, _crosshair_buffer, _gh - _crosshair_buffer);
			
			// Draws the crosshair at the GUI-space position
			draw_sprite(spr_crosshair, 0, _crosshair_pos_x, _crosshair_pos_y);
		}
	}
	
	// Resets the draw alpha
	draw_set_alpha(1.0);
}
else
{
	// Shows the default normal cursor
	window_set_cursor(cr_default);
}

// ─── DEBUG OVERLAY (toggle with gamepad Y) ──────────────────────────
if (show_debug)
{
	var _dbg_x = 10;
	var _dbg_y = display_get_gui_height() - 10;
	var _dbg_line = 22;
	
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_halign(fa_left);
	draw_set_valign(fa_bottom);
	draw_set_alpha(0.85);
	
	// Background panel
	var _panel_w = 420;
	var _panel_h = _dbg_line * 10 + 10;
	draw_set_color(c_black);
	draw_rectangle(_dbg_x, _dbg_y - _panel_h, _dbg_x + _panel_w, _dbg_y, false);
	draw_set_color(c_lime);
	draw_rectangle(_dbg_x, _dbg_y - _panel_h, _dbg_x + _panel_w, _dbg_y, true);
	draw_set_alpha(1.0);
	
	draw_set_color(c_lime);
	var _row = 1;
	
	// FPS
	draw_text(_dbg_x + 8, _dbg_y - (_panel_h - _dbg_line * _row), "FPS: " + string(fps) + "  real: " + string(fps_real));
	_row++;
	
	// Game state
	draw_text(_dbg_x + 8, _dbg_y - (_panel_h - _dbg_line * _row), "State: " + string(curr_game_state) + "  Wave: " + string(curr_wave));
	_row++;
	
	// Camera info
	var _vx2 = camera_get_view_x(view_camera[0]);
	var _vy2 = camera_get_view_y(view_camera[0]);
	var _vw2 = camera_get_view_width(view_camera[0]);
	var _vh2 = camera_get_view_height(view_camera[0]);
	draw_text(_dbg_x + 8, _dbg_y - (_panel_h - _dbg_line * _row), "View pos: " + string(floor(_vx2)) + ", " + string(floor(_vy2)));
	_row++;
	draw_text(_dbg_x + 8, _dbg_y - (_panel_h - _dbg_line * _row), "View size: " + string(_vw2) + " x " + string(_vh2));
	_row++;
	
	// Sniper state
	draw_set_color(sniper_active ? c_yellow : c_lime);
	draw_text(_dbg_x + 8, _dbg_y - (_panel_h - _dbg_line * _row), "Sniper: " + string(sniper_active));
	draw_set_color(c_lime);
	_row++;
	
	if (instance_exists(obj_player))
	{
		var _pl2 = obj_player;
		// Player world position
		draw_text(_dbg_x + 8, _dbg_y - (_panel_h - _dbg_line * _row), "Player: " + string(floor(_pl2.x)) + ", " + string(floor(_pl2.y)));
		_row++;
		// Gun angle
		draw_text(_dbg_x + 8, _dbg_y - (_panel_h - _dbg_line * _row), "Gun angle: " + string(floor(_pl2.gun_angle)) + " deg");
		_row++;
		// Mouse world position
		draw_text(_dbg_x + 8, _dbg_y - (_panel_h - _dbg_line * _row), "Mouse (world): " + string(floor(mouse_x)) + ", " + string(floor(mouse_y)));
		_row++;
		// Mouse GUI position
		draw_text(_dbg_x + 8, _dbg_y - (_panel_h - _dbg_line * _row), "Mouse (GUI): " + string(floor(device_mouse_x_to_gui(0))) + ", " + string(floor(device_mouse_y_to_gui(0))));
		_row++;
		// Aiming mode
		draw_text(_dbg_x + 8, _dbg_y - (_panel_h - _dbg_line * _row), "Mouse aim: " + string(_pl2.is_mouse_aiming));
	}
	
	// Reset draw state
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1.0);
}

// ─── DAMAGE VIGNETTE (red gradient when hit) ──────────────────────────
// Skip during airstrike (its own UI takes priority) AND when the game has
// ended (player just died — death screen takes over, no need to flash red).
if (damage_vignette_timer > 0
	&& !instance_exists(obj_airstrike)
	&& curr_game_state != GAME_STATE.ENDED)
{
	var _vw = display_get_gui_width();
	var _vh = display_get_gui_height();
	var _t = damage_vignette_timer / damage_vignette_max;     // 1 → 0 over the fade
	// Push the peak above 1.0 so the outermost bands fully saturate
	// (alpha clamps at 1.0 anyway). Net effect: deeper red at the edges
	// without changing the smooth shape of the falloff.
	var _peak_alpha = _t * 1.4;
	
	// Smooth gradient with extra red intensity. Two-pass approach:
	//   Pass 1 — saturated deep red at the screen edges (the "wound" feel)
	//   Pass 2 — fainter warm tint reaching further toward center, giving
	//            the gradient a more organic glow rather than a hard frame.
	var _layers = 80;                            // more layers = smoother gradient
	var _max_inset = min(_vw, _vh) * 0.55;       // gradient depth
	var _col_deep = make_color_rgb(220, 30, 50); // deep red — the harsh edge color
	var _col_warm = make_color_rgb(255, 80, 80); // brighter warm red — bleeds inward
	
	// ── Pass 1: deep red, drops off relatively quickly ───────────────
	for (var _l = 0; _l < _layers; _l++)
	{
		var _layer_frac = _l / _layers;          // 0 at edge, 1 at innermost
		var _inset = _max_inset * _layer_frac;
		// power 1.5 — slower falloff than quadratic, holds the color
		// further in for more "presence", but still smooth
		var _ramp = 1 - _layer_frac;
		var _layer_alpha = _peak_alpha * power(_ramp, 1.5) / _layers * 4;
		if (_layer_alpha <= 0.001) continue;
		draw_set_color(_col_deep);
		draw_set_alpha(min(_layer_alpha, 1.0));
		var _band = (_max_inset / _layers) + 1;
		draw_rectangle(0, _inset, _vw, _inset + _band, false);
		draw_rectangle(0, _vh - _inset - _band, _vw, _vh - _inset, false);
		draw_rectangle(_inset, 0, _inset + _band, _vh, false);
		draw_rectangle(_vw - _inset - _band, 0, _vw - _inset, _vh, false);
	}
	
	// ── Pass 2: warm tint, reaches deeper toward the center ──────────
	// Uses a flatter falloff curve so the warm color bleeds further in,
	// giving the vignette an organic "your character is hurting" feel
	// without the gradient ever looking like a flat colored frame.
	var _inner_inset = min(_vw, _vh) * 0.75;
	for (var _l = 0; _l < _layers; _l++)
	{
		var _layer_frac = _l / _layers;
		var _inset = _inner_inset * _layer_frac;
		var _ramp = 1 - _layer_frac;
		// linear-ish falloff for the warm layer (power 1.2) at lower peak
		var _layer_alpha = (_t * 0.35) * power(_ramp, 1.2) / _layers * 4;
		if (_layer_alpha <= 0.001) continue;
		draw_set_color(_col_warm);
		draw_set_alpha(min(_layer_alpha, 1.0));
		var _band = (_inner_inset / _layers) + 1;
		draw_rectangle(0, _inset, _vw, _inset + _band, false);
		draw_rectangle(0, _vh - _inset - _band, _vw, _vh - _inset, false);
		draw_rectangle(_inset, 0, _inset + _band, _vh, false);
		draw_rectangle(_vw - _inset - _band, 0, _vw - _inset, _vh, false);
	}
	
	draw_set_alpha(1.0);
	draw_set_color(c_white);
}

// ─── ACHIEVEMENT POPUPS (top-center toast) ────────────────────────────
if (array_length(global.achievement_popups) > 0)
{
	var _gw_a = display_get_gui_width();
	var _p = global.achievement_popups[0];
	_p.timer--;
	if (_p.timer <= 0)
	{
		array_delete(global.achievement_popups, 0, 1);
	}
	else
	{
		// Slide in/out for the first/last 30 frames
		var _full = 240;
		var _slide_in = 30;
		var _slide_out = 30;
		var _y_off = 0;
		if (_p.timer > _full - _slide_in)
		{
			var _t = (_full - _p.timer) / _slide_in;
			_y_off = -120 + 120 * _t;
		}
		else if (_p.timer < _slide_out)
		{
			var _t = _p.timer / _slide_out;
			_y_off = -120 * (1 - _t);
		}
		var _panel_w = 520;
		var _panel_h = 90;
		var _panel_x = _gw_a / 2 - _panel_w / 2;
		var _panel_y = 30 + _y_off;
		// Background
		draw_set_color(make_color_rgb(30, 30, 45));
		draw_set_alpha(0.95);
		draw_roundrect(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, false);
		draw_set_color(make_color_rgb(255, 215, 0));
		draw_roundrect(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, true);
		draw_roundrect(_panel_x + 1, _panel_y + 1, _panel_x + _panel_w - 1, _panel_y + _panel_h - 1, true);
		// Trophy icon
		draw_set_color(make_color_rgb(255, 215, 0));
		draw_circle(_panel_x + 45, _panel_y + _panel_h / 2, 24, false);
		draw_set_color(c_black);
		draw_set_font(fnt_luckiest_guy_24);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(_panel_x + 45, _panel_y + _panel_h / 2 + 3, "!");
		// "ACHIEVEMENT" small label
		draw_set_color(make_color_rgb(255, 215, 0));
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_text_transformed(_panel_x + 90, _panel_y + 14, "ACHIEVEMENT UNLOCKED", 0.6, 0.6, 0);
		// Name
		draw_set_color(c_white);
		draw_text(_panel_x + 90, _panel_y + 40, _p.name);
		// Desc small
		draw_set_color(make_color_rgb(180, 180, 200));
		draw_text_transformed(_panel_x + 90, _panel_y + 68, _p.desc, 0.7, 0.7, 0);
		draw_set_alpha(1.0);
		draw_set_color(c_white);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}
}
