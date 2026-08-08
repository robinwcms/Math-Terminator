// ─── BASIC IDENTITY ────────────────────────────────────────────────
owner = noone;
target = noone;

// ─── MAX HEALTH ──────────────────────────────────────────────────────
// Default to 1 — spawner will overwrite with HP from pending_hp_queue
max_health = 1;
curr_health = max_health;

is_spawning = true;
is_colliding = false;
// True safety net for stuck-in-spawner cases (e.g. multiple zombies queued
// in a tight cell). After 5 seconds of being unable to clear the spawn
// rectangle, force the zombie out. The random spawn offset in the spawner
// should prevent this from firing in normal gameplay; this is the
// last-resort fallback for pathological overlap cases.
spawn_stuck_timer = 300;
// Flag: was this zombie marked by a beacon? If yes, the 4-second auto-kill
// safety timeout is skipped — beacons mark indefinitely; the player must
// actually shoot the zombie to kill it.
marked_by_beacon = false;
// Beacon hint timer. Each frame a beacon's Step finds this zombie inside
// its radius, the timer is refreshed to 3 frames. The enemy Step ticks
// the timer down, so once no beacon is refreshing it, it expires within
// 3 frames and the highlight goes away. This handles multiple beacons
// gracefully (any beacon can refresh) and zombies leaving the radius
// cleanly (no beacon refreshes → expires fast).
beacon_hint_timer = 0;
is_flashed = false;
hit_immune_timer = 0;     // brief bullet immunity after surviving a hit
boss_minion = false;      // true if spawned by boss

// ─── ZOMBIE TYPES ─────────────────────────────────────────────────
// Type is set by the spawner via pending queue (so spawner controls mix).
// "normal" - regular multi-HP zombie (uses max_health for variation)
// "runner" - 1 HP but 50% faster than player base speed
// "healer" - slow, no attack, heals other multi-HP zombies nearby
// "splitter" - 1 HP, splits into 2 normal zombies when killed
// "exploder" - 1 HP, detonates AOE damage on death
zombie_type = "normal";

// ─── EXPLODER VARIANT (set by spawner via type now) ────────────────
is_exploder = false;
exploder_pulse = 0;       // animation phase
exploder_radius = 220;    // damage radius (world px)
exploder_damage = 1;      // HP of damage dealt

// ─── RUNNER VARIANT ────────────────────────────────────────────────
is_runner = false;
// Player base is 2.8, so 2x player speed = 5.6
runner_speed = 5.6;

// ─── HEALER VARIANT ────────────────────────────────────────────────
is_healer = false;
heal_cooldown = 0;        // ticks; heals when reaches 0
heal_pulse = 0;           // pulse animation phase
heal_radius = 240;        // radius within which it heals
heal_interval = 240;      // 4 sec at 60 fps

// ─── SPLITTER VARIANT ──────────────────────────────────────────────
is_splitter = false;

wall_buffer = 280;
repulse_buffer = 300;
repulse_rate = 0.9;

// ─── MOVEMENT / PATH ────────────────────────────────────────────────
path = path_add();
next_node_x = x;
next_node_y = y;
node_threshold = ((obj_game_manager.cell_width + obj_game_manager.cell_height) / 2) / 3;

rotation_speed = 0.1;
// Variable speed per zombie - 60% to 130% of base speed
base_max_speed = 2.75 * random_range(0.6, 1.3);  // 10% faster than original 2.5

// Daily challenge "Double Speed" modifier (modifier == 1)
if (variable_global_exists("is_daily_challenge")
	&& global.is_daily_challenge
	&& global.daily_modifier == 1)
{
	base_max_speed *= 2.0;
}

max_speed = base_max_speed;
speed_dropoff = 0.1;
speed_rate = 0.05;

// ─── REMOVED FIRING (zombies are melee only now) ────────────────────
fire_rate = 999;
fire_cooldown = 999;
fire_max_distance = 0;
danger_close_distance = 200;
can_danger_close = false;

flash_time = 0.1;
flash_cooldown = flash_time;
image_angle = direction + 180;
last_speed = speed;

// ─── PUNCH SYSTEM: 2 fists ──────────────────────────────────────────
// Each fist has a base offset (idle position) and an extension factor 0..1
// When extension_factor = 0 the fist is at the idle (orbit) position.
// When extension_factor = 1 the fist is fully extended toward the player.
// Right fist offset is positive x, left fist offset is negative x (relative to facing)
fist_left = {
	offset_x: 55,    // forward (in facing direction)
	offset_y: -45,   // perpendicular offset — left side
	extend: 0,        // 0..1
	extend_speed: 0.08,    // slower so the animation reads clearly
	cooldown: 0,
	is_punching: false,
	has_hit: false,         // resets at start of each punch
	x: x, y: y,
	radius: 28
};
fist_right = {
	offset_x: 55,    // forward (in facing direction)
	offset_y: 45,    // perpendicular offset — right side
	extend: 0,
	extend_speed: 0.08,
	cooldown: 0,
	is_punching: false,
	has_hit: false,
	x: x, y: y,
	radius: 28
};

// Distance at which zombie tries to punch the player
punch_range = 160;
// How far past idle position the fist extends when punching
punch_reach = 96;
// Damage dealt by a punch hit (before powerups/shield)
punch_damage = 1;
// Cooldown frames between punches per fist
punch_cooldown_frames = 75;

body_radius = 60;

// Particle smoke handlers
var _new_dust_1 = instance_create_depth(x, y, depth - 1, obj_particle_handler);
_new_dust_1.owner = self;
_new_dust_1.set_dust_smoke(1);
var _new_dust_2 = instance_create_depth(x, y, depth - 1, obj_particle_handler);
_new_dust_2.owner = self;
_new_dust_2.set_dust_smoke(3);

// Spawn off-screen indicator arrow pointing to this enemy
var _ind = instance_create_layer(0, 0, "Popups", obj_enemy_indicator);
_ind.target = self;

// ─── PATH FUNCTION ──────────────────────────────────────────────────
find_path = function()
{
	// Guard against missing target - skip pathfinding this frame
	if (!instance_exists(target)) return;
	
	var _path = path_add();
	if (mp_grid_path(obj_game_manager.grid, _path, x, y, target.x, target.y, true))
	{
		path_delete(path);
		path = _path;
		if (path_get_number(path) > 1)
		{
			next_node_x = path_get_point_x(path, 1);
			next_node_y = path_get_point_y(path, 1);
		}
	}
	else
	{
		path_delete(_path);
	}
}

lock_target = function()
{
	var _nearest_dist = infinity;
	var _nearest = noone;
	with (obj_player)
	{
		var _d = point_distance(x, y, other.x, other.y);
		if (_d < _nearest_dist)
		{
			_nearest_dist = _d;
			_nearest = self;
		}
	}
	target = _nearest;
	if (instance_exists(target)) find_path();
}

// Stub kept to avoid breaking references — zombies don't fire projectiles
create_projectile_enemy = function() {}

// ─── MATH TERMINATOR: Difficulty + problem state ────────────────────
// math_diff range is now 0..5: 0=easy add/sub, 1=med, 2=mult/div, 3=hard,
// 4=algebra/exponents, 5=square roots/mixed
// Base difficulty from wave, then adjusted by adaptive system below.
math_diff = clamp(floor((obj_game_manager.curr_wave - 1) / 3), 0, 5);

// Adaptive difficulty: nudge math_diff up or down based on player's recent
// accuracy. >90% accuracy with 10+ answers → +1 diff. <60% → -1 diff.
if (instance_exists(obj_game_manager))
{
	var _gm = obj_game_manager;
	var _total = _gm.run_correct_answers + _gm.run_wrong_answers;
	if (_total >= 10)
	{
		var _acc = _gm.run_correct_answers / _total;
		if (_acc >= 0.90) math_diff = min(math_diff + 1, 5);
		else if (_acc < 0.60) math_diff = max(math_diff - 1, 0);
	}
}

// Daily challenge "Algebra Only" modifier (modifier == 2): force diff to 4
// so every problem is algebra.
if (variable_global_exists("is_daily_challenge")
	&& global.is_daily_challenge
	&& global.daily_modifier == 2)
{
	math_diff = 4;
}

math_weakspots = [];
math_question = "";
math_answer = 0;

// ─── MARKED state: set when player answers correctly ────────────────
is_marked = false;       // when true, zombie is frozen and glowing, awaits bullet
mark_pulse = 0;          // pulse phase for visual glow
mark_timer = 0;          // counts up while marked; auto-kill if too long
wrong_lockout_timer = 0; // counts down — clicks disabled while > 0
speed_boost_timer = 0;   // counts down — zombie has temp speed boost while > 0

math_generate_problem = function()
{
	var _op;
	// In timed mode, respect the operation filters chosen in the menu
	if (obj_game_manager.is_timed_mode)
	{
		var _allowed = [];
		if (global.ops_addition)       array_push(_allowed, 0);
		if (global.ops_subtraction)    array_push(_allowed, 1);
		if (global.ops_multiplication) array_push(_allowed, 2);
		if (global.ops_division)       array_push(_allowed, 3);
		if (array_length(_allowed) == 0) array_push(_allowed, 0);
		_op = _allowed[irandom(array_length(_allowed) - 1)];
	}
	else
	{
		// Operation pool grows with difficulty.
		// diff 0-1: + - only
		// diff 2-3: + - x /
		// diff 4: + - x / algebra exponents
		// diff 5: full mix including square roots
		var _max_op;
		if (math_diff <= 1)      _max_op = 1;       // 0..1 = +/-
		else if (math_diff <= 3) _max_op = 3;       // 0..3 = +/-/x/÷
		else if (math_diff == 4) _max_op = 5;       // adds 4=algebra, 5=exponent
		else                     _max_op = 6;       // adds 6=square root
		_op = irandom(_max_op);
		
		// Daily challenge "Algebra Only" — force operation 4
		if (variable_global_exists("is_daily_challenge")
			&& global.is_daily_challenge
			&& global.daily_modifier == 2)
		{
			_op = 4;
		}
	}
	var _lo, _hi;
	switch (math_diff)
	{
		case 0: _lo = 1;  _hi = 10; break;
		case 1: _lo = 2;  _hi = 20; break;
		case 2: _lo = 5;  _hi = 50; break;
		case 3: _lo = 10; _hi = 99; break;
		case 4: _lo = 5;  _hi = 50; break;
		case 5: _lo = 10; _hi = 99; break;
	}
	var _a = irandom_range(_lo, _hi);
	var _b = irandom_range(_lo, _hi);
	var _q = ""; var _ans = 0;
	switch (_op)
	{
		case 0: _ans = _a + _b; _q = string(_a) + " + " + string(_b); break;
		case 1: if (_a < _b) { var _t=_a; _a=_b; _b=_t; } _ans = _a-_b; _q = string(_a) + " - " + string(_b); break;
		case 2: _a = irandom_range(2,12); _b = irandom_range(2,12); _ans = _a*_b; _q = string(_a) + " x " + string(_b); break;
		case 3: _b = irandom_range(2,10); _ans = irandom_range(1,12); _a = _ans*_b; _q = string(_a) + " / " + string(_b); break;
		case 4:
			// Simple algebra: solve for x in "ax + b = c", show as concise form
			// Keep numbers small so the box fits the text.
			var _x = irandom_range(2, 12);
			var _coef = irandom_range(2, 8);
			var _const = irandom_range(1, 20);
			var _result = _coef * _x + _const;
			_ans = _x;
			_q = string(_coef) + "x+" + string(_const) + "=" + string(_result);
			break;
		case 5:
			// Exponents: small base, small exponent, so answer fits
			var _base_e = irandom_range(2, 9);
			var _exp_e = irandom_range(2, 3);
			_ans = power(_base_e, _exp_e);
			_q = string(_base_e) + "^" + string(_exp_e);
			break;
		case 6:
			// Square root: pick a perfect square, ask for its root
			var _root = irandom_range(2, 12);
			_ans = _root;
			_q = "sqrt(" + string(_root * _root) + ")";
			break;
	}
	math_question = _q;
	math_answer = _ans;
}

math_generate_distractors = function(_correct)
{
	var _result = ds_list_create();
	ds_list_add(_result, _correct);
	var _attempts = 0;
	while (ds_list_size(_result) < 4 && _attempts < 200)
	{
		_attempts++;
		// Widen offset range as attempts grow, so we always find unique candidates
		var _range = (math_diff + 2) + floor(_attempts / 10);
		var _off = irandom_range(1, _range);
		if (irandom(1) == 0) _off = -_off;
		var _c = max(0, _correct + _off);
		var _dup = false;
		for (var _i = 0; _i < ds_list_size(_result); _i++)
		{
			if (_result[| _i] == _c) { _dup = true; break; }
		}
		if (!_dup) ds_list_add(_result, _c);
	}
	// Safety net: if somehow we still have <4, pad with fallback values
	var _fallback = _correct + 100;
	while (ds_list_size(_result) < 4)
	{
		ds_list_add(_result, _fallback);
		_fallback++;
	}
	for (var _i = ds_list_size(_result) - 1; _i > 0; _i--)
	{
		var _j = irandom(_i);
		var _tmp = _result[| _i];
		_result[| _i] = _result[| _j];
		_result[| _j] = _tmp;
	}
	return _result;
}

math_spawn_weakspots = function()
{
	for (var _i = 0; _i < array_length(math_weakspots); _i++)
	{
		if (instance_exists(math_weakspots[_i])) instance_destroy(math_weakspots[_i]);
	}
	math_weakspots = [];

	// 4 evenly placed: top, left, right, bottom
	var _ox = [0,    -135, 135,  0];
	var _oy = [-135,  0,   0,    135];

	var _labels = math_generate_distractors(math_answer);
	for (var _i = 0; _i < 4; _i++)
	{
		var _ws = instance_create_layer(x + _ox[_i], y + _oy[_i], "Enemies", obj_weakspot);
		_ws.owner = self;
		_ws.label = _labels[| _i];
		_ws.is_answer = (_labels[| _i] == math_answer);
		_ws.offset_x = _ox[_i];
		_ws.offset_y = _oy[_i];
		math_weakspots[_i] = _ws;
	}
	ds_list_destroy(_labels);
}

math_wrong_answer = function()
{
	with (obj_player) { player_score = max(0, player_score - 50); }
	with (obj_game_manager)
	{
		combo_count = 0;
		combo_timer = 0;
		screen_shake = min(screen_shake + 6, 16);
		run_wrong_answers++;
		// Wave no longer perfect
		run_wave_perfect = false;
	}
	math_diff = min(math_diff + 1, 5);
	math_generate_problem();
	math_spawn_weakspots();
	
	// Lock the zombie's weakspots for 3 seconds
	wrong_lockout_timer = 180;
	
	// Temporary speed boost — fast but capped below player speed.
	// Player base speed is ~2.8 (3.92 with speed boost). We boost to 2.5 max.
	speed_boost_timer = 180;     // boost lasts same duration as lockout
}

math_correct_answer = function()
{
	// Track correct answer stat (each click counts)
	with (obj_game_manager)
	{
		run_correct_answers++;
		if (run_correct_answers >= 100) unlock_achievement("math_marathon");
	}
	
	// Already marked? Don't double-process
	if (variable_instance_exists(self, "is_marked") && is_marked) exit;
	
	// ─── BRANCH: chipping HP vs killing blow ─────────────────────────
	if (curr_health > 1)
	{
		// Not the killing blow — no points, no combo bump, just chip HP and continue
		curr_health--;
		// Floating damage number above the zombie so the chip is visible
		var _dmg = instance_create_layer(x + random_range(-12, 12), y - 70, "Enemies", obj_score_popup);
		_dmg.popup_text = "-1";
		_dmg.popup_color = make_color_rgb(255, 90, 90);
		math_generate_problem();
		math_spawn_weakspots();
		return;
	}
	
	// ─── Killing blow: award points + combo (with bonus for multi-HP kills) ─
	var _pts = [100, 200, 350, 600, 900, 1200];
	var _base = _pts[math_diff];
	// Bonus multiplier: 1x for 1-HP zombies, 2x for 2-HP, 3x for 3-HP, etc.
	var _hp_bonus = max_health;
	with (obj_game_manager)
	{
		combo_count++;
		combo_timer = combo_max_window;
		if (combo_count > combo_best) combo_best = combo_count;
		if (combo_count > run_max_combo) run_max_combo = combo_count;
		if (combo_count >= 5) unlock_achievement("combo_king");
		screen_shake = min(screen_shake + 4, 16);
	}
	var _multiplier = 1 + (obj_game_manager.combo_count - 1) * 0.5;
	var _final_pts = round(_base * _multiplier * _hp_bonus);
	var _dbl = obj_game_manager.double_points_active ? 2 : 1;
	with (obj_player) { player_score += _final_pts * _dbl; }
	
	// Score popup
	var _popup = instance_create_layer(x, y - 40, "Enemies", obj_score_popup);
	_popup.popup_text = "+" + string(_final_pts);
	if (max_health > 1) {
		// Bigger, brighter popup for multi-HP kills
		_popup.popup_color = make_color_rgb(255, 100, 200);
		_popup.popup_text = "+" + string(_final_pts) + " x" + string(_hp_bonus) + "!";
	} else if (obj_game_manager.combo_count >= 5) {
		_popup.popup_color = make_color_rgb(255, 80, 80);
		_popup.popup_text = "+" + string(_final_pts) + " !!";
	} else if (obj_game_manager.combo_count >= 2) {
		_popup.popup_color = make_color_rgb(255, 200, 0);
	} else {
		_popup.popup_color = make_color_rgb(120, 255, 120);
	}
	
	// Mark zombie so bullet can finish the kill
	is_marked = true;
	mark_pulse = 0;
	
	// Remove all 4 weakspots since this is the kill answer
	for (var _i = 0; _i < array_length(math_weakspots); _i++)
	{
		if (instance_exists(math_weakspots[_i])) instance_destroy(math_weakspots[_i]);
	}
	math_weakspots = [];
}

// Function called by the bullet when it contacts a marked zombie — kills it.
math_finish_kill = function()
{
	// Play the kill sound — short impact for satisfying feedback
	audio_play_sound(snd_enemy_hit, 100, false, 0.01, 0, 1.0);
	// Track kill stat
	with (obj_game_manager)
	{
		run_zombies_killed++;
		unlock_achievement("first_blood");
		if (run_zombies_killed >= 25) unlock_achievement("sharp_shoot");
	}
	
	// ─── EXPLODER: detonate AOE damage ──────────────────────────────
	if (is_exploder)
	{
		// Create a visible explosion ring
		var _boom = instance_create_layer(x, y, "Enemies", obj_score_popup);
		_boom.popup_text = "BOOM!";
		_boom.popup_color = make_color_rgb(255, 100, 30);
		// Big screen shake
		with (obj_game_manager) screen_shake = min(screen_shake + 14, 24);
		// Damage the player if within radius (respect shield + i-frames)
		if (instance_exists(obj_player))
		{
			var _d = point_distance(x, y, obj_player.x, obj_player.y);
			if (_d < exploder_radius
				&& obj_player.damage_cooldown <= 0
				&& obj_player.shield_timer <= 0)
			{
				obj_player.player_health -= exploder_damage;
				obj_player.damage_cooldown = 35;
				obj_player.is_flashed = true;
				obj_player.flash_cooldown = obj_player.flash_time;
				obj_player.hud_health_alpha = 1.0;
				// Only flash the vignette if the player survived this blast
				if (obj_player.player_health > 0)
				{
					obj_game_manager.damage_vignette_timer = obj_game_manager.damage_vignette_max;
					audio_play_sound(snd_player_hit, 100, false, 0.01, 0, 1.0);
				}
				obj_game_manager.run_damage_taken_wave++;
			}
			// Also damage other zombies in the radius (chain explosions)
			with (obj_enemy)
			{
				if (id != other.id && point_distance(x, y, other.x, other.y) < other.exploder_radius)
				{
					curr_health = max(0, curr_health - 1);
					if (curr_health <= 0)
					{
						// Trigger chain — just mark dead, the cascading kills
						// are handled by normal destroy
						instance_destroy();
					}
				}
			}
		}
	}
	
	// ─── SPLITTER: spawn 2 smaller normal zombies on death ───────────
	if (is_splitter)
	{
		var _boom = instance_create_layer(x, y, "Enemies", obj_score_popup);
		_boom.popup_text = "SPLIT!";
		_boom.popup_color = make_color_rgb(180, 80, 255);
		// Spawn 2 normal 1-HP zombies offset slightly from this position
		for (var _si = 0; _si < 2; _si++)
		{
			var _ang = irandom(359);
			var _dist = 40;
			var _sx = x + lengthdir_x(_dist, _ang);
			var _sy = y + lengthdir_y(_dist, _ang);
			var _spawn = instance_create_layer(_sx, _sy, "Enemies", obj_enemy);
			_spawn.owner = owner;
			_spawn.max_health = 1;
			_spawn.curr_health = 1;
			_spawn.zombie_type = "normal";
			_spawn.is_spawning = false;     // skip the spawner-rectangle wait
			_spawn.image_xscale = 0.7;      // smaller children
			_spawn.image_yscale = 0.7;
			// Generate a math problem and lock onto the player
			_spawn.math_generate_problem();
			_spawn.math_spawn_weakspots();
			_spawn.lock_target();
		}
	}
	
	// Powerup drop chance: base + combo bonus + HP bonus
	// 1-HP zombies: 20% base, 2-HP: +15%, 3-HP: +30%, etc.
	// Daily challenge "No Powerups" modifier blocks ALL drops.
	var _no_powerups = (variable_global_exists("is_daily_challenge")
		&& global.is_daily_challenge
		&& global.daily_modifier == 0);
	var _hp_bonus = (max_health - 1) * 0.15;
	var _drop_chance = _no_powerups ? 0 : min(0.20 + obj_game_manager.combo_count * 0.05 + _hp_bonus, 0.85);
	if (random(1) < _drop_chance)
	{
		var _types = ["health", "shield", "speed", "rapid", "freeze"];
		var _t = _types[irandom(array_length(_types) - 1)];
		var _pu = instance_create_layer(x, y, "Enemies", obj_powerup);
		_pu.powerup_type = _t;
	}
	
	// ─── Drop a coin based on max HP ────────────────────────────────
	// 1-HP = silver (50), 2-HP = gold (75), 3-HP+ = diamond (100)
	var _coin = instance_create_layer(x, y, "Enemies", obj_coin);
	if (max_health <= 1)      { _coin.coin_tier = 1; _coin.coin_value = 50; }
	else if (max_health == 2) { _coin.coin_tier = 2; _coin.coin_value = 75; }
	else                       { _coin.coin_tier = 3; _coin.coin_value = 100; }
	
	curr_health = 0;
	instance_destroy();
}

math_generate_problem();
math_spawn_weakspots();
