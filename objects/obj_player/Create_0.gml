// Variable for local player id
player_local_id = 0;
// Variable for player score
player_score = 0;
// Variable for player health
player_health = 3;

// Variable for player ammo
player_curr_ammo = 31;
// Variable for player max ammo
player_max_ammo = 31;
// Variable for player fire rate
player_fire_rate = 0.25;
// Variable for firing cooldown
player_fire_cooldown = 0;
// Variable for reload rate
player_reload_rate = 0.075;
// Variable for reload cooldown
player_reload_cooldown = 0;
// Variable for reloading state
player_is_reloading = false;

// Brief input lockout so clicks from the main menu (which use the same
// mouse press flag) don't immediately fire a bullet on game spawn
input_lockout = 20;

// Variable for gamepad deadzone
controller_deadzone = 0.1;
// Variable for if player is mouse aiming
if (!variable_global_exists("is_mouse_aiming")) global.is_mouse_aiming = true;
is_mouse_aiming = global.is_mouse_aiming;
// Variable for checking if the first frame has finished (used for mouse aiming)
is_first_frame = true;
// Variable for storing previous mouse positions
mouse_prev_x = mouse_x;
mouse_prev_y = mouse_y;

// Variable for the players buffer distance from arena edges
wall_buffer = 250;
// Variable for players rotation speed
rotation_speed = 0.25;
// Variable for players speed drop off
speed_dropoff = 0.9;
// Variable for players move speed
move_speed = 1;
// Variable for players maximum move speed
max_speed = 10;

// Sets players direction to its image angle
direction = image_angle;
// Variable for players gun angle
gun_angle = direction;
// Variable for players body angle
body_angle = direction;

// Variables for players speeds
hspeed = 0;
vspeed = 0;

// Variable for storing players speed when paused
last_speed = speed;

// Variable for players flashed state
is_flashed = false;
// Variable for players immunity time
flash_time = 0.2;
// Variable for immunity cooldown
flash_cooldown = flash_time;

// Variable for players last hud alpha
hud_health_alpha = 0;

// Variable for storing players reloading sound
reloading_sound = -1;

// Creates new particle emitter for dust smoke on left
var _new_dust_1 = instance_create_depth(x, y, depth - 1, obj_particle_handler);
_new_dust_1.owner = self;
_new_dust_1.set_dust_smoke(1);

// Creates new particle emitter for dust smoke centre
var _new_dust_2 = instance_create_depth(x, y, depth - 1, obj_particle_handler);
_new_dust_2.owner = self;
_new_dust_2.set_dust_smoke(1);

// Creates new particle emitter for dust smoke on right
var _new_dust_3 = instance_create_depth(x, y, depth - 1, obj_particle_handler);
_new_dust_3.owner = self;
_new_dust_3.set_dust_smoke(3);


// ─── MATH TERMINATOR: Power-up state ─────────────────────────────────
shield_timer = 0;          // Frames of invulnerability remaining
speed_boost_timer = 0;     // Frames of speed boost remaining
rapid_fire_timer = 0;      // Frames of rapid fire remaining
freeze_timer = 0;          // Frames of zombie freeze remaining (global effect)
base_max_speed = max_speed;
base_move_speed = move_speed;
base_fire_rate = player_fire_rate;
base_health_max = 3;       // baseline health cap
player_max_health = 3;     // matches HUD heart count

// ─── MATH TERMINATOR: Damage cooldown ─────────────────────────────────
damage_cooldown = 0;       // Frames before player can take damage again

// Apply a powerup based on type string
apply_powerup = function(_type)
{
	switch (_type)
	{
		case "health":
			player_health = min(player_health + 1, player_max_health);
			break;
		case "shield":
			shield_timer = 480;  // ~8 seconds at 60 fps
			break;
		case "speed":
			speed_boost_timer = 360;
			move_speed = base_move_speed * 1.8;   // actual acceleration boost
			max_speed  = base_max_speed  * 1.8;   // raise cap to match
			break;
		case "rapid":
			rapid_fire_timer = 180;  // 3 seconds at 60 fps
			player_fire_rate = base_fire_rate * 0.35;
			break;
		case "freeze":
			freeze_timer = 240;  // freezes all zombies for 4 seconds
			break;
		case "ammo":
			player_curr_ammo = player_max_ammo;
			break;
	}
}

// Function for creating projectile from players gun angle
create_projectile = function(_gun_angle)
{
	// Offsets for players gun position
	var _projectile_origin_x = 110;
	var _projectile_origin_y = 0;
	
	// Gun angle stored in radians
	var _theta = degtorad(_gun_angle);
	
	// Calculates the adjusted positions from offsets and angle
	var _projectile_adjust_x = (_projectile_origin_x * cos(_theta)) - (_projectile_origin_y * sin(_theta));
	var _projectile_adjust_y = (_projectile_origin_y * cos(_theta)) + (_projectile_origin_x * sin(_theta));
	
	// Sets new postions from adjusted positions and players position
	var _projectile_pos_x = x + _projectile_adjust_x;
	var _projectile_pos_y = y - _projectile_adjust_y;

	// Creates new player projectile from the new positions
	var _new_projectile = instance_create_layer(_projectile_pos_x, _projectile_pos_y, "Projectiles", obj_projectile);
	_new_projectile.owner = self;	
	_new_projectile.correct_player();
	
	// Creates new sparked projectile from angle and offset to add to players fired effect
	var _new_hit = instance_create_depth(_projectile_pos_x, _projectile_pos_y, depth - 1, obj_particle_handler);
	_new_hit.set_player_shot();
	_new_hit.owner = self;
	_new_hit.set_angle(_gun_angle);
	_new_hit.set_offset(true, 110, 0)
	
	// Plays firing audio sound
	var _sound_spark = -1;  // silenced
}

// Function called when player triggers to fire
trigger_pressed = function()
{
	// Infinite ammo - just fire on cooldown
	if (player_fire_cooldown <= 0)
	{
		// Resets the fire cooldown
		player_fire_cooldown = player_fire_rate;
		// Creates a projectile
		create_projectile(gun_angle);
	}
}