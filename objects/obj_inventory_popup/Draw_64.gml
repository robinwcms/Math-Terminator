// ─── INVENTORY POPUP DRAW ──────────────────────────────────────────
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _cx = _gw / 2;
var _cy = _gh / 2;

var _panel_w = 920;
var _panel_h = 760;
var _panel_x = _cx - _panel_w / 2;
var _panel_y = _cy - _panel_h / 2;

// Dim background overlay
draw_set_color(c_black);
draw_set_alpha(0.65);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1.0);

// Panel
draw_set_color(make_color_rgb(20, 18, 30));
draw_set_alpha(0.97);
draw_roundrect(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, false);
draw_set_alpha(1.0);
// Gold border
draw_set_color(make_color_rgb(200, 160, 50));
draw_roundrect(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, true);
draw_roundrect(_panel_x + 1, _panel_y + 1, _panel_x + _panel_w - 1, _panel_y + _panel_h - 1, true);
draw_roundrect(_panel_x + 2, _panel_y + 2, _panel_x + _panel_w - 2, _panel_y + _panel_h - 2, true);

// Title
draw_set_font(fnt_luckiest_guy_36_outline);
draw_set_color(make_color_rgb(245, 195, 30));
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(_cx, _panel_y + 25, "INVENTORY");

// Subtitle
draw_set_font(fnt_luckiest_guy_24);
draw_set_color(make_color_rgb(180, 180, 200));
draw_text(_cx, _panel_y + 80, "Click an item to use it   -   E or ESC to close");

// Divider line
draw_set_color(make_color_rgb(200, 160, 50));
draw_line_width(_panel_x + 40, _panel_y + 120, _panel_x + _panel_w - 40, _panel_y + 120, 2);

// Mouse for hover
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// ─── ITEM CARDS (4 cards per row, scrollable) ──────────────────────
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
// Viewport: 2 full rows visible, with buffer at top and bottom for the
// fade band so cards exit smoothly under the chrome.
var _viewport_top = _panel_y + 138;
var _viewport_bottom = _panel_y + _panel_h - 50;
var _viewport_h = _viewport_bottom - _viewport_top;
// Soft fade band — pixels at top/bottom edge over which cards smoothly fade
var _fade_band = 60;

// Clamp scroll so user can't scroll past the last row
var _content_h = _row_count * _card_h + (_row_count - 1) * _card_gap_y;
var _max_scroll = max(0, _content_h - (_viewport_h - 8));
scroll_offset = clamp(scroll_offset, 0, _max_scroll);

selected_index = -1;

// Pre-compute the uniform description text scale that works for every item.
// We use one shared scale across all cards so the font size is visually consistent.
draw_set_font(fnt_luckiest_guy_24);
var _uniform_desc_scale = 1.0;
var _desc_max_w = _card_w - 12;
for (var _ui = 0; _ui < _card_count; _ui++)
{
	var _uitem = items[_ui];
	var _udesc = _uitem.desc;
	var _ulen = string_length(_udesc);
	// Determine the wider of the two lines (if it'll be split)
	if (_ulen > 18)
	{
		var _umid = floor(_ulen / 2);
		var _usplit_at = -1;
		for (var _uo = 0; _uo < _ulen; _uo++) {
			var _utry = _umid + _uo;
			if (_utry <= _ulen && string_char_at(_udesc, _utry) == " ")
			{ _usplit_at = _utry; break; }
			_utry = _umid - _uo;
			if (_utry >= 1 && string_char_at(_udesc, _utry) == " ")
			{ _usplit_at = _utry; break; }
		}
		if (_usplit_at > 0)
		{
			var _l1 = string_copy(_udesc, 1, _usplit_at - 1);
			var _l2 = string_copy(_udesc, _usplit_at + 1, _ulen - _usplit_at);
			var _w1 = string_width(_l1);
			var _w2 = string_width(_l2);
			var _wider = max(_w1, _w2);
			if (_wider > _desc_max_w)
			{
				var _s = _desc_max_w / _wider;
				if (_s < _uniform_desc_scale) _uniform_desc_scale = _s;
			}
		}
		else
		{
			var _w = string_width(_udesc);
			if (_w > _desc_max_w)
			{
				var _s = _desc_max_w / _w;
				if (_s < _uniform_desc_scale) _uniform_desc_scale = _s;
			}
		}
	}
	else
	{
		var _w = string_width(_udesc);
		if (_w > _desc_max_w)
		{
			var _s = _desc_max_w / _w;
			if (_s < _uniform_desc_scale) _uniform_desc_scale = _s;
		}
	}
}

for (var _i = 0; _i < _card_count; _i++)
{
	var _item  = items[_i];
	var _count = variable_global_get(_item.inv);
	var _owned = (_count > 0);
	var _col = _i mod _cards_per_row;
	var _row = _i div _cards_per_row;
	var _bx = _cards_x + _col * (_card_w + _card_gap_x);
	var _by = _cards_y_base + _row * (_card_h + _card_gap_y) - scroll_offset;
	
	// PAGINATION-STYLE CULL: skip any card not FULLY inside the viewport.
	// Cards on the current page render at full alpha, cards on other pages
	// don't render at all. No partial visibility.
	if (_by < _viewport_top || _by + _card_h > _viewport_bottom) continue;
	var _fade_alpha = 1.0;
	
	// Hover check (only when fully visible)
	var _hovered = (_mx >= _bx && _mx <= _bx + _card_w
				 && _my >= _by && _my <= _by + _card_h);
	if (_hovered) selected_index = _i;

	// Card background
	var _bg_col = _owned
		? (_hovered ? make_color_rgb(44, 38, 58) : make_color_rgb(30, 26, 42))
		: make_color_rgb(22, 20, 28);
	draw_set_color(_bg_col);
	draw_set_alpha(_fade_alpha);
	draw_roundrect(_bx, _by, _bx + _card_w, _by + _card_h, false);
	
	// Card border
	var _border_col = _owned
		? (_hovered ? _item.col : merge_color(_item.col, c_black, 0.4))
		: make_color_rgb(50, 50, 60);
	draw_set_color(_border_col);
	draw_set_alpha((_owned ? 1.0 : 0.5) * _fade_alpha);
	draw_roundrect(_bx, _by, _bx + _card_w, _by + _card_h, true);
	draw_roundrect(_bx + 1, _by + 1, _bx + _card_w - 1, _by + _card_h - 1, true);
	draw_set_alpha(_fade_alpha);

	// Color band at top
	draw_set_color(_item.col);
	draw_set_alpha((_owned ? 1.0 : 0.25) * _fade_alpha);
	draw_rectangle(_bx, _by, _bx + _card_w, _by + 6, false);
	draw_set_alpha(_fade_alpha);

	// Hotkey badge (top-left) — just shows position number (no longer activates)
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_color(_owned ? c_white : make_color_rgb(80, 80, 90));
	draw_text(_bx + 12, _by + 30, string(_i + 1));
	
	// Count badge (top-right)
	draw_set_halign(fa_right);
	draw_set_color(_owned ? _item.col : make_color_rgb(70, 70, 80));
	draw_text(_bx + _card_w - 12, _by + 30, "x" + string(_count));
	
	// Icon circle
	var _icon_cx = _bx + _card_w / 2;
	var _icon_cy = _by + 70;
	draw_set_color(_owned ? _item.col : make_color_rgb(40, 40, 50));
	draw_circle(_icon_cx, _icon_cy, 32, false);
	draw_set_color(_owned ? c_white : make_color_rgb(80, 80, 90));
	draw_circle(_icon_cx, _icon_cy, 32, true);
	draw_circle(_icon_cx, _icon_cy, 33, true);
	// Icon letter inside circle
	var _icon_letter = "?";
	switch (_item.key) {
		case "heart":     _icon_letter = "+"; break;
		case "shield":    _icon_letter = "S"; break;
		case "sniper":    _icon_letter = "X"; break;
		case "dblpoints": _icon_letter = "2"; break;
		case "airstrike": _icon_letter = "!"; break;
		case "rapid":     _icon_letter = "R"; break;
		case "speed":     _icon_letter = ">"; break;
		case "freeze":    _icon_letter = "*"; break;
		case "decoy":     _icon_letter = "D"; break;
		case "beacon":    _icon_letter = "B"; break;
		case "sanctuary": _icon_letter = "@"; break;
		case "turret":    _icon_letter = "T"; break;
		case "mobshop":   _icon_letter = "$"; break;
	}
	draw_set_font(fnt_luckiest_guy_36_outline);
	draw_set_color(_owned ? c_white : make_color_rgb(80, 80, 90));
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text_transformed(_icon_cx, _icon_cy + 5, _icon_letter, 0.7, 0.7, 0);
	
	// Item name (auto-fit single line)
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(_owned ? c_white : make_color_rgb(85, 85, 95));
	draw_set_valign(fa_middle);
	{
		var _name = _item.name;
		var _max_w = _card_w - 16;
		var _tw = string_width(_name);
		var _ts = (_tw > _max_w) ? _max_w / _tw : 1.0;
		draw_text_transformed(_bx + _card_w / 2, _by + 140, _name, _ts, _ts, 0);
	}
	
	// Description — uniform scale across every card so font size is consistent
	draw_set_color(_owned ? make_color_rgb(170, 170, 195) : make_color_rgb(60, 60, 70));
	{
		var _desc = _item.desc;
		var _len = string_length(_desc);
		var _ds = _uniform_desc_scale;
		var _line_h = round(28 * _ds);
		if (_len > 18)
		{
			var _mid = floor(_len / 2);
			var _split_at = -1;
			for (var _o = 0; _o < _len; _o++)
			{
				var _try = _mid + _o;
				if (_try <= _len && string_char_at(_desc, _try) == " ")
				{ _split_at = _try; break; }
				_try = _mid - _o;
				if (_try >= 1 && string_char_at(_desc, _try) == " ")
				{ _split_at = _try; break; }
			}
			if (_split_at > 0)
			{
				var _line1 = string_copy(_desc, 1, _split_at - 1);
				var _line2 = string_copy(_desc, _split_at + 1, _len - _split_at);
				draw_text_transformed(_bx + _card_w / 2, _by + 185, _line1, _ds, _ds, 0);
				draw_text_transformed(_bx + _card_w / 2, _by + 185 + _line_h, _line2, _ds, _ds, 0);
			}
			else
			{
				draw_text_transformed(_bx + _card_w / 2, _by + 195, _desc, _ds, _ds, 0);
			}
		}
		else
		{
			draw_text_transformed(_bx + _card_w / 2, _by + 195, _desc, _ds, _ds, 0);
		}
	}
	
	// (PRESS X footer removed - hotkey number at top-left is enough)
	
	// (No "EMPTY" overlay — dimmed card colors already convey unowned state)
	
	// Hover glow outline
	if (_hovered && _owned)
	{
		draw_set_color(_item.col);
		draw_set_alpha(0.6 * _fade_alpha);
		draw_roundrect(_bx - 3, _by - 3, _bx + _card_w + 3, _by + _card_h + 3, true);
		draw_roundrect(_bx - 2, _by - 2, _bx + _card_w + 2, _by + _card_h + 2, true);
	}
	
	// Reset alpha for next card
	draw_set_alpha(1.0);
}

// With pagination, cards never overflow the viewport so cover strips
// are no longer needed. The panel chrome is drawn first and stays intact.

// Reset
draw_set_color(c_white);
draw_set_alpha(1.0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
