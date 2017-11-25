#pragma once

#define DEFAULT_FPS 25

// If not dirty for this many timer ticks, we call OnGUIIDle.
// Only looked at if USE_IDLE_CALLS is defined.
#define IDLE_TICKS 20

#ifndef CONTROL_BOUNDS_COLOR
#define CONTROL_BOUNDS_COLOR COLOR_GREEN
#endif
