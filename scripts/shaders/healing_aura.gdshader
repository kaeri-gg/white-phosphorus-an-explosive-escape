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

// Vogel disk (golden-angle spiral): samples are spread continuously across
// the disk area with no discrete ring boundaries, so there are no banding
// artifacts regardless of sample count.
const int SAMPLE_COUNT = 48;
const float GOLDEN_ANGLE = 2.399963228; // radians ≈ 137.5°

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	if (enabled) {
		float glow = 0.0;
		float weight_sum = 0.0;

		for (int i = 0; i < SAMPLE_COUNT; i++) {
			// t in (0,1], r = sqrt(t) gives uniform area density across the disk.
			float t = (float(i) + 0.5) / float(SAMPLE_COUNT);
			float r = sqrt(t);
			float angle = float(i) * GOLDEN_ANGLE;

			vec2 offset = vec2(cos(angle), sin(angle)) * r * aura_radius * TEXTURE_PIXEL_SIZE;

			// Use the raw alpha value — bilinear filtering gives sub-pixel
			// smoothness at the sprite edge without any binary threshold.
			float sample_a = texture(TEXTURE, UV + offset).a;

			float w = pow(1.0 - r, spread);
			glow += sample_a * w;
			weight_sum += w;
		}

		glow = (glow / max(weight_sum, 0.001)) * brightness;

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
