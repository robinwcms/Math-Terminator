var _life_frac = lifetime / max_lifetime;
var _pulse = 0.5 + 0.5 * sin(degtorad(pulse_phase));

// Base (chunky platform)
draw_set_color(c_black);
draw_set_alpha(0.4);
draw_circle(x + 5, y + 8, 32, false);
draw_set_alpha(1.0);

draw_set_color(make_color_rgb(60, 65, 75));
draw_circle(x, y, 30, false);
draw_set_color(make_color_rgb(130, 140, 155));
draw_circle(x, y, 26, false);

// Inner ring
draw_set_color(make_color_rgb(100, 120, 200));
draw_circle(x, y, 22, true);
draw_circle(x, y, 22, false);
draw_set_color(make_color_rgb(80, 90, 110));
draw_circle(x, y, 22, true);

// Gun barrel pointing at target
var _bx = x + lengthdir_x(40, gun_angle);
var _by = y + lengthdir_y(40, gun_angle);
draw_set_color(make_color_rgb(40, 45, 55));
draw_line_width(x, y, _bx, _by, 12);
draw_set_color(make_color_rgb(80, 90, 110));
draw_line_width(x, y, _bx, _by, 8);

// Muzzle dot (pulses when about to fire)
draw_set_color(fire_cooldown < 6 ? make_color_rgb(255, 220, 100) : make_color_rgb(140, 160, 200));
draw_circle(_bx, _by, 6, false);

// Lifetime arc
draw_set_color(make_color_rgb(180, 220, 255));
draw_set_alpha(_life_frac);
draw_circle(x, y, 36, true);
draw_set_alpha(1.0);

// Lifetime label above
draw_set_font(fnt_luckiest_guy_24);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(180, 220, 255));
draw_text_transformed(x, y - 44,
	string(round(lifetime / 60)) + "s", 0.55, 0.55, 0);

// Tracer line to target (faint)
if (instance_exists(target_id))
{
	draw_set_color(make_color_rgb(255, 220, 100));
	draw_set_alpha(0.18);
	draw_line_width(x, y, target_id.x, target_id.y, 2);
	draw_set_alpha(1.0);
}

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
