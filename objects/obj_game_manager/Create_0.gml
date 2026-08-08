	
// ─── COMBO SYSTEM ────────────────────────────────────────────────────
combo_count = 0;
combo_timer = 0;            // resets if no correct answer in this window
combo_max_window = 240;     // 4 seconds at 60 fps to keep combo alive
combo_best = 0;             // session record
screen_shake = 0;           // screen shake intensity in pixels
final_score = 0;            // stashed score for lose banner after death
pending_hp_queue = [];      // HP values assigned to next-spawned zombies
pending_type_queue = [];    // Type strings (normal/runner/healer/splitter/exploder)

// ─── RUN STATS (saved to recent games on death/win) ────────────────
run_zombies_killed = 0;
run_correct_answers = 0;
run_wrong_answers = 0;
run_boss_kills = 0;
run_start_time = current_time;
run_max_combo = 0;
run_wave_perfect = true;   // no wrong answers yet this wave
run_damage_taken_wave = 0;
run_credits_earned = 0;

// ─── ACHIEVEMENTS (persistent across runs) ─────────────────────────
// Each achievement is { id, name, desc, unlocked, progress?, target? }
if (!variable_global_exists("achievements"))
{
	global.achievements = [
		{ id:"first_blood",  name:"First Blood",     desc:"Kill your first zombie",                         unlocked:false },
		{ id:"sharp_shoot",  name:"Sharp Shooter",   desc:"Kill 25 zombies in a single run",                unlocked:false },
		{ id:"math_marathon",name:"Math Marathon",   desc:"100 correct answers in one run",                 unlocked:false },
		{ id:"boss_slayer",  name:"Boss Slayer",     desc:"Defeat the boss for the first time",             unlocked:false },
		{ id:"perfect_wave", name:"Perfect Wave",    desc:"Clear a wave with zero wrong answers",           unlocked:false },
		{ id:"combo_king",   name:"Combo King",      desc:"Hit a 5x combo",                                 unlocked:false },
		{ id:"high_roller",  name:"High Roller",     desc:"Earn 1,000 credits in one run",                  unlocked:false },
		{ id:"survivor",     name:"Survivor",        desc:"Reach wave 20",                                  unlocked:false },
		{ id:"untouchable",  name:"Untouchable",     desc:"Clear wave 5 without taking damage",             unlocked:false },
		{ id:"math_maniac",  name:"Math Maniac",     desc:"95%+ accuracy with 50+ answers in a run",        unlocked:false },
		{ id:"wave_master",  name:"Wave Master",     desc:"Reach wave 50",                                  unlocked:false },
		{ id:"speedrunner",  name:"Speedrunner",     desc:"Reach wave 5 within 2 minutes",                  unlocked:false },
		{ id:"tutorial_ok",  name:"Tutorial Done",   desc:"Complete the tutorial",                          unlocked:false },
	];
	// Try to load from disk
	if (file_exists("achievements.sav"))
	{
		var _fa = file_text_open_read("achievements.sav");
		var _aj = "";
		while (!file_text_eof(_fa))
		{
			_aj += file_text_read_string(_fa);
			file_text_readln(_fa);
		}
		file_text_close(_fa);
		if (_aj != "")
		{
			try {
				var _saved = json_parse(_aj);
				if (is_array(_saved))
				{
					// Merge unlocked flags by id, keeping our definitions current
					for (var _ai = 0; _ai < array_length(global.achievements); _ai++)
					{
						var _a = global.achievements[_ai];
						for (var _sj = 0; _sj < array_length(_saved); _sj++)
						{
							var _s = _saved[_sj];
							if (variable_struct_exists(_s, "id") && _s.id == _a.id
								&& variable_struct_exists(_s, "unlocked"))
							{
								_a.unlocked = _s.unlocked;
							}
						}
					}
				}
			} catch (_e) {}
		}
	}
}
// Track popups for newly-unlocked achievements this session
if (!variable_global_exists("achievement_popups")) global.achievement_popups = [];

// Helper: unlock an achievement by id, save to disk, queue popup
unlock_achievement = function(_id)
{
	for (var _i = 0; _i < array_length(global.achievements); _i++)
	{
		if (global.achievements[_i].id == _id && !global.achievements[_i].unlocked)
		{
			global.achievements[_i].unlocked = true;
			// Save to disk
			var _f = file_text_open_write("achievements.sav");
			file_text_write_string(_f, json_stringify(global.achievements));
			file_text_close(_f);
			// Queue popup (3 seconds = 180 frames)
			array_push(global.achievement_popups, {
				name: global.achievements[_i].name,
				desc: global.achievements[_i].desc,
				timer: 240
			});
			break;
		}
	}
}

// ─── CREDITS (shop currency) ──────────────────────────────────────
if (!variable_global_exists("credits")) global.credits = 0;
// Reset credits on new run (player just entered arena)
global.credits = 0;

// ─── INVENTORY ────────────────────────────────────────────────────
// Persistent inventory of shop-bought items. All activation goes through the
// inventory popup (E key); no 1-8 hotkey shortcuts.
if (!variable_global_exists("inv_heart"))      global.inv_heart = 0;
if (!variable_global_exists("inv_shield"))     global.inv_shield = 0;
if (!variable_global_exists("inv_sniper"))     global.inv_sniper = 0;
if (!variable_global_exists("inv_dblpoints"))  global.inv_dblpoints = 0;
if (!variable_global_exists("inv_airstrike")) global.inv_airstrike = 0;
if (!variable_global_exists("inv_rapid"))     global.inv_rapid = 0;
if (!variable_global_exists("inv_speed"))     global.inv_speed = 0;
if (!variable_global_exists("inv_freeze"))    global.inv_freeze = 0;
if (!variable_global_exists("inv_decoy"))     global.inv_decoy = 0;
if (!variable_global_exists("inv_beacon"))    global.inv_beacon = 0;
if (!variable_global_exists("inv_sanctuary")) global.inv_sanctuary = 0;
if (!variable_global_exists("inv_turret"))    global.inv_turret = 0;
if (!variable_global_exists("inv_mobshop"))   global.inv_mobshop = 0;
// Reset on new run — apply loadout picks. If no loadout has been set (first
// run), grant x1 of each so the player can try every gadget.
global.inv_heart = 0;
global.inv_shield = 0;
global.inv_sniper = 0;
global.inv_dblpoints = 0;
global.inv_airstrike = 0;
global.inv_rapid = 0;
global.inv_speed = 0;
global.inv_freeze = 0;
global.inv_decoy = 0;
global.inv_beacon = 0;
global.inv_sanctuary = 0;
global.inv_turret = 0;
global.inv_mobshop = 0;

if (variable_global_exists("loadout_picks") && array_length(global.loadout_picks) > 0)
{
	// Grant 1 of each gadget the player picked in the loadout panel
	for (var _li = 0; _li < array_length(global.loadout_picks); _li++)
	{
		var _key = global.loadout_picks[_li];
		switch (_key) {
			case "heart":     global.inv_heart++;     break;
			case "shield":    global.inv_shield++;    break;
			case "sniper":    global.inv_sniper++;    break;
			case "dblpoints": global.inv_dblpoints++; break;
			case "airstrike": global.inv_airstrike++; break;
			case "rapid":     global.inv_rapid++;     break;
			case "speed":     global.inv_speed++;     break;
			case "freeze":    global.inv_freeze++;    break;
			case "decoy":     global.inv_decoy++;     break;
			case "beacon":    global.inv_beacon++;    break;
			case "sanctuary": global.inv_sanctuary++; break;
			case "turret":    global.inv_turret++;    break;
			case "mobshop":   global.inv_mobshop++;   break;
		}
	}
}
else
{
	// No loadout chosen yet — give a sampler of all gadgets
	global.inv_heart = 1;
	global.inv_shield = 1;
	global.inv_sniper = 1;
	global.inv_dblpoints = 1;
	global.inv_airstrike = 1;
	global.inv_rapid = 1;
	global.inv_speed = 1;
	global.inv_freeze = 1;
	global.inv_decoy = 1;
	global.inv_beacon = 1;
	global.inv_sanctuary = 1;
	global.inv_turret = 1;
	global.inv_mobshop = 1;
}

// Used to prevent re-opening the inventory popup on the same frame it closes
global.suppress_e_open = false;
suppress_e_timer = 0;

// Damage vignette: ticks down each frame; > 0 means show red overlay
damage_vignette_timer = 0;
damage_vignette_max = 45;

// Double points active for this wave?
double_points_active = false;
// Sniper zoom active?
sniper_active = false;
sniper_toggle_disabled = false;
_prev_sniper_active = false;
// Current camera zoom factor (1.0 = normal, 1.5 = sniper). Lerps smoothly.
view_zoom_current = 1.0;

// Debug overlay toggle (press Y on gamepad to show/hide)
show_debug = false;

// States used for storing the game playing state
enum GAME_STATE
{
	PLAYING,
	PAUSED,
	ENDED,
	SIZE
}

// Sets a random seed for the project
randomise();

// Variable for the current game state - initally set to playing
curr_game_state = GAME_STATE.PLAYING;
// Variable for storing the current wave - initally set to 0
curr_wave = 0;
// Variable for storing the maximum waves a player can go through
max_levels = 10;

// Variables for setting the grid size of the level
// can be changed to larger or smaller sizes for bigger or smaller levels
arena_grid_width = 8;
arena_grid_height = 8;

// Variables for cell sizes (background grid pieces)
cell_width = 512;
cell_height = 512;

// Variables for setting up the pathfiding grid
// The higher the rate the more precise the pathfinding but more resource demanding
grid_rate = 8;
grid = mp_grid_create(0, 0, arena_grid_width * grid_rate, arena_grid_height * grid_rate, cell_width / grid_rate, cell_height / grid_rate);

// Variables for setting up the rate gaps appear in the walls (enemy spawn points)
// Rate is how offten a side peice will become a gap
gap_rate = 1/3;
// Count is how many gaps are created
gap_count = 0;
// Min is the minimum amount of gaps a level can have or it will regenerate
gap_min = 2;
// Max is the maximum amount of gaps a level can have before it stops making more
gap_max = 8;

// Variables used for the score font used in the hud
score_font = fnt_luckiest_guy_48;
score_colour = c_white;
score_alpha = 0.75;
score_halign = fa_center;
score_valign = fa_middle;

// Variables used to check the last states of paused and new waves so they arnt acceidentally called twice
was_paused = false;
was_new_wave = false;

// Variable used to change how long the inital wave will take to start after the game begins
start_time = 1.5;
// Variable used to set the maximum amount of enemeies that can appear on screen at any time
max_enemies = 40;

// ─── TIMED MODE STATE ──────────────────────────────────────────────
if (!variable_global_exists("game_mode")) global.game_mode = "normal";
if (!variable_global_exists("timed_duration")) global.timed_duration = 60;
is_timed_mode = (global.game_mode == "timed");
is_tutorial_mode = (global.game_mode == "tutorial");
timed_time_left = global.timed_duration;       // seconds
timed_max_concurrent = 10;                      // 10 zombies on screen at once
timed_spawn_cooldown = 0;                       // frames until next spawn
timed_spawn_rate = 30;                          // spawn check every 0.5 sec
if (is_timed_mode)
{
	max_enemies = timed_max_concurrent;
	// Skip the wave intro - waves are disabled in timed mode
	curr_wave = 1;
}

// Creates pause button used in the top left corner of the screen
instance_create_layer(0, 0, "Popups", obj_button_pause);

// (Reload HUD removed — no reload mechanic anymore, infinite ammo)
// (Touch reload button also removed)

// Checks if game has touch controls
if (global.is_touch)
{
	// Creates the touch manager
	instance_create_layer(0, 0, "GM", obj_touch_manager);
	
	// Creates virtual joysticks
	instance_create_layer(0, 0, "Popups", obj_joystick_left);
	instance_create_layer(0, 0, "Popups", obj_joystick_right);
}

// Stop menu music if it's still playing (we're now in arena, not on the menu).
// Don't blanket audio_stop_all() — that would also kill any sounds queued by
// the splash manager during the transition.
if (variable_global_exists("menu_music_inst")
	&& global.menu_music_inst != -1
	&& audio_is_playing(global.menu_music_inst))
{
	audio_stop_sound(global.menu_music_inst);
	global.menu_music_inst = -1;
}
// Music variable initialized so later audio_stop_sound() calls don't crash.
// Safety: also stop any music handle that survived from a previous arena
// session — protects against double-music from re-entering arena fast.
if (variable_global_exists("arena_music_inst")
	&& global.arena_music_inst != -1
	&& audio_is_playing(global.arena_music_inst))
{
	audio_stop_sound(global.arena_music_inst);
}
music = -1;
// Pick a random wave music track and play it on loop. The three original
// snd_music_game_1/2/3 assets are kept; one is chosen per run.
var _track = choose(snd_music_game_1, snd_music_game_2, snd_music_game_3);
music = audio_play_sound(_track, 100, true, 0.01, 0, 1.0);
global.arena_music_inst = music;

// Loops that create the level from the grid variables by its width and height
for (var _i = 0; _i < arena_grid_width; _i++)
{
	for (var _j = 0; _j < arena_grid_height; _j++)
	{
		// Checks if current grid element is on the left wall
		if (_i == 0)
		{
			// Checks if the current grid element is along the top wall
			if (_j == 0)
			{
				// Sets top left grid element
				var _new_wall = instance_create_layer(_i * cell_width, _j * cell_height, "Level", obj_level_wall);
				_new_wall.curr_face_type = FACE_TYPE.TOP_LEFT;
				_new_wall.set_sprite();
			}
			// Checks if the current grid element is along the bottom wall
			else if (_j == arena_grid_height - 1)
			{
				// Sets the bottom left grid element
				var _new_wall = instance_create_layer(_i * cell_width, _j * cell_height, "Level", obj_level_wall);
				_new_wall.curr_face_type = FACE_TYPE.BOTTOM_LEFT;
				_new_wall.set_sprite();
			}
			else
			{
				// Checks if the wall element should become a gap if too many dont already exist
				if (random(1.0) <= gap_rate && gap_count < gap_max)
				{
					// Sets a left gap element
					var _new_wall = instance_create_layer(_i * cell_width, _j * cell_height, "Level", obj_level_wall);
					_new_wall.curr_face_type = FACE_TYPE.LEFT_GAP;
					_new_wall.set_sprite();
					
					// Creates an enemy spawner inside the gap location
					var _new_spawner = instance_create_layer(_new_wall.x - cell_width / 2, _new_wall.y + cell_height / 2, "Level", obj_enemy_spawner);
					_new_spawner.curr_face_direction = FACE_DIRECTION.LEFT;
					
					// Increases the gap count
					gap_count++;
				}
				else
				{
					// Sets a left wall element
					var _new_wall = instance_create_layer(_i * cell_width, _j * cell_height, "Level", obj_level_wall);
					_new_wall.curr_face_type = FACE_TYPE.LEFT;
					_new_wall.set_sprite();
				}
			}
		}
		// Checks if current grid element is on the right wall
		else if (_i == arena_grid_width - 1)
		{
			// Checks if current grid element is along the top wall
			if (_j == 0)
			{
				// Sets the top right grid element
				var _new_wall = instance_create_layer(_i * cell_width, _j * cell_height, "Level", obj_level_wall);
				_new_wall.curr_face_type = FACE_TYPE.TOP_RIGHT;
				_new_wall.set_sprite();
			}
			// Checks if the current grid element is along the bottom wall
			else if (_j == arena_grid_height - 1)
			{
				// Sets the bottom right grid element
				var _new_wall = instance_create_layer(_i * cell_width, _j * cell_height, "Level", obj_level_wall);
				_new_wall.curr_face_type = FACE_TYPE.BOTTOM_RIGHT;
				_new_wall.set_sprite();
			}
			else
			{
				// Checks if the wall element should become a gap if too many dont already exist
				if (random(1.0) <= gap_rate && gap_count < gap_max)
				{
					// Sets right gap element
					var _new_wall = instance_create_layer(_i * cell_width, _j * cell_height, "Level", obj_level_wall);
					_new_wall.curr_face_type = FACE_TYPE.RIGHT_GAP;
					_new_wall.set_sprite();
					
					// Creates an enemy spawner inside the gap location
					var _new_spawner = instance_create_layer(_new_wall.x + (3 * cell_width) / 2, _new_wall.y + cell_height / 2, "Level", obj_enemy_spawner);
					_new_spawner.curr_face_direction = FACE_DIRECTION.RIGHT;
					
					// Increases the gap count
					gap_count++;
				}
				else
				{
					// Sets a right wall element
					var _new_wall = instance_create_layer(_i * cell_width, _j * cell_height, "Level", obj_level_wall);
					_new_wall.curr_face_type = FACE_TYPE.RIGHT;
					_new_wall.set_sprite();
				}
			}
		}
		// Checks if current grid element is along the top wall
		else if (_j == 0)
		{
			// Checks if the wall element should become a gap if too many dont already exist
			if (random(1.0) <= gap_rate && gap_count < gap_max)
			{
				// Sets top gap element
				var _new_wall = instance_create_layer(_i * cell_width, _j * cell_height, "Level", obj_level_wall);
				_new_wall.curr_face_type = FACE_TYPE.TOP_GAP;
				_new_wall.set_sprite();
				
				// Creates an enemy spawner inside the gap location
				var _new_spawner = instance_create_layer(_new_wall.x + cell_width / 2, _new_wall.y - cell_height / 2, "Level", obj_enemy_spawner);
				_new_spawner.curr_face_direction = FACE_DIRECTION.TOP;
				
				// Increases the gap count
				gap_count++;
			}
			else
			{
				// Sets a top wall element
				var _new_wall = instance_create_layer(_i * cell_width, _j * cell_height, "Level", obj_level_wall);
				_new_wall.curr_face_type = FACE_TYPE.TOP;
				_new_wall.set_sprite();
			}
		}
		// Checks if current grid element is along the bottom wall
		else if (_j == arena_grid_height - 1)
		{
			// Checks if the wall element should become a gap if too many dont already exist
			if (random(1.0) <= gap_rate && gap_count < gap_max)
			{
				// Sets a bottom gap element
				var _new_wall = instance_create_layer(_i * cell_width, _j * cell_height, "Level", obj_level_wall);
				_new_wall.curr_face_type = FACE_TYPE.BOTTOM_GAP;
				_new_wall.set_sprite();
				
				// Creates an enemy spawner inside the gap location
				var _new_spawner = instance_create_layer(_new_wall.x + cell_width / 2, _new_wall.y + (3 * cell_height) / 2, "Level", obj_enemy_spawner);
				_new_spawner.curr_face_direction = FACE_DIRECTION.BOTTOM;
				
				// Increases the gap count
				gap_count++;
			}
			else
			{
				// Sets a bottom wall element
				var _new_wall = instance_create_layer(_i * cell_width, _j * cell_height, "Level", obj_level_wall);
				_new_wall.curr_face_type = FACE_TYPE.BOTTOM;
				_new_wall.set_sprite();
			}
		}
		else
		{
			// Sets a normal ground element
			instance_create_layer(_i * cell_width, _j * cell_height, "Level", obj_level_ground);
		}
	}
}

// Checks enough gaps have been created to fufil the minimum criteria
if (gap_count < gap_min)
{
	// Restarts room to try generate new level
	room_restart();	
}

// Variabls used for the rate flowers can be made per level grid cell
var _flower_rate = 3;
// Variable for the offset flowers can spawn from wall edges
var _flower_edge_offset = 240;

// Variable created to set the amount of flowers within the level
var _flower_count = round(arena_grid_width * arena_grid_height * _flower_rate);
	
// Loop for creation of flowers 
for (var _i = 0; _i < _flower_count; _i++)
{
	// Creates new flower at random location within the bounds of the level and offset
	var _new_flower_x = random_range(_flower_edge_offset, (cell_width * arena_grid_width) - _flower_edge_offset);
	var _new_flower_y = random_range(_flower_edge_offset, (cell_height * arena_grid_height) - _flower_edge_offset);
	instance_create_layer(_new_flower_x, _new_flower_y, "Flowers", obj_flower);
}

// Creates a player within the centre of the room and sets their ID to 0 (player 1) facing them down
var _player = instance_create_layer((arena_grid_width * cell_width) / 2, (arena_grid_height * cell_height) / 2,"Instances", obj_player);
_player.player_local_id = 0;
_player.image_angle = 270;
_player.gun_angle = 270;

// ─── DAILY CHALLENGE MODIFIERS ─────────────────────────────────────
// 0=No Powerups, 1=Double Speed, 2=Algebra Only, 3=Half Hearts, 4=Glass Cannon
if (variable_global_exists("is_daily_challenge") && global.is_daily_challenge)
{
	switch (global.daily_modifier)
	{
		case 3: // Half Hearts
			_player.player_health = 1;
			_player.player_max_health = 1;
			break;
		case 4: // Glass Cannon
			_player.player_health = 1;
			_player.player_max_health = 1;
			// Double damage means rapid_fire effect — easiest hack: keep
			// it 1 HP but rapid_fire is permanent
			_player.rapid_fire_timer = 999999;
			break;
	}
	// Reset the flag once consumed so a normal mode run after won't carry it
	// (will be re-set if player launches daily again)
	// We'll let the modifier persist for the run; reset on lose / leave.
}

// Variables for spwaning the obstacles within the room
// Rate of obstacles per grid cell in level
var _obstacle_rate = 0.2;
// Offset from room edges they can spawn
var _obstacle_edge_offset = 600;
// Buffer distance from each other they can spawn to allow spacing
var _obstacle_cell_buffer_width = cell_width * 1.5;
var _obstacle_cell_buffer_height = cell_height * 1.5;

// Total obstacle count based from the variables
var _obstacle_count = round(arena_grid_width * arena_grid_height * _obstacle_rate);

// Loop for creating the obstacles
for (var _i = 0; _i < _obstacle_count; _i++)
{
	// Variables for checking if a placement is possible
	var _new_search = true;
	var _can_place = true;
	
	// Variables for checking how many tries have been attempted to prevent excessive hangs
	var _tries = 0;
	var _max_tries = 60;
	
	// Variables for new obstacles position
	var _new_obstacle_x = 0;
	var _new_obstacle_y = 0;
	
	// Loop for searching
	while (_new_search)
	{
		// Reset loop criteria
		_new_search = false;
	
		// Set new positions
		_new_obstacle_x = random_range(_obstacle_edge_offset, (cell_width * arena_grid_width) - _obstacle_edge_offset);
		_new_obstacle_y = random_range(_obstacle_edge_offset, (cell_height * arena_grid_height) - _obstacle_edge_offset);
		
		// Loop through players
		with (obj_player)
		{
			// Check if objects within spawn location
			if (point_in_rectangle(_new_obstacle_x, _new_obstacle_y, x - _obstacle_cell_buffer_width, y - _obstacle_cell_buffer_height, x + _obstacle_cell_buffer_width, y + _obstacle_cell_buffer_height))
			{	
				// Ask for new search
				_new_search = true;
			}
		}
		
		// Checks if still can search
		if (_new_search == false)
		{
			// Loops through obstable objects within room
			with (obj_obstacle)
			{
				// Check if objects within spawn location
				if (point_in_rectangle(_new_obstacle_x, _new_obstacle_y, x - _obstacle_cell_buffer_width, y - _obstacle_cell_buffer_height, x + _obstacle_cell_buffer_width, y + _obstacle_cell_buffer_height))
				{
					// Ask for new search
					_new_search = true;
				}
			}
		}
		
		// Increase try counter
		_tries++;
		
		// Check if tries have been exceded and still needs to search
		if (_tries >= _max_tries && _new_search)
		{
			// Stops search but cant place obstacle
			_can_place = false;
			_new_search = false;
		}
	}
	
	// Checks if can place obstacle
	if (_can_place)
	{
		// Creates new obstacle at desired position
		instance_create_layer(_new_obstacle_x, _new_obstacle_y, "Obstacles", obj_obstacle);
	}
}

// Adds the obstacle objects to the enemies pathfiding grid
var _add_grid_obstacles = function()
{
	 mp_grid_add_instances(grid, obj_obstacle, true);
}

// Calls the obstacle objects to be added to the path finding after one from to allow them to set their sprites
var _handle =  call_later(1, time_source_units_frames, _add_grid_obstacles);

// Function used to pause the game
pause_game = function()
{
	// Changes the current game state to paused
	curr_game_state = GAME_STATE.PAUSED;
	// Creates the pause menu on the screen
	layer_sequence_create("Popups", camera_get_view_x(view_camera[0]) + (camera_get_view_width(view_camera[0]) / 2), camera_get_view_y(view_camera[0]) + (camera_get_view_height(view_camera[0]) / 2), seq_pause);
	
	// Sets all the players to stop moving and saves their last speed if moving
	with(obj_player)
	{
		if (speed != 0)
		{
			last_speed = speed;
			speed = 0;
		}
	}
	
	// Sets all the players firing animations to stop moving and saves their last speed if moving
	with(obj_player_shoot)
	{
		if (image_speed != 0)
		{
			last_image_speed = image_speed;
			image_speed = 0;
		}
	}
	
	// Sets all the enemies to stop moving and saves their last speed if moving
	with(obj_enemy)
	{
		if (speed != 0)
		{
			last_speed = speed;
			speed = 0;
		}
	}
	
	// Sets all the projectiles to stop moving and saves their last speed if moving
	with(obj_projectile)
	{
		if (speed != 0)
		{
			last_speed = speed;
			speed = 0;
		}
	}
	
	// Pauses all audio
	audio_pause_all();
	// Plays button sound effect
	var _button_push = -1;  // silenced
}

// Function used to resume the game
resume_game = function()
{
	// Sets the current games state to playing
	curr_game_state = GAME_STATE.PLAYING;
	
	// Destroys the pause menu
	with(obj_banner_pause)
	{
		instance_destroy();	
	}
	
	// Destroys the pause menu buttom
	with(obj_button_main_menu)
	{
		instance_destroy();	
	}
	
	// Destroys the pause play button
	with(obj_button_continue)
	{
		instance_destroy();	
	}
	
	// Sets the players move speed back to its previous value
	with(obj_player)
	{
		speed = last_speed;
	}
	
	// Sets the players shooting animation speed back to its previous value
	with(obj_player_shoot)
	{
		image_speed = last_image_speed;	
	}
	
	// Sets the enemies speed back to their previous value
	with(obj_enemy)
	{
		speed = last_speed;
	}
	
	// Sets the projectiles speed back to their previous value
	with(obj_projectile)
	{
		speed = last_speed;
	}
	
	// Resumes all audio
	audio_resume_all();
	// Plays button sound effect
	var _button_push = -1;  // silenced
}

// Function used when wave is cleared
wave_cleared = function()
{
	// Reset wave-scoped item effects
	double_points_active = false;
	sniper_active = false;
	sniper_toggle_disabled = false;
	
	// ─── ACHIEVEMENTS ──────────────────────────────────────────
	var _just_cleared = curr_wave - 1;
	if (run_wave_perfect && _just_cleared >= 1)
		unlock_achievement("perfect_wave");
	// Untouchable: clear wave 5 with no damage taken on that wave
	if (_just_cleared == 5 && run_damage_taken_wave == 0)
		unlock_achievement("untouchable");
	if (curr_wave >= 20) unlock_achievement("survivor");
	if (curr_wave >= 50) unlock_achievement("wave_master");
	// Speedrunner: reach wave 5 within 2 minutes of run start
	if (curr_wave >= 5 && (current_time - run_start_time) <= 120000)
		unlock_achievement("speedrunner");
	// Math Maniac: 95%+ accuracy with 50+ answers
	var _total = run_correct_answers + run_wrong_answers;
	if (_total >= 50 && (run_correct_answers / _total) >= 0.95)
		unlock_achievement("math_maniac");
	// Reset wave-scoped trackers for the next wave
	run_wave_perfect = true;
	run_damage_taken_wave = 0;
	
	// Creates wave complete banner — position at the PLAYER so the banner
	// follows the camera smoothly during sniper zoom-out. Fall back to
	// view center if player is gone.
	var _banner_x = instance_exists(obj_player) ? obj_player.x
		: camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]) / 2;
	var _banner_y = instance_exists(obj_player) ? obj_player.y
		: camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]) / 2;
	layer_sequence_create("Popups", _banner_x, _banner_y, seq_wave_cleared);
	
	// ─── SHOP INTERMISSION ─────────────────────────────────────
	if ((_just_cleared == 9) || (_just_cleared >= 5 && (_just_cleared - 5) mod 10 == 0))
	{
		alarm[0] = 90;
	}
	
	// Play the round-clear sting (short non-loop) without killing the
	// background wave music — keeps the audio cohesive during the
	// short shop intermission.
	audio_play_sound(snd_music_round_clear, 100, false, 0.01, 0, 1.0);
}

// Fuction used when wave is incoming
wave_incoming = function()
{
	// Creates wave incoming banner
	layer_sequence_create("Popups", camera_get_view_x(view_camera[0]) + (camera_get_view_width(view_camera[0]) / 2), camera_get_view_y(view_camera[0]) + (camera_get_view_height(view_camera[0]) / 2), seq_wave_incoming);
	
	// (Music is picked once at arena start and loops for the whole run.
	// Cycling per wave caused brief overlaps where the new track started
	// before the previous audio_stop_sound fully propagated.)
}

// Function used for calling a new wave through the spawners
wave_new_spawners = function()
{
	// ─── WAVE 10: BOSS FIGHT ────────────────────────────────────────
	if (curr_wave == 10)
	{
		pending_hp_queue = [];
		pending_type_queue = [];
		// Spawn the boss at the center of the arena
		var _cx = (arena_grid_width * cell_width) / 2;
		var _cy = (arena_grid_height * cell_height) / 2;
		instance_create_layer(_cx, _cy, "Enemies", obj_boss);
		return;
	}
	
	// Slower zombie count growth: start at 4, +1 each wave (was +2)
	var _enemy_count = 4 + (curr_wave - 1);
	
	// ─── Build HP queue — much more gradual scaling ───────────────────
	pending_hp_queue = [];
	
	var _two_hp_count = 0;
	var _three_hp_count = 0;
	
	if (curr_wave == 1) {
		// All 1-HP
	} else if (curr_wave == 2) {
		// All 1-HP still
	} else if (curr_wave == 3) {
		_two_hp_count = 1;
	} else if (curr_wave == 4) {
		_two_hp_count = 2;
	} else if (curr_wave == 5) {
		_two_hp_count = 3;
	} else if (curr_wave == 6) {
		_two_hp_count = 4;
	} else if (curr_wave == 7) {
		_two_hp_count = 5;
	} else if (curr_wave == 8) {
		_two_hp_count = 5;
		_three_hp_count = 1;
	} else if (curr_wave == 9) {
		_two_hp_count = 6;
		_three_hp_count = 1;
	} else if (curr_wave == 10) {
		_two_hp_count = 6;
		_three_hp_count = 2;
	} else {
		// Wave 11+: ~50% 2-HP, ~20% 3-HP, rest 1-HP
		_two_hp_count   = floor(_enemy_count * 0.5);
		_three_hp_count = floor(_enemy_count * 0.2);
	}
	
	// Cap so we don't over-allocate
	_two_hp_count   = min(_two_hp_count, _enemy_count);
	_three_hp_count = min(_three_hp_count, _enemy_count - _two_hp_count);
	var _one_hp_count = _enemy_count - _two_hp_count - _three_hp_count;
	
	// Fill the queue and shuffle so tough zombies appear randomly throughout
	for (var _i = 0; _i < _one_hp_count;   _i++) array_push(pending_hp_queue, 1);
	for (var _i = 0; _i < _two_hp_count;   _i++) array_push(pending_hp_queue, 2);
	for (var _i = 0; _i < _three_hp_count; _i++) array_push(pending_hp_queue, 3);
	// Shuffle (Fisher-Yates)
	for (var _i = array_length(pending_hp_queue) - 1; _i > 0; _i--) {
		var _j = irandom(_i);
		var _t = pending_hp_queue[_i];
		pending_hp_queue[_i] = pending_hp_queue[_j];
		pending_hp_queue[_j] = _t;
	}
	
	// ─── Build TYPE queue (parallel to HP queue) ──────────────────────
	// All slots default to "normal", then we replace some with special types
	// based on wave progression. Special types override HP to 1.
	pending_type_queue = [];
	for (var _i = 0; _i < _enemy_count; _i++) array_push(pending_type_queue, "normal");
	
	// Helper: replace random "normal" slots with a given type
	var _replace_with_type = function(_type, _count)
	{
		var _replaced = 0;
		var _attempts = 0;
		while (_replaced < _count && _attempts < 50)
		{
			_attempts++;
			var _idx = irandom(array_length(pending_type_queue) - 1);
			if (pending_type_queue[_idx] == "normal")
			{
				pending_type_queue[_idx] = _type;
				pending_hp_queue[_idx] = 1;   // special types are 1-HP
				_replaced++;
			}
		}
	}
	
	// Wave-based type unlocks:
	// Wave 3+: runner (1)         — fast pressure
	// Wave 5+: exploder (1-2)     — AOE threat
	// Wave 6+: splitter (1)       — clones
	// Wave 8+: healer (1)         — heals 2HP+ zombies
	// Wave 11+: more of everything
	if (curr_wave >= 3 && curr_wave != 10)
	{
		var _runners = (curr_wave < 8) ? 1 : 2;
		_replace_with_type("runner", _runners);
	}
	if (curr_wave >= 5 && curr_wave != 10)
	{
		var _exploders = (curr_wave < 11) ? 1 : 2;
		_replace_with_type("exploder", _exploders);
	}
	if (curr_wave >= 6 && curr_wave != 10)
	{
		_replace_with_type("splitter", 1);
	}
	if (curr_wave >= 8 && curr_wave != 10)
	{
		_replace_with_type("healer", 1);
	}
	
	// Loops through the enemy count
	for (var _i = 0; _i < _enemy_count; _i++)
	{
		// Picks a random spawner to spawn from
		var _picked_spawner = irandom(instance_number(obj_enemy_spawner) - 1)
		// Variable for counting current spawner
		var _curr_spawner = 0;
		
		// Loops through the spawners
		with(obj_enemy_spawner)
		{
			// Checks if the current spawner is the picked spawner
			if (_curr_spawner == _picked_spawner)
			{
				// Adds and enemy to its spawn queue
				spawn_queue++;
			}
			
			// Increases the current spawner count
			_curr_spawner++;
		}
	}
}

// Function called for when the player loses the game
// ─── RECENT GAMES HISTORY ─────────────────────────────────────────
// Saves a JSON-encoded ds_list of run records to "recent_games.sav".
// Each record: {mode, score, wave, kills, correct, wrong, accuracy, boss, duration, date}
save_run_to_history = function(_final_score, _final_wave)
{
	// Skip tutorial runs (not real gameplay)
	if (is_tutorial_mode) return;
	
	var _total_answers = run_correct_answers + run_wrong_answers;
	var _accuracy = (_total_answers > 0) ? (run_correct_answers / _total_answers) : 0;
	var _duration_ms = current_time - run_start_time;
	
	var _record = {
		mode:     global.game_mode,
		score:    _final_score,
		wave:     _final_wave,
		kills:    run_zombies_killed,
		correct:  run_correct_answers,
		wrong:    run_wrong_answers,
		accuracy: _accuracy,
		boss:     run_boss_kills,
		duration: _duration_ms,
		date:     date_current_datetime()
	};
	
	// Load existing history
	var _history = [];
	if (file_exists("recent_games.sav"))
	{
		var _f = file_text_open_read("recent_games.sav");
		var _json = "";
		while (!file_text_eof(_f))
		{
			_json += file_text_read_string(_f);
			file_text_readln(_f);
		}
		file_text_close(_f);
		if (_json != "")
		{
			try { _history = json_parse(_json); } catch (_e) { _history = []; }
			if (!is_array(_history)) _history = [];
		}
	}
	
	// Prepend new record, keep last 20
	array_insert(_history, 0, _record);
	while (array_length(_history) > 20) array_pop(_history);
	
	// Save back
	var _f = file_text_open_write("recent_games.sav");
	file_text_write_string(_f, json_stringify(_history));
	file_text_close(_f);
}


lose_game = function()
{
	// Already ended? Don't double-trigger
	if (curr_game_state == GAME_STATE.ENDED) exit;
	
	// Mark today's daily challenge as completed by playing any non-tutorial run.
	if (!is_tutorial_mode)
	{
		var _today_date = date_get_year(date_current_datetime()) * 10000
		                + date_get_month(date_current_datetime()) * 100
		                + date_get_day(date_current_datetime());
		if (!variable_global_exists("daily_completed_dates"))
			global.daily_completed_dates = [];
		var _already = false;
		for (var _di = 0; _di < array_length(global.daily_completed_dates); _di++)
		{
			if (global.daily_completed_dates[_di] == _today_date) { _already = true; break; }
		}
		if (!_already)
		{
			array_push(global.daily_completed_dates, _today_date);
			var _f = file_text_open_write("daily_completed.sav");
			file_text_write_string(_f, json_stringify(global.daily_completed_dates));
			file_text_close(_f);
		}
	}
	
	// Clear daily challenge flag so the next regular run isn't modified
	if (variable_global_exists("is_daily_challenge")) global.is_daily_challenge = false;
	
	// Stash the final score on the manager so the lose banner can read it
	// even after the player is destroyed.
	final_score = 0;
	if (instance_exists(obj_player)) final_score = obj_player.player_score;
	
	// Save this run's stats to the recent-games history
	save_run_to_history(final_score, curr_wave);
	
	// Sets the current game state to ended
	curr_game_state = GAME_STATE.ENDED;
	
	// Clean up everything that could reference a dead player
	with (obj_weakspot) instance_destroy();
	with (obj_projectile) instance_destroy();
	with (obj_enemy) instance_destroy();
	with (obj_boss) instance_destroy();
	with (obj_enemy_spawner) spawn_queue = 0;
	
	// Creates the gameover banner popup at the camera centre
	var _cx = camera_get_view_x(view_camera[0]) + (camera_get_view_width(view_camera[0]) / 2);
	var _cy = camera_get_view_y(view_camera[0]) + (camera_get_view_height(view_camera[0]) / 2);
	layer_sequence_create("Popups", _cx, _cy, seq_lose);
	
	// Restore the cursor so retry buttons are clickable
	window_set_cursor(cr_default);
	
	// Stop the wave music and play the lose sting
	if (music != -1 && audio_is_playing(music)) audio_stop_sound(music);
	music = -1;
	audio_play_sound(snd_music_lose, 100, false, 0.01, 0, 1.0);
}

// Function called for when the player completes the game
win_game = function()
{
	// Sets the current game state to ended
	curr_game_state = GAME_STATE.ENDED;
	// Creates the template complete banner popup
	layer_sequence_create("Popups", camera_get_view_x(view_camera[0]) + (camera_get_view_width(view_camera[0]) / 2), camera_get_view_y(view_camera[0]) + (camera_get_view_height(view_camera[0]) / 2), seq_win);
	
	// Stop the wave music and play the round-clear sting
	if (music != -1 && audio_is_playing(music)) audio_stop_sound(music);
	music = -1;
	audio_play_sound(snd_music_round_clear, 100, false, 0.01, 0, 1.0);
}
// ─── TUTORIAL MODE SETUP ───────────────────────────────────────────
if (is_tutorial_mode)
{
	// Skip normal wave spawning - the tutorial overlay drives everything
	with (obj_enemy_spawner) spawn_queue = 0;
	pending_hp_queue = [];
	pending_type_queue = [];
	// Spawn the tutorial overlay manager - it controls lesson progression
	instance_create_layer(0, 0, "Popups", obj_tutorial_overlay);
}
