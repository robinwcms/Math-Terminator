// Force pause state every frame so player/manager Step events stay gated
obj_game_manager.curr_game_state = GAME_STATE.PAUSED;
// Zero all velocities every frame — held movement keys would otherwise
// carry the player across the map during the shop intermission
if (instance_exists(obj_player))
{
	obj_player.hspeed = 0;
	obj_player.vspeed = 0;
	obj_player.speed = 0;
}
with (obj_enemy)      { speed = 0; hspeed = 0; vspeed = 0; }
with (obj_boss)       { speed = 0; hspeed = 0; vspeed = 0; }
with (obj_projectile) { speed = 0; }

// ─── Layout (mirrors Draw_64) ───────────────────────────────────────
var _cw = display_get_gui_width();
var _ch = display_get_gui_height();
var _cx = _cw / 2;
var _cy = _ch / 2;
var _panel_w = 920;
var _panel_h = 760;
var _panel_x = _cx - _panel_w / 2;
var _panel_y = _cy - _panel_h / 2;

var _card_count = array_length(shop_pool);
var _cards_per_row = 4;
var _card_w = 196;
var _card_h = 240;
var _card_gap_x = 18;
var _card_gap_y = 22;
var _row_count = ceil(_card_count / _cards_per_row);
var _row_total_w = _cards_per_row * _card_w + (_cards_per_row - 1) * _card_gap_x;
var _cards_x = _cx - _row_total_w / 2;
var _cards_y_base = _panel_y + 122;
var _viewport_top = _panel_y + 118;
var _viewport_bottom = _panel_y + 122 + 502 + 4;
var _viewport_h = _viewport_bottom - _viewport_top;

// Scroll
// Page-snap scroll: each wheel tick jumps by one full row so cards
// always land aligned at the viewport top. No partial cards visible.
var _content_h = _row_count * _card_h + (_row_count - 1) * _card_gap_y;
var _max_scroll = max(0, _content_h - (_viewport_h - 8));
var _page_step = _card_h + _card_gap_y;   // 262 per row
if (mouse_wheel_down()) scroll_offset = min(scroll_offset + _page_step, _max_scroll);
if (mouse_wheel_up())   scroll_offset = max(scroll_offset - _page_step, 0);
scroll_target = scroll_offset;

// Only respond to a fresh click
if (!mouse_check_button_pressed(mb_left)) exit;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// Check click on any card
for (var _i = 0; _i < _card_count; _i++)
{
	var _col = _i mod _cards_per_row;
	var _row = _i div _cards_per_row;
	var _bx = _cards_x + _col * (_card_w + _card_gap_x);
	var _by = _cards_y_base + _row * (_card_h + _card_gap_y) - scroll_offset;
	// Strict viewport gate — match the draw cull
	if (_by < _viewport_top || _by + _card_h > _viewport_bottom) continue;
	if (_mx >= _bx && _mx <= _bx + _card_w
	 && _my >= _by && _my <= _by + _card_h)
	{
		// Try to buy
		var _item = shop_pool[_i];
		if (global.credits >= _item.price)
		{
			global.credits -= _item.price;
			switch (_item.key)
			{
				case "sniper":    global.inv_sniper++;    break;
				case "heart":     global.inv_heart++;     break;
				case "shield":    global.inv_shield++;    break;
				case "dblpoints": global.inv_dblpoints++; break;
				case "airstrike": global.inv_airstrike++; break;
				case "rapid":     global.inv_rapid++;     break;
				case "speed":     global.inv_speed++;     break;
				case "freeze":    global.inv_freeze++;    break;
				case "decoy":     global.inv_decoy++;     break;
				case "beacon":    global.inv_beacon++;    break;
				case "sanctuary": global.inv_sanctuary++; break;
				case "turret":    global.inv_turret++;    break;
				case "mobshop":   global.inv_mobshop++;   break;
			}
		}
		return;
	}
}

// Continue button (centered at bottom — matches Draw_64)
var _cont_w = 280;
var _cont_h = 56;
var _cont_x = _cx - _cont_w / 2;
var _cont_y = _panel_y + _panel_h - 68;
if (point_in_box(_mx, _my, _cont_x, _cont_y, _cont_w, _cont_h))
{
	// Resume game, close shop. Zero player velocity so held movement keys
	// don't produce a sudden lurch when control returns.
	obj_game_manager.curr_game_state = GAME_STATE.PLAYING;
	if (instance_exists(obj_player))
	{
		obj_player.hspeed = 0;
		obj_player.vspeed = 0;
		obj_player.speed = 0;
		obj_player.input_lockout = 10;
	}
	instance_destroy();
	return;
}
