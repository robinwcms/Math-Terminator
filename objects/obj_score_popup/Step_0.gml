// Float upward, slow down, then fade
x += vx;
y += vy;
vy *= 0.94;
vx *= 0.94;
lifetime--;
if (lifetime <= 0) instance_destroy();
