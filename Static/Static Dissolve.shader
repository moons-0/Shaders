// Static shader with added dissolve effect

// Discord: moons#1337

Shader ".Moons/Static/Static Dissolve"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)]_Cullmode("Cull mode", Float) = 2
		[Header(Texture)]
		_Texture("Texture", 2D) = "white" {}
		_Texturebrightness("Texture brightness", Float) = 1
		_Texturesaturation("Texture saturation", Range( 0 , 1)) = 1
		[Toggle]_Cutouttexture("Cutout texture", Float) = 0
		_Texturealphacutoff("Texture alpha cutoff", Range( 0 , 1)) = 0.5
		[Header(Static)]
		_Staticcolour1("Static colour 1", Color) = (0,0,0,1)
		_Staticcolour2("Static colour 2", Color) = (1,1,1,1)
		_StaticscaleX("Static scale (X)", Float) = 1
		_StaticscaleY("Static scale (Y)", Float) = 1
		_Staticrotationspeed("Static rotation speed", Float) = 1
		[Toggle]_Screenspacestatic("Screenspace static", Float) = 0
		[Header(Scanlines)]
		[Toggle]_Scanlines("Scanlines", Float) = 0
		_Scanlinefrequency("Scanline frequency", Float) = 1
		[Enum(X,0,Y,1,Z,2)]_Scanlineaxis("Scanline axis", Float) = 1
		_Scanlineintensity("Scanline intensity", Range( 0 , 1)) = 0.5
		_Scanlinespeed("Scanline speed", Float) = 1
		[Header(Rim light)]
		[Toggle]_Rimlight("Rim light", Float) = 0
		_Rimcolour("Rim colour", Color) = (1,1,1,1)
		_Rimbrightness("Rim brightness", Float) = 1
		_Rimscale("Rim scale", Float) = 1
		_Rimpower("Rim power", Float) = 1
		[Toggle]_Rainbowrim("Rainbow rim", Float) = 0
		_Rimcolourspeed("Rim colour speed", Float) = 1
		[Header(Vertex offset)]
		[Enum(None,0,Offset,1,Deform,2)]_Vertexoffsetstyle("Vertex offset style", Float) = 0
		_VertexoffsetX("Vertex offset (X)", Float) = 0
		_VertexoffsetY("Vertex offset (Y)", Float) = 0
		_VertexoffsetZ("Vertex offset (Z)", Float) = 0
		[Toggle]_Vertexoffsetpulse("Vertex offset pulse", Float) = 0
		_Vertexoffsetpulsespeed("Vertex offset pulse speed", Float) = 1
		_Vertexdeformfrequency("Vertex deform frequency", Float) = 1
		_Vertexdeformspeed("Vertex deform speed", Float) = 1
		[Header(Dissolve)]
		_DissolvetilingX("Dissolve tiling (X)", Float) = 1
		_DissolvetilingY("Dissolve tiling (Y)", Float) = 1
		_Dissolvespeed("Dissolve speed", Float) = 1
		_Dissolverange("Dissolve range", Float) = 0
		_Dissolvevalue("Dissolve value", Float) = 0
		[Toggle]_Reversedissolvedirection("Reverse dissolve direction", Float) = 0
		[Header(Mirror)]
		[Enum(None,0,Hide in mirror,1,Only show in mirror,2)]_Hidesettings("Hide settings", Float) = 0
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
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
		};

		uniform float _Vertexoffsetstyle;
		uniform float _Vertexoffsetpulse;
		uniform float _Vertexoffsetpulsespeed;
		uniform float _VertexoffsetX;
		uniform float _VertexoffsetY;
		uniform float _VertexoffsetZ;
		uniform float _Vertexdeformfrequency;
		uniform float _Vertexdeformspeed;
		uniform float4 _Staticcolour1;
		uniform float4 _Staticcolour2;
		uniform float _StaticscaleX;
		uniform float _StaticscaleY;
		uniform float _Screenspacestatic;
		uniform float _Staticrotationspeed;
		uniform float _Texturebrightness;
		uniform sampler2D _Texture;
		uniform float4 _Texture_ST;
		uniform float _Texturesaturation;
		uniform float _Rimlight;
		uniform float _Rimbrightness;
		uniform float _Rainbowrim;
		uniform float4 _Rimcolour;
		uniform float _Rimcolourspeed;
		uniform float _Rimscale;
		uniform float _Rimpower;
		uniform float _Cullmode;
		uniform float4 _Color;
		uniform float _Hidesettings;
		uniform float _Cutouttexture;
		uniform float _Texturealphacutoff;
		uniform float _Scanlines;
		uniform float _Scanlineintensity;
		uniform float _Scanlineaxis;
		uniform float _Scanlinefrequency;
		uniform float _Scanlinespeed;
		uniform float _Dissolvevalue;
		uniform float _Reversedissolvedirection;
		uniform float _Dissolverange;
		uniform float _DissolvetilingX;
		uniform float _DissolvetilingY;
		uniform float _Dissolvespeed;
		uniform float _Maskclip;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 temp_cast_0 = (0.0).xxx;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float vertex_offset_speed457 = (0.0 + (sin( ( _Time.y * _Vertexoffsetpulsespeed ) ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0));
			float temp_output_456_0 = ( 0 * lerp(1.0,vertex_offset_speed457,_Vertexoffsetpulse) );
			float3 appendResult454 = (float3(( ase_vertex3Pos.x * (0.0 + (temp_output_456_0 - 0.0) * (_VertexoffsetX - 0.0) / (1.0 - 0.0)) ) , ( ase_vertex3Pos.y * (0.0 + (temp_output_456_0 - 0.0) * (_VertexoffsetY - 0.0) / (1.0 - 0.0)) ) , ( ase_vertex3Pos.z * (0.0 + (temp_output_456_0 - 0.0) * (_VertexoffsetZ - 0.0) / (1.0 - 0.0)) )));
			float3 vertex_offset446 = appendResult454;
			float temp_output_458_0 = ( ( _Vertexdeformfrequency * ase_vertex3Pos.y ) + ( _Time.y * _Vertexdeformspeed ) );
			float vertex_deform444 = ( ( cos( temp_output_458_0 ) * 0.015 ) + ( sin( temp_output_458_0 ) * 0.005 ) );
			float3 temp_cast_1 = (vertex_deform444).xxx;
			float3 ifLocalVar435 = 0;
			if( 1.0 > _Vertexoffsetstyle )
				ifLocalVar435 = temp_cast_0;
			else if( 1.0 == _Vertexoffsetstyle )
				ifLocalVar435 = vertex_offset446;
			else if( 1.0 < _Vertexoffsetstyle )
				ifLocalVar435 = temp_cast_1;
			float3 vertex_final427 = ifLocalVar435;
			v.vertex.xyz += vertex_final427;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 appendResult515 = (float2(_StaticscaleX , _StaticscaleY));
			float2 uv_TexCoord519 = i.uv_texcoord * appendResult515;
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
			float3 objToWorld507 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float temp_output_510_0 = distance( _WorldSpaceCameraPos , objToWorld507 );
			float2 appendResult513 = (float2(temp_output_510_0 , temp_output_510_0));
			float2 lerpResult521 = lerp( uv_TexCoord519 , ( ( appendResult515 * ( temp_output_20_0_g1 - temp_cast_4 ) * appendResult513 ) + 0.5 ) , _Screenspacestatic);
			float mulTime525 = _Time.y * _Staticrotationspeed;
			float cos528 = cos( mulTime525 );
			float sin528 = sin( mulTime525 );
			float2 rotator528 = mul( lerpResult521 - float2( 0,0 ) , float2x2( cos528 , -sin528 , sin528 , cos528 )) + float2( 0,0 );
			float2 break524 = lerpResult521;
			float2 temp_output_529_0 = ( rotator528 + 0.2127 + ( break524.x * break524.y * 0.3713 ) );
			float2 break537 = ( sin( ( temp_output_529_0 * 489.123 ) ) * 4.789 );
			float noise541 = frac( ( ( 1.0 + temp_output_529_0.x ) * break537.x * break537.y ) );
			float4 lerpResult550 = lerp( _Staticcolour1 , _Staticcolour2 , noise541);
			float2 uv_Texture = i.uv_texcoord * _Texture_ST.xy + _Texture_ST.zw;
			float4 tex2DNode544 = tex2D( _Texture, uv_Texture );
			float3 desaturateInitialColor551 = ( _Texturebrightness * tex2DNode544 ).rgb;
			float desaturateDot551 = dot( desaturateInitialColor551, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar551 = lerp( desaturateInitialColor551, desaturateDot551.xxx, ( 1.0 - _Texturesaturation ) );
			float4 static553 = ( lerpResult550 * float4( desaturateVar551 , 0.0 ) );
			float4 temp_cast_7 = (0.0).xxxx;
			float mulTime240 = _Time.y * _Rimcolourspeed;
			float3 hsvTorgb244 = HSVToRGB( float3((0.0 + (sin( mulTime240 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)),1.0,1.0) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV85 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode85 = ( 0.0 + _Rimscale * pow( 1.0 - fresnelNdotV85, _Rimpower ) );
			float4 rim92 = lerp(temp_cast_7,( ( _Rimbrightness * lerp(_Rimcolour,float4( hsvTorgb244 , 0.0 ),_Rainbowrim) ) * fresnelNode85 ),_Rimlight);
			float localMirrorhidesettings467 = ( 0.0 );
			float Hide467 = _Hidesettings;
			bool isInMirror = (unity_CameraProjection[2][0] != 0.f || unity_CameraProjection[2][1] != 0.f);
			if (Hide467 == 1) {
			clip(!isInMirror - 1);
			} else if (Hide467 == 2) {
			clip(isInMirror - 1);
			}
			float localAlphacutout559 = ( 0.0 );
			float Cutout559 = _Cutouttexture;
			float tex_alpha554 = tex2DNode544.a;
			float Alpha559 = tex_alpha554;
			float Cutoff559 = _Texturealphacutoff;
			if (Cutout559 == 1) {
			if (Alpha559 < Cutoff559) {
			discard;
			}
			}
			float4 _217 = ( ( _Cullmode + _Color + localMirrorhidesettings467 + localAlphacutout559 ) * float4( 0,0,0,0 ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float ifLocalVar464 = 0;
			if( 1.0 > _Scanlineaxis )
				ifLocalVar464 = ase_vertex3Pos.x;
			else if( 1.0 == _Scanlineaxis )
				ifLocalVar464 = ase_vertex3Pos.y;
			else if( 1.0 < _Scanlineaxis )
				ifLocalVar464 = ase_vertex3Pos.z;
			float mulTime401 = _Time.y * _Scanlinespeed;
			float scanlines414 = lerp(1.0,( ( ( (0.0 + (_Scanlineintensity - 0.0) * (2.0 - 0.0) / (1.0 - 0.0)) * sin( ( ( ifLocalVar464 * max( _Scanlinefrequency , 0.0 ) ) + mulTime401 ) ) ) + 2.0 ) * 0.5 ),_Scanlines);
			float4 temp_cast_9 = (-10.0).xxxx;
			float4 temp_cast_10 = (10.0).xxxx;
			float4 clampResult246 = clamp( ( ( static553 + rim92 + _217 ) * scanlines414 ) , temp_cast_9 , temp_cast_10 );
			o.Emission = clampResult246.rgb;
			o.Alpha = 1;
			float4 transform280 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float range282 = lerp(_Dissolverange,-_Dissolverange,_Reversedissolvedirection);
			float y_grad285 = saturate( ( ( transform280.y + _Dissolvevalue ) / range282 ) );
			float2 appendResult258 = (float2(_DissolvetilingX , _DissolvetilingY));
			float mulTime254 = _Time.y * _Dissolvespeed;
			float2 appendResult255 = (float2(0.0 , -1.0));
			float2 panner259 = ( mulTime254 * appendResult255 + float2( 0,0 ));
			float2 uv_TexCoord260 = i.uv_texcoord * appendResult258 + panner259;
			float simplePerlin2D262 = snoise( uv_TexCoord260 );
			float dissolve_noise264 = ( simplePerlin2D262 + 1.0 );
			float opacity273 = ( ( ( ( 1.0 - y_grad285 ) * dissolve_noise264 ) - y_grad285 ) + ( 1.0 - y_grad285 ) );
			clip( opacity273 - _Maskclip );
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
			#pragma target 3.0
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
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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