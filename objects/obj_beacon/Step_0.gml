if (obj_game_manager.curr_game_state != GAME_STATE.PLAYING) exit;

pulse_phase += 4;
lifetime--;

// Highlight the CORRECT answer weakspot for any zombie inside the beacon
// radius. The zombie isn't marked or auto-killed — the player still has to
// shoot the zombie after seeing which answer is correct.
//
// Each beacon REFRESHES a short timer on in-range zombies. The enemy's
// own Step ticks that timer down, so when no beacon is refreshing it the
// flag goes false naturally within a few frames. This handles multiple
// beacons cleanly — each one can independently keep zombies highlighted
// without stomping the others.
with (obj_enemy)
{
	if (is_spawning) continue;
	if (point_distance(x, y, other.x, other.y) < other.beacon_radius)
	{
		beacon_hint_timer = 3;   // refresh every 3 frames
	}
}

if (lifetime <= 0) instance_destroy();
