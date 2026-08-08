// Toggle fullscreen with F11 or exit fullscreen with M (works on menu screens)
if (keyboard_check_pressed(vk_f11))
{
	window_set_fullscreen(!window_get_fullscreen());
}
if (keyboard_check_pressed(ord("M")) && window_get_fullscreen())
{
	window_set_fullscreen(false);
}

// Admin: lowercase 'u' resets all achievements
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

// Scroll achievements panel with mouse wheel — page-snap by one row
if (is_achievements && achievements_alpha > 0.5)
{
	// card_h 180 + gap_y 18 = 198 per row
	if (mouse_wheel_down()) achievements_scroll = min(achievements_scroll + 198, 600);
	if (mouse_wheel_up())   achievements_scroll = max(achievements_scroll - 198, 0);
}
else if (!is_achievements)
{
	achievements_scroll = 0;
}

// Scroll loadout panel with mouse wheel — page-snap by TWO rows (one page)
if (is_loadout_panel && loadout_alpha > 0.5)
{
	// 2 rows × (card_h 150 + gap_y 16) = 332 per page
	if (mouse_wheel_down()) loadout_scroll = min(loadout_scroll + 332, 800);
	if (mouse_wheel_up())   loadout_scroll = max(loadout_scroll - 332, 0);
	loadout_scroll_target = loadout_scroll;
}
else if (!is_loadout_panel)
{
	loadout_scroll = 0;
	loadout_scroll_target = 0;
}

// Only respond to clicks when highscore overlay is visible — but skip this
// guard if we're handling recent-games panel logic at the bottom.
if ((!is_highscore_table || highscores_alpha < 0.5)
	&& !mouse_check_button_pressed(mb_left)) exit;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _cw = display_get_gui_width();
var _ch = display_get_gui_height();
var _cx = _cw / 2;
var _cy = _ch / 2;

// Only do highscore-specific click handling when the highscore panel is up
if (is_highscore_table && highscores_alpha >= 0.5
	&& mouse_check_button_pressed(mb_left))
{
	var _panel_w = 760;
	var _panel_h = 720;
	var _panel_x = _cx - _panel_w / 2;
	var _panel_y = _cy - _panel_h / 2;

// Close button (top-right X)
{
	var _x_cx = _panel_x + _panel_w - 36;
	var _x_cy = _panel_y + 36;
	var _x_half = 28;
	if (_mx >= _x_cx - _x_half && _mx <= _x_cx + _x_half
	 && _my >= _x_cy - _x_half && _my <= _x_cy + _x_half)
	{
		is_highscore_table = false;
		return;
	}
}

// Tab click detection
var _tab_y = _panel_y + 100;
var _tab_h = 48;
var _tab_total_w = _panel_w - 80;
var _tab_w = _tab_total_w / array_length(global.hs_modes);
for (var _t = 0; _t < array_length(global.hs_modes); _t++)
{
	var _tx = _panel_x + 40 + _t * _tab_w;
	if (_mx >= _tx && _mx <= _tx + _tab_w - 4 && _my >= _tab_y && _my <= _tab_y + _tab_h)
	{
		hs_tab = _t;
		load_highscores_for(global.hs_modes[hs_tab].key);
		return;
	}
}

// Reset button
var _btn_w = 280;
var _btn_h = 56;
var _btn_x = _cx - _btn_w / 2;
var _btn_y = _panel_y + _panel_h - 76;
if (_mx >= _btn_x && _mx <= _btn_x + _btn_w
	&& _my >= _btn_y && _my <= _btn_y + _btn_h)
{
	// Zero out and persist the wipe to the current tab file only
	for (var _i = 0; _i < 10; _i++) highscores[_i] = 0;
	var _buf = buffer_create(16384, buffer_fixed, 2);
	buffer_seek(_buf, buffer_seek_start, 0);
	for (var _i = 0; _i < 10; _i++) {
		buffer_write(_buf, buffer_u64, 0);
	}
	buffer_save(_buf, global.hs_modes[hs_tab].key);
	buffer_delete(_buf);
	return;
}
}   // end of highscore-specific click block

// ═══ RECENT GAMES BUTTON & PANEL CLICK HANDLING ════════════════════
// Read mouse fresh here in case the earlier exits in this Step caused us to skip
if (mouse_check_button_pressed(mb_left))
{
	var _mx_r = device_mouse_x_to_gui(0);
	var _my_r = device_mouse_y_to_gui(0);
	var _gw_r = display_get_gui_width();
	var _gh_r = display_get_gui_height();
	
	// "ACHIEVEMENTS" corner button (always visible)
	{
		var _ab_w = 280;
		var _ab_h = 70;
		var _ab_x = _gw_r - _ab_w - 24;
		var _ab_y = 440;
		if (!is_recent_games && !is_highscore_table && !is_achievements
			&& !is_daily_panel && !is_loadout_panel
			&& _mx_r >= _ab_x && _mx_r <= _ab_x + _ab_w
			&& _my_r >= _ab_y && _my_r <= _ab_y + _ab_h)
		{
			audio_play_sound(snd_menu_button, 100, false, 0.01, 0, 1.0); is_achievements = true;
			exit;
		}
	}
	
	// "DAILY" corner button
	{
		var _db_w = 280;
		var _db_h = 70;
		var _db_x = _gw_r - _db_w - 24;
		var _db_y = 524;
		if (!is_recent_games && !is_highscore_table && !is_achievements
			&& !is_daily_panel && !is_loadout_panel
			&& _mx_r >= _db_x && _mx_r <= _db_x + _db_w
			&& _my_r >= _db_y && _my_r <= _db_y + _db_h)
		{
			// Reload completion data from disk in case the player just finished a run
			global.daily_completed_dates = [];
			if (file_exists("daily_completed.sav"))
			{
				var _fd = file_text_open_read("daily_completed.sav");
				var _dj = "";
				while (!file_text_eof(_fd))
				{
					_dj += file_text_read_string(_fd);
					file_text_readln(_fd);
				}
				file_text_close(_fd);
				if (_dj != "")
				{
					try {
						var _da = json_parse(_dj);
						if (is_array(_da)) global.daily_completed_dates = _da;
					} catch (_e) {}
				}
			}
			audio_play_sound(snd_menu_button, 100, false, 0.01, 0, 1.0); is_daily_panel = true;
			exit;
		}
	}
	
	// "LOADOUT" corner button
	{
		var _lb_w = 280;
		var _lb_h = 70;
		var _lb_x = _gw_r - _lb_w - 24;
		var _lb_y = 608;
		if (!is_recent_games && !is_highscore_table && !is_achievements
			&& !is_daily_panel && !is_loadout_panel
			&& _mx_r >= _lb_x && _mx_r <= _lb_x + _lb_w
			&& _my_r >= _lb_y && _my_r <= _lb_y + _lb_h)
		{
			audio_play_sound(snd_menu_button, 100, false, 0.01, 0, 1.0); is_loadout_panel = true;
			exit;
		}
	}
	
	// Close X for achievements panel
	if (is_achievements && achievements_alpha > 0.5)
	{
		var _ap_w = 980;
		var _ap_h = 760;
		var _ap_x = _gw_r / 2 - _ap_w / 2;
		var _ap_y = _gh_r / 2 - _ap_h / 2;
		var _x_cx = _ap_x + _ap_w - 36;
		var _x_cy = _ap_y + 36;
		if (_mx_r >= _x_cx - 28 && _mx_r <= _x_cx + 28
		 && _my_r >= _x_cy - 28 && _my_r <= _x_cy + 28)
		{
			is_achievements = false;
			exit;
		}
		// Click outside panel closes
		if (_mx_r < _ap_x || _mx_r > _ap_x + _ap_w
		 || _my_r < _ap_y || _my_r > _ap_y + _ap_h)
		{
			is_achievements = false;
			exit;
		}
	}
	
	// Daily panel: just the close X (it's a viewer, no START button)
	if (is_daily_panel && daily_alpha > 0.5)
	{
		var _dp_w = 760;
		var _dp_h = 540;
		var _dp_x = _gw_r / 2 - _dp_w / 2;
		var _dp_y = _gh_r / 2 - _dp_h / 2;
		// Close X
		var _x_cx_d = _dp_x + _dp_w - 36;
		var _x_cy_d = _dp_y + 36;
		if (_mx_r >= _x_cx_d - 28 && _mx_r <= _x_cx_d + 28
		 && _my_r >= _x_cy_d - 28 && _my_r <= _x_cy_d + 28)
		{
			is_daily_panel = false;
			exit;
		}
		// Click outside closes
		if (_mx_r < _dp_x || _mx_r > _dp_x + _dp_w
		 || _my_r < _dp_y || _my_r > _dp_y + _dp_h)
		{
			is_daily_panel = false;
			exit;
		}
	}
	
	// Loadout panel: close X + item toggles
	if (is_loadout_panel && loadout_alpha > 0.5)
	{
		var _lp_w = 880;
		var _lp_h = 680;
		var _lp_x = _gw_r / 2 - _lp_w / 2;
		var _lp_y = _gh_r / 2 - _lp_h / 2;
		// Close X
		var _x_cx_l = _lp_x + _lp_w - 36;
		var _x_cy_l = _lp_y + 36;
		if (_mx_r >= _x_cx_l - 28 && _mx_r <= _x_cx_l + 28
		 && _my_r >= _x_cy_l - 28 && _my_r <= _x_cy_l + 28)
		{
			is_loadout_panel = false;
			// Persist picks to the global
			global.loadout_picks = [];
			for (var _li = 0; _li < array_length(loadout_items); _li++)
			{
				if (loadout_items[_li].picked)
					array_push(global.loadout_picks, loadout_items[_li].key);
			}
			exit;
		}
		// Item grid click toggle — respects scroll position + viewport bounds
		var _it_w = 180;
		var _it_h = 150;
		var _it_gx = 16;
		var _it_gy = 16;
		var _grid_w = _it_w * 4 + _it_gx * 3;
		var _gx_start = _gw_r / 2 - _grid_w / 2;
		var _gy_base = _lp_y + 180;
		var _viewport_top_l = _lp_y + 176;
		var _viewport_bot_l = _lp_y + 180 + 316 + 4;
		for (var _i = 0; _i < array_length(loadout_items); _i++)
		{
			var _col = _i mod 4;
			var _row = _i div 4;
			var _ix = _gx_start + _col * (_it_w + _it_gx);
			var _iy = _gy_base + _row * (_it_h + _it_gy) - loadout_scroll;
			// Skip cards that aren't mostly inside the viewport
			if (_iy < _viewport_top_l || _iy + _it_h > _viewport_bot_l) continue;
			if (_mx_r >= _ix && _mx_r <= _ix + _it_w
			 && _my_r >= _iy && _my_r <= _iy + _it_h)
			{
				// Toggle - but cap at 3 selected
				if (loadout_items[_i].picked)
				{
					loadout_items[_i].picked = false;
				}
				else
				{
					var _picked = 0;
					for (var _pi = 0; _pi < array_length(loadout_items); _pi++)
						if (loadout_items[_pi].picked) _picked++;
					if (_picked < 3) loadout_items[_i].picked = true;
				}
				exit;
			}
		}
		// Click outside closes
		if (_mx_r < _lp_x || _mx_r > _lp_x + _lp_w
		 || _my_r < _lp_y || _my_r > _lp_y + _lp_h)
		{
			is_loadout_panel = false;
			global.loadout_picks = [];
			for (var _li = 0; _li < array_length(loadout_items); _li++)
			{
				if (loadout_items[_li].picked)
					array_push(global.loadout_picks, loadout_items[_li].key);
			}
			exit;
		}
	}
	
	// (The "RECENT" main menu button is handled in obj_main_menu_ui; it sets
	// is_recent_games on this splash manager. We only need panel-inside clicks here.)
	
	// Click handling inside the recent games panel
	if (is_recent_games && recent_games_alpha > 0.5)
	{
		var _cx_r = _gw_r / 2;
		var _cy_r = _gh_r / 2;
		var _rp_w = 880;
		var _rp_h = 720;
		var _rp_x = _cx_r - _rp_w / 2;
		var _rp_y = _cy_r - _rp_h / 2;
		
		if (recent_selected_index < 0)
		{
			// Click on a game row to view details
			var _row_h = 56;
			var _row_y_start = _rp_y + 140;
			var _max_rows = min(array_length(recent_games), 10);
			var _clicked_row = -1;
			for (var _i = 0; _i < _max_rows; _i++)
			{
				var _rx = _rp_x + 40;
				var _ry = _row_y_start + _i * _row_h;
				var _rw = _rp_w - 80;
				var _rh = _row_h - 8;
				if (_mx_r >= _rx && _mx_r <= _rx + _rw
				 && _my_r >= _ry && _my_r <= _ry + _rh)
				{
					_clicked_row = _i;
					break;
				}
			}
			if (_clicked_row >= 0)
			{
				recent_selected_index = _clicked_row;
				exit;
			}
			
			// Close button (top-right X) — only way to close while in list view
			var _x_cx_a = _rp_x + _rp_w - 36;
			var _x_cy_a = _rp_y + 36;
			var _x_half_a = 28;
			if (_mx_r >= _x_cx_a - _x_half_a && _mx_r <= _x_cx_a + _x_half_a
			 && _my_r >= _x_cy_a - _x_half_a && _my_r <= _x_cy_a + _x_half_a)
			{
				is_recent_games = false;
				exit;
			}
		}
		else
		{
			// Detail view: BACK button
			var _back_w = 200;
			var _back_h = 50;
			var _back_x = _cx_r - _back_w / 2;
			var _back_y = _rp_y + _rp_h - 70;
			if (_mx_r >= _back_x && _mx_r <= _back_x + _back_w
			 && _my_r >= _back_y && _my_r <= _back_y + _back_h)
			{
				recent_selected_index = -1;
				exit;
			}
			
			// Close button (top-right X) in detail view too
			var _x_cx_b = _rp_x + _rp_w - 36;
			var _x_cy_b = _rp_y + 36;
			var _x_half_b = 28;
			if (_mx_r >= _x_cx_b - _x_half_b && _mx_r <= _x_cx_b + _x_half_b
			 && _my_r >= _x_cy_b - _x_half_b && _my_r <= _x_cy_b + _x_half_b)
			{
				is_recent_games = false;
				recent_selected_index = -1;
				exit;
			}
		}
	}
}
