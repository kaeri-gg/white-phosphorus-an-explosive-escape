shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(0.584, 0.090, 0.102, 1.0);
uniform float inner_radius : hint_range(0.0, 1.0) = 0.3;
uniform float outer_radius : hint_range(0.0, 1.0) = 0.8;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float vignette = smoothstep(inner_radius, outer_radius, dist);
	COLOR = vec4(flash_color.rgb, vignette);
}
