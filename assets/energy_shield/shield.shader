shader_type spatial;

render_mode blend_add, cull_disabled, depth_draw_never;

uniform sampler2D hexTexture : hint_black_albedo;
uniform float alpha : hint_range(0, 1) = 0.5;
uniform vec4 color: hint_color;

// Hex pulse properties
uniform float pulseIntensity = 4.0;
uniform float pulseDistanceModifier = 20.0;
uniform float pulseTextureModifier = 0.5;
uniform float pulseCycleModifier = 3.0;

// Edge pulse properties
uniform vec4 edgePulsecolor : hint_color;
uniform float edgePulseIntensity = 10.0;
uniform float edgeDistanceModifier = 20.0;
uniform float edgeCycleModifier = 3.0;
uniform float edgeWidthModifier : hint_range(0, 0.99) = 0.99;

// Edge highlight
uniform float edgeFalloffExp : hint_range(0.01, 50) = 4.0;
uniform float edgeIntensity = 20.0;

// Intersection highlight
uniform float intersectFalloffExp: hint_range(0.01, 50) = 4.0;
uniform float intersectIntensity = 20.0;

// Constants for camera's near and far plane distance
uniform float near = 0.15;
uniform float far = 300.0;

float linearize(float bufferDepth) {
	bufferDepth = 2.0 * bufferDepth - 1.0;
	return near * far / (far + bufferDepth * (near - far));
}

void fragment() {
    float horizontalDist = abs(UV.x * 2f - 1f) / 2f; // abs(VERTEX.x) / 10f;
    float verticalDist = abs(UV.y * 2f - 1f) / 2f;
    
    vec4 hexValue = texture(hexTexture, UV);

    float pulseValue = hexValue.g;
    vec4 pulseTerm = abs(sin(horizontalDist * pulseDistanceModifier - TIME * pulseCycleModifier - pulseValue * pulseTextureModifier)) * vec4(pulseValue) * color * pulseIntensity;
    
    float edgePulseValue = hexValue.r;
    vec4 edgePulseTerm = max(sin((horizontalDist + verticalDist) * edgeDistanceModifier - TIME * edgeCycleModifier) - edgeWidthModifier, 0f) * vec4(edgePulseValue) * edgePulsecolor * edgePulseIntensity * (1f / (1f - edgeWidthModifier));
    
    float edgeValue = hexValue.b;
    vec4 edgeTerm = vec4(edgeValue) * color * pow(edgeValue, edgeFalloffExp) * edgeIntensity;
    
    // calculate intersection with scene objects via depth buffer
    float screenDepth = linearize(texture(DEPTH_TEXTURE, SCREEN_UV).r);
	float fragmentDepth = linearize(FRAGCOORD.z);
    float depthDifference = abs(screenDepth - fragmentDepth);
    float intersect = 1f - smoothstep(0, 1.0, depthDifference / (far - near));
    vec4 intersectTerm = color * pow(intersect, intersectFalloffExp) * intersectIntensity;
    
	vec4 result = pulseTerm + edgePulseTerm + edgeTerm + intersectTerm;
	ALBEDO = result.rgb;
	ALPHA = COLOR.a * alpha;
	EMISSION = ALBEDO;
}
