// ─── BOSS: GIANT MULTI-PHASE ZOMBIE ─────────────────────────────────
// Phase 1 (HP 12-9): slow, big punches, occasional summon
// Phase 2 (HP 8-5): faster, summons more often, can ground-slam
// Phase 3 (HP 4-1): enraged, very fast, rapid summons, screen shake on hit

target = noone;
body_radius = 140;        // 2.3x normal zombie
fist_radius = 60;

max_health = 12;
curr_health = max_health;
phase = 1;

is_flashed = false;
flash_time = 0.1;
flash_cooldown = flash_time;

// Movement
base_max_speed = 1.4;     // slower than regular zombies (they're huge)
max_speed = base_max_speed;
speed_dropoff = 0.1;

// Targeting
lock_target = function()
{
	target = instance_find(obj_player, 0);
}
lock_target();

// ─── FISTS (2 huge ones, like normal but bigger) ────────────────────
fist_left = {
	offset_x: 110,
	offset_y: -90,
	extend: 0,
	extend_speed: 0.06,
	cooldown: 0,
	is_punching: false,
	has_hit: false,
	x: x, y: y,
	radius: 60
};
fist_right = {
	offset_x: 110,
	offset_y: 90,
	extend: 0,
	extend_speed: 0.06,
	cooldown: 0,
	is_punching: false,
	has_hit: false,
	x: x, y: y,
	radius: 60
};

punch_range = 280;
punch_reach = 180;
punch_damage = 1;
punch_cooldown_frames = 100;

// ─── MATH PROBLEM SYSTEM ────────────────────────────────────────────
math_diff = 3;            // boss is always X-Hard
math_weakspots = [];
math_question = "";
math_answer = 0;
is_marked = false;
mark_pulse = 0;
mark_timer = 0;
wrong_lockout_timer = 0;
speed_boost_timer = 0;
hit_immune_timer = 0;

math_generate_problem = function()
{
	// Boss respects timed-mode op filter if applicable, else uses all 4 ops
	var _allowed = [];
	if (obj_game_manager.is_timed_mode)
	{
		if (global.ops_addition)       array_push(_allowed, 0);
		if (global.ops_subtraction)    array_push(_allowed, 1);
		if (global.ops_multiplication) array_push(_allowed, 2);
		if (global.ops_division)       array_push(_allowed, 3);
	}
	else
	{
		_allowed = [0, 1, 2, 3];
	}
	if (array_length(_allowed) == 0) _allowed = [0];
	var _op = _allowed[irandom(array_length(_allowed) - 1)];
	
	var _lo = 10, _hi = 99;
	var _a = irandom_range(_lo, _hi);
	var _b = irandom_range(_lo, _hi);
	var _q = ""; var _ans = 0;
	switch (_op)
	{
		case 0: _ans = _a + _b; _q = string(_a) + " + " + string(_b); break;
		case 1: if (_a < _b) { var _t=_a; _a=_b; _b=_t; } _ans = _a-_b; _q = string(_a) + " - " + string(_b); break;
		case 2: _a = irandom_range(5,15); _b = irandom_range(5,15); _ans = _a*_b; _q = string(_a) + " x " + string(_b); break;
		case 3: _b = irandom_range(2,12); _ans = irandom_range(2,15); _a = _ans*_b; _q = string(_a) + " / " + string(_b); break;
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
		var _range = 5 + floor(_attempts / 10);
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

	// 4 boss weakspots placed farther out — boss is huge
	var _ox = [0,    -210, 210,  0];
	var _oy = [-210,  0,   0,    210];

	var _labels = math_generate_distractors(math_answer);
	for (var _i = 0; _i < 4; _i++)
	{
		var _ws = instance_create_layer(x + _ox[_i], y + _oy[_i], "Enemies", obj_weakspot);
		_ws.owner = self;
		_ws.label = _labels[| _i];
		_ws.is_answer = (_labels[| _i] == math_answer);
		_ws.offset_x = _ox[_i];
		_ws.offset_y = _oy[_i];
		_ws.ws_width = 96;     // larger weakspots for the boss
		_ws.ws_height = 76;
		math_weakspots[_i] = _ws;
	}
	ds_list_destroy(_labels);
}

math_wrong_answer = function()
{
	with (obj_player) { player_score = max(0, player_score - 100); }
	with (obj_game_manager)
	{
		combo_count = 0;
		combo_timer = 0;
		screen_shake = min(screen_shake + 10, 20);
	}
	math_generate_problem();
	math_spawn_weakspots();
	wrong_lockout_timer = 180;
	speed_boost_timer = 120;
}

math_correct_answer = function()
{
	if (is_marked) exit;
	
	// Bigger points for boss hits — multiplied by remaining HP
	var _base = 500;
	with (obj_game_manager)
	{
		combo_count++;
		combo_timer = combo_max_window;
		if (combo_count > combo_best) combo_best = combo_count;
		screen_shake = min(screen_shake + 8, 20);
	}
	var _multiplier = 1 + (obj_game_manager.combo_count - 1) * 0.5;
	var _final_pts = round(_base * _multiplier);
	var _dbl = obj_game_manager.double_points_active ? 2 : 1;
	with (obj_player) { player_score += _final_pts * _dbl; }
	
	var _popup = instance_create_layer(x, y - 80, "Enemies", obj_score_popup);
	_popup.popup_text = "+" + string(_final_pts);
	_popup.popup_color = make_color_rgb(255, 100, 200);
	
	// Mark for bullet kill
	is_marked = true;
	mark_pulse = 0;
	
	for (var _i = 0; _i < array_length(math_weakspots); _i++)
	{
		if (instance_exists(math_weakspots[_i])) instance_destroy(math_weakspots[_i]);
	}
	math_weakspots = [];
}

math_finish_kill = function()
{
	curr_health--;
	
	// Floating damage number above the boss so each chip is visible
	var _dmg = instance_create_layer(x + random_range(-30, 30), y - 160, "Enemies", obj_score_popup);
	_dmg.popup_text = "-1";
	_dmg.popup_color = make_color_rgb(255, 90, 90);
	
	// Update phase based on remaining HP
	if (curr_health <= 4 && phase < 3) {
		phase = 3;
		// Rage activation: heal a bit of effects and summon minions immediately
		boss_summon_minions(4);
		with (obj_game_manager) screen_shake = 20;
	}
	else if (curr_health <= 8 && phase < 2) {
		phase = 2;
		boss_summon_minions(3);
		with (obj_game_manager) screen_shake = 16;
	}
	
	if (curr_health > 0)
	{
		// Boss survives — new problem, brief immunity
		is_marked = false;
		mark_pulse = 0;
		mark_timer = 0;
		hit_immune_timer = 20;
		math_generate_problem();
		math_spawn_weakspots();
		return;
	}
	
	// BOSS DEAD — drop multiple powerups + huge score + coins
	with (obj_game_manager)
	{
		run_boss_kills++;
		unlock_achievement("boss_slayer");
	}
	with (obj_player) { player_score += 5000; }
	for (var _i = 0; _i < 5; _i++)
	{
		var _types = ["health", "shield", "speed", "rapid", "freeze"];
		var _t = _types[irandom(array_length(_types) - 1)];
		var _ang = irandom(359);
		var _dist = irandom_range(80, 150);
		var _pu = instance_create_layer(
			x + lengthdir_x(_dist, _ang),
			y + lengthdir_y(_dist, _ang),
			"Enemies", obj_powerup);
		_pu.powerup_type = _t;
	}
	// Big coin payday: 8 diamonds
	for (var _i = 0; _i < 8; _i++)
	{
		var _ang = irandom(359);
		var _dist = irandom_range(60, 180);
		var _c = instance_create_layer(
			x + lengthdir_x(_dist, _ang),
			y + lengthdir_y(_dist, _ang),
			"Enemies", obj_coin);
		_c.coin_tier = 3;
		_c.coin_value = 100;
	}
	with (obj_game_manager) screen_shake = 25;
	instance_destroy();
}

// ─── MINION SUMMONING (caps + slower rates) ────────────────────────
boss_summon_minions = function(_count)
{
	// Phase summon cap: P1=5, P2=10, P3=20
	var _cap = 5;
	if (phase == 2) _cap = 10;
	if (phase == 3) _cap = 20;
	
	// Count this boss's living minions
	var _alive = 0;
	with (obj_enemy) { if (boss_minion) _alive++; }
	var _room = _cap - _alive;
	if (_room <= 0) return;
	_count = min(_count, _room);
	
	for (var _i = 0; _i < _count; _i++)
	{
		// Pick a random nearby spawn point
		var _ang = irandom(359);
		var _dist = irandom_range(180, 260);
		var _sx = x + lengthdir_x(_dist, _ang);
		var _sy = y + lengthdir_y(_dist, _ang);
		// Clamp inside arena
		var _arena_w = obj_game_manager.arena_grid_width * obj_game_manager.cell_width;
		var _arena_h = obj_game_manager.arena_grid_height * obj_game_manager.cell_height;
		_sx = clamp(_sx, 200, _arena_w - 200);
		_sy = clamp(_sy, 200, _arena_h - 200);
		
		var _minion = instance_create_layer(_sx, _sy, "Enemies", obj_enemy);
		_minion.max_health = 1;
		_minion.curr_health = 1;
		_minion.boss_minion = true;     // tag so we can count them
		// Phase-based speed boost for minions
		if (phase == 2) _minion.base_max_speed *= 1.15;
		if (phase == 3) _minion.base_max_speed *= 1.35;
		// Minions need an owner spawner — pick any
		with (obj_enemy_spawner) { _minion.owner = id; break; }
	}
}

summon_cooldown = 0;
summon_rate_p1 = 960;     // every 16 sec (was 8) - 50% reduction in rate
summon_rate_p2 = 600;     // every 10 sec (was 5)
summon_rate_p3 = 360;     // every 6 sec (was 3)

math_generate_problem();
math_spawn_weakspots();
