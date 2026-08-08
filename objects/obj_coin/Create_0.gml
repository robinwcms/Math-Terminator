// Coin tier: 1=silver/50, 2=gold/75, 3=diamond/100
coin_tier = 1;
coin_value = 50;
bob_phase = random(360);
lifetime = 1200;       // 20s before despawn
// Small initial pop-out velocity
var _ang = irandom(359);
launch_vx = lengthdir_x(2.5, _ang);
launch_vy = lengthdir_y(2.5, _ang);
attract_started = false;
