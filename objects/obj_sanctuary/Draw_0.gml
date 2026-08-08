var _life_frac = lifetime / max_lifetime;
var _pulse = 0.5 + 0.5 * sin(degtorad(pulse_phase));

// Inner safe zone (soft blue fill)
for (var _i = 0; _i < 6; _i++)
{
	var _r = sanctuary_radius - _i * 24;
	if (_r <= 0) break;
	draw_set_color(make_color_rgb(110, 180, 255));
	draw_set_alpha((0.04 + _pulse * 0.03) * _life_frac);
	draw_circle(x, y, _r, false);
}

// Outline ring (the "wall")
draw_set_color(make_color_rgb(180, 220, 255));
draw_set_alpha((0.7 + _pulse * 0.3) * _life_frac);
draw_circle(x, y, sanctuary_radius, true);
draw_circle(x, y, sanctuary_radius - 1, true);
draw_circle(x, y, sanctuary_radius - 2, true);

// Center marker
draw_set_color(make_color_rgb(220, 240, 255));
draw_set_alpha(_life_frac);
draw_circle(x, y, 18, false);
draw_set_color(make_color_rgb(60, 100, 180));
draw_circle(x, y, 18, true);

// Letter "S"
draw_set_font(fnt_luckiest_guy_24);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(20, 40, 80));
draw_text_transformed(x, y + 2, "S", 0.7, 0.7, 0);

// Lifetime above
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(180, 220, 255));
draw_text_transformed(x, y - 32,
	string(round(lifetime / 60)) + "s", 0.55, 0.55, 0);

draw_set_alpha(1.0);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
