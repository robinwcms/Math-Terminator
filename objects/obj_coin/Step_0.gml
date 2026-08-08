// Lifetime
lifetime--;
if (lifetime <= 0) { instance_destroy(); exit; }
bob_phase += 5;

// Initial pop-out movement (decays quickly)
x += launch_vx;
y += launch_vy;
launch_vx *= 0.92;
launch_vy *= 0.92;

// After a short delay, magnet toward the player
if (lifetime < 1180 && instance_exists(obj_player))
{
	var _pl = instance_find(obj_player, 0);
	var _d = point_distance(x, y, _pl.x, _pl.y);
	// Attract if within range, then accelerate as we get closer
	if (_d < 350 || attract_started)
	{
		attract_started = true;
		var _ang = point_direction(x, y, _pl.x, _pl.y);
		var _spd = clamp(12 - _d * 0.02, 6, 14);
		x += lengthdir_x(_spd, _ang);
		y += lengthdir_y(_spd, _ang);
	}
	
	// Pickup
	if (_d < 75)
	{
		global.credits += coin_value;
		// Track per-run credits earned for the High Roller achievement
		if (instance_exists(obj_game_manager))
		{
			obj_game_manager.run_credits_earned += coin_value;
			if (obj_game_manager.run_credits_earned >= 1000)
				obj_game_manager.unlock_achievement("high_roller");
		}
		instance_destroy();
	}
}
