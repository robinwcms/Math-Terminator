title_pulse += 1;

// Periodic title pop: fire a scale-up burst every 3-6 seconds.
// title_pop_value rises to 1 instantly when fired, then decays smoothly
// each frame so the title visibly snaps then settles back.
title_pop_timer--;
if (title_pop_timer <= 0)
{
	title_pop_value = 1.0;
	title_pop_timer = irandom_range(180, 360);   // 3-6 seconds at 60fps
}
title_pop_value = max(0, title_pop_value - 0.045);   // decay rate (~22 frames total)

if (!mouse_check_button_pressed(mb_left)) exit;

// Don't process clicks if any overlay panel is open (highscores, recent games,
// achievements, daily, loadout, etc).
if (instance_exists(obj_splash_manager)
	&& (obj_splash_manager.is_highscore_table
	  || obj_splash_manager.is_recent_games
	  || obj_splash_manager.is_achievements
	  || obj_splash_manager.is_daily_panel
	  || obj_splash_manager.is_loadout_panel))
{
	exit;
}

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _cw = display_get_gui_width();
var _ch = display_get_gui_height();
var _cx = _cw / 2;

// ═══ MAIN BUTTONS ═══════════════════════════════════════════════════
if (!show_timed_submenu)
{
	var _btn_w = 440;
	var _btn_h = 80;
	var _base_y = _ch * 0.50;
	var _btn_y_unlimited = _base_y;
	var _btn_y_timed     = _base_y + 100;
	var _btn_y_tutorial  = _base_y + 200;
	var _btn_y_recents   = _base_y + 300;
	
	if (point_in_box(_mx, _my, _cx - _btn_w/2, _btn_y_unlimited, _btn_w, _btn_h))
	{
		audio_play_sound(snd_menu_button, 100, false, 0.01, 0, 1.0);
		launch_game("normal");
		return;
	}
	if (point_in_box(_mx, _my, _cx - _btn_w/2, _btn_y_timed, _btn_w, _btn_h))
	{
		audio_play_sound(snd_menu_button, 100, false, 0.01, 0, 1.0);
		show_timed_submenu = true;
		return;
	}
	if (point_in_box(_mx, _my, _cx - _btn_w/2, _btn_y_tutorial, _btn_w, _btn_h))
	{
		audio_play_sound(snd_menu_button, 100, false, 0.01, 0, 1.0);
		// Launch game in tutorial mode - real arena with guided lessons
		global.game_mode = "tutorial";
		room_goto(rm_arena);
		return;
	}
	if (point_in_box(_mx, _my, _cx - _btn_w/2, _btn_y_recents, _btn_w, _btn_h))
	{
		audio_play_sound(snd_menu_button, 100, false, 0.01, 0, 1.0);
		// Open recent games panel via splash manager
		if (instance_exists(obj_splash_manager))
		{
			obj_splash_manager.load_recent_games();
			obj_splash_manager.is_recent_games = true;
			obj_splash_manager.recent_selected_index = -1;
		}
		return;
	}
}
else
{
	// ═══ TIMED SUBMENU ══════════════════════════════════════════════
	// Panel sized smaller now that the Math Operations section is gone
	var _panel_w = 700;
	var _panel_h = 400;
	var _panel_x = _cx - _panel_w / 2;
	var _panel_y = _ch / 2 - _panel_h / 2;
	
	// Back button
	if (point_in_box(_mx, _my, _panel_x + 20, _panel_y + 20, 100, 40))
	{
		show_timed_submenu = false;
		return;
	}
	
	// Duration buttons
	var _dur_x = _panel_x + 60;
	var _dur_y = _panel_y + 160;
	var _dur_w = 130;
	var _dur_h = 50;
	for (var _i = 0; _i < 4; _i++)
	{
		var _bx = _dur_x + _i * (_dur_w + 15);
		if (point_in_box(_mx, _my, _bx, _dur_y, _dur_w, _dur_h))
		{
			global.timed_duration = duration_choices[_i];
			return;
		}
	}
	
	// (Operation toggles removed — timed mode now uses all operations.)
	
	// Play button
	var _play_w = 220;
	var _play_h = 60;
	var _play_x = _cx - _play_w / 2;
	var _play_y = _panel_y + _panel_h - 90;
	if (point_in_box(_mx, _my, _play_x, _play_y, _play_w, _play_h))
	{
		// Force all operations on so timed mode always uses the full mix
		global.ops_addition = true;
		global.ops_subtraction = true;
		global.ops_multiplication = true;
		global.ops_division = true;
		launch_game("timed");
		return;
	}
}
