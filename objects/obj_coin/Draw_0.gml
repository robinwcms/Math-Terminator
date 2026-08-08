var _bob = sin(degtorad(bob_phase)) * 5;
var _dy = y + _bob;

// Shadow
draw_set_color(c_black);
draw_set_alpha(0.4);
draw_circle(x + 3, y + 30, 22, false);
draw_set_alpha(1.0);

var _col, _ring, _txt;
switch (coin_tier)
{
	case 1: _col = make_color_rgb(192, 192, 192); _ring = make_color_rgb(120, 120, 120); _txt = "S"; break;
	case 2: _col = make_color_rgb(255, 215, 0);   _ring = make_color_rgb(180, 140, 0);   _txt = "G"; break;
	case 3: _col = make_color_rgb(160, 230, 255); _ring = make_color_rgb(80, 180, 230);  _txt = "D"; break;
}

// Pulsing alpha if near expiry
var _a = (lifetime < 180) ? (0.4 + 0.6 * (sin(current_time / 80) * 0.5 + 0.5)) : 1.0;
draw_set_alpha(_a);
draw_set_color(_ring);
draw_circle(x, _dy, 28, false);
draw_set_color(_col);
draw_circle(x, _dy, 24, false);
draw_set_color(c_black);
draw_set_font(fnt_luckiest_guy_24);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x, _dy + 3, _txt);
draw_set_alpha(1.0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
