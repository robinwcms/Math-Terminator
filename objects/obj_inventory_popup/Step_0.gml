// Keep player and other things absolutely still during pause
if (instance_exists(obj_player))
{
	obj_player.hspeed = 0;
	obj_player.vspeed = 0;
	obj_player.speed = 0;
}
with (obj_enemy)      { speed = 0; hspeed = 0; vspeed = 0; }
with (obj_boss)       { speed = 0; hspeed = 0; vspeed = 0; }
with (obj_projectile) { speed = 0; }

// Skip input handling until E (the open-key) has been released at least once.
// Otherwise the same E press that opened the popup would also close it.
if (!e_was_released)
{
	if (!keyboard_check(ord("E")))
	{
		e_was_released = true;
	}
	exit;
}

// ─── CLOSE on E or ESC ──────────────────────────────────────────────
if (keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_escape))
{
	obj_game_manager.resume_game();
	// Block E from reopening the popup on this same frame
	global.suppress_e_open = true;
	obj_game_manager.suppress_e_timer = 6;
	// Zero player velocity one more time on exit so held movement keys don't
	// produce a sudden lurch
	if (instance_exists(obj_player))
	{
		obj_player.hspeed = 0;
		obj_player.vspeed = 0;
		obj_player.speed = 0;
	}
	// Snap zombies' velocity to path direction so they don't ramp from 0
	with (obj_enemy)
	{
		if (instance_exists(target) && !is_spawning)
		{
			var _dir = point_direction(x, y, target.x, target.y);
			hspeed = lengthdir_x(max_speed, _dir);
			vspeed = lengthdir_y(max_speed, _dir);
		}
	}
	// Brief input lockout so the click that triggered the use doesn't
	// also fire a bullet or click a weakspot
	if (instance_exists(obj_player)) obj_player.input_lockout = 10;
	instance_destroy();
	exit;
}

// ─── GUI layout (must match Draw_64) ────────────────────────────────
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _cx = _gw / 2;
var _cy = _gh / 2;

var _panel_w = 920;
var _panel_h = 760;
var _panel_x = _cx - _panel_w / 2;
var _panel_y = _cy - _panel_h / 2;

var _card_count = array_length(items);
var _cards_per_row = 4;
var _card_w = 196;
var _card_h = 240;
var _card_gap_x = 18;
var _card_gap_y = 22;
var _row_count = ceil(_card_count / _cards_per_row);
var _row_total_w = _cards_per_row * _card_w + (_cards_per_row - 1) * _card_gap_x;
var _cards_x = _cx - _row_total_w / 2;
var _cards_y_base = _panel_y + 140;
var _viewport_top = _panel_y + 138;
var _viewport_bottom = _panel_y + _panel_h - 50;
var _viewport_h = _viewport_bottom - _viewport_top;

// Page-snap scroll: each wheel tick jumps by one full row so cards always
// land aligned at the viewport top. No partial cards ever visible.
var _content_h = _row_count * _card_h + (_row_count - 1) * _card_gap_y;
var _max_scroll = max(0, _content_h - (_viewport_h - 8));
var _page_step = _card_h + _card_gap_y;
if (mouse_wheel_down()) scroll_offset = min(scroll_offset + _page_step, _max_scroll);
if (mouse_wheel_up())   scroll_offset = max(scroll_offset - _page_step, 0);
// Mirror to target so any old lerp code doesn't drift it
scroll_target = scroll_offset;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// ─── HOVER DETECTION (strict viewport gate) ─────────────────────────
selected_index = -1;
for (var _i = 0; _i < _card_count; _i++)
{
	var _col = _i mod _cards_per_row;
	var _row = _i div _cards_per_row;
	var _bx = _cards_x + _col * (_card_w + _card_gap_x);
	var _by = _cards_y_base + _row * (_card_h + _card_gap_y) - scroll_offset;
	// Only hover-select cards fully inside the viewport
	if (_by < _viewport_top || _by + _card_h > _viewport_bottom) continue;
	if (_mx >= _bx && _mx <= _bx + _card_w
	 && _my >= _by && _my <= _by + _card_h)
	{
		selected_index = _i;
	}
}

// ─── USE ITEM: mouse click only (no hotkeys) ─────────────────────────
if (mouse_check_button_pressed(mb_left) && selected_index >= 0)
{
	use_item(selected_index);
	exit;
}
