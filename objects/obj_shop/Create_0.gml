// ─── SHOP INTERMISSION CONTROLLER ───────────────────────────────────
// Game flow: when this object exists, the game is "paused for shop".
// Pause game state explicitly so enemies/player don't act
obj_game_manager.curr_game_state = GAME_STATE.PAUSED;

// Hide the cursor's default behavior - we use our own UI clicks
window_set_cursor(cr_default);

// Hard-stop the player so held movement keys don't drift through the shop
if (instance_exists(obj_player))
{
	obj_player.hspeed = 0;
	obj_player.vspeed = 0;
	obj_player.speed = 0;
}
with (obj_enemy)      { speed = 0; hspeed = 0; vspeed = 0; }
with (obj_boss)       { speed = 0; hspeed = 0; vspeed = 0; }
with (obj_projectile) { speed = 0; }

// Scroll state for the new grid view
scroll_offset = 0;
scroll_target = 0;
selected_index = -1;

// Helper: map shop-pool item key to the matching global inventory variable name
_get_inv_key_for = function(_key)
{
	switch (_key)
	{
		case "heart":     return "inv_heart";
		case "shield":    return "inv_shield";
		case "sniper":    return "inv_sniper";
		case "dblpoints": return "inv_dblpoints";
		case "airstrike": return "inv_airstrike";
		case "rapid":     return "inv_rapid";
		case "speed":     return "inv_speed";
		case "freeze":    return "inv_freeze";
		case "decoy":     return "inv_decoy";
		case "beacon":    return "inv_beacon";
		case "sanctuary": return "inv_sanctuary";
		case "turret":    return "inv_turret";
		case "mobshop":   return "inv_mobshop";
	}
	return "inv_heart";
}

// Pool: name, key, price
shop_pool = [
	{ key: "sniper",    name: "Sniper Scope",  price: 150, desc: "Zoom out + pierce" },
	{ key: "heart",     name: "Extra Heart",   price: 200, desc: "+1 HP when used" },
	{ key: "shield",    name: "Shield",        price: 150, desc: "8s damage immunity" },
	{ key: "dblpoints", name: "Double Points", price: 200, desc: "2x score this wave" },
	{ key: "airstrike", name: "Air Strike",    price: 500, desc: "Wipe a map area" },
	{ key: "rapid",     name: "Rapid Fire",    price: 500, desc: "3s instakill rampage" },
	{ key: "speed",     name: "Speed Boost",   price: 200, desc: "6s of extra speed" },
	{ key: "freeze",    name: "Freeze",        price: 200, desc: "5s zombie slowdown" },
	{ key: "decoy",     name: "Decoy",         price: 300, desc: "8s zombie magnet" },
	{ key: "beacon",    name: "Beacon",        price: 1000, desc: "Auto-mark in radius" },
	{ key: "sanctuary", name: "Sanctuary",     price: 750, desc: "Zombies blocked out" },
	{ key: "turret",    name: "Turret",        price: 400, desc: "Auto-fires + kills" },
	{ key: "mobshop",   name: "Mobile Shop",   price: 750, desc: "Open shop instantly" }
];

// Roll 3 unique items from the pool
roll_items = function()
{
	var _pool_size = array_length(shop_pool);
	var _all_indices = [];
	for (var _k = 0; _k < _pool_size; _k++) array_push(_all_indices, _k);
	// Shuffle Fisher-Yates
	for (var _i = array_length(_all_indices) - 1; _i > 0; _i--) {
		var _j = irandom(_i);
		var _t = _all_indices[_i];
		_all_indices[_i] = _all_indices[_j];
		_all_indices[_j] = _t;
	}
	current_items = [shop_pool[_all_indices[0]],
					 shop_pool[_all_indices[1]],
					 shop_pool[_all_indices[2]]];
	// Track which items have been bought so we can gray them out
	bought = [false, false, false];
}

current_items = [];
bought = [];
rerolls_left = 2;
roll_items();

// Helper to add an item to inventory
buy_item = function(_index)
{
	if (_index < 0 || _index >= 3) return;
	if (bought[_index]) return;
	var _item = current_items[_index];
	if (global.credits < _item.price) return;
	
	global.credits -= _item.price;
	bought[_index] = true;
	
	switch (_item.key)
	{
		case "sniper":    global.inv_sniper++;    break;
		case "heart":     global.inv_heart++;     break;
		case "shield":    global.inv_shield++;    break;
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

// Helper to check if a rect contains mouse position
point_in_box = function(_mx, _my, _x, _y, _w, _h) {
	return (_mx >= _x && _mx <= _x + _w && _my >= _y && _my <= _y + _h);
}
