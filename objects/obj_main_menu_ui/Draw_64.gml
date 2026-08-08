var _cw = display_get_gui_width();
var _ch = display_get_gui_height();
var _cx = _cw / 2;
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// ═══ TITLE ═══════════════════════════════════════════════════════════
// Draw the MATH TERMINATOR title sprite, fit to screen width
var _title_y = _ch * 0.20;
var _title_bob = sin(degtorad(title_pulse)) * 4;

// Target width: 70% of screen, max 1100px
var _title_sw = sprite_get_width(spr_math_title);
var _title_sh = sprite_get_height(spr_math_title);
var _title_target_w = min(_cw * 0.70, 1100);
var _title_scale = _title_target_w / _title_sw;

// Periodic pop: when title_pop_value > 0, we briefly upscale the title.
// Use a curve where the pop bursts quickly and eases out (1-cos)
var _pop_curve = 1 - cos(title_pop_value * 3.14159);   // peaks at 2, eases to 0
var _pop_extra_scale = _pop_curve * 0.08;              // up to +8% scale
var _draw_scale = _title_scale * (1 + _pop_extra_scale);

// ─── PULSING WARM GLOW BEHIND THE TITLE (layered concentric ellipses) ───
// Drawn before the title sprite so the title sits on top of the glow.
// The glow brightens and expands during a title pop.
{
	var _glow_pulse = 0.6 + 0.3 * sin(degtorad(title_pulse * 2));
	// Boost glow intensity and size during the pop
	var _glow_boost = 1 + _pop_curve * 0.5;       // up to 1.5x glow brightness
	var _glow_size_boost = 1 + _pop_curve * 0.15; // up to 1.15x glow size
	var _glow_x = _cx;
	var _glow_y = _title_y + _title_bob;
	var _glow_rw = _title_target_w * 0.85 * _glow_size_boost;
	var _glow_rh = _title_sh * _title_scale * 1.8 * _glow_size_boost;
	for (var _g = 0; _g < 14; _g++)
	{
		var _gfrac = _g / 14;
		var _ga = (1 - _gfrac) * 0.07 * _glow_pulse * _glow_boost;
		var _rw = _glow_rw * (0.4 + _gfrac * 0.6);
		var _rh = _glow_rh * (0.4 + _gfrac * 0.6);
		draw_set_color(make_color_rgb(255, 180, 60));
		draw_set_alpha(_ga);
		draw_ellipse(_glow_x - _rw, _glow_y - _rh, _glow_x + _rw, _glow_y + _rh, false);
	}
	draw_set_alpha(1.0);
}

// Subtle shadow
draw_sprite_ext(spr_math_title, 0,
	_cx + 5, _title_y + _title_bob + 5,
	_draw_scale, _draw_scale, 0, c_black, 0.55);
// Main title
draw_sprite_ext(spr_math_title, 0,
	_cx, _title_y + _title_bob,
	_draw_scale, _draw_scale, 0, c_white, 1.0);

// Subtitle
draw_set_font(fnt_luckiest_guy_24);
draw_set_color(make_color_rgb(200, 200, 200));
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var _subtitle_y = _title_y + _title_sh * _title_scale / 2 + 30;
draw_text(_cx, _subtitle_y, "shoot the right answer. survive the math.");

// ═══ DRAW BUTTONS (main view) ═══════════════════════════════════════
if (!show_timed_submenu)
{
	var _btn_w = 440;
	var _btn_h = 80;
	var _base_y = _ch * 0.50;
	
	// Compute one uniform scale based on the WIDEST sprite so all four
	// label heights match visually.
	var _pad_w = _btn_w - 40;
	var _pad_h = _btn_h - 20;
	var _w_u = sprite_get_width(spr_btn_unlimited);
	var _h_u = sprite_get_height(spr_btn_unlimited);
	var _w_t = sprite_get_width(spr_btn_timed);
	var _h_t = sprite_get_height(spr_btn_timed);
	var _w_tut = sprite_get_width(spr_btn_tutorial);
	var _h_tut = sprite_get_height(spr_btn_tutorial);
	var _w_r = sprite_get_width(spr_btn_recents);
	var _h_r = sprite_get_height(spr_btn_recents);
	var _uniform_scale = min(
		min(min(_pad_w / _w_u,   _pad_h / _h_u),
		    min(_pad_w / _w_t,   _pad_h / _h_t)),
		min(min(_pad_w / _w_tut, _pad_h / _h_tut),
		    min(_pad_w / _w_r,   _pad_h / _h_r))
	);
	
	// UNLIMITED button — dark warm charcoal
	var _ub_y = _base_y;
	var _ub_hover = (_mx >= _cx - _btn_w/2 && _mx <= _cx + _btn_w/2
				  && _my >= _ub_y && _my <= _ub_y + _btn_h);
	var _ub_bg = _ub_hover ? make_color_rgb(58, 44, 36) : make_color_rgb(36, 28, 24);
	draw_set_color(_ub_bg);
	draw_roundrect(_cx - _btn_w/2, _ub_y, _cx + _btn_w/2, _ub_y + _btn_h, false);
	draw_set_color(make_color_rgb(200, 160, 50));
	draw_roundrect(_cx - _btn_w/2, _ub_y, _cx + _btn_w/2, _ub_y + _btn_h, true);
	draw_roundrect(_cx - _btn_w/2 + 1, _ub_y + 1, _cx + _btn_w/2 - 1, _ub_y + _btn_h - 1, true);
	draw_roundrect(_cx - _btn_w/2 + 2, _ub_y + 2, _cx + _btn_w/2 - 2, _ub_y + _btn_h - 2, true);
	draw_sprite_ext(spr_btn_unlimited, 0,
		_cx, _ub_y + _btn_h / 2,
		_uniform_scale, _uniform_scale, 0, c_white, 1.0);
	
	// TIMED button — dark cool charcoal
	var _tb_y = _base_y + 100;
	var _tb_hover = (_mx >= _cx - _btn_w/2 && _mx <= _cx + _btn_w/2
				  && _my >= _tb_y && _my <= _tb_y + _btn_h);
	var _tb_bg = _tb_hover ? make_color_rgb(44, 48, 58) : make_color_rgb(28, 30, 38);
	draw_set_color(_tb_bg);
	draw_roundrect(_cx - _btn_w/2, _tb_y, _cx + _btn_w/2, _tb_y + _btn_h, false);
	draw_set_color(make_color_rgb(200, 160, 50));
	draw_roundrect(_cx - _btn_w/2, _tb_y, _cx + _btn_w/2, _tb_y + _btn_h, true);
	draw_roundrect(_cx - _btn_w/2 + 1, _tb_y + 1, _cx + _btn_w/2 - 1, _tb_y + _btn_h - 1, true);
	draw_roundrect(_cx - _btn_w/2 + 2, _tb_y + 2, _cx + _btn_w/2 - 2, _tb_y + _btn_h - 2, true);
	draw_sprite_ext(spr_btn_timed, 0,
		_cx, _tb_y + _btn_h / 2,
		_uniform_scale, _uniform_scale, 0, c_white, 1.0);
	
	// TUTORIAL button — dark neutral charcoal
	var _tut_y = _base_y + 200;
	var _tut_hover = (_mx >= _cx - _btn_w/2 && _mx <= _cx + _btn_w/2
				   && _my >= _tut_y && _my <= _tut_y + _btn_h);
	var _tut_bg = _tut_hover ? make_color_rgb(50, 46, 34) : make_color_rgb(32, 28, 20);
	draw_set_color(_tut_bg);
	draw_roundrect(_cx - _btn_w/2, _tut_y, _cx + _btn_w/2, _tut_y + _btn_h, false);
	draw_set_color(make_color_rgb(200, 160, 50));
	draw_roundrect(_cx - _btn_w/2, _tut_y, _cx + _btn_w/2, _tut_y + _btn_h, true);
	draw_roundrect(_cx - _btn_w/2 + 1, _tut_y + 1, _cx + _btn_w/2 - 1, _tut_y + _btn_h - 1, true);
	draw_roundrect(_cx - _btn_w/2 + 2, _tut_y + 2, _cx + _btn_w/2 - 2, _tut_y + _btn_h - 2, true);
	draw_sprite_ext(spr_btn_tutorial, 0,
		_cx, _tut_y + _btn_h / 2,
		_uniform_scale, _uniform_scale, 0, c_white, 1.0);
	
	// RECENTS button — dark cool steel
	var _rb_y = _base_y + 300;
	var _rb_hover = (_mx >= _cx - _btn_w/2 && _mx <= _cx + _btn_w/2
				  && _my >= _rb_y && _my <= _rb_y + _btn_h);
	var _rb_bg = _rb_hover ? make_color_rgb(40, 50, 60) : make_color_rgb(24, 30, 38);
	draw_set_color(_rb_bg);
	draw_roundrect(_cx - _btn_w/2, _rb_y, _cx + _btn_w/2, _rb_y + _btn_h, false);
	draw_set_color(make_color_rgb(200, 160, 50));
	draw_roundrect(_cx - _btn_w/2, _rb_y, _cx + _btn_w/2, _rb_y + _btn_h, true);
	draw_roundrect(_cx - _btn_w/2 + 1, _rb_y + 1, _cx + _btn_w/2 - 1, _rb_y + _btn_h - 1, true);
	draw_roundrect(_cx - _btn_w/2 + 2, _rb_y + 2, _cx + _btn_w/2 - 2, _rb_y + _btn_h - 2, true);
	draw_sprite_ext(spr_btn_recents, 0,
		_cx, _rb_y + _btn_h / 2,
		_uniform_scale, _uniform_scale, 0, c_white, 1.0);
}
else
{
	// ═══ TIMED SUBMENU OVERLAY ═════════════════════════════════════
	draw_set_color(c_black);
	draw_set_alpha(0.7);
	draw_rectangle(0, 0, _cw, _ch, false);
	draw_set_alpha(1.0);
	
	// Shorter panel now that the Math Operations section is gone
	var _panel_w = 700;
	var _panel_h = 400;
	var _panel_x = _cx - _panel_w / 2;
	var _panel_y = _ch / 2 - _panel_h / 2;
	
	draw_set_color(make_color_rgb(30, 30, 40));
	draw_roundrect(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, false);
	draw_set_color(make_color_rgb(255, 215, 0));
	draw_roundrect(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, true);
	draw_roundrect(_panel_x + 1, _panel_y + 1, _panel_x + _panel_w - 1, _panel_y + _panel_h - 1, true);
	
	// BACK button
	var _back_hover = (_mx >= _panel_x + 20 && _mx <= _panel_x + 120
					&& _my >= _panel_y + 20 && _my <= _panel_y + 60);
	draw_set_color(_back_hover ? make_color_rgb(255, 215, 0) : c_white);
	draw_roundrect(_panel_x + 20, _panel_y + 20, _panel_x + 120, _panel_y + 60, true);
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	// Slight Y nudge for visual centering with Luckiest Guy font
	draw_text(_panel_x + 70, _panel_y + 44, "BACK");
	
	// Title
	draw_set_font(fnt_luckiest_guy_36_outline);
	draw_set_color(make_color_rgb(255, 215, 0));
	draw_text(_cx, _panel_y + 50, "TIMED CHALLENGE");
	
	// Duration section
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_text(_panel_x + 60, _panel_y + 120, "Round Length");
	
	var _dur_x = _panel_x + 60;
	var _dur_y = _panel_y + 160;
	var _dur_w = 130;
	var _dur_h = 50;
	for (var _i = 0; _i < 4; _i++) {
		var _bx = _dur_x + _i * (_dur_w + 15);
		var _selected = (global.timed_duration == duration_choices[_i]);
		var _hover = (_mx >= _bx && _mx <= _bx + _dur_w && _my >= _dur_y && _my <= _dur_y + _dur_h);
		var _bg, _border, _txt;
		if (_selected) { _bg = make_color_rgb(255, 215, 0); _border = c_black; _txt = c_black; }
		else if (_hover) { _bg = make_color_rgb(80, 80, 100); _border = make_color_rgb(255, 215, 0); _txt = c_white; }
		else { _bg = make_color_rgb(50, 50, 60); _border = c_white; _txt = c_white; }
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
	
	// PLAY button
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
}

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
