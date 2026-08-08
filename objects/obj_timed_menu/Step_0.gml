// Toggle the timed menu with T key
if (keyboard_check_pressed(ord("T")))
{
	menu_visible = !menu_visible;
}

if (!menu_visible) exit;

// ─── Click handling ─────────────────────────────────────────────────
if (!mouse_check_button_pressed(mb_left)) exit;

// Use GUI-space mouse coords so clicks line up with Draw GUI drawing
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _cw = display_get_gui_width();
var _ch = display_get_gui_height();
var _cx = _cw / 2;
var _cy = _ch / 2;

// Panel geometry (matches Draw)
var _panel_w = 700;
var _panel_h = 400;
var _panel_x = _cx - _panel_w / 2;
var _panel_y = _cy - _panel_h / 2;

// BACK button (top-left of panel)
if (point_in_box(_mx, _my, _panel_x + 20, _panel_y + 20, 100, 40))
{
	menu_visible = false;
	exit;
}

// DURATION buttons
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
		exit;
	}
}

// (Operation toggles removed — timed mode now uses all operations.)

// PLAY button (bottom centre)
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
	global.game_mode = "timed";
	menu_visible = false;
	audio_play_sound(snd_menu_button, 100, false, 0.01, 0, 1.0);
	room_goto(rm_arena);
}
