// Tick flash timer
if (flash_timer > 0) flash_timer--;

// Destroy if owner enemy is gone
if (!instance_exists(owner))
{
	instance_destroy();
	exit;
}

// Follow owner
x = owner.x + offset_x;
y = owner.y + offset_y;

// Hover detection (mouse over this answer button)
is_hovered = (mouse_x >= x - ws_width/2 && mouse_x <= x + ws_width/2
		   && mouse_y >= y - ws_height/2 && mouse_y <= y + ws_height/2);

// ─── CLICK TO ANSWER ────────────────────────────────────────────────
// Only the SINGLE WINNING weakspot (closest to mouse cursor center) fires.
// This prevents overlapping answers from triggering two clicks simultaneously.
if (mouse_check_button_pressed(mb_left)
		&& obj_game_manager.curr_game_state == GAME_STATE.PLAYING
		&& instance_exists(obj_player)
		&& obj_player.input_lockout <= 0)
{
	// Find the BEST weakspot at the cursor — the one whose center is closest
	// to the mouse, with locked weakspots skipped entirely.
	var _best_ws = noone;
	var _best_dist = 999999;
	with (obj_weakspot)
	{
		if (!instance_exists(owner)) continue;
		// Skip locked zombies — clicks should ignore them, not lock them again
		if (owner.wrong_lockout_timer > 0) continue;
		// Is the mouse inside this box?
		var _inside = (mouse_x >= x - ws_width/2 && mouse_x <= x + ws_width/2
					&& mouse_y >= y - ws_height/2 && mouse_y <= y + ws_height/2);
		if (!_inside) continue;
		// Distance from mouse to weakspot center
		var _d = point_distance(mouse_x, mouse_y, x, y);
		if (_d < _best_dist)
		{
			_best_dist = _d;
			_best_ws = id;
		}
	}
	
	// Only THIS weakspot fires if it is the winner
	if (_best_ws == id)
	{
		flash_timer = 18;
		if (is_answer)
		{
			/* SILENCED: audio_play_sound(snd_enemy_hit, 100, false, 0.01, 0, 1.0); */
			owner.math_correct_answer();
		}
		else
		{
			/* SILENCED: audio_play_sound(snd_gun_jam, 100, false, 0.01, 0, 1.0); */
			owner.math_wrong_answer();
		}
	}
}
