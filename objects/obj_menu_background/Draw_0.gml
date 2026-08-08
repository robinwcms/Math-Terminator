// ─── DYNAMIC MENU BACKGROUND ────────────────────────────────────────
var _w = room_width;
var _h = room_height;

// Solid base — slightly off-black so we can see if it's drawing at all
draw_set_color(make_color_rgb(20, 15, 30));
draw_rectangle(0, 0, _w, _h, false);

// ─── LIGHT BEAMS (drawn before content for depth feel) ──────────────
for (var _i = 0; _i < array_length(beams); _i++)
{
	var _bm = beams[_i];
	draw_set_color(_bm.color);
	// Draw the beam as a quadrilateral from a vanishing point at the top
	// using two parallel lines at slightly different widths for a glow effect
	for (var _k = 0; _k < 4; _k++)
	{
		var _kw = _bm.width * (1 - _k * 0.15);
		draw_set_alpha(_bm.alpha * (0.5 + 0.5 * (3 - _k) / 3));
		var _tip_dx = lengthdir_x(_bm.length, _bm.angle);
		var _tip_dy = lengthdir_y(_bm.length, _bm.angle);
		draw_line_width(_bm.x, _bm.y, _bm.x + _tip_dx, _bm.y + _tip_dy, _kw);
	}
	draw_set_alpha(1.0);
}

// Pulsing warm vignette at bottom
var _pulse = 0.5 + 0.2 * sin(degtorad(pulse_phase));
for (var _band = 0; _band < 6; _band++)
{
	var _by = _h - (_band * 60);
	draw_set_alpha(0.05 * _pulse * (1 - _band * 0.15));
	draw_set_color(make_color_rgb(140, 30, 30));
	draw_rectangle(0, _by - 80, _w, _by + 80, false);
}
draw_set_alpha(1.0);

// ─── ZOMBIES (game-style: body circle + outline + 2 fists) ─────────
for (var _i = 0; _i < array_length(zombies); _i++)
{
	var _z = zombies[_i];
	var _bob = sin(degtorad(_z.shamble_phase)) * 3;
	var _zx = _z.x;
	var _zy = _z.y + _bob;
	var _size = _z.size;
	var _body_r = 40 * _size;
	var _fist_r = 14 * _size;
	
	// Fist positions: forward-and-side relative to facing direction
	// Same offsets as in-game (scaled)
	var _facing = point_direction(0, 0, _z.vx, _z.vy);
	var _shamble = sin(degtorad(_z.shamble_phase * 1.5)) * 6 * _size;
	var _fwd_off = 38 * _size;
	var _side_off = 28 * _size;
	
	// Left fist
	var _lfx = _zx + lengthdir_x(_fwd_off + _shamble, _facing)
				   + lengthdir_x(_side_off, _facing + 90);
	var _lfy = _zy + lengthdir_y(_fwd_off + _shamble, _facing)
				   + lengthdir_y(_side_off, _facing + 90);
	// Right fist
	var _rfx = _zx + lengthdir_x(_fwd_off - _shamble, _facing)
				   + lengthdir_x(_side_off, _facing - 90);
	var _rfy = _zy + lengthdir_y(_fwd_off - _shamble, _facing)
				   + lengthdir_y(_side_off, _facing - 90);
	
	// Drop shadow under body
	draw_set_color(c_black);
	draw_set_alpha(0.4);
	draw_circle(_zx + 5, _zy + 12, _body_r * 0.95, false);
	draw_set_alpha(0.3);
	draw_circle(_lfx + 3, _lfy + 6, _fist_r * 0.9, false);
	draw_circle(_rfx + 3, _rfy + 6, _fist_r * 0.9, false);
	draw_set_alpha(1.0);
	
	// Fists (drawn first so body sits on top when fists are near body)
	draw_set_color(make_color_rgb(30, 30, 35));
	draw_circle(_lfx, _lfy, _fist_r + 3, false);
	draw_circle(_rfx, _rfy, _fist_r + 3, false);
	draw_set_color(_z.tint);
	draw_circle(_lfx, _lfy, _fist_r, false);
	draw_circle(_rfx, _rfy, _fist_r, false);
	
	// Body — dark outline + tinted fill
	draw_set_color(make_color_rgb(30, 30, 35));
	draw_circle(_zx, _zy, _body_r + 4, false);
	draw_set_color(_z.tint);
	draw_circle(_zx, _zy, _body_r, false);
}

// Floating math symbols
draw_set_font(fnt_luckiest_guy_48);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
for (var _i = 0; _i < array_length(symbols); _i++)
{
	var _s = symbols[_i];
	draw_set_color(_s.color);
	draw_set_alpha(_s.alpha);
	draw_text_transformed(_s.x, _s.y, _s.text, _s.scale, _s.scale, _s.rot);
}
draw_set_alpha(1.0);

// Bullet streaks — trail oriented along velocity so diagonal bullets look right
for (var _i = 0; _i < array_length(bullets); _i++)
{
	var _b = bullets[_i];
	// Trail extends opposite to the velocity vector
	var _tail_x_far  = _b.x - _b.vx * 2;
	var _tail_y_far  = _b.y - _b.vy * 2;
	var _tail_x_near = _b.x - _b.vx;
	var _tail_y_near = _b.y - _b.vy;
	draw_set_color(make_color_rgb(255, 220, 100));
	draw_set_alpha(0.4);
	draw_line_width(_tail_x_far, _tail_y_far, _b.x, _b.y, 3);
	draw_set_alpha(0.8);
	draw_line_width(_tail_x_near, _tail_y_near, _b.x, _b.y, 4);
	draw_set_color(c_white);
	draw_set_alpha(1.0);
	draw_circle(_b.x, _b.y, 3, false);
}
draw_set_alpha(1.0);

// ─── SPLATTER PARTICLES (from bullet-zombie hits) ──────────────────
for (var _i = 0; _i < array_length(splatters); _i++)
{
	var _sp = splatters[_i];
	var _life_frac = _sp.life / _sp.max_life;
	draw_set_color(_sp.color);
	draw_set_alpha(_life_frac);
	draw_circle(_sp.x, _sp.y, _sp.size, false);
}
draw_set_alpha(1.0);

// ─── SCORE POPUPS (floating "+100" text from kills) ────────────────
draw_set_font(fnt_luckiest_guy_24);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
for (var _i = 0; _i < array_length(score_popups); _i++)
{
	var _sp2 = score_popups[_i];
	var _life_frac = _sp2.life / _sp2.max_life;
	// Slight scale-up as life drains for emphasis
	var _scale = 0.8 + (1 - _life_frac) * 0.3;
	// Drop shadow
	draw_set_color(c_black);
	draw_set_alpha(0.5 * _life_frac);
	draw_text_transformed(_sp2.x + 2, _sp2.y + 2, _sp2.text, _scale, _scale, 0);
	// Main
	draw_set_color(_sp2.color);
	draw_set_alpha(_life_frac);
	draw_text_transformed(_sp2.x, _sp2.y, _sp2.text, _scale, _scale, 0);
}
draw_set_alpha(1.0);

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
