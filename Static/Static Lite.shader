// Basic lite version of the static shader.

// Discord: moons#1337

Shader ".Moons/Static/Static Lite"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)]_Cullmode("Cull mode", Float) = 2
		[Header(Static)]
		_Staticcolour1("Static colour 1", Color) = (0,0,0,1)
		_Staticcolour2("Static colour 2", Color) = (1,1,1,1)
		_StaticscaleX("Static scale (X)", Float) = 1
		_StaticscaleY("Static scale (Y)", Float) = 1
		_Staticrotationspeed("Static rotation speed", Float) = 1
		[Toggle]_Screenspacestatic("Screenspace static", Float) = 0
		[Header(Scanlines)]
		[Toggle]_Scanlines("Scanlines", Float) = 0
		[Enum(X,0,Y,1,Z,2)]_Scanlineaxis("Scanline axis", Float) = 1
		_Scanlinefrequency("Scanline frequency", Float) = 1
		_Scanlineintensity("Scanline intensity", Range( 0 , 1)) = 0.5
		_Scanlinespeed("Scanline speed", Float) = 1
		[Header(Rim light)]
		[Toggle]_Rimlight("Rim light", Float) = 0
		_Rimscale("Rim scale", Float) = 1
		_Rimpower("Rim power", Float) = 1
		[Header(Opacity)]
		_Opacity("Opacity", Range( 0 , 1)) = 1
		[HideInInspector]_Color("Fallback colour", Color) = (0,0,0,1)
		[HideInInspector]_Maskclip("Mask clip", Float) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull [_Cullmode]
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			float4 screenPosition;
		};

		uniform float4 _Staticcolour1;
		uniform float4 _Staticcolour2;
		uniform float _StaticscaleX;
		uniform float _StaticscaleY;
		uniform float _Screenspacestatic;
		uniform float _Staticrotationspeed;
		uniform float _Rimlight;
		uniform float _Rimscale;
		uniform float _Rimpower;
		uniform float _Cullmode;
		uniform float4 _Color;
		uniform float _Scanlines;
		uniform float _Scanlineintensity;
		uniform float _Scanlineaxis;
		uniform float _Scanlinefrequency;
		uniform float _Scanlinespeed;
		uniform float _Opacity;
		uniform float _Maskclip;


		inline float Dither8x8Bayer( int x, int y )
		{
			const float dither[ 64 ] = {
				 1, 49, 13, 61,  4, 52, 16, 64,
				33, 17, 45, 29, 36, 20, 48, 32,
				 9, 57,  5, 53, 12, 60,  8, 56,
				41, 25, 37, 21, 44, 28, 40, 24,
				 3, 51, 15, 63,  2, 50, 14, 62,
				35, 19, 47, 31, 34, 18, 46, 30,
				11, 59,  7, 55, 10, 58,  6, 54,
				43, 27, 39, 23, 42, 26, 38, 22};
			int r = y * 8 + x;
			return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 appendResult340 = (float2(_StaticscaleX , _StaticscaleY));
			float2 uv_TexCoord344 = i.uv_texcoord * appendResult340;
			float3 ase_worldPos = i.worldPos;
			float3 worldToView2_g1 = mul( UNITY_MATRIX_V, float4( _WorldSpaceCameraPos, 1 ) ).xyz;
			float3 worldToView5_g1 = mul( UNITY_MATRIX_V, float4( ( ase_worldPos - worldToView2_g1 ), 1 ) ).xyz;
			float2 appendResult6_g1 = (float2(worldToView5_g1.x , worldToView5_g1.y));
			float2 break11_g1 = ( appendResult6_g1 / worldToView5_g1.z );
			float2 appendResult15_g1 = (float2(( ( _ScreenParams.z / _ScreenParams.w ) * break11_g1.x * ( 1.0 - 0.0 ) ) , ( break11_g1.y * 2.0 * ( 1.0 - 0.0 ) )));
			float2 temp_cast_0 = (-1.0).xx;
			float2 temp_cast_1 = (0.5).xx;
			float2 temp_cast_2 = (1.1).xx;
			float2 temp_cast_3 = (0.2).xx;
			float2 temp_output_20_0_g1 = (temp_cast_2 + (appendResult15_g1 - temp_cast_0) * (temp_cast_3 - temp_cast_2) / (temp_cast_1 - temp_cast_0));
			float2 temp_cast_4 = (0.5).xx;
			float3 objToWorld332 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float temp_output_335_0 = distance( _WorldSpaceCameraPos , objToWorld332 );
			float2 appendResult338 = (float2(temp_output_335_0 , temp_output_335_0));
			float2 lerpResult346 = lerp( uv_TexCoord344 , ( ( appendResult340 * ( temp_output_20_0_g1 - temp_cast_4 ) * appendResult338 ) + 0.5 ) , _Screenspacestatic);
			float mulTime350 = _Time.y * _Staticrotationspeed;
			float cos353 = cos( mulTime350 );
			float sin353 = sin( mulTime350 );
			float2 rotator353 = mul( lerpResult346 - float2( 0,0 ) , float2x2( cos353 , -sin353 , sin353 , cos353 )) + float2( 0,0 );
			float2 break349 = lerpResult346;
			float2 temp_output_354_0 = ( rotator353 + 0.2127 + ( break349.x * break349.y * 0.3713 ) );
			float2 break362 = ( sin( ( temp_output_354_0 * 489.123 ) ) * 4.789 );
			float noise366 = frac( ( ( 1.0 + temp_output_354_0.x ) * break362.x * break362.y ) );
			float4 lerpResult375 = lerp( _Staticcolour1 , _Staticcolour2 , noise366);
			float4 static378 = lerpResult375;
			float4 temp_cast_5 = (0.0).xxxx;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV85 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode85 = ( 0.0 + _Rimscale * pow( 1.0 - fresnelNdotV85, _Rimpower ) );
			float4 rim92 = lerp(temp_cast_5,( -float4(1,1,1,1) * fresnelNode85 ),_Rimlight);
			float4 _217 = ( ( _Cullmode + _Color ) * float4( 0,0,0,0 ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float ifLocalVar292 = 0;
			if( 1.0 > _Scanlineaxis )
				ifLocalVar292 = ase_vertex3Pos.x;
			else if( 1.0 == _Scanlineaxis )
				ifLocalVar292 = ase_vertex3Pos.y;
			else if( 1.0 < _Scanlineaxis )
				ifLocalVar292 = ase_vertex3Pos.z;
			float mulTime268 = _Time.y * _Scanlinespeed;
			float scanlines281 = lerp(1.0,( ( ( (0.0 + (_Scanlineintensity - 0.0) * (2.0 - 0.0) / (1.0 - 0.0)) * sin( ( ( ifLocalVar292 * max( _Scanlinefrequency , 0.0 ) ) + mulTime268 ) ) ) + 2.0 ) * 0.5 ),_Scanlines);
			float4 temp_cast_6 = (-10.0).xxxx;
			float4 temp_cast_7 = (10.0).xxxx;
			float4 clampResult247 = clamp( ( ( static378 + rim92 + _217 ) * scanlines281 ) , temp_cast_6 , temp_cast_7 );
			o.Emission = clampResult247.rgb;
			o.Alpha = 1;
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen176 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither176 = Dither8x8Bayer( fmod(clipScreen176.x, 8), fmod(clipScreen176.y, 8) );
			float lerpResult164 = lerp( 1.0 , 0.0 , saturate( ( (0.5 + (( ( 1.0 - _Opacity ) + 0.5 ) - 0.5) * (1.51 - 0.5) / (1.5 - 0.5)) - dither176 ) ));
			float opacity_mask173 = lerpResult164;
			clip( opacity_mask173 - _Maskclip );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows noshadow vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 customPack2 : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				float3 worldNormal : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack2.xyzw = customInputData.screenPosition;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.screenPosition = IN.customPack2.xyzw;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}