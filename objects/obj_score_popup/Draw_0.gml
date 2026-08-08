var _alpha = lifetime / max_lifetime;
var _scale = 1.0 + (1.0 - _alpha) * 0.4;
draw_set_font(fnt_luckiest_guy_36_outline);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(_alpha);
// Black outline shadow
draw_set_color(c_black);
draw_text_transformed(x + 2, y + 2, popup_text, _scale, _scale, 0);
draw_set_color(popup_color);
draw_text_transformed(x, y, popup_text, _scale, _scale, 0);
draw_set_alpha(1.0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
