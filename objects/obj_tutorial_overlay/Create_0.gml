// ─── INTERACTIVE TUTORIAL OVERLAY ──────────────────────────────────
// Drives lesson progression through real gameplay.

current_step = 0;
step_state = "intro";   // "intro" | "active" | "outro"
step_timer = 0;
intro_clicked = false;

// Track player progress
player_start_x = 0;
player_start_y = 0;
shots_fired = 0;
shots_fired_baseline = 0;
kills_so_far = 0;
kills_baseline = 0;

// Pulse for prompt animation
prompt_pulse = 0;

tutorial_finished = false;

// Helper: spawn a tutorial zombie near the player
tutorial_spawn_zombie = function(_hp)
{
	var _ang = random(360);
	var _dist = 450;
	var _zx = obj_player.x + lengthdir_x(_dist, _ang);
	var _zy = obj_player.y + lengthdir_y(_dist, _ang);
	var _world_w = obj_game_manager.arena_grid_width * obj_game_manager.cell_width;
	var _world_h = obj_game_manager.arena_grid_height * obj_game_manager.cell_height;
	var _inset = obj_game_manager.cell_width;
	_zx = clamp(_zx, _inset, _world_w - _inset);
	_zy = clamp(_zy, _inset, _world_h - _inset);
	var _e = instance_create_layer(_zx, _zy, "Instances", obj_enemy);
	if (variable_instance_exists(_e, "max_health")) {
		_e.max_health = _hp;
		_e.curr_health = _hp;
	}
	if (variable_instance_exists(_e, "is_spawning")) {
		_e.is_spawning = false;
	}
	// Make the zombie acquire the player as a target right away
	with (_e) {
		if (variable_instance_exists(self, "lock_target")) {
			lock_target();
		}
	}
}

point_in_dialog = function(_mx, _my)
{
	var _ch = display_get_gui_height();
	return _my > _ch - 300;
}

advance_step = function()
{
	current_step++;
	if (current_step >= array_length(steps))
	{
		// Tutorial complete!
		if (instance_exists(obj_game_manager))
			obj_game_manager.unlock_achievement("tutorial_ok");
		// Stop arena music before returning to the menu so it doesn't keep
		// playing on top of the menu music we're about to start.
		if (instance_exists(obj_game_manager)
			&& variable_instance_exists(obj_game_manager, "music")
			&& obj_game_manager.music != -1
			&& audio_is_playing(obj_game_manager.music))
		{
			audio_stop_sound(obj_game_manager.music);
			obj_game_manager.music = -1;
		}
		room_goto(rm_main_menu);
		return;
	}
	step_state = "intro";
}

// ─── STEP CALLBACKS (bound to this instance using method()) ─────────
// method(self, function(){...}) ensures the function's `self` is THIS instance,
// not the struct, so we can use instance vars directly.

var _on_movement_start = method(self, function() {
	player_start_x = obj_player.x;
	player_start_y = obj_player.y;
});
var _on_movement_check = method(self, function() {
	return point_distance(obj_player.x, obj_player.y,
						  player_start_x, player_start_y) > 200;
});

var _on_shooting_start = method(self, function() {
	shots_fired_baseline = shots_fired;
});
var _on_shooting_check = method(self, function() {
	return (shots_fired - shots_fired_baseline) >= 3;
});

var _on_zombie1_start = method(self, function() {
	tutorial_spawn_zombie(1);
});
var _on_zombie1_check = method(self, function() {
	return instance_number(obj_enemy) == 0;
});

var _on_zombie2_start = method(self, function() {
	tutorial_spawn_zombie(2);
});
var _on_zombie2_check = method(self, function() {
	return instance_number(obj_enemy) == 0;
});

var _on_coins_check = method(self, function() {
	return instance_number(obj_coin) == 0;
});

var _on_powerup_start = method(self, function() {
	var _p = instance_create_layer(
		obj_player.x + 200, obj_player.y, "Instances", obj_powerup);
	_p.powerup_type = "health";
});
var _on_powerup_check = method(self, function() {
	return instance_number(obj_powerup) == 0;
});

steps = [
	{
		title: "WELCOME, RECRUIT",
		intro: ["The math zombies are coming.",
				"Your only weapon is your wits - and your gun.",
				"This tutorial will teach you the basics.",
				"",
				"Click anywhere to continue."],
		objective: "",
		check: undefined,
		on_start: undefined
	},
	{
		title: "MOVEMENT",
		intro: ["Use WASD to move your character.",
				"",
				"Click anywhere first, then try moving around."],
		objective: "Move around with WASD",
		check: _on_movement_check,
		on_start: _on_movement_start
	},
	{
		title: "AIMING & SHOOTING",
		intro: ["Your mouse controls where the gun points.",
				"LEFT CLICK to fire bullets.",
				"",
				"Click anywhere first, then fire 3 shots."],
		objective: "Fire 3 shots (left click)",
		check: _on_shooting_check,
		on_start: _on_shooting_start
	},
	{
		title: "MATH ZOMBIES",
		intro: ["Now the important part.",
				"A zombie will appear with a MATH PROBLEM above its head.",
				"You CANNOT kill it by just shooting - bullets bounce off!",
				"",
				"STEP 1: Click the box with the CORRECT answer.",
				"STEP 2: The zombie freezes and gets a green halo.",
				"STEP 3: Shoot it - now the bullet kills it.",
				"",
				"Click to spawn the zombie."],
		objective: "Click correct answer, then shoot the zombie",
		check: _on_zombie1_check,
		on_start: _on_zombie1_start
	},
	{
		title: "WRONG ANSWERS HURT",
		intro: ["WARNING: Clicking a WRONG answer locks the zombie",
				"for 3 seconds AND makes it move faster!",
				"You will see a red halo and a countdown.",
				"",
				"Wrong answers also reset your score combo.",
				"",
				"Read the problem carefully before clicking!"],
		objective: "",
		check: undefined,
		on_start: undefined
	},
	{
		title: "MULTI-HP ZOMBIES",
		intro: ["Some zombies have MULTIPLE HP (the pips below them).",
				"Each correct answer chips 1 HP and gives a new problem.",
				"Only the FINAL correct answer marks them for the kill.",
				"",
				"You score nothing until the kill - but the final hit gives",
				"score multiplied by max HP. Commit to finishing them off!",
				"",
				"Click to spawn a 2-HP zombie."],
		objective: "Kill the 2-HP zombie",
		check: _on_zombie2_check,
		on_start: _on_zombie2_start
	},
	{
		title: "COINS",
		intro: ["Notice the coins on the ground? Walk over them.",
				"Coins MAGNETIZE toward you when you get close.",
				"Silver = 50cr, Gold = 75cr, Diamond = 100cr.",
				"",
				"Click anywhere, then collect the coins."],
		objective: "Collect all the coins",
		check: _on_coins_check,
		on_start: undefined
	},
	{
		title: "POWERUPS",
		intro: ["Killed zombies sometimes drop POWERUPS.",
				"They give temporary buffs: Health, Shield, Speed,",
				"Rapid Fire, or Freeze.",
				"",
				"Click to spawn a powerup, then walk over to grab it."],
		objective: "Pick up the powerup",
		check: _on_powerup_check,
		on_start: _on_powerup_start
	},
	{
		title: "SHOP & INVENTORY",
		intro: ["Every 10 waves (5, 15, 25...) a SHOP appears.",
				"Buy items with credits to grow your inventory.",
				"",
				"Press E in-game to open your INVENTORY.",
				"Click any item card in the popup to use it.",
				"",
				"You can also set a default loadout from the",
				"main menu's LOADOUT panel before each run."],
		objective: "",
		check: undefined,
		on_start: undefined
	},
	{
		title: "GAME MODES",
		intro: ["UNLIMITED MODE: endless waves with shop intermissions.",
				"Survive as long as you can.",
				"",
				"TIMED MODE: pick a duration and play through it.",
				"Get the highest score before time runs out.",
				"",
				"Each timed length has its own leaderboard!"],
		objective: "",
		check: undefined,
		on_start: undefined
	},
	{
		title: "YOU'RE READY!",
		intro: ["That covers the essentials.",
				"",
				"Remember:",
				"  1. Click the right answer FIRST",
				"  2. Then shoot the marked zombie",
				"  3. Don't stand still, zombies hit hard",
				"  4. Save credits for big items like Airstrike",
				"",
				"Good luck, soldier. Click to return to the main menu."],
		objective: "",
		check: undefined,
		on_start: undefined
	}
];
