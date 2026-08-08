// ─── BOSS DRAW ─────────────────────────────────────────────────────

// Massive shadow
draw_set_color(c_black);
draw_set_alpha(0.5);
draw_circle(x + 12, y + 18, body_radius, false);
draw_set_alpha(1.0);

// Marked glow (green)
if (is_marked)
{
	var _pulse = 0.4 + 0.4 * sin(degtorad(mark_pulse));
	for (var _g = 0; _g < 5; _g++)
	{
		draw_set_alpha(_pulse * (1 - _g * 0.18));
		draw_set_color(make_color_rgb(80, 255, 120));
		draw_circle(x, y, body_radius + 10 + _g * 10, true);
	}
	draw_set_alpha(1.0);
}

// Wrong-answer lockout (red)
if (wrong_lockout_timer > 0)
{
	var _lpulse = 0.5 + 0.4 * sin(current_time / 80);
	for (var _g = 0; _g < 5; _g++)
	{
		draw_set_alpha(_lpulse * (1 - _g * 0.18));
		draw_set_color(make_color_rgb(255, 80, 80));
		draw_circle(x, y, body_radius + 10 + _g * 10, true);
	}
	draw_set_alpha(1.0);
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(make_color_rgb(255, 80, 80));
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text(x, y + body_radius + 30, "LOCKED " + string(ceil(wrong_lockout_timer / 60)) + "s");
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// ─── FISTS (drawn first so body sits on top) ────────────────────────
var _fists = [fist_left, fist_right];
for (var _fi = 0; _fi < 2; _fi++)
{
	var _f = _fists[_fi];
	// Shadow
	draw_set_color(c_black);
	draw_set_alpha(0.4);
	draw_circle(_f.x + 8, _f.y + 12, 58, false);
	draw_set_alpha(1.0);
	// Outline
	draw_set_color(make_color_rgb(30, 30, 35));
	draw_circle(_f.x, _f.y, 62, false);
	// Body — phase-tinted
	var _fc;
	if (is_marked)        _fc = make_color_rgb(160, 255, 180);
	else if (is_flashed)  _fc = c_white;
	else if (phase == 3)  _fc = make_color_rgb(240, 90, 90);   // raging red
	else if (phase == 2)  _fc = make_color_rgb(240, 160, 90);  // angry orange
	else                  _fc = make_color_rgb(180, 130, 200); // calm purple
	draw_set_color(_fc);
	draw_circle(_f.x, _f.y, 56, false);
}

// ─── MAIN BODY ─────────────────────────────────────────────────────
// Outline
draw_set_color(make_color_rgb(30, 30, 35));
draw_circle(x, y, body_radius + 6, false);
// Body
var _bc;
if (is_marked)        _bc = make_color_rgb(160, 255, 180);
else if (is_flashed)  _bc = c_white;
else if (phase == 3)  _bc = make_color_rgb(240, 90, 90);
else if (phase == 2)  _bc = make_color_rgb(240, 160, 90);
else                  _bc = make_color_rgb(180, 130, 200);
draw_set_color(_bc);
draw_circle(x, y, body_radius, false);

// Phase pulse — bigger boss = more menacing
if (phase == 3)
{
	var _rage = 0.3 + 0.3 * sin(current_time / 100);
	draw_set_alpha(_rage);
	draw_set_color(c_red);
	draw_circle(x, y, body_radius - 10, true);
	draw_circle(x, y, body_radius - 15, true);
	draw_set_alpha(1.0);
}

// ─── HEALTH BAR (always visible above boss) ─────────────────────────
var _bar_w = 280;
var _bar_h = 20;
var _bar_x = x - _bar_w / 2;
var _bar_y = y - body_radius - 160;
// Background
draw_set_color(c_black);
draw_set_alpha(0.7);
draw_roundrect(_bar_x - 4, _bar_y - 4, _bar_x + _bar_w + 4, _bar_y + _bar_h + 4, false);
draw_set_alpha(1.0);
draw_set_color(make_color_rgb(50, 50, 60));
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);
// Fill — color based on phase
var _hp_frac = curr_health / max_health;
var _hp_col;
if (_hp_frac > 0.66)      _hp_col = make_color_rgb(100, 220, 100);
else if (_hp_frac > 0.33) _hp_col = make_color_rgb(240, 180, 60);
else                      _hp_col = make_color_rgb(240, 80, 80);
draw_set_color(_hp_col);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w * _hp_frac, _bar_y + _bar_h, false);
// Border
draw_set_color(c_white);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, true);

// BOSS label + HP text
draw_set_font(fnt_luckiest_guy_24);
draw_set_color(c_yellow);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_text(x, _bar_y - 8, "BOSS  -  PHASE " + string(phase));
draw_set_color(c_white);
draw_set_valign(fa_middle);
draw_text(x, _bar_y + _bar_h / 2, string(curr_health) + " / " + string(max_health));

// ─── MATH QUESTION ─────────────────────────────────────────────────
if (!is_marked)
{
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	
	var _qw = string_width(math_question) + 36;
	var _qh = string_height(math_question) + 14;
	// Place between the HP bar and the top weakspot (which is at y - 210)
	var _qy = y - body_radius - 100;
	
	draw_set_color(make_color_rgb(255, 215, 0));
	draw_roundrect(x - _qw/2, _qy - _qh/2, x + _qw/2, _qy + _qh/2, false);
	draw_set_color(c_black);
	draw_roundrect(x - _qw/2, _qy - _qh/2, x + _qw/2, _qy + _qh/2, true);
	draw_set_color(c_black);
	draw_text(x, _qy, math_question);
}

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
