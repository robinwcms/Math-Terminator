// Floating bob effect
var _bob = sin(degtorad(bob_phase)) * 8;
var _dy = y + _bob;

// Drop shadow
draw_set_color(c_black);
draw_set_alpha(0.4);
draw_circle(x + 4, y + 50, 30, false);
draw_set_alpha(1.0);

// Pick colours/letter based on powerup type
var _col, _border, _letter;
switch (powerup_type)
{
	case "health":  _col = make_color_rgb(220, 50, 80);   _border = c_white; _letter = "+"; break;
	case "shield":  _col = make_color_rgb(80, 180, 220);  _border = c_white; _letter = "S"; break;
	case "speed":   _col = make_color_rgb(255, 200, 0);   _border = c_black; _letter = ">"; break;
	case "rapid":   _col = make_color_rgb(255, 100, 0);   _border = c_white; _letter = "R"; break;
	case "freeze":  _col = make_color_rgb(140, 220, 255); _border = c_white; _letter = "F"; break;
	case "ammo":    _col = make_color_rgb(150, 150, 160); _border = c_black; _letter = "A"; break;
	default:        _col = c_white; _border = c_black; _letter = "?"; break;
}

// Outer ring (pulses if about to disappear)
var _ring_alpha = (lifetime < 180) ? (0.3 + 0.7 * (sin(current_time / 80) * 0.5 + 0.5)) : 1.0;
draw_set_alpha(_ring_alpha);
draw_set_color(_border);
draw_circle(x, _dy, 36, false);
draw_set_color(_col);
draw_circle(x, _dy, 30, false);
draw_set_alpha(1.0);

// Letter
draw_set_font(fnt_luckiest_guy_36_outline);
draw_set_color(_border);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x, _dy + 5, _letter);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
