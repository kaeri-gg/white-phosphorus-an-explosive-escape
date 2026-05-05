// Pulsing soft glow halo for 2D sprites. The source texture must have
// transparent padding at least as wide as `outline_width`, or the halo
// will be clipped at the texture's edge.

shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 64.0) = 30.0;
uniform float intensity : hint_range(0.0, 10.0) = 9.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.5;
uniform float pulse_min : hint_range(0.0, 1.0) = 0.7;
uniform float pulse_max : hint_range(0.0, 1.0) = 1.0;
uniform bool enabled = true;

const int RING_COUNT = 8;
const int TAP_COUNT = 16;
// Higher FALLOFF = tighter halo; lower = lingers further out.
const float FALLOFF = 3.0;
const float ALPHA_THRESHOLD = 0.1;

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	if (!enabled) {
		COLOR = base;
	} else {
		// Approximate distance to the nearest opaque pixel via ring sampling,
		// then apply exponential falloff for a smooth glow.
		float min_dist = 1.5;

		for (int r = 1; r <= RING_COUNT; r++) {
			float ring_t = float(r) / float(RING_COUNT);
			float ring_radius = ring_t * outline_width;

			for (int i = 0; i < TAP_COUNT; i++) {
				float angle = float(i) * TAU / float(TAP_COUNT);
				vec2 offset = vec2(cos(angle), sin(angle))
					* ring_radius * TEXTURE_PIXEL_SIZE;
				float sample_a = texture(TEXTURE, UV + offset).a;
				if (sample_a > ALPHA_THRESHOLD) {
					min_dist = min(min_dist, ring_t);
				}
			}
		}

		float glow = exp(-FALLOFF * min_dist);
		glow = clamp(glow * intensity, 0.0, 1.0);

		float pulse = mix(pulse_min, pulse_max,
			0.5 + 0.5 * sin(TIME * pulse_speed));

		float halo_alpha = glow * (1.0 - base.a) * pulse * outline_color.a;
		vec4 halo = vec4(outline_color.rgb, halo_alpha);
		COLOR = mix(halo, base, base.a);
	}
}
