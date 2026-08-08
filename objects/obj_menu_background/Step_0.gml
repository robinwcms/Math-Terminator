// Pulse phases
pulse_phase += 1;
flash_phase += 2;

// ─── UPDATE FLOATING SYMBOLS ────────────────────────────────────────
for (var _i = 0; _i < array_length(symbols); _i++)
{
	var _s = symbols[_i];
	_s.x += _s.vx;
	_s.y += _s.vy;
	_s.rot += _s.rot_speed;
	// Wrap around screen edges
	if (_s.y < -50) {
		_s.y = room_height + 50;
		_s.x = random(room_width);
	}
	if (_s.x < -80) _s.x = room_width + 80;
	if (_s.x > room_width + 80) _s.x = -80;
}

// ─── UPDATE WANDERING ZOMBIES ───────────────────────────────────────
for (var _i = 0; _i < array_length(zombies); _i++)
{
	var _z = zombies[_i];
	_z.x += _z.vx;
	_z.y += _z.vy;
	_z.shamble_phase += 4;
	_z.turn_cooldown--;
	
	// Occasionally pick a new random direction
	if (_z.turn_cooldown <= 0)
	{
		var _new_ang = random(360);
		var _spd = random_range(0.4, 1.1);
		_z.vx = lengthdir_x(_spd, _new_ang);
		_z.vy = lengthdir_y(_spd, _new_ang);
		_z.facing = _new_ang;
		_z.turn_cooldown = irandom_range(180, 480);
	}
	
	// Wrap around screen edges
	if (_z.x < -120) _z.x = room_width + 120;
	else if (_z.x > room_width + 120) _z.x = -120;
	if (_z.y < -120) _z.y = room_height + 120;
	else if (_z.y > room_height + 120) _z.y = -120;
}

// ─── BULLET STREAKS ─────────────────────────────────────────────────
bullet_cooldown--;
if (bullet_cooldown <= 0)
{
	bullet_cooldown = irandom_range(60, 180);   // 1-3 sec between shots
	
	// Pick a random edge to spawn from (0=top, 1=right, 2=bottom, 3=left)
	var _spawn_edge = irandom(3);
	var _sx, _sy;
	switch (_spawn_edge)
	{
		case 0: _sx = random(room_width);  _sy = -40; break;
		case 1: _sx = room_width + 40;     _sy = random(room_height); break;
		case 2: _sx = random(room_width);  _sy = room_height + 40; break;
		case 3: _sx = -40;                 _sy = random(room_height); break;
	}
	
	// Pick a target point on a DIFFERENT edge so the bullet crosses the screen
	var _target_edge = (_spawn_edge + irandom_range(1, 3)) mod 4;
	var _tx, _ty;
	switch (_target_edge)
	{
		case 0: _tx = random(room_width);  _ty = -40; break;
		case 1: _tx = room_width + 40;     _ty = random(room_height); break;
		case 2: _tx = random(room_width);  _ty = room_height + 40; break;
		case 3: _tx = -40;                 _ty = random(room_height); break;
	}
	
	// Compute velocity vector from spawn to target with a random speed
	var _dir = point_direction(_sx, _sy, _tx, _ty);
	var _spd = random_range(18, 28);
	array_push(bullets, {
		x: _sx,
		y: _sy,
		vx: lengthdir_x(_spd, _dir),
		vy: lengthdir_y(_spd, _dir),
		life: 120,                  // longer so diagonal shots can cross
		angle: _dir                 // store for trail rendering
	});
}

for (var _i = array_length(bullets) - 1; _i >= 0; _i--)
{
	var _b = bullets[_i];
	_b.x += _b.vx;
	_b.y += _b.vy;
	_b.life--;
	
	// Check bullet-zombie collision for splatter effect
	var _bullet_hit = false;
	for (var _zi = 0; _zi < array_length(zombies); _zi++)
	{
		var _z2 = zombies[_zi];
		if (point_distance(_b.x, _b.y, _z2.x, _z2.y) < 40)
		{
			// Splatter! Add red particles bursting from the hit point
			for (var _pi = 0; _pi < 12; _pi++)
			{
				var _pang = random(360);
				var _pspd = random_range(2, 6);
				array_push(splatters, {
					x: _z2.x,
					y: _z2.y,
					vx: lengthdir_x(_pspd, _pang),
					vy: lengthdir_y(_pspd, _pang),
					life: irandom_range(30, 50),
					max_life: 50,
					size: random_range(2, 5),
					color: choose(make_color_rgb(180, 30, 30),
								   make_color_rgb(210, 50, 50),
								   make_color_rgb(140, 20, 20))
				});
			}
			// Spawn a score popup at the hit
			array_push(score_popups, {
				x: _z2.x,
				y: _z2.y - 40,
				vy: random_range(-1.2, -0.8),
				life: 60,
				max_life: 60,
				text: choose("+100", "+200", "+350", "x2!", "+50"),
				color: make_color_rgb(255, 215, 0)
			});
			// Kick the zombie back from the impact (visual reaction)
			var _knock = point_direction(_b.x, _b.y, _z2.x, _z2.y);
			_z2.vx = lengthdir_x(2.5, _knock);
			_z2.vy = lengthdir_y(2.5, _knock);
			_z2.facing = _knock;
			_z2.turn_cooldown = 90;
			_bullet_hit = true;
			break;
		}
	}
	
	if (_bullet_hit || _b.life <= 0
		|| _b.x < -100 || _b.x > room_width + 100
		|| _b.y < -100 || _b.y > room_height + 100) {
		array_delete(bullets, _i, 1);
	}
}

// ─── UPDATE SPLATTERS ───────────────────────────────────────────────
for (var _i = array_length(splatters) - 1; _i >= 0; _i--)
{
	var _sp = splatters[_i];
	_sp.x += _sp.vx;
	_sp.y += _sp.vy;
	_sp.vy += 0.25;             // gravity
	_sp.vx *= 0.96;             // air drag
	_sp.life--;
	if (_sp.life <= 0) array_delete(splatters, _i, 1);
}

// ─── UPDATE SCORE POPUPS ────────────────────────────────────────────
for (var _i = array_length(score_popups) - 1; _i >= 0; _i--)
{
	var _sp2 = score_popups[_i];
	_sp2.y += _sp2.vy;
	_sp2.vy *= 0.98;            // slow as they rise
	_sp2.life--;
	if (_sp2.life <= 0) array_delete(score_popups, _i, 1);
}

// Occasionally spawn an ambient "math" popup too — gives the menu a sense
// that the game is constantly running in the background
score_popup_cooldown--;
if (score_popup_cooldown <= 0)
{
	score_popup_cooldown = irandom_range(45, 120);
	array_push(score_popups, {
		x: random_range(room_width * 0.15, room_width * 0.85),
		y: random_range(room_height * 0.7, room_height * 0.85),
		vy: random_range(-1.2, -0.6),
		life: 80,
		max_life: 80,
		text: choose("+100", "+200", "x3!", "+50", "+350", "COMBO!"),
		color: choose(make_color_rgb(255, 215, 0),
					   make_color_rgb(120, 255, 120),
					   make_color_rgb(255, 120, 80))
	});
}

// ─── UPDATE LIGHT BEAMS ─────────────────────────────────────────────
for (var _i = 0; _i < array_length(beams); _i++)
{
	var _bm = beams[_i];
	_bm.x += _bm.speed;
	_bm.angle += 0.15;
	if (_bm.x > room_width + 300) _bm.x = -300;
}

// ─── TITLE BOB/GLOW ─────────────────────────────────────────────────
title_phase += 1.5;
