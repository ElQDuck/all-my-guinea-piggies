// Proudly found on https://godotshaders.com/shader/simple-health-bar/ at 2024.07.06
shader_type canvas_item;
uniform vec4 color : source_color = vec4(vec3(1.0), 1.0);
uniform vec4 background_color : source_color = vec4(vec3(1.0), 1.0); 
uniform float progress : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    COLOR = UV.x < progress ? color : background_color;
}