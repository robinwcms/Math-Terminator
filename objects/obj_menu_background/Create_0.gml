// ─── DYNAMIC MENU BACKGROUND ────────────────────────────────────────
// Floating math symbols/numbers — three parallax layers for depth
symbols = [];
var _symbol_pool = ["+", "-", "x", "÷", "=", "?", "0","1","2","3","4","5","6","7","8","9"];
// Background layer (far) - small, very low alpha, slow drift
for (var _i = 0; _i < 16; _i++)
{
	array_push(symbols, {
		x: random(room_width),
		y: random(room_height),
		text: _symbol_pool[irandom(array_length(_symbol_pool) - 1)],
		vx: random_range(-0.1, 0.1),
		vy: random_range(-0.25, -0.05),
		scale: random_range(0.4, 0.8),
		alpha: random_range(0.04, 0.10),
		rot: random(360),
		rot_speed: random_range(-0.15, 0.15),
		depth_layer: 0,
		color: choose(make_color_rgb(255, 215, 0),
					   make_color_rgb(200, 80, 80),
					   make_color_rgb(180, 130, 200),
					   make_color_rgb(100, 200, 100))
	});
}
// Middle layer (medium speed)
for (var _i = 0; _i < 18; _i++)
{
	array_push(symbols, {
		x: random(room_width),
		y: random(room_height),
		text: _symbol_pool[irandom(array_length(_symbol_pool) - 1)],
		vx: random_range(-0.25, 0.25),
		vy: random_range(-0.55, -0.15),
		scale: random_range(0.8, 1.3),
		alpha: random_range(0.08, 0.16),
		rot: random(360),
		rot_speed: random_range(-0.3, 0.3),
		depth_layer: 1,
		color: choose(make_color_rgb(255, 215, 0),
					   make_color_rgb(200, 80, 80),
					   make_color_rgb(180, 130, 200),
					   make_color_rgb(100, 200, 100))
	});
}
// Front layer (large, slower drift, more visible)
for (var _i = 0; _i < 8; _i++)
{
	array_push(symbols, {
		x: random(room_width),
		y: random(room_height),
		text: _symbol_pool[irandom(array_length(_symbol_pool) - 1)],
		vx: random_range(-0.5, 0.5),
		vy: random_range(-0.9, -0.3),
		scale: random_range(1.4, 2.4),
		alpha: random_range(0.14, 0.24),
		rot: random(360),
		rot_speed: random_range(-0.6, 0.6),
		depth_layer: 2,
		color: choose(make_color_rgb(255, 215, 0),
					   make_color_rgb(200, 80, 80),
					   make_color_rgb(180, 130, 200),
					   make_color_rgb(100, 200, 100))
	});
}

// Wandering zombies across the menu - game-shaped, all directions
zombies = [];
for (var _i = 0; _i < 8; _i++)
{
	var _ang = random(360);
	var _spd = random_range(0.4, 1.1);
	array_push(zombies, {
		x: random(room_width),
		y: random(room_height),
		vx: lengthdir_x(_spd, _ang),
		vy: lengthdir_y(_spd, _ang),
		facing: _ang,
		shamble_phase: random(360),
		size: random_range(0.85, 1.3),
		tint: choose(
			make_color_rgb(140, 90, 110),
			make_color_rgb(120, 130, 100),
			make_color_rgb(150, 100, 80),
			make_color_rgb(110, 90, 130)
		),
		turn_cooldown: irandom_range(120, 360)
	});
}

// Floating bullets (gunshots streaking by)
bullets = [];
// Spawn a new bullet streak occasionally
bullet_cooldown = 0;

// Splatter particles (red bits when a bullet hits a zombie)
splatters = [];

// Score popups floating up — visual flavor like during gameplay
score_popups = [];
score_popup_cooldown = 0;

// Big "spotlight" beams that sweep across the screen
beams = [];
for (var _i = 0; _i < 3; _i++)
{
	array_push(beams, {
		x: random(room_width),
		y: -200,
		angle: random_range(70, 110),       // mostly vertical
		width: random_range(60, 140),
		length: random_range(800, 1400),
		alpha: random_range(0.04, 0.10),
		speed: random_range(0.6, 1.6),
		color: choose(make_color_rgb(255, 200, 80),
					   make_color_rgb(180, 80, 80),
					   make_color_rgb(120, 80, 200))
	});
}

// Pulsing red flash phase (zombie blood spatter feel)
flash_phase = 0;

// Global drift timer for the gradient pulse
pulse_phase = 0;

// Title bob/glow phase for the title sprite
title_phase = 0;
