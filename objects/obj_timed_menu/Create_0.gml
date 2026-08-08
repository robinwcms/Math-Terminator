// ─── TIMED MODE MENU CONTROLLER ───────────────────────────────────────
// Drawn as an overlay on top of the main menu.

// Make sure global game-mode state exists with safe defaults
if (!variable_global_exists("game_mode")) global.game_mode = "normal";
if (!variable_global_exists("timed_duration")) global.timed_duration = 60;   // seconds
if (!variable_global_exists("ops_addition"))     global.ops_addition = true;
if (!variable_global_exists("ops_subtraction"))  global.ops_subtraction = false;
if (!variable_global_exists("ops_multiplication")) global.ops_multiplication = false;
if (!variable_global_exists("ops_division"))     global.ops_division = false;

// Menu visibility — starts hidden
menu_visible = false;

// Duration choices
duration_choices = [30, 60, 180, 300];      // 30s, 1m, 3m, 5m
duration_labels  = ["30s", "1 min", "3 min", "5 min"];

// Click detection helper
function point_in_box(_mx, _my, _x, _y, _w, _h) {
	return (_mx >= _x && _mx <= _x + _w && _my >= _y && _my <= _y + _h);
}
