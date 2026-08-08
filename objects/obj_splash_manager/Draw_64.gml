// Checks if highscore table should show
if (is_highscore_table) {
	highscores_alpha_target = 1.0;
} else {
	highscores_alpha_target = 0.0;
}
highscores_alpha = lerp(highscores_alpha, highscores_alpha_target, 0.1);

// Only draw the highscore overlay if it's visible
if (highscores_alpha > 0.01)
{
	var _cw = display_get_gui_width();
	var _ch = display_get_gui_height();
var _cx = _cw / 2;
var _cy = _ch / 2;

// Backdrop
draw_set_color(c_black);
draw_set_alpha(0.65 * highscores_alpha);
draw_rectangle(0, 0, _cw, _ch, false);
draw_set_alpha(highscores_alpha);

// Panel
var _panel_w = 760;
var _panel_h = 720;
var _panel_x = _cx - _panel_w / 2;
var _panel_y = _cy - _panel_h / 2;

draw_set_color(make_color_rgb(30, 30, 40));
draw_roundrect(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, false);
draw_set_color(make_color_rgb(255, 215, 0));
draw_roundrect(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, true);
draw_roundrect(_panel_x + 1, _panel_y + 1, _panel_x + _panel_w - 1, _panel_y + _panel_h - 1, true);

// Close X button at top-right of panel (small version of the red X sprite)
{
	var _x_cx = _panel_x + _panel_w - 36;
	var _x_cy = _panel_y + 36;
	var _scale = 0.5;
	draw_sprite_ext(spr_button_close, 0, _x_cx, _x_cy, _scale, _scale, 0, c_white, highscores_alpha);
}

// Title
draw_set_font(font_1);
draw_set_color(make_color_rgb(255, 235, 130));
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text_transformed(_cx, _panel_y + 20, "HIGH SCORES", 0.55, 0.55, 0);

// Tabs row
var _tab_y = _panel_y + 100;
var _tab_h = 48;
var _tab_total_w = _panel_w - 80;
var _tab_w = _tab_total_w / array_length(global.hs_modes);
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

draw_set_font(fnt_luckiest_guy_24);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
for (var _t = 0; _t < array_length(global.hs_modes); _t++)
{
	var _tx = _panel_x + 40 + _t * _tab_w;
	var _hover = (_mx >= _tx && _mx <= _tx + _tab_w - 4 && _my >= _tab_y && _my <= _tab_y + _tab_h);
	var _selected = (_t == hs_tab);
	var _bg, _txt;
	if (_selected) { _bg = make_color_rgb(255, 215, 0); _txt = c_black; }
	else if (_hover) { _bg = make_color_rgb(80, 80, 100); _txt = c_white; }
	else { _bg = make_color_rgb(50, 50, 60); _txt = c_white; }
	draw_set_color(_bg);
	draw_roundrect(_tx, _tab_y, _tx + _tab_w - 4, _tab_y + _tab_h, false);
	draw_set_color(_txt);
	// Auto-fit label
	var _label = global.hs_modes[_t].label;
	var _max_w = _tab_w - 14;
	var _tw = string_width(_label);
	var _ts = _tw > _max_w ? _max_w / _tw : 1.0;
	draw_text_transformed(_tx + (_tab_w - 4) / 2, _tab_y + _tab_h / 2, _label, _ts, _ts, 0);
}

// Scores list
draw_set_font(fnt_luckiest_guy_36_outline);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
for (var _i = 0; _i < 10; _i++)
{
	var _line_y = _panel_y + 180 + 42 * _i;
	// Rank
	draw_set_halign(fa_left);
	draw_set_color(make_color_rgb(180, 180, 180));
	draw_text_transformed(_panel_x + 80, _line_y, string(_i + 1) + ".", 0.7, 0.7, 0);
	// Score
	draw_set_halign(fa_right);
	draw_set_color(c_white);
	draw_text_transformed(_panel_x + _panel_w - 80, _line_y, string(highscores[_i]), 0.8, 0.8, 0);
}

// Reset button
var _btn_w = 280;
var _btn_h = 56;
var _btn_x = _cx - _btn_w / 2;
var _btn_y = _panel_y + _panel_h - 76;
var _btn_hover = (_mx >= _btn_x && _mx <= _btn_x + _btn_w
			   && _my >= _btn_y && _my <= _btn_y + _btn_h);
draw_set_color(_btn_hover ? make_color_rgb(255, 100, 100) : make_color_rgb(180, 60, 60));
draw_roundrect(_btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h, false);
draw_set_color(c_white);
draw_roundrect(_btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h, true);
draw_roundrect(_btn_x + 1, _btn_y + 1, _btn_x + _btn_w - 1, _btn_y + _btn_h - 1, true);
draw_set_font(fnt_luckiest_guy_24);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(_btn_x + _btn_w / 2, _btn_y + _btn_h / 2, "RESET THIS TAB");

draw_set_color(c_white);
draw_set_alpha(1.0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

}   // end of "if (highscores_alpha > 0.01)" block

// ═══ ACHIEVEMENTS CORNER BUTTON (always visible) ═══════════════════
{
	var _gw_ab = display_get_gui_width();
	var _ab_w = 280;
	var _ab_h = 70;
	var _ab_x = _gw_ab - _ab_w - 24;
	var _ab_y = 440;
	var _mx_ab = device_mouse_x_to_gui(0);
	var _my_ab = device_mouse_y_to_gui(0);
	var _ab_hover = (_mx_ab >= _ab_x && _mx_ab <= _ab_x + _ab_w
				  && _my_ab >= _ab_y && _my_ab <= _ab_y + _ab_h);
	draw_set_alpha(1.0);
	draw_set_color(_ab_hover ? make_color_rgb(80, 70, 30) : make_color_rgb(40, 35, 20));
	draw_roundrect(_ab_x, _ab_y, _ab_x + _ab_w, _ab_y + _ab_h, false);
	draw_set_color(make_color_rgb(255, 215, 0));
	draw_roundrect(_ab_x, _ab_y, _ab_x + _ab_w, _ab_y + _ab_h, true);
	draw_roundrect(_ab_x + 1, _ab_y + 1, _ab_x + _ab_w - 1, _ab_y + _ab_h - 1, true);
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	// Nudge text down a few pixels for visual centering
	draw_text(_ab_x + _ab_w / 2, _ab_y + _ab_h / 2 + 4, "ACHIEVEMENTS");
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// ═══ ACHIEVEMENTS PANEL ════════════════════════════════════════════
if (is_achievements) {
	achievements_alpha_target = 1.0;
} else {
	achievements_alpha_target = 0.0;
}
achievements_alpha = lerp(achievements_alpha, achievements_alpha_target, 0.1);

if (achievements_alpha > 0.01)
{
	var _cw_a = display_get_gui_width();
	var _ch_a = display_get_gui_height();
	var _cx_a = _cw_a / 2;
	var _cy_a = _ch_a / 2;
	
	draw_set_color(c_black);
	draw_set_alpha(0.65 * achievements_alpha);
	draw_rectangle(0, 0, _cw_a, _ch_a, false);
	draw_set_alpha(achievements_alpha);
	
	var _ap_w = 980;
	var _ap_h = 760;
	var _ap_x = _cx_a - _ap_w / 2;
	var _ap_y = _cy_a - _ap_h / 2;
	
	draw_set_color(make_color_rgb(20, 18, 30));
	draw_roundrect(_ap_x, _ap_y, _ap_x + _ap_w, _ap_y + _ap_h, false);
	draw_set_color(make_color_rgb(255, 215, 0));
	draw_roundrect(_ap_x, _ap_y, _ap_x + _ap_w, _ap_y + _ap_h, true);
	draw_roundrect(_ap_x + 1, _ap_y + 1, _ap_x + _ap_w - 1, _ap_y + _ap_h - 1, true);
	
	// Close X
	draw_sprite_ext(spr_button_close, 0,
		_ap_x + _ap_w - 36, _ap_y + 36, 0.5, 0.5, 0, c_white, achievements_alpha);
	
	// Title
	draw_set_font(fnt_luckiest_guy_96_outline);
	draw_set_color(make_color_rgb(255, 215, 0));
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_text_transformed(_cx_a, _ap_y + 20, "ACHIEVEMENTS", 0.55, 0.55, 0);
	
	// Progress count
	var _total_a = array_length(global.achievements);
	var _unlocked_count = 0;
	for (var _ci = 0; _ci < _total_a; _ci++)
		if (global.achievements[_ci].unlocked) _unlocked_count++;
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(make_color_rgb(200, 200, 220));
	draw_text(_cx_a, _ap_y + 90, string(_unlocked_count) + " / " + string(_total_a) + " UNLOCKED");
	
	// Grid: 4 columns, scrollable
	var _cards_per_row = 4;
	var _card_w = 200;
	var _card_h = 180;
	var _gap_x = 16;
	var _gap_y = 18;
	var _row_total_w = _cards_per_row * _card_w + (_cards_per_row - 1) * _gap_x;
	var _cards_x = _cx_a - _row_total_w / 2;
	var _cards_y = _ap_y + 135;
	
	// Viewport bounds for scroll clipping. Bottom is reserved for the
	// "scroll with mouse wheel" hint strip so card text doesn't bleed into it.
	var _viewport_top = _ap_y + 130;
	var _viewport_bottom = _ap_y + _ap_h - 44;
	
	// Per-achievement icon letters (one for each)
	var _ach_letters = ["B", "S", "M", "K", "P", "C", "$", "20", "U", "%", "50", "!", "T"];
	
	for (var _i = 0; _i < _total_a; _i++)
	{
		var _a = global.achievements[_i];
		var _col = _i mod _cards_per_row;
		var _row = _i div _cards_per_row;
		var _bx = _cards_x + _col * (_card_w + _gap_x);
		var _by = _cards_y + _row * (_card_h + _gap_y) - achievements_scroll;
		
		// PAGINATION-STYLE CULL: skip any card not FULLY inside the viewport.
		// No partial cards ever visible; scroll snaps by row.
		if (_by < _viewport_top || _by + _card_h > _viewport_bottom) continue;
		var _a_final = achievements_alpha;
		
		// Card background
		draw_set_color(_a.unlocked ? make_color_rgb(40, 50, 32) : make_color_rgb(28, 28, 36));
		draw_set_alpha(_a_final);
		draw_roundrect(_bx, _by, _bx + _card_w, _by + _card_h, false);
		draw_set_color(_a.unlocked ? make_color_rgb(120, 220, 80) : make_color_rgb(70, 70, 90));
		draw_roundrect(_bx, _by, _bx + _card_w, _by + _card_h, true);
		draw_roundrect(_bx + 1, _by + 1, _bx + _card_w - 1, _by + _card_h - 1, true);
		
		// Status banner (top color strip)
		draw_set_color(_a.unlocked ? make_color_rgb(255, 215, 0) : make_color_rgb(70, 70, 90));
		draw_rectangle(_bx + 6, _by + 6, _bx + _card_w - 6, _by + 12, false);
		
		// Icon circle (smaller for compact card)
		var _icon_cx = _bx + _card_w / 2;
		var _icon_cy = _by + 56;
		draw_set_color(_a.unlocked ? make_color_rgb(255, 215, 0) : make_color_rgb(50, 50, 65));
		draw_circle(_icon_cx, _icon_cy, 26, false);
		draw_set_color(_a.unlocked ? c_white : make_color_rgb(90, 90, 110));
		draw_circle(_icon_cx, _icon_cy, 26, true);
		draw_circle(_icon_cx, _icon_cy, 27, true);
		// Letter
		draw_set_font(fnt_luckiest_guy_36_outline);
		draw_set_color(_a.unlocked ? c_black : make_color_rgb(90, 90, 110));
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _letter = (_i < array_length(_ach_letters)) ? _ach_letters[_i] : "?";
		var _lscale = (string_length(_letter) > 1) ? 0.55 : 0.8;
		draw_text_transformed(_icon_cx, _icon_cy + 4, _letter, _lscale, _lscale, 0);
		
		// Name (auto-fit horizontally)
		draw_set_font(fnt_luckiest_guy_24);
		draw_set_color(_a.unlocked ? c_white : make_color_rgb(120, 120, 140));
		draw_set_valign(fa_middle);
		{
			var _name_max = _card_w - 24;
			var _nw = string_width(_a.name);
			var _ns = (_nw > _name_max) ? _name_max / _nw : 1.0;
			draw_text_transformed(_bx + _card_w / 2, _by + 105, _a.name, _ns, _ns, 0);
		}
		
		// Description — always rendered at smaller scale, wrapped to 2 lines if needed
		draw_set_color(_a.unlocked ? make_color_rgb(190, 200, 195) : make_color_rgb(85, 85, 100));
		{
			var _desc = _a.desc;
			var _len = string_length(_desc);
			var _dmax = _card_w - 24;          // tighter margin so text never touches the card edge
			var _base_scale = 0.6;              // smaller default than before
			
			if (_len > 22)
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
					var _ts1 = (_tw1 > 0) ? _dmax / _tw1 : 1.0;
					var _ts2 = (_tw2 > 0) ? _dmax / _tw2 : 1.0;
					var _ts = min(min(_ts1, _ts2), _base_scale);
					draw_text_transformed(_bx + _card_w / 2, _by + 138, _l1, _ts, _ts, 0);
					draw_text_transformed(_bx + _card_w / 2, _by + 158, _l2, _ts, _ts, 0);
				}
				else
				{
					var _tw = string_width(_desc);
					var _ts = min((_tw > 0) ? _dmax / _tw : 1.0, _base_scale);
					draw_text_transformed(_bx + _card_w / 2, _by + 148, _desc, _ts, _ts, 0);
				}
			}
			else
			{
				var _tw = string_width(_desc);
				var _ts = min((_tw > 0) ? _dmax / _tw : 1.0, _base_scale + 0.1);
				draw_text_transformed(_bx + _card_w / 2, _by + 148, _desc, _ts, _ts, 0);
			}
		}
	}
	
	// ─── COVER STRIPS: hide overflow above/below the viewport ────────
	// Strips stay inside the panel chrome; the panel already has buffer.
	draw_set_color(make_color_rgb(20, 18, 30));
	draw_set_alpha(achievements_alpha);
	draw_rectangle(_ap_x + 3, _ap_y + 3, _ap_x + _ap_w - 3, _viewport_top, false);
	draw_rectangle(_ap_x + 3, _viewport_bottom, _ap_x + _ap_w - 3, _ap_y + _ap_h - 3, false);
	// Redraw the gold border on top of the cover strips
	draw_set_color(make_color_rgb(255, 215, 0));
	draw_roundrect(_ap_x, _ap_y, _ap_x + _ap_w, _ap_y + _ap_h, true);
	draw_roundrect(_ap_x + 1, _ap_y + 1, _ap_x + _ap_w - 1, _ap_y + _ap_h - 1, true);
	// Redraw close X
	draw_sprite_ext(spr_button_close, 0,
		_ap_x + _ap_w - 36, _ap_y + 36, 0.5, 0.5, 0, c_white, achievements_alpha);
	// Redraw the title + progress count on top of the cover
	draw_set_font(fnt_luckiest_guy_96_outline);
	draw_set_color(make_color_rgb(255, 215, 0));
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_text_transformed(_cx_a, _ap_y + 20, "ACHIEVEMENTS", 0.55, 0.55, 0);
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(make_color_rgb(200, 200, 220));
	draw_text(_cx_a, _ap_y + 90, string(_unlocked_count) + " / " + string(_total_a) + " UNLOCKED");
	
	// Scroll hint at the bottom — drawn on top of the bottom cover strip
	var _total_rows = ceil(_total_a / _cards_per_row);
	var _content_h = _total_rows * _card_h + (_total_rows - 1) * _gap_y;
	var _view_h = _viewport_bottom - _viewport_top;
	if (_content_h > _view_h)
	{
		draw_set_font(fnt_luckiest_guy_24);
		draw_set_color(make_color_rgb(180, 180, 200));
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text_transformed(_cx_a, _ap_y + _ap_h - 22, "scroll with mouse wheel", 0.7, 0.7, 0);
	}
	
	draw_set_alpha(1.0);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// ═══ DAILY CHALLENGE CORNER BUTTON ═════════════════════════════════
{
	var _gw_d = display_get_gui_width();
	var _db_w = 280;
	var _db_h = 70;
	var _db_x = _gw_d - _db_w - 24;
	var _db_y = 524;
	var _mx_d = device_mouse_x_to_gui(0);
	var _my_d = device_mouse_y_to_gui(0);
	var _db_hover = (_mx_d >= _db_x && _mx_d <= _db_x + _db_w
				  && _my_d >= _db_y && _my_d <= _db_y + _db_h);
	draw_set_alpha(1.0);
	draw_set_color(_db_hover ? make_color_rgb(80, 50, 80) : make_color_rgb(40, 25, 45));
	draw_roundrect(_db_x, _db_y, _db_x + _db_w, _db_y + _db_h, false);
	draw_set_color(make_color_rgb(220, 130, 220));
	draw_roundrect(_db_x, _db_y, _db_x + _db_w, _db_y + _db_h, true);
	draw_roundrect(_db_x + 1, _db_y + 1, _db_x + _db_w - 1, _db_y + _db_h - 1, true);
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_text(_db_x + _db_w / 2, _db_y + _db_h / 2 + 4, "DAILY");
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// ═══ LOADOUT CORNER BUTTON ════════════════════════════════════════
{
	var _gw_l = display_get_gui_width();
	var _lb_w = 280;
	var _lb_h = 70;
	var _lb_x = _gw_l - _lb_w - 24;
	var _lb_y = 608;
	var _mx_l = device_mouse_x_to_gui(0);
	var _my_l = device_mouse_y_to_gui(0);
	var _lb_hover = (_mx_l >= _lb_x && _mx_l <= _lb_x + _lb_w
				  && _my_l >= _lb_y && _my_l <= _lb_y + _lb_h);
	draw_set_alpha(1.0);
	draw_set_color(_lb_hover ? make_color_rgb(40, 80, 60) : make_color_rgb(20, 40, 30));
	draw_roundrect(_lb_x, _lb_y, _lb_x + _lb_w, _lb_y + _lb_h, false);
	draw_set_color(make_color_rgb(120, 220, 140));
	draw_roundrect(_lb_x, _lb_y, _lb_x + _lb_w, _lb_y + _lb_h, true);
	draw_roundrect(_lb_x + 1, _lb_y + 1, _lb_x + _lb_w - 1, _lb_y + _lb_h - 1, true);
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_text(_lb_x + _lb_w / 2, _lb_y + _lb_h / 2 + 4, "LOADOUT");
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// ═══ DAILY CHALLENGE PANEL ═════════════════════════════════════════
if (is_daily_panel) daily_alpha_target = 1.0; else daily_alpha_target = 0.0;
daily_alpha = lerp(daily_alpha, daily_alpha_target, 0.1);

if (daily_alpha > 0.01)
{
	var _cw_d = display_get_gui_width();
	var _ch_d = display_get_gui_height();
	var _cx_d = _cw_d / 2;
	var _cy_d = _ch_d / 2;
	draw_set_color(c_black);
	draw_set_alpha(0.65 * daily_alpha);
	draw_rectangle(0, 0, _cw_d, _ch_d, false);
	draw_set_alpha(daily_alpha);
	var _dp_w = 760;
	var _dp_h = 540;
	var _dp_x = _cx_d - _dp_w / 2;
	var _dp_y = _cy_d - _dp_h / 2;
	draw_set_color(make_color_rgb(30, 25, 40));
	draw_roundrect(_dp_x, _dp_y, _dp_x + _dp_w, _dp_y + _dp_h, false);
	draw_set_color(make_color_rgb(220, 130, 220));
	draw_roundrect(_dp_x, _dp_y, _dp_x + _dp_w, _dp_y + _dp_h, true);
	draw_roundrect(_dp_x + 1, _dp_y + 1, _dp_x + _dp_w - 1, _dp_y + _dp_h - 1, true);
	draw_sprite_ext(spr_button_close, 0,
		_dp_x + _dp_w - 36, _dp_y + 36, 0.5, 0.5, 0, c_white, daily_alpha);
	draw_set_font(fnt_luckiest_guy_96_outline);
	draw_set_color(make_color_rgb(220, 130, 220));
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_text_transformed(_cx_d, _dp_y + 24, "DAILY CHALLENGE", 0.55, 0.55, 0);
	
	// Daily challenge date (currently yesterday — the daily was reverted)
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(make_color_rgb(180, 180, 200));
	var _ddate = date_inc_day(date_current_datetime(), -1);
	var _ymd = string(date_get_year(_ddate)) + "-" + string(date_get_month(_ddate)) + "-" + string(date_get_day(_ddate));
	draw_text(_cx_d, _dp_y + 110, _ymd);
	
	// Modifier name
	draw_set_font(fnt_luckiest_guy_36_outline);
	draw_set_color(make_color_rgb(255, 235, 130));
	draw_text(_cx_d, _dp_y + 200, daily_modifier_names[daily_modifier]);
	
	// Modifier description
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(c_white);
	{
		var _ddesc = daily_modifier_descs[daily_modifier];
		var _dmax_w = _dp_w - 80;
		var _dtw = string_width(_ddesc);
		var _dts = (_dtw > _dmax_w) ? _dmax_w / _dtw : 1.0;
		draw_text_transformed(_cx_d, _dp_y + 280, _ddesc, _dts, _dts, 0);
	}
	
	// Completion badge: check if today's date is in the completed list
	var _is_completed = false;
	if (variable_global_exists("daily_completed_dates"))
	{
		for (var _ci = 0; _ci < array_length(global.daily_completed_dates); _ci++)
		{
			if (global.daily_completed_dates[_ci] == daily_seed_date)
			{ _is_completed = true; break; }
		}
	}
	
	// Footer badge
	draw_set_font(fnt_luckiest_guy_36_outline);
	if (_is_completed)
	{
		draw_set_color(make_color_rgb(120, 255, 140));
		draw_text(_cx_d, _dp_y + _dp_h - 100, "COMPLETED");
		draw_set_font(fnt_luckiest_guy_24);
		draw_set_color(make_color_rgb(180, 200, 190));
		draw_text(_cx_d, _dp_y + _dp_h - 60, "Come back tomorrow for a new challenge!");
	}
	else
	{
		draw_set_color(make_color_rgb(255, 215, 0));
		draw_text(_cx_d, _dp_y + _dp_h - 100, "NOT COMPLETED");
		draw_set_font(fnt_luckiest_guy_24);
		draw_set_color(make_color_rgb(180, 200, 190));
		draw_text(_cx_d, _dp_y + _dp_h - 60,
			"Play an Unlimited run today to complete it");
	}
	
	draw_set_alpha(1.0);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// ═══ LOADOUT PANEL ═════════════════════════════════════════════════
if (is_loadout_panel) loadout_alpha_target = 1.0; else loadout_alpha_target = 0.0;
loadout_alpha = lerp(loadout_alpha, loadout_alpha_target, 0.1);

if (loadout_alpha > 0.01)
{
	var _cw_l = display_get_gui_width();
	var _ch_l = display_get_gui_height();
	var _cx_l = _cw_l / 2;
	var _cy_l = _ch_l / 2;
	draw_set_color(c_black);
	draw_set_alpha(0.65 * loadout_alpha);
	draw_rectangle(0, 0, _cw_l, _ch_l, false);
	draw_set_alpha(loadout_alpha);
	var _lp_w = 880;
	var _lp_h = 680;
	var _lp_x = _cx_l - _lp_w / 2;
	var _lp_y = _cy_l - _lp_h / 2;
	draw_set_color(make_color_rgb(20, 35, 25));
	draw_roundrect(_lp_x, _lp_y, _lp_x + _lp_w, _lp_y + _lp_h, false);
	draw_set_color(make_color_rgb(120, 220, 140));
	draw_roundrect(_lp_x, _lp_y, _lp_x + _lp_w, _lp_y + _lp_h, true);
	draw_roundrect(_lp_x + 1, _lp_y + 1, _lp_x + _lp_w - 1, _lp_y + _lp_h - 1, true);
	draw_sprite_ext(spr_button_close, 0,
		_lp_x + _lp_w - 36, _lp_y + 36, 0.5, 0.5, 0, c_white, loadout_alpha);
	draw_set_font(fnt_luckiest_guy_96_outline);
	draw_set_color(make_color_rgb(120, 220, 140));
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_text_transformed(_cx_l, _lp_y + 24, "LOADOUT", 0.55, 0.55, 0);
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(make_color_rgb(180, 200, 190));
	draw_text_transformed(_cx_l, _lp_y + 95, "Pick 3 starting gadgets - click to toggle - scroll for more", 0.7, 0.7, 0);
	var _picked = 0;
	for (var _li = 0; _li < array_length(loadout_items); _li++)
		if (loadout_items[_li].picked) _picked++;
	draw_set_color(_picked == 3 ? make_color_rgb(120, 255, 140) : make_color_rgb(220, 180, 60));
	draw_text(_cx_l, _lp_y + 125, string(_picked) + " / 3 SELECTED");
	
	// Scrollable card grid: 4 columns, 2 rows visible. Total items = 13.
	var _it_w = 180;
	var _it_h = 150;
	var _it_gx = 16;
	var _it_gy = 16;
	var _grid_w = _it_w * 4 + _it_gx * 3;
	var _gx_start = _cx_l - _grid_w / 2;
	// Viewport tuned to fit EXACTLY 2 rows: 150 + 16 + 150 = 316px.
	// Add 4px of breathing room top and bottom so cards don't touch the
	// cover strips (which can otherwise visually clip the card top edge).
	var _gy_base = _lp_y + 180;
	var _viewport_top_l = _lp_y + 176;
	var _viewport_bot_l = _lp_y + 180 + 316 + 4;   // +500
	var _row_count_l = ceil(array_length(loadout_items) / 4);
	var _content_h_l = _row_count_l * _it_h + (_row_count_l - 1) * _it_gy;
	var _view_h_l = _viewport_bot_l - _viewport_top_l;
	var _max_scroll_l = max(0, _content_h_l - (_view_h_l - 8));
	loadout_scroll = clamp(loadout_scroll, 0, _max_scroll_l);
	
	var _mx_l2 = device_mouse_x_to_gui(0);
	var _my_l2 = device_mouse_y_to_gui(0);
	for (var _i = 0; _i < array_length(loadout_items); _i++)
	{
		var _it = loadout_items[_i];
		var _col = _i mod 4;
		var _row = _i div 4;
		var _ix = _gx_start + _col * (_it_w + _it_gx);
		var _iy = _gy_base + _row * (_it_h + _it_gy) - loadout_scroll;
		
		// Strict viewport cull — page-snap scroll (no partial cards)
		if (_iy < _viewport_top_l || _iy + _it_h > _viewport_bot_l) continue;
		var _final_l = loadout_alpha;
		
		var _it_hover = (_mx_l2 >= _ix && _mx_l2 <= _ix + _it_w
					  && _my_l2 >= _iy && _my_l2 <= _iy + _it_h);
		var _it_bg = _it.picked
			? make_color_rgb(50, 100, 70)
			: (_it_hover ? make_color_rgb(40, 50, 45) : make_color_rgb(28, 35, 32));
		draw_set_color(_it_bg);
		draw_set_alpha(_final_l);
		draw_roundrect(_ix, _iy, _ix + _it_w, _iy + _it_h, false);
		draw_set_color(_it.picked ? make_color_rgb(120, 255, 150) : make_color_rgb(80, 100, 90));
		draw_roundrect(_ix, _iy, _ix + _it_w, _iy + _it_h, true);
		draw_set_color(_it.picked ? make_color_rgb(120, 255, 150) : make_color_rgb(80, 90, 85));
		draw_circle(_ix + _it_w / 2, _iy + 50, 26, false);
		draw_set_font(fnt_luckiest_guy_36_outline);
		draw_set_color(c_black);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text_transformed(_ix + _it_w / 2, _iy + 50 + 7, _it.letter, 0.7, 0.7, 0);
		draw_set_font(fnt_luckiest_guy_24);
		draw_set_color(c_white);
		// Auto-fit name within the card width
		{
			var _name_max = _it_w - 16;
			var _nw = string_width(_it.name);
			var _ns = (_nw > _name_max) ? _name_max / _nw : 1.0;
			_ns = min(_ns, 0.7);
			draw_text_transformed(_ix + _it_w / 2, _iy + 110, _it.name, _ns, _ns, 0);
		}
		if (_it.picked)
		{
			draw_set_color(make_color_rgb(120, 255, 150));
			draw_text(_ix + _it_w / 2, _iy + 134, "PICKED");
		}
		draw_set_alpha(1.0);
	}
	
	// Cover strips stay inside the panel chrome (panel has buffer now)
	draw_set_color(make_color_rgb(20, 35, 25));
	draw_set_alpha(loadout_alpha);
	draw_rectangle(_lp_x + 3, _lp_y + 3, _lp_x + _lp_w - 3, _viewport_top_l, false);
	draw_rectangle(_lp_x + 3, _viewport_bot_l, _lp_x + _lp_w - 3, _lp_y + _lp_h - 3, false);
	// Redraw the green border on top
	draw_set_color(make_color_rgb(120, 220, 140));
	draw_roundrect(_lp_x, _lp_y, _lp_x + _lp_w, _lp_y + _lp_h, true);
	draw_roundrect(_lp_x + 1, _lp_y + 1, _lp_x + _lp_w - 1, _lp_y + _lp_h - 1, true);
	// Redraw the header on top of the cover strip
	draw_sprite_ext(spr_button_close, 0,
		_lp_x + _lp_w - 36, _lp_y + 36, 0.5, 0.5, 0, c_white, loadout_alpha);
	draw_set_font(fnt_luckiest_guy_96_outline);
	draw_set_color(make_color_rgb(120, 220, 140));
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_text_transformed(_cx_l, _lp_y + 24, "LOADOUT", 0.55, 0.55, 0);
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(make_color_rgb(180, 200, 190));
	draw_text_transformed(_cx_l, _lp_y + 95, "Pick 3 starting gadgets - click to toggle - scroll for more", 0.7, 0.7, 0);
	draw_set_color(_picked == 3 ? make_color_rgb(120, 255, 140) : make_color_rgb(220, 180, 60));
	draw_text(_cx_l, _lp_y + 125, string(_picked) + " / 3 SELECTED");
	// Scroll hint at the bottom if content overflows
	if (_max_scroll_l > 0)
	{
		draw_set_color(make_color_rgb(180, 220, 200));
		draw_text_transformed(_cx_l, _lp_y + _lp_h - 16, "scroll with mouse wheel", 0.55, 0.55, 0);
	}
	
	draw_set_alpha(1.0);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// (The RECENTS button is now drawn by obj_main_menu_ui as the 4th main button.
// Its click handler opens the recent games panel via this splash manager.)

// ═══ RECENT GAMES PANEL ════════════════════════════════════════════
if (is_recent_games) {
	recent_games_alpha_target = 1.0;
} else {
	recent_games_alpha_target = 0.0;
}
recent_games_alpha = lerp(recent_games_alpha, recent_games_alpha_target, 0.1);

if (recent_games_alpha > 0.01)
{
	var _cw2 = display_get_gui_width();
	var _ch2 = display_get_gui_height();
	var _cx2 = _cw2 / 2;
	var _cy2 = _ch2 / 2;
	
	// Backdrop
	draw_set_color(c_black);
	draw_set_alpha(0.65 * recent_games_alpha);
	draw_rectangle(0, 0, _cw2, _ch2, false);
	draw_set_alpha(recent_games_alpha);
	
	var _rp_w = 880;
	var _rp_h = 720;
	var _rp_x = _cx2 - _rp_w / 2;
	var _rp_y = _cy2 - _rp_h / 2;
	
	draw_set_color(make_color_rgb(30, 30, 40));
	draw_roundrect(_rp_x, _rp_y, _rp_x + _rp_w, _rp_y + _rp_h, false);
	draw_set_color(make_color_rgb(255, 215, 0));
	draw_roundrect(_rp_x, _rp_y, _rp_x + _rp_w, _rp_y + _rp_h, true);
	draw_roundrect(_rp_x + 1, _rp_y + 1, _rp_x + _rp_w - 1, _rp_y + _rp_h - 1, true);
	
	// Close X button at top-right
	{
		var _x_cx = _rp_x + _rp_w - 36;
		var _x_cy = _rp_y + 36;
		var _scale = 0.5;
		draw_sprite_ext(spr_button_close, 0, _x_cx, _x_cy, _scale, _scale, 0, c_white, recent_games_alpha);
	}
	
	// Title
	draw_set_font(fnt_luckiest_guy_96_outline);
	draw_set_color(make_color_rgb(255, 215, 0));
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_text_transformed(_cx2, _rp_y + 20, "RECENT GAMES", 0.55, 0.55, 0);
	
	// Close hint
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(make_color_rgb(180, 180, 180));
	draw_text(_cx2, _rp_y + 90, "Click a game to see details   -   Click the X to close");
	
	var _mx2 = device_mouse_x_to_gui(0);
	var _my2 = device_mouse_y_to_gui(0);
	
	if (recent_selected_index < 0)
	{
		// List view: each row is a game summary
		if (array_length(recent_games) == 0)
		{
			draw_set_color(make_color_rgb(150, 150, 160));
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_font(fnt_luckiest_guy_24);
			draw_text(_cx2, _cy2, "No games played yet. Go play some!");
		}
		else
		{
			var _row_h = 56;
			var _row_y_start = _rp_y + 140;
			var _max_rows = min(array_length(recent_games), 10);
			for (var _i = 0; _i < _max_rows; _i++)
			{
				var _g = recent_games[_i];
				var _rx = _rp_x + 40;
				var _ry = _row_y_start + _i * _row_h;
				var _rw = _rp_w - 80;
				var _rh = _row_h - 8;
				
				// Row hover
				var _row_hover = (_mx2 >= _rx && _mx2 <= _rx + _rw
							  && _my2 >= _ry && _my2 <= _ry + _rh);
				draw_set_color(_row_hover
					? make_color_rgb(60, 60, 85)
					: make_color_rgb(40, 40, 55));
				draw_roundrect(_rx, _ry, _rx + _rw, _ry + _rh, false);
				draw_set_color(make_color_rgb(100, 100, 130));
				draw_roundrect(_rx, _ry, _rx + _rw, _ry + _rh, true);
				
				// Mode label
				draw_set_color(make_color_rgb(255, 215, 0));
				draw_set_font(fnt_luckiest_guy_24);
				draw_set_halign(fa_left);
				draw_set_valign(fa_middle);
				var _mode = "UNLIMITED";
				if (variable_struct_exists(_g, "mode") && _g.mode == "timed") _mode = "TIMED";
				draw_text(_rx + 16, _ry + _rh / 2, _mode);
				
				// Score
				draw_set_color(c_white);
				draw_set_halign(fa_center);
				draw_text(_rx + _rw * 0.45, _ry + _rh / 2, "Score: " + string(_g.score));
				
				// Wave / kills
				draw_set_color(make_color_rgb(200, 200, 220));
				draw_set_halign(fa_right);
				draw_text(_rx + _rw - 16, _ry + _rh / 2,
					"Wave " + string(_g.wave) + "   " + string(_g.kills) + " kills");
			}
		}
	}
	else if (recent_selected_index < array_length(recent_games))
	{
		// Detail view: show stats for the selected game
		var _g = recent_games[recent_selected_index];
		var _total = _g.correct + _g.wrong;
		var _acc_pct = (_total > 0) ? round(_g.accuracy * 100) : 0;
		var _dur_sec = round(_g.duration / 1000);
		var _dur_min = _dur_sec div 60;
		_dur_sec = _dur_sec mod 60;
		
		var _mode = "UNLIMITED MODE";
		if (variable_struct_exists(_g, "mode") && _g.mode == "timed") _mode = "TIMED MODE";
		
		// Sub-header
		draw_set_font(fnt_luckiest_guy_36_outline);
		draw_set_color(make_color_rgb(255, 215, 80));
		draw_set_halign(fa_center);
		draw_set_valign(fa_top);
		draw_text(_cx2, _rp_y + 140, _mode);
		
		// Stat lines
		draw_set_font(fnt_luckiest_guy_24);
		draw_set_color(c_white);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		var _sx = _rp_x + 100;
		var _sw = _rp_w - 200;
		var _line_y = _rp_y + 220;
		var _gap = 50;
		
		var _stats = [
			["FINAL SCORE",        string(_g.score)],
			["WAVE REACHED",       string(_g.wave)],
			["ZOMBIES KILLED",     string(_g.kills)],
			["BOSS KILLS",         string(_g.boss)],
			["CORRECT ANSWERS",    string(_g.correct)],
			["WRONG ANSWERS",      string(_g.wrong)],
			["ACCURACY",           string(_acc_pct) + "%"],
			["TIME PLAYED",        string(_dur_min) + "m " + string(_dur_sec) + "s"]
		];
		for (var _i = 0; _i < array_length(_stats); _i++)
		{
			var _row = _stats[_i];
			draw_set_color(make_color_rgb(200, 200, 220));
			draw_set_halign(fa_left);
			draw_text(_sx, _line_y + _i * _gap, _row[0]);
			draw_set_color(make_color_rgb(255, 230, 100));
			draw_set_halign(fa_right);
			draw_text(_sx + _sw, _line_y + _i * _gap, _row[1]);
		}
		
		// BACK button at bottom
		var _back_w = 200;
		var _back_h = 50;
		var _back_x = _cx2 - _back_w / 2;
		var _back_y = _rp_y + _rp_h - 70;
		var _back_hover = (_mx2 >= _back_x && _mx2 <= _back_x + _back_w
					   && _my2 >= _back_y && _my2 <= _back_y + _back_h);
		draw_set_color(_back_hover ? make_color_rgb(80, 60, 60) : make_color_rgb(50, 35, 35));
		draw_roundrect(_back_x, _back_y, _back_x + _back_w, _back_y + _back_h, false);
		draw_set_color(make_color_rgb(220, 160, 80));
		draw_roundrect(_back_x, _back_y, _back_x + _back_w, _back_y + _back_h, true);
		draw_set_font(fnt_luckiest_guy_24);
		draw_set_color(c_white);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(_back_x + _back_w / 2, _back_y + _back_h / 2, "BACK TO LIST");
	}
	
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1.0);
}
