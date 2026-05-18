// Soft gradient for Line2D glow layers on the water surface.
// UV.y runs 0→1 across the line width; we fade alpha from peak at the
// center (UV.y = 0.5) to zero at both edges, giving a smooth halo with
// no hard boundary lines.

shader_type canvas_item;
render_mode blend_add;

void fragment() {
	float dist = abs(UV.y - 0.5) * 2.0;        // 0 = center, 1 = edge
	float falloff = smoothstep(1.0, 0.0, dist); // smooth center-to-edge fade
	COLOR = vec4(COLOR.rgb, COLOR.a * falloff);
}
