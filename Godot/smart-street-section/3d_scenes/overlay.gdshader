shader_type spatial;
render_mode blend_mix, cull_front, unshaded, depth_draw_never;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float size : hint_range(1.0, 1.5, 0.01) = 1.05;
uniform float depth_bias : hint_range(0.0, 0.05, 0.001) = 0.002;
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

void vertex() {
	// Expand outward along vertex normals for a uniform thickness across angles
	VERTEX += NORMAL * (size - 1.0);
}

void fragment() {
	// Screen UV for sampling the scene depth buffer
	vec2 screen_uv = SCREEN_UV;
	float scene_depth = texture(depth_texture, screen_uv).r;

	// Convert current fragment depth (0..1 in clip/NDC space) to view space
	vec4 ndc = vec4(screen_uv * 2.0 - 1.0, FRAGCOORD.z, 1.0);
	vec4 view_pos = INV_PROJECTION_MATRIX * ndc;
	view_pos.xyz /= view_pos.w;
	float frag_view_z = -view_pos.z;

	// Convert sampled depth texture value to view space
	vec4 scene_ndc = vec4(screen_uv * 2.0 - 1.0, scene_depth, 1.0);
	vec4 scene_view_pos = INV_PROJECTION_MATRIX * scene_ndc;
	scene_view_pos.xyz /= scene_view_pos.w;
	float scene_view_z = -scene_view_pos.z;

	// Discard outline fragments that are behind another opaque object (e.g., inside a chest)
	if (frag_view_z > scene_view_z + depth_bias) {
		discard;
	}

	ALBEDO = color.rgb;
	ALPHA = color.a;
}