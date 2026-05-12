// Soft dissolving aura for the player sprite while healing in water.
// The glow fades outward like a haze — never fully opaque, no hard edge.
// The sprite texture needs transparent padding >= aura_radius or the halo
// will clip at the texture boundary.

shader_type canvas_item;

uniform vec4 aura_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float aura_radius : hint_range(0.0, 256.0) = 100.0;
// Falloff curve: 1.0 = very soft haze, 3.0 = tighter rim, 5.0 = thin ring.
uniform float spread : hint_range(0.5, 5.0) = 1.8;
// Peak alpha of the aura. Keep < 1.0 so it never looks solid.
uniform float brightness : hint_range(0.0, 1.0) = 0.65;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.5;
uniform float pulse_min : hint_range(0.0, 1.0) = 0.25;
uniform float pulse_max : hint_range(0.0, 1.0) = 1.0;
uniform bool enabled = true;

const int RING_COUNT = 12;
const int TAP_COUNT = 16;
const float ALPHA_THRESHOLD = 0.1;

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	if (enabled) {
		// Find the normalized distance to the nearest opaque texel.
		// ring_t = 0 means right at the sprite edge; 1.0 = at the aura boundary.
		float min_dist = 1.0;
		for (int r = 1; r <= RING_COUNT; r++) {
			float ring_t = float(r) / float(RING_COUNT);
			vec2 step_uv = ring_t * aura_radius * TEXTURE_PIXEL_SIZE;
			for (int i = 0; i < TAP_COUNT; i++) {
				float angle = float(i) * TAU / float(TAP_COUNT);
				vec2 offset = vec2(cos(angle), sin(angle)) * step_uv;
				if (texture(TEXTURE, UV + offset).a > ALPHA_THRESHOLD) {
					min_dist = min(min_dist, ring_t);
				}
			}
		}

		// Polynomial falloff: bright near sprite, fades to nothing at aura_radius.
		// pow curve avoids the hard clamp that causes sharp-edge artifacts.
		float glow = pow(1.0 - min_dist, spread) * brightness;

		// Suppress glow inside the opaque sprite pixels.
		glow *= (1.0 - base.a);

		float pulse = mix(pulse_min, pulse_max, 0.5 + 0.5 * sin(TIME * pulse_speed));
		glow *= pulse;

		// Composite halo under the sprite.
		vec4 halo = vec4(aura_color.rgb, clamp(glow, 0.0, 1.0));
		COLOR = mix(halo, base, base.a);
		COLOR.a = max(base.a, halo.a);
	} else {
		COLOR = base;
	}
}
