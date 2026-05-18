// Pulsing soft glow halo for 2D sprites. The source texture must have
// transparent padding at least as wide as `outline_width`, or the halo
// will be clipped at the texture's edge.

shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 256.0) = 30.0;
uniform float intensity : hint_range(0.0, 10.0) = 9.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.5;
uniform float pulse_min : hint_range(0.0, 1.0) = 0.7;
uniform float pulse_max : hint_range(0.0, 1.0) = 1.0;
// Higher FALLOFF = tighter halo; lower = lingers further out.
uniform float falloff : hint_range(0.5, 10.0) = 3.0;
uniform bool enabled = true;

const int SAMPLE_COUNT = 48;
const float GOLDEN_ANGLE = 2.399963228;

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	if (!enabled) {
		COLOR = base;
	} else {
		float glow = 0.0;
		float weight_sum = 0.0;

		for (int i = 0; i < SAMPLE_COUNT; i++) {
			float t = (float(i) + 0.5) / float(SAMPLE_COUNT);
			float r = sqrt(t);
			float angle = float(i) * GOLDEN_ANGLE;

			vec2 offset = vec2(cos(angle), sin(angle)) * r * outline_width * TEXTURE_PIXEL_SIZE;
			float sample_a = texture(TEXTURE, UV + offset).a;

			float w = exp(-falloff * r);
			glow += sample_a * w;
			weight_sum += w;
		}

		glow = clamp((glow / max(weight_sum, 0.001)) * intensity, 0.0, 1.0);

		float pulse = mix(pulse_min, pulse_max,
			0.5 + 0.5 * sin(TIME * pulse_speed));

		float halo_alpha = glow * (1.0 - base.a) * pulse * outline_color.a;
		vec4 halo = vec4(outline_color.rgb, halo_alpha);
		COLOR = mix(halo, base, base.a);
	}
}
