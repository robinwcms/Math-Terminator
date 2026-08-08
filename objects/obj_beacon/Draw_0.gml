var _life_frac = lifetime / max_lifetime;
var _pulse = 0.5 + 0.5 * sin(degtorad(pulse_phase));

// Outer aura (multiple concentric rings for soft falloff)
for (var _i = 0; _i < 6; _i++)
{
	var _r = beacon_radius - _i * 24;
	if (_r <= 0) break;
	draw_set_color(make_color_rgb(120, 255, 130));
	draw_set_alpha((0.06 + _pulse * 0.04) * _life_frac);
	draw_circle(x, y, _r, false);
}

// Outline ring
draw_set_color(make_color_rgb(160, 255, 180));
draw_set_alpha((0.6 + _pulse * 0.3) * _life_frac);
draw_circle(x, y, beacon_radius, true);
draw_circle(x, y, beacon_radius - 2, true);

// Center beacon
draw_set_color(make_color_rgb(180, 255, 200));
draw_set_alpha(_life_frac);
draw_circle(x, y, 18, false);
draw_set_color(make_color_rgb(60, 180, 80));
draw_circle(x, y, 18, true);

// Letter "B" inside
draw_set_font(fnt_luckiest_guy_24);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(20, 60, 30));
draw_text_transformed(x, y + 2, "B", 0.7, 0.7, 0);

// Lifetime countdown above
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(160, 255, 180));
draw_text_transformed(x, y - 32,
	string(round(lifetime / 60)) + "s", 0.55, 0.55, 0);

draw_set_alpha(1.0);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
