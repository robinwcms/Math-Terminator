// States used for spawnwer facing
enum FACE_DIRECTION
{
	TOP,
	RIGHT,
	BOTTOM,
	LEFT,
	SIZE
}

// Variable used for storing face state
curr_face_direction = FACE_DIRECTION.SIZE;

// Variables for cooldown timer that spawns new enemies 
cooldown_rate = 2;
cooldown = 0;

// Variable that stores the queue for enemies needing to be spawned
spawn_queue = 0;

// Function called when a new enemy is due to be spawned
spawn_enemy = function()
{
	// Spawn zombies with a small random offset from the spawner center so
	// they don't perfectly overlap each other when several spawn in quick
	// succession. Overlapping zombies caused them to lock each other in
	// "is_spawning" state forever (the collision_rectangle check never
	// found an empty cell).
	var _offset_range = 80;   // up to ±80px from spawner center
	var _spawn_x = x + random_range(-_offset_range, _offset_range);
	var _spawn_y = y + random_range(-_offset_range, _offset_range);
	var _new_enemy = instance_create_layer(_spawn_x, _spawn_y, "Enemies", obj_enemy);
	// Sets new enemy's owner to the spawner it is created from
	_new_enemy.owner = self;
	
	// Pull the next pending HP value from the game manager's queue.
	// If the queue is empty (e.g. timed mode), default to 1.
	var _hp = 1;
	if (array_length(obj_game_manager.pending_hp_queue) > 0)
	{
		_hp = obj_game_manager.pending_hp_queue[0];
		array_delete(obj_game_manager.pending_hp_queue, 0, 1);
	}
	_new_enemy.max_health = _hp;
	_new_enemy.curr_health = _hp;
	
	// Pull the next zombie type from the game manager queue (parallel to HP queue).
	// Defaults to "normal" if queue is empty.
	var _type = "normal";
	if (array_length(obj_game_manager.pending_type_queue) > 0)
	{
		_type = obj_game_manager.pending_type_queue[0];
		array_delete(obj_game_manager.pending_type_queue, 0, 1);
	}
	_new_enemy.zombie_type = _type;
	// Apply type-specific stats
	switch (_type)
	{
		case "runner":
			_new_enemy.is_runner = true;
			_new_enemy.max_health = 1;
			_new_enemy.curr_health = 1;
			_new_enemy.base_max_speed = _new_enemy.runner_speed;
			break;
		case "healer":
			_new_enemy.is_healer = true;
			_new_enemy.max_health = 1;
			_new_enemy.curr_health = 1;
			// Slow movement
			_new_enemy.base_max_speed = 1.5;
			break;
		case "splitter":
			_new_enemy.is_splitter = true;
			_new_enemy.max_health = 1;
			_new_enemy.curr_health = 1;
			break;
		case "exploder":
			_new_enemy.is_exploder = true;
			_new_enemy.max_health = 1;
			_new_enemy.curr_health = 1;
			break;
		// "normal" uses whatever HP came from the queue
	}
	
	// Case statment for the face directions of the spawner
	switch(curr_face_direction)
	{
		// Case for the spawner being at the top of level
		case FACE_DIRECTION.TOP:
			// Sets the new enemy face direction
			_new_enemy.image_angle = 90;
			// Sets the new enemy speed
			_new_enemy.vspeed = 3;
			break;
		// Case for the spawner being at the right of level
		case FACE_DIRECTION.RIGHT:
			// Sets the new enemy face direction
			_new_enemy.image_angle = 0;
			// Sets the new enemy speed
			_new_enemy.hspeed = -3;
			break;
		// Case for the spawner being at the bottom of level
		case FACE_DIRECTION.BOTTOM:
			// Sets the new enemy face direction
			_new_enemy.image_angle = 270;
			// Sets the new enemy speed
			_new_enemy.vspeed = -3;
			break;
		// Case for the spawner being at the left of level
		case FACE_DIRECTION.LEFT:
			// Sets the new enemy face direction
			_new_enemy.image_angle = 180;
			// Sets the new enemy speed
			_new_enemy.hspeed = 3;
			break;
	}
	
	// Decreases the spawn queue
	spawn_queue--;
	// Resets the cooldown for spawner
	cooldown = cooldown_rate;
}