// Wireframe player look — semi-transparent blue circle pulsing
var _life_frac = lifetime / max_lifetime;
var _pulse = 1 + 0.1 * sin(degtorad(pulse_phase));
var _r = 40 * _pulse;

// Glow ring
draw_set_color(make_color_rgb(80, 180, 255));
draw_set_alpha(0.25 * _life_frac);
draw_circle(x, y, _r + 14, false);
draw_set_alpha(0.5 * _life_frac);
draw_circle(x, y, _r + 4, false);

// Body (wireframe)
draw_set_alpha(_life_frac);
draw_set_color(make_color_rgb(120, 200, 255));
draw_circle(x, y, _r, true);
draw_circle(x, y, _r - 1, true);
draw_circle(x, y, _r - 2, true);

// Crosshair inside to denote "fake player"
draw_set_color(c_white);
draw_set_alpha(0.7 * _life_frac);
draw_line_width(x - _r * 0.5, y, x + _r * 0.5, y, 2);
draw_line_width(x, y - _r * 0.5, x, y + _r * 0.5, 2);

// Lifetime countdown above
draw_set_font(fnt_luckiest_guy_24);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(180, 220, 255));
draw_set_alpha(_life_frac);
draw_text_transformed(x, y - _r - 16,
	string(round(lifetime / 60)) + "s", 0.6, 0.6, 0);

draw_set_alpha(1.0);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
