var _cw = display_get_gui_width();
var _ch = display_get_gui_height();
var _cx = _cw / 2;
var _cy = _ch / 2;

// Dark backdrop
draw_set_color(c_black);
draw_set_alpha(0.75);
draw_rectangle(0, 0, _cw, _ch, false);
draw_set_alpha(1.0);

// Panel
var _panel_w = 920;
var _panel_h = 760;
var _panel_x = _cx - _panel_w / 2;
var _panel_y = _cy - _panel_h / 2;

draw_set_color(make_color_rgb(30, 30, 40));
draw_roundrect(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, false);
draw_set_color(make_color_rgb(255, 215, 0));
draw_roundrect(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, true);
draw_roundrect(_panel_x + 1, _panel_y + 1, _panel_x + _panel_w - 1, _panel_y + _panel_h - 1, true);

// Title
draw_set_font(fnt_luckiest_guy_36_outline);
draw_set_color(make_color_rgb(255, 215, 0));
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(_cx, _panel_y + 24, "SHOP - WAVE " + string(obj_game_manager.curr_wave) + " CLEARED");

// Credits display
draw_set_font(fnt_luckiest_guy_24);
draw_set_color(c_white);
draw_text(_cx, _panel_y + 72, "Credits: " + string(global.credits));

// Mouse pos for hover
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// ─── ITEM CARDS (scrollable 4-col grid, same style as inventory) ─────
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
// Viewport tuned to fit EXACTLY 2 rows (240 + 22 + 240 = 502px)
var _viewport_top = _panel_y + 118;
var _viewport_bottom = _panel_y + 122 + 502 + 4;   // top + 2 rows + 4px buffer
var _viewport_h = _viewport_bottom - _viewport_top;

// Clamp scroll
var _content_h = _row_count * _card_h + (_row_count - 1) * _card_gap_y;
var _max_scroll = max(0, _content_h - (_viewport_h - 8));
scroll_offset = clamp(scroll_offset, 0, _max_scroll);

selected_index = -1;

for (var _i = 0; _i < _card_count; _i++)
{
	var _item   = shop_pool[_i];
	var _inv_count = variable_global_get(_get_inv_key_for(_item.key));
	var _can_afford = (global.credits >= _item.price);
	var _col = _i mod _cards_per_row;
	var _row = _i div _cards_per_row;
	var _bx = _cards_x + _col * (_card_w + _card_gap_x);
	var _by = _cards_y_base + _row * (_card_h + _card_gap_y) - scroll_offset;
	
	// Strict viewport cull (no partial cards — same approach as inventory,
	// achievements, and loadout panels)
	if (_by < _viewport_top || _by + _card_h > _viewport_bottom) continue;
	var _fade_alpha = 1.0;
	
	// Hover
	var _hovered = (_mx >= _bx && _mx <= _bx + _card_w
				 && _my >= _by && _my <= _by + _card_h);
	if (_hovered) selected_index = _i;
	
	// Icon
	var _icon_col = c_white;
	var _icon_letter = "?";
	switch (_item.key)
	{
		case "sniper":    _icon_col = make_color_rgb(150, 150, 230); _icon_letter = "X"; break;
		case "heart":     _icon_col = make_color_rgb(220, 50, 80);   _icon_letter = "+"; break;
		case "shield":    _icon_col = make_color_rgb(80, 180, 220);  _icon_letter = "S"; break;
		case "dblpoints": _icon_col = make_color_rgb(255, 215, 0);   _icon_letter = "2"; break;
		case "airstrike": _icon_col = make_color_rgb(220, 100, 60);  _icon_letter = "!"; break;
		case "rapid":     _icon_col = make_color_rgb(255, 100, 100); _icon_letter = "R"; break;
		case "speed":     _icon_col = make_color_rgb(100, 230, 100); _icon_letter = ">"; break;
		case "freeze":    _icon_col = make_color_rgb(150, 200, 255); _icon_letter = "*"; break;
		case "decoy":     _icon_col = make_color_rgb(80, 180, 255);  _icon_letter = "D"; break;
		case "beacon":    _icon_col = make_color_rgb(120, 255, 130); _icon_letter = "B"; break;
		case "sanctuary": _icon_col = make_color_rgb(180, 220, 255); _icon_letter = "@"; break;
		case "turret":    _icon_col = make_color_rgb(130, 140, 155); _icon_letter = "T"; break;
		case "mobshop":   _icon_col = make_color_rgb(255, 180, 80);  _icon_letter = "$"; break;
	}
	
	// Background
	var _bg_col = _can_afford
		? (_hovered ? make_color_rgb(50, 50, 64) : make_color_rgb(36, 36, 48))
		: make_color_rgb(28, 25, 32);
	draw_set_color(_bg_col);
	draw_set_alpha(_fade_alpha);
	draw_roundrect(_bx, _by, _bx + _card_w, _by + _card_h, false);
	
	// Border
	var _border_col = _can_afford
		? (_hovered ? _icon_col : merge_color(_icon_col, c_black, 0.4))
		: make_color_rgb(60, 50, 50);
	draw_set_color(_border_col);
	draw_set_alpha((_can_afford ? 1.0 : 0.55) * _fade_alpha);
	draw_roundrect(_bx, _by, _bx + _card_w, _by + _card_h, true);
	draw_roundrect(_bx + 1, _by + 1, _bx + _card_w - 1, _by + _card_h - 1, true);
	draw_set_alpha(_fade_alpha);
	
	// Top color band
	draw_set_color(_icon_col);
	draw_set_alpha((_can_afford ? 1.0 : 0.3) * _fade_alpha);
	draw_rectangle(_bx, _by, _bx + _card_w, _by + 6, false);
	draw_set_alpha(_fade_alpha);
	
	// Owned count (left)
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	if (_inv_count > 0)
	{
		draw_set_color(make_color_rgb(120, 255, 140));
		draw_text(_bx + 12, _by + 30, "x" + string(_inv_count));
	}
	
	// Price (right)
	draw_set_halign(fa_right);
	draw_set_color(_can_afford ? make_color_rgb(255, 215, 0) : make_color_rgb(180, 80, 80));
	draw_text(_bx + _card_w - 12, _by + 30, "$" + string(_item.price));
	
	// Icon circle
	var _icon_cx = _bx + _card_w / 2;
	var _icon_cy = _by + 70;
	draw_set_color(_can_afford ? _icon_col : make_color_rgb(50, 45, 55));
	draw_circle(_icon_cx, _icon_cy, 32, false);
	draw_set_color(_can_afford ? c_white : make_color_rgb(80, 70, 85));
	draw_circle(_icon_cx, _icon_cy, 32, true);
	draw_circle(_icon_cx, _icon_cy, 33, true);
	draw_set_font(fnt_luckiest_guy_36_outline);
	draw_set_color(_can_afford ? c_white : make_color_rgb(80, 70, 85));
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text_transformed(_icon_cx, _icon_cy + 5, _icon_letter, 0.7, 0.7, 0);
	
	// Item name
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(_can_afford ? c_white : make_color_rgb(120, 110, 130));
	{
		var _name_max = _card_w - 16;
		var _nw = string_width(_item.name);
		var _ns = (_nw > _name_max) ? _name_max / _nw : 1.0;
		draw_text_transformed(_bx + _card_w / 2, _by + 140, _item.name, _ns, _ns, 0);
	}
	
	// Description
	draw_set_color(_can_afford ? make_color_rgb(180, 180, 200) : make_color_rgb(90, 80, 100));
	{
		var _desc = _item.desc;
		var _len = string_length(_desc);
		var _dmax = _card_w - 16;
		var _base_scale = 0.7;
		if (_len > 20)
		{
			var _mid = floor(_len / 2);
			var _split_at = -1;
			for (var _o = 0; _o < _len; _o++) {
				var _try = _mid + _o;
				if (_try <= _len && string_char_at(_desc, _try) == " ") { _split_at = _try; break; }
				_try = _mid - _o;
				if (_try >= 1 && string_char_at(_desc, _try) == " ") { _split_at = _try; break; }
			}
			if (_split_at > 0)
			{
				var _l1 = string_copy(_desc, 1, _split_at - 1);
				var _l2 = string_copy(_desc, _split_at + 1, _len - _split_at);
				var _tw1 = string_width(_l1);
				var _tw2 = string_width(_l2);
				var _ts = min(min((_tw1 > 0) ? _dmax / _tw1 : 1, (_tw2 > 0) ? _dmax / _tw2 : 1), _base_scale);
				draw_text_transformed(_bx + _card_w / 2, _by + 175, _l1, _ts, _ts, 0);
				draw_text_transformed(_bx + _card_w / 2, _by + 200, _l2, _ts, _ts, 0);
			}
			else
			{
				var _tw = string_width(_desc);
				var _ts = min((_tw > 0) ? _dmax / _tw : 1, _base_scale);
				draw_text_transformed(_bx + _card_w / 2, _by + 188, _desc, _ts, _ts, 0);
			}
		}
		else
		{
			var _tw = string_width(_desc);
			var _ts = min((_tw > 0) ? _dmax / _tw : 1, _base_scale + 0.1);
			draw_text_transformed(_bx + _card_w / 2, _by + 188, _desc, _ts, _ts, 0);
		}
	}
	
	// Hover glow
	if (_hovered && _can_afford)
	{
		draw_set_color(_icon_col);
		draw_set_alpha(0.6 * _fade_alpha);
		draw_roundrect(_bx - 3, _by - 3, _bx + _card_w + 3, _by + _card_h + 3, true);
		draw_roundrect(_bx - 2, _by - 2, _bx + _card_w + 2, _by + _card_h + 2, true);
	}
	
	draw_set_alpha(1.0);
}

// ─── COVER STRIPS: hide card overflow above/below the viewport ─────
// Strips stay inside the panel chrome. Panel is sized with buffer space.
draw_set_color(make_color_rgb(30, 30, 40));
draw_set_alpha(1.0);
draw_rectangle(_panel_x + 3, _panel_y + 3, _panel_x + _panel_w - 3, _viewport_top, false);
draw_rectangle(_panel_x + 3, _viewport_bottom, _panel_x + _panel_w - 3, _panel_y + _panel_h - 3, false);

// Redraw gold border so panel chrome is preserved
draw_set_color(make_color_rgb(255, 215, 0));
draw_roundrect(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, true);
draw_roundrect(_panel_x + 1, _panel_y + 1, _panel_x + _panel_w - 1, _panel_y + _panel_h - 1, true);

// Redraw the title + credits header on top of the cover strip
draw_set_font(fnt_luckiest_guy_36_outline);
draw_set_color(make_color_rgb(255, 215, 0));
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(_cx, _panel_y + 24, "SHOP - WAVE " + string(obj_game_manager.curr_wave) + " CLEARED");
draw_set_font(fnt_luckiest_guy_24);
draw_set_color(c_white);
draw_text(_cx, _panel_y + 72, "Credits: " + string(global.credits));

// ─── CONTINUE BUTTON (centered at bottom) ───────────────────────────
var _cont_w = 280;
var _cont_h = 56;
var _cont_x = _cx - _cont_w / 2;
var _cont_y = _panel_y + _panel_h - 68;
var _cont_hover = (_mx >= _cont_x && _mx <= _cont_x + _cont_w
				 && _my >= _cont_y && _my <= _cont_y + _cont_h);
draw_set_color(_cont_hover ? make_color_rgb(120, 255, 120) : make_color_rgb(76, 175, 80));
draw_set_alpha(1.0);
draw_roundrect(_cont_x, _cont_y, _cont_x + _cont_w, _cont_y + _cont_h, false);
draw_set_color(c_white);
draw_roundrect(_cont_x, _cont_y, _cont_x + _cont_w, _cont_y + _cont_h, true);
draw_set_font(fnt_luckiest_guy_24);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(_cont_x + _cont_w / 2, _cont_y + _cont_h / 2 + 2, "CONTINUE");

// Reset
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1.0);
