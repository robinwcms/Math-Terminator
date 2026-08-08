// Determine colours based on lockout, flash, and hover state
var _bg, _border, _txt;
// Beacon highlight: owner zombie is within beacon range — visually mark
// the CORRECT answer weakspot with a gold glow so the player knows which
// to click without solving the math.
var _beacon_hint = (instance_exists(owner)
				 && variable_instance_exists(owner, "beacon_hint_timer")
				 && owner.beacon_hint_timer > 0
				 && is_answer);

// Wrong-answer lockout overrides everything — grayed out
if (instance_exists(owner) && owner.wrong_lockout_timer > 0)
{
	_bg = make_color_rgb(70, 70, 80);
	_border = make_color_rgb(40, 40, 50);
	_txt = make_color_rgb(120, 120, 130);
}
else if (_beacon_hint)
{
	// Gold pulsing highlight on the correct weakspot
	var _pulse = 0.5 + 0.5 * sin(current_time * 0.008);
	_bg = make_color_rgb(255, 230 - _pulse * 30, 100);
	_border = make_color_rgb(200, 160, 30);
	_txt = c_black;
}
else if (flash_timer > 0)
{
	if (is_answer)
	{
		_bg = make_color_rgb(76, 175, 80);   // green
		_border = make_color_rgb(20, 80, 20);
		_txt = c_white;
	}
	else
	{
		_bg = make_color_rgb(226, 75, 74);   // red
		_border = make_color_rgb(120, 30, 30);
		_txt = c_white;
	}
}
else if (is_hovered)
{
	_bg = make_color_rgb(255, 235, 130);     // bright yellow on hover
	_border = c_black;
	_txt = c_black;
}
else
{
	_bg = c_white;
	_border = c_black;
	_txt = c_black;
}

// Drop shadow
draw_set_color(c_black);
draw_set_alpha(0.4);
draw_roundrect(x - ws_width/2 + 4, y - ws_height/2 + 5,
			   x + ws_width/2 + 4, y + ws_height/2 + 5, false);
draw_set_alpha(1.0);

// Gold halo around the correct weakspot when beacon-highlighted
if (_beacon_hint)
{
	var _glow_pulse = 0.5 + 0.5 * sin(current_time * 0.008);
	for (var _g = 0; _g < 5; _g++)
	{
		var _gx = _g * 3;
		draw_set_color(make_color_rgb(255, 215, 0));
		draw_set_alpha((0.6 - _g * 0.1) * (0.6 + _glow_pulse * 0.4));
		draw_roundrect(x - ws_width/2 - _gx, y - ws_height/2 - _gx,
					   x + ws_width/2 + _gx, y + ws_height/2 + _gx, true);
	}
	draw_set_alpha(1.0);
}

// Background
draw_set_color(_bg);
draw_roundrect(x - ws_width/2, y - ws_height/2,
			   x + ws_width/2, y + ws_height/2, false);

// Thick black border (drawn 3 times for thickness)
draw_set_color(_border);
draw_roundrect(x - ws_width/2,     y - ws_height/2,     x + ws_width/2,     y + ws_height/2,     true);
draw_roundrect(x - ws_width/2 + 1, y - ws_height/2 + 1, x + ws_width/2 - 1, y + ws_height/2 - 1, true);
draw_roundrect(x - ws_width/2 + 2, y - ws_height/2 + 2, x + ws_width/2 - 2, y + ws_height/2 - 2, true);

// Bold readable label centred — auto-scale down if it exceeds box width
draw_set_font(fnt_luckiest_guy_24);
draw_set_color(_txt);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var _label_str = string(label);
var _label_w = string_width(_label_str);
var _label_h = string_height(_label_str);
var _max_w = ws_width - 16;     // 8px padding each side
var _max_h = ws_height - 8;
var _scale = 1.0;
if (_label_w > _max_w) _scale = _max_w / _label_w;
if (_label_h * _scale > _max_h) _scale = _max_h / _label_h;
draw_text_transformed(x, y, _label_str, _scale, _scale, 0);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
