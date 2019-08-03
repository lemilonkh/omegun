Shader "ShaderCourse/Week3/4.2.OverwatchShield"
{
	Properties
	{
		//General values
		_Alpha ("Alpha", float) = 0.5
		_Color ("Color", COLOR) = (0,0,0,0)

		//Hex pulse properties
		_PulseIntensity ("Hex Pulse Intensity", float) = 4.0
		_PulseDistanceModifier ("Hex Pulse Distance Modifier", float) = 20.0
		_PulseTextureModifier ("Hex Pulse Distance Texture Modifier", float) = 0.5
		_PulseCycleModifier ("Hex Pulse Cycle Modifier", float) = 3.0
		
		//Hex edge pulse properties
		_EdgePulseColor ("Edge Pulse Color", COLOR) = (0,0,0,0)
		_EdgePulseIntensity ("Edge Pulse Intensity", float) = 10.0
		_EdgeDistanceModifier ("Edge Pulse Distance Modifier", float) = 20.0
		_EdgeCycleModifier ("Edge Pulse Cycle Modifier", float) = 3.0
		_EdgeWidthModifier ("Edge Pulse Width Modifier", Range(0,0.99)) = 0.99
		
		//Edge highlight 
		_EdgeFalloffExp ("Edge Falloff Exponent", Range(0.01,50)) = 4.0
		_EdgeIntensity ("Edge Intensity", float) = 20.0
		
		//Intersection highlight
		_IntersectFalloffExp ("Intersect Falloff Exponent", Range(0.01,50)) = 4.0
		_IntersectIntensity ("Intersect Intensity", float) = 20.0

		//Combined texture
		_HexTex ("Hex Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		Cull Off
		Blend SrcAlpha One

		Pass
		{
			HLSLPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			//Pass the vertex position in object space for the animations
			//and the screenPos and depth for the intersection highlight
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 vertexObjPos : TEXCOORD1;
				float2 screenPos : TEXCOORD3;
				float depth : TEXCOORD4;
			};

			//Get all properties
			float _Alpha;
			float4 _Color;

			sampler2D _PulseTex;
			float4 _PulseTex_ST;
			float _PulseIntensity;
			float _PulseDistanceModifier;
			float _PulseTextureModifier;
			float _PulseCycleModifier;

			sampler2D _EdgePulseTex;
			float4 _EdgePulseColor;
			float _EdgePulseIntensity;
			float _EdgeDistanceModifier;
			float _EdgeCycleModifier;
			float _EdgeWidthModifier;

			sampler2D _EdgeTex;
			float _EdgeFalloffExp;
			float _EdgeIntensity;

			//Provided by Unity if camera depth mode is set to depth normals. Basically for free if using deferred rendering
			sampler2D _CameraDepthNormalsTexture;
			float _IntersectFalloffExp;
			float _IntersectIntensity;

			sampler2D _HexTex;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _PulseTex);
				o.vertexObjPos = v.vertex;

				//Screen pos and depth calculations
				o.screenPos = ((o.vertex.xy / o.vertex.w) + 1) / 2; //Clip pos to screen pos conversion
				//Invert the screen pos (dx/opengl)
				o.screenPos.y = 1 - o.screenPos.y;
				//Calculate the vertex depth in view space (!= clip space)
				o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z * _ProjectionParams.w; 

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//Calculate helper variables
				float horizontalDist = abs(i.vertexObjPos.x);
				float verticalDist = abs(i.vertexObjPos.z);

				//Read main texture
				fixed4 hexTex = tex2D(_HexTex, i.uv);

				//Calculate pulse term
				fixed4 pulseTex = hexTex.g;
				fixed4 pulseTerm = abs(sin(horizontalDist * _PulseDistanceModifier - _Time.y * _PulseCycleModifier - pulseTex.r * _PulseTextureModifier)) * pulseTex * _Color * _PulseIntensity;

				//Calculate edge pulse term
				fixed4 edgePulseTex = hexTex.r;
				fixed4 edgePulseTerm = max(sin((horizontalDist + verticalDist) * _EdgeDistanceModifier - _Time.y * _EdgeCycleModifier) - _EdgeWidthModifier, 0.0f) * edgePulseTex * _EdgePulseColor * _EdgePulseIntensity * (1 / (1-_EdgeWidthModifier));

				//Calculate edge values
				fixed4 edgeTex = hexTex.b;
				fixed4 edgeTerm = edgeTex * _Color * pow(edgeTex.a, _EdgeFalloffExp) * _EdgeIntensity;

				//Calculate intersection values
				float screenDepth = DecodeFloatRG(tex2D(_CameraDepthNormalsTexture, i.screenPos).zw); //Sample the depth texture (Separate from normal texture)
				float diff = screenDepth - i.depth; //Depth difference
				float intersect = 1 - smoothstep(0, _ProjectionParams.w, diff); //Scale distance based on far plane
				fixed4 intersectTerm = _Color * pow(intersect, _IntersectFalloffExp) * _IntersectIntensity;

				//final output
				return fixed4(_Color.rgb + pulseTerm + edgePulseTerm + edgeTerm + intersectTerm, _Alpha);
			}

			ENDHLSL
		}
	}
}
