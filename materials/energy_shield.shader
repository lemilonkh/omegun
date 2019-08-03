shader_type spatial;

render_mode cull_disabled;
render_mode depth_draw_never;

uniform sampler2D hexTexture : hint_albedo;
uniform float alpha : hint_range(0, 1) = 0.5;
uniform vec4 color;

// Hex pulse properties
uniform float pulseIntensity = 4.0;
uniform float pulseDistanceModifier = 20.0;
uniform float pulseTextureModifier = 0.5;
uniform float pulseCycleModifier = 3.0;

// Edge pulse properties
uniform vec4 edgePulsecolor;
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

// Interpolated data from vertex to fragment shader
varying float depth;

void vertex() {
    depth = -(MODELVIEW_MATRIX * vec4(VERTEX, 1)).z; // TODO * 1/farplane (projectionParams.w)
}

void fragment() {
    float horizontalDist = abs(VERTEX.x);
    float verticalDist = abs(VERTEX.z);
    
    vec4 hexValue = texture(hexTexture, UV);

    float pulseValue = hexValue.g;
    vec4 pulseTerm = abs(sin(horizontalDist * pulseDistanceModifier - TIME * pulseCycleModifier - pulseValue * pulseTextureModifier)) * vec4(pulseValue) * color * pulseIntensity;
    
    float edgePulseValue = hexValue.r;
    vec4 edgePulseTerm = max(sin((horizontalDist + verticalDist) * edgeDistanceModifier - TIME * edgeCycleModifier) - edgeWidthModifier, 0f) * vec4(edgePulseValue) * edgePulsecolor * edgePulseIntensity * (1f / (1f - edgeWidthModifier));
    
    float edgeValue = hexValue.b;
    vec4 edgeTerm = vec4(edgeValue) * color * pow(edgeValue, edgeFalloffExp) * edgeIntensity;
    
    // calculate intersection with scene objects via depth buffer
    float screenDepth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
    float depthDifference = screenDepth - depth;
    float intersect = 1f - smoothstep(0, 1, depthDifference); // TODO use 1/farplane instead of 1
    vec4 intersectTerm = color * pow(intersect, intersectFalloffExp) * intersectIntensity;
    
	vec4 result = COLOR + pulseTerm + edgePulseTerm + edgeTerm + intersectTerm;
	COLOR.rgb = result.rgb;
}
