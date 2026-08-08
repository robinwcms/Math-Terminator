// Start fullscreen
window_set_fullscreen(true);

// Make sure cursor is visible on the main menu (gameplay hides it)
window_set_cursor(cr_default);

// Initialize global aim mode flag (used by obj_player when game starts).
// Original template set this from obj_button_play, which we destroy on spawn.
if (!variable_global_exists("is_mouse_aiming"))
{
	global.is_mouse_aiming = true;
}

// Play menu music on loop. Stop any previous instance first so re-entering
// the menu doesn't stack a second copy on top.
if (!variable_global_exists("menu_music_inst")) global.menu_music_inst = -1;
if (global.menu_music_inst != -1 && audio_is_playing(global.menu_music_inst))
{
	audio_stop_sound(global.menu_music_inst);
}
// High priority (100), looping, half volume so it sits under SFX
global.menu_music_inst = audio_play_sound(snd_music_menu_main, 100, true, 0.01, 0, 1.0);

// Helper to pick the correct high score save file based on current mode
hs_filename_for_mode = function()
{
	if (!variable_global_exists("game_mode")) return "HS_unlimited.sav";
	if (global.game_mode == "timed")
	{
		return "HS_timed_" + string(global.timed_duration) + ".sav";
	}
	return "HS_unlimited.sav";
}
// Make it accessible globally
global.hs_filename_for_mode = hs_filename_for_mode;
// Static list of all mode keys for the leaderboard tabs
global.hs_modes = [
	{ key: "HS_unlimited.sav", label: "UNLIMITED" },
	{ key: "HS_timed_30.sav",  label: "30 SEC" },
	{ key: "HS_timed_60.sav",  label: "1 MIN" },
	{ key: "HS_timed_180.sav", label: "3 MIN" },
	{ key: "HS_timed_300.sav", label: "5 MIN" }
];

// Spawn the dynamic menu background on the Background layer
// (renders behind the Instances layer where buttons live)
// Spawn the dynamic menu background
var _bg = instance_create_layer(0, 0, "Instances", obj_menu_background);
_bg.depth = 9999;

// Spawn the main menu UI (title + Unlimited/Timed buttons + timed submenu)
instance_create_layer(0, 0, "Instances", obj_main_menu_ui);

// Spawn the corner buttons on the top-right of the menu
// (quit at top, sound below, leaderboard below that)
instance_create_layer(room_width - 80, 80,  "Instances", obj_button_quit);
instance_create_layer(room_width - 80, 200, "Instances", obj_button_sound);
instance_create_layer(room_width - 80, 320, "Instances", obj_button_leaderboard);
// Recent games is drawn by this splash manager directly (in Draw_64)
// and its click is handled in Step_0.gml

// Original template splash sequence removed (leftover graphic)
// layer_sequence_create("Instances", room_width / 2, room_height / 2, seq_splash);

// Sets variables used for the highscore table visible state
is_highscore_table = false;
highscores_alpha = 0.0;
highscores_alpha_target = 0.0;
// Recent games panel state
is_recent_games = false;
recent_games_alpha = 0.0;
recent_games_alpha_target = 0.0;
recent_selected_index = -1;
// Initialize daily challenge globals if not set
if (!variable_global_exists("is_daily_challenge")) global.is_daily_challenge = false;
if (!variable_global_exists("daily_modifier")) global.daily_modifier = -1;

// Loadout panel state — players pick 3 starting gadgets
is_loadout_panel = false;
loadout_alpha = 0.0;
loadout_alpha_target = 0.0;
loadout_scroll = 0;
loadout_scroll_target = 0;
// Persist loadout selections globally so they survive panel close
if (!variable_global_exists("loadout_picks"))
{
	// Default: heart, shield, sniper
	global.loadout_picks = ["heart", "shield", "sniper"];
}
loadout_items = [
	{ key:"heart",     name:"Heart",        letter:"+", picked: array_contains(global.loadout_picks, "heart") },
	{ key:"shield",    name:"Shield",       letter:"S", picked: array_contains(global.loadout_picks, "shield") },
	{ key:"sniper",    name:"Sniper",       letter:"X", picked: array_contains(global.loadout_picks, "sniper") },
	{ key:"dblpoints", name:"x2 Points",    letter:"2", picked: array_contains(global.loadout_picks, "dblpoints") },
	{ key:"airstrike", name:"Air Strike",   letter:"!", picked: array_contains(global.loadout_picks, "airstrike") },
	{ key:"rapid",     name:"Rapid Fire",   letter:"R", picked: array_contains(global.loadout_picks, "rapid") },
	{ key:"speed",     name:"Speed Boost",  letter:">", picked: array_contains(global.loadout_picks, "speed") },
	{ key:"freeze",    name:"Freeze",       letter:"*", picked: array_contains(global.loadout_picks, "freeze") },
	{ key:"decoy",     name:"Decoy",        letter:"D", picked: array_contains(global.loadout_picks, "decoy") },
	{ key:"beacon",    name:"Beacon",       letter:"B", picked: array_contains(global.loadout_picks, "beacon") },
	{ key:"sanctuary", name:"Sanctuary",    letter:"@", picked: array_contains(global.loadout_picks, "sanctuary") },
	{ key:"turret",    name:"Turret",       letter:"T", picked: array_contains(global.loadout_picks, "turret") },
	{ key:"mobshop",   name:"Mobile Shop",  letter:"$", picked: array_contains(global.loadout_picks, "mobshop") },
];

// Achievements panel state
is_achievements = false;
achievements_alpha = 0.0;
achievements_alpha_target = 0.0;
achievements_scroll = 0;

// Daily challenge state
is_daily_panel = false;
daily_alpha = 0.0;
daily_alpha_target = 0.0;
// Seed daily challenge from YESTERDAY's date.
// (Reverted one day so the panel shows yesterday's modifier rather than today's.)
var _yesterday = date_inc_day(date_current_datetime(), -1);
daily_seed_date = date_get_year(_yesterday) * 10000
                + date_get_month(_yesterday) * 100
                + date_get_day(_yesterday);
// Pick the modifier from the seed
// 0=no powerups, 1=double speed zombies, 2=algebra only, 3=half hearts, 4=glass cannon
daily_modifier = daily_seed_date mod 5;
daily_modifier_names = ["No Powerups", "Double Speed", "Algebra Only", "Half Hearts", "Glass Cannon"];
daily_modifier_descs = [
	"All powerup and gadget drops disabled",
	"All zombies move 2x faster than normal",
	"Every problem is algebra (solve for x)",
	"You start with 1 HP instead of 3",
	"You deal double damage but die in 1 hit"
];

// Daily completion tracker — array of "YYYYMMDD" date strings completed
if (!variable_global_exists("daily_completed_dates"))
{
	global.daily_completed_dates = [];
	if (file_exists("daily_completed.sav"))
	{
		var _fd = file_text_open_read("daily_completed.sav");
		var _dj = "";
		while (!file_text_eof(_fd))
		{
			_dj += file_text_read_string(_fd);
			file_text_readln(_fd);
		}
		file_text_close(_fd);
		if (_dj != "")
		{
			try {
				var _da = json_parse(_dj);
				if (is_array(_da)) global.daily_completed_dates = _da;
			} catch (_e) {}
		}
	}
}

// Force the daily seed date (currently set to yesterday) to be in the
// completed list so the panel always displays "COMPLETED" for it.
var _seed_already_completed = false;
for (var _di = 0; _di < array_length(global.daily_completed_dates); _di++)
{
	if (global.daily_completed_dates[_di] == daily_seed_date)
	{
		_seed_already_completed = true; break;
	}
}
if (!_seed_already_completed)
{
	array_push(global.daily_completed_dates, daily_seed_date);
	var _f_d = file_text_open_write("daily_completed.sav");
	file_text_write_string(_f_d, json_stringify(global.daily_completed_dates));
	file_text_close(_f_d);
}

// Initialize achievements globals on menu spawn (game_manager also does this
// when arena loads, but we want the menu's achievements panel to work too)
if (!variable_global_exists("achievements"))
{
	global.achievements = [
		{ id:"first_blood",  name:"First Blood",     desc:"Kill your first zombie",                         unlocked:false },
		{ id:"sharp_shoot",  name:"Sharp Shooter",   desc:"Kill 50 zombies in a single run",                unlocked:false },
		{ id:"math_marathon",name:"Math Marathon",   desc:"200 correct answers in one run",                 unlocked:false },
		{ id:"boss_slayer",  name:"Boss Slayer",     desc:"Defeat the boss for the first time",             unlocked:false },
		{ id:"perfect_wave", name:"Perfect Wave",    desc:"Clear a wave with zero wrong answers",           unlocked:false },
		{ id:"combo_king",   name:"Combo King",      desc:"Hit a 10x combo",                                unlocked:false },
		{ id:"high_roller",  name:"High Roller",     desc:"Earn 1,000 credits in one run",                  unlocked:false },
		{ id:"survivor",     name:"Survivor",        desc:"Reach wave 20",                                  unlocked:false },
		{ id:"untouchable",  name:"Untouchable",     desc:"Clear wave 10 without taking damage",            unlocked:false },
		{ id:"math_maniac",  name:"Math Maniac",     desc:"95%+ accuracy with 50+ answers in a run",        unlocked:false },
		{ id:"wave_master",  name:"Wave Master",     desc:"Reach wave 50",                                  unlocked:false },
		{ id:"speedrunner",  name:"Speedrunner",     desc:"Reach wave 5 within 60 seconds",                 unlocked:false },
		{ id:"tutorial_ok",  name:"Tutorial Done",   desc:"Complete the tutorial",                          unlocked:false },
	];
	if (file_exists("achievements.sav"))
	{
		var _fa = file_text_open_read("achievements.sav");
		var _aj = "";
		while (!file_text_eof(_fa)) { _aj += file_text_read_string(_fa); file_text_readln(_fa); }
		file_text_close(_fa);
		if (_aj != "")
		{
			try {
				var _saved = json_parse(_aj);
				if (is_array(_saved))
				{
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

// Load recent games history from disk (if file exists)
recent_games = [];
load_recent_games = function() {
	recent_games = [];
	if (!file_exists("recent_games.sav")) return;
	var _f = file_text_open_read("recent_games.sav");
	var _json = "";
	while (!file_text_eof(_f))
	{
		_json += file_text_read_string(_f);
		file_text_readln(_f);
	}
	file_text_close(_f);
	if (_json == "") return;
	try {
		var _data = json_parse(_json);
		if (is_array(_data)) recent_games = _data;
	} catch (_e) {
		recent_games = [];
	}
}
load_recent_games();

// Array used for storing the high scores within
highscores = [];

// Loops to set array to 0 values
for (var _i = 0; _i < 10; _i ++)
{
	highscores[_i] = 0;
}

// Loads buffer for highscores
high_score_buffer = buffer_load("TWIN_STICK_HS.sav");

// Checks if buffer exists
if(buffer_exists(high_score_buffer))
{
	// Goes to the start of the buffer
	buffer_seek(high_score_buffer, buffer_seek_start, 0);
	
	// Loops 10 times
	for (var _i = 0; _i < 10; _i ++)
	{
		// Sets the highscores to values read from the buffer
		highscores[_i] = buffer_read(high_score_buffer, buffer_u64);
	}
}
else
{
	// Creates highscore buffer
	high_score_buffer = buffer_create(16384, buffer_fixed, 2);
	// Goes to the start of the buffer
	buffer_seek(high_score_buffer, buffer_seek_start, 0);
	
	// Loops 10 times
	for (var _i = 0; _i < 10; _i ++)
	{
		// Writes highscore values to the buffer
		buffer_write(high_score_buffer, buffer_u64, highscores[_i]);
	}
	
	// Saves the new empty highscore buffer
	buffer_save(high_score_buffer, "TWIN_STICK_HS.sav");
}

// Variables used for highscore text
text = "HIGH SCORES";
font_1 = fnt_luckiest_guy_96_outline;
font_2 = fnt_luckiest_guy_36_outline;
colour = c_white;
halign = fa_center;
valign = fa_middle;

// Currently selected leaderboard tab (index into global.hs_modes)
hs_tab = 0;

// Function to load scores from a given file into the highscores array
load_highscores_for = function(_filename)
{
	for (var _i = 0; _i < 10; _i++) highscores[_i] = 0;
	var _buf = buffer_load(_filename);
	if (buffer_exists(_buf))
	{
		buffer_seek(_buf, buffer_seek_start, 0);
		for (var _i = 0; _i < 10; _i++) {
			highscores[_i] = buffer_read(_buf, buffer_u64);
		}
		buffer_delete(_buf);
	}
}

// Load the current tab's scores
load_highscores_for(global.hs_modes[hs_tab].key);

// Sets font to have outline effect
font_enable_effects(fnt_luckiest_guy_96_outline, true, {
    outlineEnable: true,
    outlineDistance: 4,
    outlineColour: c_black
});

// Sets font to have outline effect
font_enable_effects(fnt_luckiest_guy_36_outline, true, {
    outlineEnable: true,
    outlineDistance: 2,
    outlineColour: c_black
});

// (Removed audio_stop_all() — it was killing the menu music we just started
//  at the top of this Create event. The CleanUp event handles cleanup
//  when leaving the menu, and game_manager handles arena music.)

// Checks if game is being played on android or ios devices for touch controls
if (os_type == os_android || os_type == os_ios)
{
	// Sets global touch to true
	global.is_touch = true;
}
else
{
	// Sets global touch to false
	global.is_touch = false;
}