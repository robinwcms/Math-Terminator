// ─── DRAW SHADOW ───────────────────────────────────────────────────────
draw_set_color(c_black);
draw_set_alpha(0.35);
draw_circle(x + 6, y + 8, 60, false);
draw_set_alpha(1.0);

// ─── MARKED GLOW: pulsing green halo around marked zombies ───────────
if (is_marked)
{
	var _pulse = 0.4 + 0.4 * sin(degtorad(mark_pulse));
	for (var _g = 0; _g < 4; _g++)
	{
		draw_set_alpha(_pulse * (1 - _g * 0.22));
		draw_set_color(make_color_rgb(80, 255, 120));
		draw_circle(x, y, 70 + _g * 8, true);
	}
	draw_set_alpha(1.0);
}

// ─── WRONG-ANSWER LOCKOUT: pulsing red halo + countdown ─────────────
if (wrong_lockout_timer > 0)
{
	var _lpulse = 0.5 + 0.4 * sin(current_time / 80);
	for (var _g = 0; _g < 4; _g++)
	{
		draw_set_alpha(_lpulse * (1 - _g * 0.22));
		draw_set_color(make_color_rgb(255, 80, 80));
		draw_circle(x, y, 70 + _g * 8, true);
	}
	draw_set_alpha(1.0);
	
	// Countdown text in seconds
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(make_color_rgb(255, 80, 80));
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text(x, y + 80, "LOCKED " + string(ceil(wrong_lockout_timer / 60)) + "s");
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}

// ─── COMPUTE BODY/FIST COLOR (shared across body + both fists) ────
var _frozen_now = (instance_exists(obj_player) && obj_player.freeze_timer > 0);
var _body_col;
if (is_marked)         _body_col = make_color_rgb(160, 255, 180);  // green (kill cue)
else if (_frozen_now)  _body_col = make_color_rgb(170, 220, 255);
else if (is_flashed)   _body_col = c_white;
else if (is_exploder)  _body_col = make_color_rgb(225, 75, 60);    // bright red
else if (is_healer)    _body_col = make_color_rgb(120, 220, 140);  // mint green
else if (is_runner)    _body_col = make_color_rgb(255, 215, 80);   // bright yellow
else if (is_splitter)  _body_col = make_color_rgb(200, 110, 255);  // violet
else if (max_health >= 3) _body_col = make_color_rgb(200, 110, 90);
else if (max_health >= 2) _body_col = make_color_rgb(220, 150, 90);
else                   _body_col = make_color_rgb(245, 196, 120);  // tan

// ─── DRAW FISTS (drawn first so they sit "behind" the body when retracted) ──
var _facing = image_angle - 180;
var _fists = [fist_left, fist_right];
for (var _fi = 0; _fi < 2; _fi++)
{
	var _f = _fists[_fi];
	// Fist shadow
	draw_set_color(c_black);
	draw_set_alpha(0.3);
	draw_circle(_f.x + 4, _f.y + 6, 28, false);
	draw_set_alpha(1.0);
	// Fist outline
	draw_set_color(make_color_rgb(40, 40, 45));
	draw_circle(_f.x, _f.y, 30, false);
	// Fist body matches the zombie's body color
	draw_set_color(_body_col);
	draw_circle(_f.x, _f.y, 26, false);
	draw_set_color(c_white);
}

// ─── DRAW BODY ─────────────────────────────────────────────────────────
// Outline
draw_set_color(make_color_rgb(40, 40, 45));
draw_circle(x, y, 64, false);

// Exploder glow ring (pulsing red around the body)
if (is_exploder && !is_spawning)
{
	exploder_pulse += 0.12;
	var _glow_a = 0.35 + 0.25 * sin(exploder_pulse);
	draw_set_alpha(_glow_a);
	draw_set_color(make_color_rgb(255, 60, 30));
	draw_circle(x, y, 78, false);
	draw_set_alpha(1.0);
}

// Healer glow ring (pulsing green)
if (is_healer && !is_spawning)
{
	heal_pulse += 0.10;
	var _hg_a = 0.30 + 0.20 * sin(heal_pulse);
	draw_set_alpha(_hg_a);
	draw_set_color(make_color_rgb(60, 220, 100));
	draw_circle(x, y, 80, false);
	draw_set_alpha(1.0);
}

// Runner motion lines (small horizontal streaks behind the body)
if (is_runner && !is_spawning && !is_marked)
{
	draw_set_alpha(0.5);
	draw_set_color(make_color_rgb(255, 200, 80));
	for (var _li = 0; _li < 3; _li++)
	{
		var _llen = 30 + _li * 12;
		var _ld = direction + 180;
		var _lx = x + lengthdir_x(_llen, _ld);
		var _ly = y + lengthdir_y(_llen, _ld);
		draw_circle(_lx, _ly, 14 - _li * 3, false);
	}
	draw_set_alpha(1.0);
}

// Body — uses the shared _body_col computed above (also used for fists)
draw_set_color(_body_col);
draw_circle(x, y, 60, false);

draw_set_color(c_white);

// ─── DRAW MATH QUESTION (hide when marked) ─────────────────────────
if (obj_game_manager.curr_game_state == GAME_STATE.PLAYING && !is_marked)
{
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	
	var _qw = string_width(math_question) + 28;
	var _qh = string_height(math_question) + 10;
	// Moved down so the box overlaps the top of the zombie's body circle
	var _qy = y - 75;
	
	// Yellow rounded backdrop
	draw_set_color(make_color_rgb(255, 215, 0));
	draw_roundrect(x - _qw/2, _qy - _qh/2, x + _qw/2, _qy + _qh/2, false);
	// Black border
	draw_set_color(c_black);
	draw_roundrect(x - _qw/2, _qy - _qh/2, x + _qw/2, _qy + _qh/2, true);
	// Black text
	draw_set_color(c_black);
	draw_text(x, _qy, math_question);
	
	// HP pips above question (only if multi-hit zombie)
	if (max_health > 1)
	{
		var _pip_size = 8;
		var _pip_gap = 4;
		var _total_w = (_pip_size + _pip_gap) * max_health - _pip_gap;
		var _start_x = x - _total_w / 2;
		var _pip_y = _qy - _qh/2 - 10;
		for (var _i = 0; _i < max_health; _i++)
		{
			var _px = _start_x + _i * (_pip_size + _pip_gap);
			// Filled if HP remains, empty outline if lost
			if (_i < curr_health) draw_set_color(make_color_rgb(220, 50, 80));
			else                  draw_set_color(make_color_rgb(80, 30, 40));
			draw_rectangle(_px, _pip_y, _px + _pip_size, _pip_y + _pip_size, false);
			draw_set_color(c_black);
			draw_rectangle(_px, _pip_y, _px + _pip_size, _pip_y + _pip_size, true);
		}
	}
	
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
