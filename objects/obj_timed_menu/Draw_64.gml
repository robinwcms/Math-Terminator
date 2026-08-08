// Draw the "Press T for Timed Mode" hint at top of main menu (always)
if (!menu_visible)
{
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(c_white);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_alpha(0.7);
	draw_text(display_get_gui_width() / 2, 30, "Press T for Timed Mode");
	draw_set_alpha(1.0);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	exit;
}

// ─── DRAW OVERLAY PANEL ────────────────────────────────────────────
var _cw = display_get_gui_width();
var _ch = display_get_gui_height();
var _cx = _cw / 2;
var _cy = _ch / 2;

// Dark backdrop
draw_set_color(c_black);
draw_set_alpha(0.7);
draw_rectangle(0, 0, _cw, _ch, false);
draw_set_alpha(1.0);

// Panel
var _panel_w = 700;
var _panel_h = 400;
var _panel_x = _cx - _panel_w / 2;
var _panel_y = _cy - _panel_h / 2;

// Panel background
draw_set_color(make_color_rgb(30, 30, 40));
draw_roundrect(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, false);
// Panel border (gold)
draw_set_color(make_color_rgb(255, 215, 0));
draw_roundrect(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, true);
draw_roundrect(_panel_x + 1, _panel_y + 1, _panel_x + _panel_w - 1, _panel_y + _panel_h - 1, true);

// Mouse position (GUI space)
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// ─── BACK BUTTON ───────────────────────────────────────────────────
var _back_hover = (_mx >= _panel_x + 20 && _mx <= _panel_x + 120
				&& _my >= _panel_y + 20 && _my <= _panel_y + 60);
draw_set_color(_back_hover ? make_color_rgb(255, 215, 0) : c_white);
draw_roundrect(_panel_x + 20, _panel_y + 20, _panel_x + 120, _panel_y + 60, true);
draw_set_font(fnt_luckiest_guy_24);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(_back_hover ? make_color_rgb(255, 215, 0) : c_white);
draw_text(_panel_x + 70, _panel_y + 44, "BACK");

// ─── TITLE ─────────────────────────────────────────────────────────
draw_set_font(fnt_luckiest_guy_36_outline);
draw_set_color(make_color_rgb(255, 215, 0));
draw_text(_cx, _panel_y + 50, "TIMED CHALLENGE");

// ─── DURATION SECTION ──────────────────────────────────────────────
draw_set_font(fnt_luckiest_guy_24);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_text(_panel_x + 60, _panel_y + 120, "Round Length");

var _dur_x = _panel_x + 60;
var _dur_y = _panel_y + 160;
var _dur_w = 130;
var _dur_h = 50;
for (var _i = 0; _i < 4; _i++)
{
	var _bx = _dur_x + _i * (_dur_w + 15);
	var _selected = (global.timed_duration == duration_choices[_i]);
	var _hover = (_mx >= _bx && _mx <= _bx + _dur_w && _my >= _dur_y && _my <= _dur_y + _dur_h);
	
	var _bg, _border, _txt;
	if (_selected) {
		_bg = make_color_rgb(255, 215, 0);
		_border = c_black;
		_txt = c_black;
	} else if (_hover) {
		_bg = make_color_rgb(80, 80, 100);
		_border = make_color_rgb(255, 215, 0);
		_txt = c_white;
	} else {
		_bg = make_color_rgb(50, 50, 60);
		_border = c_white;
		_txt = c_white;
	}
	
	draw_set_color(_bg);
	draw_roundrect(_bx, _dur_y, _bx + _dur_w, _dur_y + _dur_h, false);
	draw_set_color(_border);
	draw_roundrect(_bx, _dur_y, _bx + _dur_w, _dur_y + _dur_h, true);
	draw_roundrect(_bx + 1, _dur_y + 1, _bx + _dur_w - 1, _dur_y + _dur_h - 1, true);
	
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(_txt);
	draw_text(_bx + _dur_w / 2, _dur_y + _dur_h / 2, duration_labels[_i]);
	draw_set_halign(fa_left);
}

// (Math Operations section removed — timed mode uses all operations by default.)

// ─── PLAY BUTTON ───────────────────────────────────────────────────
var _play_w = 220;
var _play_h = 60;
var _play_x = _cx - _play_w / 2;
var _play_y = _panel_y + _panel_h - 90;
var _play_hover = (_mx >= _play_x && _mx <= _play_x + _play_w
				&& _my >= _play_y && _my <= _play_y + _play_h);

draw_set_color(_play_hover ? make_color_rgb(120, 255, 120) : make_color_rgb(76, 175, 80));
draw_roundrect(_play_x, _play_y, _play_x + _play_w, _play_y + _play_h, false);
draw_set_color(c_white);
draw_roundrect(_play_x, _play_y, _play_x + _play_w, _play_y + _play_h, true);
draw_roundrect(_play_x + 1, _play_y + 1, _play_x + _play_w - 1, _play_y + _play_h - 1, true);

draw_set_font(fnt_luckiest_guy_36_outline);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(_play_x + _play_w / 2, _play_y + _play_h / 2, "PLAY");

// Reset
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
