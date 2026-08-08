// ─── MAIN MENU UI: title + Unlimited/Timed buttons ──────────────────
// Game mode globals
if (!variable_global_exists("game_mode")) global.game_mode = "normal";
if (!variable_global_exists("timed_duration")) global.timed_duration = 60;

// Timed-mode submenu state
show_timed_submenu = false;

duration_choices = [30, 60, 180, 300];
duration_labels  = ["30s", "1 min", "3 min", "5 min"];

// Ops defaults
if (!variable_global_exists("ops_addition"))      global.ops_addition = true;
if (!variable_global_exists("ops_subtraction"))   global.ops_subtraction = false;
if (!variable_global_exists("ops_multiplication")) global.ops_multiplication = false;
if (!variable_global_exists("ops_division"))      global.ops_division = false;

// Pulse phase for title animation
title_pulse = 0;
// Periodic "pop": a quick scale-up-and-decay that fires every few seconds
title_pop_timer = 120;       // frames until next pop (initial)
title_pop_value = 0;          // current pop magnitude (0..1), decays after firing

point_in_box = function(_mx, _my, _x, _y, _w, _h) {
	return (_mx >= _x && _mx <= _x + _w && _my >= _y && _my <= _y + _h);
}

// Helper: launch a game in the given mode
launch_game = function(_mode)
{
	global.game_mode = _mode;
	room_goto(rm_arena);
}
