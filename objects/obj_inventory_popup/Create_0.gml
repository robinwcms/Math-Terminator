// ─── INVENTORY POPUP ─────────────────────────────────────────────────
// Opened with E during gameplay. Shows all 5 powerups, owned counts, and lets
// the player click (or press 1-5) to use one. Closes with E or ESC.

// Pause the game while open
obj_game_manager.curr_game_state = GAME_STATE.PAUSED;
window_set_cursor(cr_default);

// Hard-stop the player so held movement keys don't carry through the pause
if (instance_exists(obj_player))
{
	obj_player.hspeed = 0;
	obj_player.vspeed = 0;
	obj_player.speed = 0;
}
// And anything else with momentum
with (obj_enemy)     { speed = 0; hspeed = 0; vspeed = 0; }
with (obj_boss)      { speed = 0; hspeed = 0; vspeed = 0; }
with (obj_projectile){ speed = 0; }

// Wait for E to be released before allowing close (so the open-press doesn't close)
e_was_released = false;

// Item definitions
items = [
	{ key: "heart",     name: "Heart",          desc: "Restores 1 HP instantly",        col: make_color_rgb(220, 60, 80),   inv: "inv_heart" },
	{ key: "shield",    name: "Shield",         desc: "8 seconds of damage immunity",   col: make_color_rgb(60, 180, 220),  inv: "inv_shield" },
	{ key: "sniper",    name: "Sniper Scope",   desc: "Zoom out + piercing shots",      col: make_color_rgb(140, 140, 230), inv: "inv_sniper" },
	{ key: "dblpoints", name: "Double Points",  desc: "2x score for this wave",         col: make_color_rgb(255, 210, 0),   inv: "inv_dblpoints" },
	{ key: "airstrike", name: "Air Strike",     desc: "Wipe a large map area",          col: make_color_rgb(220, 100, 50),  inv: "inv_airstrike" },
	{ key: "rapid",     name: "Rapid Fire",     desc: "3s instakill rampage",           col: make_color_rgb(255, 100, 100), inv: "inv_rapid" },
	{ key: "speed",     name: "Speed Boost",    desc: "6s of extra speed",              col: make_color_rgb(100, 230, 100), inv: "inv_speed" },
	{ key: "freeze",    name: "Freeze",         desc: "5s zombie slowdown",             col: make_color_rgb(150, 200, 255), inv: "inv_freeze" },
	{ key: "decoy",     name: "Decoy",          desc: "8s zombie magnet",               col: make_color_rgb(80, 180, 255),  inv: "inv_decoy" },
	{ key: "beacon",    name: "Beacon",         desc: "Auto-marks zombies in radius",   col: make_color_rgb(120, 255, 130), inv: "inv_beacon" },
	{ key: "sanctuary", name: "Sanctuary",      desc: "Zombies blocked from radius",    col: make_color_rgb(180, 220, 255), inv: "inv_sanctuary" },
	{ key: "turret",    name: "Turret",         desc: "Auto-fires + kills for 10s",     col: make_color_rgb(130, 140, 155), inv: "inv_turret" },
	{ key: "mobshop",   name: "Mobile Shop",    desc: "Open shop instantly",            col: make_color_rgb(255, 180, 80),  inv: "inv_mobshop" },
];

selected_index = -1;
scroll_offset = 0;
// Smooth-scroll animation: target vs current
scroll_target = 0;

// USE ITEM function — defined here so Step can call it
use_item = function(_idx)
{
	var _item = items[_idx];
	var _count = variable_global_get(_item.inv);
	if (_count <= 0) exit;

	variable_global_set(_item.inv, _count - 1);

	// Airstrike is special: it pauses the game itself. Don't resume after.
	var _launched_airstrike = false;
	
	switch (_item.key)
	{
		case "heart":
			if (instance_exists(obj_player))
				obj_player.player_health = min(obj_player.player_health + 1, obj_player.player_max_health);
		break;
		case "shield":
			if (instance_exists(obj_player))
				obj_player.shield_timer = 480;
		break;
		case "sniper":
			obj_game_manager.sniper_active = true;
			obj_game_manager.sniper_toggle_disabled = false;
		break;
		case "dblpoints":
			obj_game_manager.double_points_active = true;
		break;
		case "airstrike":
			if (!instance_exists(obj_airstrike))
			{
				// Resume now so the airstrike can capture a fresh PLAYING prev_state
				obj_game_manager.resume_game();
				instance_create_layer(0, 0, "Popups", obj_airstrike);
				_launched_airstrike = true;
			}
		break;
		case "rapid":
			// 3 seconds of instakill bullets — match the pickup effect
			if (instance_exists(obj_player))
			{
				obj_player.rapid_fire_timer = 180;
				obj_player.player_fire_rate = obj_player.base_fire_rate * 0.35;
			}
		break;
		case "speed":
			// 6 seconds of extra player speed
			if (instance_exists(obj_player))
			{
				obj_player.speed_boost_timer = 360;
				obj_player.max_speed  = obj_player.base_max_speed * 1.8;
				obj_player.move_speed = obj_player.base_move_speed * 1.8;
			}
		break;
		case "freeze":
			// 5 seconds of zombie slowdown
			if (instance_exists(obj_player))
				obj_player.freeze_timer = 300;
		break;
		case "decoy":
			// Place a decoy at the player's position; zombies will retarget it
			if (instance_exists(obj_player))
			{
				var _dpx = obj_player.x;
				var _dpy = obj_player.y;
				instance_create_layer(_dpx, _dpy, "Instances", obj_decoy);
			}
		break;
		case "beacon":
			// Place a beacon at the player's position
			if (instance_exists(obj_player))
			{
				var _bpx = obj_player.x;
				var _bpy = obj_player.y;
				instance_create_layer(_bpx, _bpy, "Instances", obj_beacon);
			}
		break;
		case "sanctuary":
			// Place a sanctuary bubble at the player's position
			if (instance_exists(obj_player))
			{
				var _spx = obj_player.x;
				var _spy = obj_player.y;
				instance_create_layer(_spx, _spy, "Instances", obj_sanctuary);
			}
		break;
		case "turret":
			// Place a turret at the player's position
			if (instance_exists(obj_player))
			{
				var _tpx = obj_player.x;
				var _tpy = obj_player.y;
				instance_create_layer(_tpx, _tpy, "Instances", obj_turret);
			}
		break;
		case "mobshop":
			// Open shop instantly. Like airstrike, this opens its own
			// pause flow — don't resume game after closing the inventory.
			if (!instance_exists(obj_shop))
			{
				obj_game_manager.resume_game();
				instance_create_layer(0, 0, "Popups", obj_shop);
				_launched_airstrike = true;   // reuses the "don't resume" flag
			}
		break;
	}

	// Close the popup (but only resume the game if we DIDN'T launch airstrike,
	// because airstrike has already paused everything itself)
	if (!_launched_airstrike)
	{
		obj_game_manager.resume_game();
		// Re-zero velocity in case anything crept in
		if (instance_exists(obj_player))
		{
			obj_player.hspeed = 0;
			obj_player.vspeed = 0;
			obj_player.speed = 0;
		}
	}
	// Brief input lockout so the click that activated the item doesn't
	// also fire a bullet or trigger a weakspot
	if (instance_exists(obj_player)) obj_player.input_lockout = 10;
	instance_destroy();
}
