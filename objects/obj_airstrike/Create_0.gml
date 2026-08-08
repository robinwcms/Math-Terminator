// ─── AIRSTRIKE: Math gate + target selection ───────────────────────
// Pause game while this exists
prev_state = obj_game_manager.curr_game_state;
obj_game_manager.curr_game_state = GAME_STATE.PAUSED;

// Hard-freeze the player so any leftover momentum stops
if (instance_exists(obj_player))
{
	obj_player.hspeed = 0;
	obj_player.vspeed = 0;
	obj_player.speed = 0;
}
// Also stop boss momentum
with (obj_boss) {
	speed = 0;
	hspeed = 0;
	vspeed = 0;
}
// Stop any regular zombies too
with (obj_enemy) {
	speed = 0;
	hspeed = 0;
	vspeed = 0;
}
// And bullets
with (obj_projectile) {
	speed = 0;
}

phase = "math";              // "math" -> "select" -> "done"
questions_left = 3;
question_text = "";
question_answer = 0;
choices = [];                // 4 numbers
flash_timer = 0;
flash_correct = false;

gen_question = function()
{
	var _op = irandom(3);
	var _a = irandom_range(5, 50);
	var _b = irandom_range(2, 15);
	var _q = ""; var _ans = 0;
	switch (_op) {
		case 0: _ans = _a + _b; _q = string(_a) + " + " + string(_b); break;
		case 1: if (_a < _b) { var _t=_a; _a=_b; _b=_t; } _ans = _a - _b; _q = string(_a) + " - " + string(_b); break;
		case 2: _a = irandom_range(2,12); _b = irandom_range(2,12); _ans = _a*_b; _q = string(_a) + " x " + string(_b); break;
		case 3: _b = irandom_range(2,10); _ans = irandom_range(2,12); _a = _ans*_b; _q = string(_a) + " / " + string(_b); break;
	}
	question_text = _q;
	question_answer = _ans;
	// Generate 3 distractors + answer, shuffle
	var _list = [_ans];
	while (array_length(_list) < 4) {
		var _off = irandom_range(1, 6);
		if (irandom(1) == 0) _off = -_off;
		var _c = max(0, _ans + _off);
		var _dup = false;
		for (var _i = 0; _i < array_length(_list); _i++) {
			if (_list[_i] == _c) { _dup = true; break; }
		}
		if (!_dup) array_push(_list, _c);
	}
	// Fisher-Yates
	for (var _i = array_length(_list) - 1; _i > 0; _i--) {
		var _j = irandom(_i);
		var _t = _list[_i];
		_list[_i] = _list[_j];
		_list[_j] = _t;
	}
	choices = _list;
}

point_in_box = function(_mx, _my, _x, _y, _w, _h) {
	return (_mx >= _x && _mx <= _x + _w && _my >= _y && _my <= _y + _h);
}

gen_question();
