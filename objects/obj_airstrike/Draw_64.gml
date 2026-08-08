var _cw = display_get_gui_width();
var _ch = display_get_gui_height();
var _cx = _cw / 2;
var _cy = _ch / 2;

// Cancel button top-left
draw_set_color(make_color_rgb(120, 50, 50));
draw_roundrect(30, 30, 130, 70, false);
draw_set_color(c_white);
draw_roundrect(30, 30, 130, 70, true);
draw_set_font(fnt_luckiest_guy_24);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(80, 50, "CANCEL");

if (phase == "math")
{
	// Dark background
	draw_set_color(c_black);
	draw_set_alpha(0.75);
	draw_rectangle(0, 0, _cw, _ch, false);
	draw_set_alpha(1.0);
	
	// Title
	draw_set_font(fnt_luckiest_guy_36_outline);
	draw_set_color(make_color_rgb(220, 100, 60));
	draw_text(_cx, 80, "AIRSTRIKE  -  ANSWER " + string(questions_left) + " MORE");
	
	// Question
	draw_set_font(fnt_luckiest_guy_36_outline);
	draw_set_color(make_color_rgb(255, 215, 0));
	var _qw = string_width(question_text) + 60;
	var _qh = string_height(question_text) + 30;
	var _qy = _cy - 200;
	draw_roundrect(_cx - _qw/2, _qy - _qh/2, _cx + _qw/2, _qy + _qh/2, false);
	draw_set_color(c_black);
	draw_roundrect(_cx - _qw/2, _qy - _qh/2, _cx + _qw/2, _qy + _qh/2, true);
	draw_set_color(c_black);
	draw_text(_cx, _qy, question_text);
	
	// 2x2 answer grid
	var _btn_w = 220;
	var _btn_h = 100;
	var _gap = 30;
	var _grid_w = _btn_w * 2 + _gap;
	var _gx0 = _cx - _grid_w / 2;
	var _gy0 = _cy - 40;
	
	var _mx = device_mouse_x_to_gui(0);
	var _my = device_mouse_y_to_gui(0);
	
	draw_set_font(fnt_luckiest_guy_24);
	for (var _i = 0; _i < 4; _i++) {
		var _col = _i mod 2;
		var _row = _i div 2;
		var _bx = _gx0 + _col * (_btn_w + _gap);
		var _by = _gy0 + _row * (_btn_h + _gap);
		var _hover = (_mx >= _bx && _mx <= _bx + _btn_w && _my >= _by && _my <= _by + _btn_h);
		
		// Flash visual
		var _bg, _txt_col;
		if (flash_timer > 0 && choices[_i] == question_answer) {
			_bg = make_color_rgb(76, 175, 80);
			_txt_col = c_white;
		} else if (_hover) {
			_bg = make_color_rgb(255, 235, 130);
			_txt_col = c_black;
		} else {
			_bg = c_white;
			_txt_col = c_black;
		}
		draw_set_color(_bg);
		draw_roundrect(_bx, _by, _bx + _btn_w, _by + _btn_h, false);
		draw_set_color(c_black);
		draw_roundrect(_bx, _by, _bx + _btn_w, _by + _btn_h, true);
		draw_roundrect(_bx + 1, _by + 1, _bx + _btn_w - 1, _by + _btn_h - 1, true);
		draw_set_color(_txt_col);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(_bx + _btn_w / 2, _by + _btn_h / 2, string(choices[_i]));
	}
}
else if (phase == "select")
{
	// Faint red tint overlay
	draw_set_color(make_color_rgb(120, 30, 30));
	draw_set_alpha(0.15);
	draw_rectangle(0, 0, _cw, _ch, false);
	draw_set_alpha(1.0);
	
	// Instruction at top
	draw_set_font(fnt_luckiest_guy_36_outline);
	draw_set_color(make_color_rgb(220, 80, 80));
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_text(_cx, 80, "CLICK TO AIRSTRIKE  -  WASD TO PAN MAP");
	
	// Crosshair at mouse - convert world mouse to GUI for drawing
	var _vx = camera_get_view_x(view_camera[0]);
	var _vy = camera_get_view_y(view_camera[0]);
	var _vw = camera_get_view_width(view_camera[0]);
	var _vh = camera_get_view_height(view_camera[0]);
	// World mouse -> GUI
	var _mx_gui = (mouse_x - _vx) / _vw * _cw;
	var _my_gui = (mouse_y - _vy) / _vh * _ch;
	// Strike radius in world (400) -> GUI
	var _gui_radius = 400 / _vw * _cw;
	
	// Filled red zone (translucent, makes the strike area obvious)
	draw_set_color(make_color_rgb(255, 50, 50));
	draw_set_alpha(0.18);
	draw_circle(_mx_gui, _my_gui, _gui_radius, false);
	draw_set_alpha(1.0);
	
	// Pulse-thickness outline — bright red, very thick (8px wide ring)
	var _pulse = 1.0 + 0.2 * sin(current_time / 100);
	var _ring_thickness = 8 * _pulse;
	draw_set_color(make_color_rgb(255, 60, 60));
	// Draw concentric circles to fake a thick stroke
	for (var _r = 0; _r < _ring_thickness; _r++) {
		draw_circle(_mx_gui, _my_gui, _gui_radius - _r, true);
	}
	// White inner highlight ring for contrast against red ground
	draw_set_color(c_white);
	draw_circle(_mx_gui, _my_gui, _gui_radius - _ring_thickness - 1, true);
	draw_circle(_mx_gui, _my_gui, _gui_radius - _ring_thickness - 2, true);
	// Black outer outline for contrast against light backgrounds
	draw_set_color(c_black);
	draw_circle(_mx_gui, _my_gui, _gui_radius + 1, true);
	draw_circle(_mx_gui, _my_gui, _gui_radius + 2, true);
	
	// Center crosshair — thicker and longer
	draw_set_color(make_color_rgb(255, 240, 100));
	draw_line_width(_mx_gui - 30, _my_gui, _mx_gui + 30, _my_gui, 4);
	draw_line_width(_mx_gui, _my_gui - 30, _mx_gui, _my_gui + 30, 4);
	// Black outline on crosshair for contrast
	draw_set_color(c_black);
	draw_line_width(_mx_gui - 30, _my_gui - 3, _mx_gui + 30, _my_gui - 3, 1);
	draw_line_width(_mx_gui - 30, _my_gui + 3, _mx_gui + 30, _my_gui + 3, 1);
	draw_line_width(_mx_gui - 3, _my_gui - 30, _mx_gui - 3, _my_gui + 30, 1);
	draw_line_width(_mx_gui + 3, _my_gui - 30, _mx_gui + 3, _my_gui + 30, 1);
	// Center dot
	draw_set_color(make_color_rgb(255, 50, 50));
	draw_circle(_mx_gui, _my_gui, 5, false);
	draw_set_color(c_white);
	draw_circle(_mx_gui, _my_gui, 5, true);
}

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
