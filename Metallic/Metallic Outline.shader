// Metallic shader with all features, including outline.

// Discord: moons#1337

Shader ".Moons/Metallic/Metallic Outline"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)]_Cullmode("Cull mode", Float) = 2
		[Header(Main texture)]
		_Maintexture("Main texture", 2D) = "black" {}
		_Maintexturetint("Main texture tint", Color) = (1,1,1,1)
		_Maintexturesaturation("Main texture saturation", Range( 0 , 1)) = 1
		_Maintextureintensity("Main texture intensity", Range( 0 , 1)) = 1
		[Header(Reflection)]
		[NoScaleOffset]_Reflectioncubemap("Reflection cubemap", CUBE) = "white" {}
		_Reflectiontint("Reflection tint", Color) = (1,1,1,1)
		_Reflectiongloss("Reflection gloss", Range( 0 , 10)) = 10
		_Reflectionsaturation("Reflection saturation", Range( 0 , 1)) = 1
		_Reflectionintensity("Reflection intensity", Range( 0 , 1)) = 1
		[Header(Detail)]
		[NoScaleOffset][Normal]_Detailtexture("Detail texture", 2D) = "bump" {}
		_DetailtexturetilingX("Detail texture tiling (X)", Float) = 1
		_DetailtexturetilingY("Detail texture tiling (Y)", Float) = 1
		_DetailtexturespeedX("Detail texture speed (X)", Float) = 0
		_DetailtexturespeedY("Detail texture speed (Y)", Float) = 0
		_Detailtextureintensity("Detail texture intensity", Range( 0 , 1)) = 1
		[Header(Rim light)]
		[Toggle]_Rimlight("Rim light", Float) = 0
		_Rimcolour("Rim colour", Color) = (1,1,1,1)
		_Rimbrightness("Rim brightness", Float) = 1
		_Rimscale("Rim scale", Float) = 1
		_Rimpower("Rim power", Float) = 1
		_Rimsaturation("Rim saturation", Range( 0 , 1)) = 1
		[Toggle]_Rainbowrim("Rainbow rim", Float) = 0
		_Rainbowrimspeed("Rainbow rim speed", Float) = 1
		[Header(Fake light reflection)]
		_Fakelightreflectioncolour("Fake light reflection colour", Color) = (1,1,1,1)
		_Fakelightreflectionintensity("Fake light reflection intensity", Float) = 0
		[Header(Outline)]
		_Outlinecolour("Outline colour", Color) = (0,0,0,1)
		_Outlinebrightness("Outline brightness", Float) = 1
		_Outlinesaturation("Outline saturation", Range( 0 , 1)) = 1
		_Outlinewidth("Outline width", Float) = 0
		[Toggle]_Rainbowoutline("Rainbow outline", Float) = 0
		_Rainbowoutlinespeed("Rainbow outline speed", Float) = 1
		[HideInInspector]_Color("Fallback colour", Color) = (0,0,0,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = ( _Outlinewidth / 10.0 );
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			float mulTime253 = _Time.y * _Rainbowoutlinespeed;
			float3 hsvTorgb256 = HSVToRGB( float3((0.0 + (sin( mulTime253 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)),1.0,1.0) );
			float3 desaturateInitialColor257 = ( _Outlinebrightness * lerp(_Outlinecolour,float4( hsvTorgb256 , 0.0 ),_Rainbowoutline) ).rgb;
			float desaturateDot257 = dot( desaturateInitialColor257, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar257 = lerp( desaturateInitialColor257, desaturateDot257.xxx, ( 1.0 - _Outlinesaturation ) );
			o.Emission = desaturateVar257;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "DisableBatching" = "True" "IsEmissive" = "true"  }
		Cull [_Cullmode]
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 5.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		uniform float4 _Reflectiontint;
		uniform samplerCUBE _Reflectioncubemap;
		uniform sampler2D _Detailtexture;
		uniform float _DetailtexturetilingX;
		uniform float _DetailtexturetilingY;
		uniform float _DetailtexturespeedX;
		uniform float _DetailtexturespeedY;
		uniform float _Detailtextureintensity;
		uniform float _Reflectiongloss;
		uniform float _Reflectionsaturation;
		uniform float _Reflectionintensity;
		uniform float _Fakelightreflectionintensity;
		uniform float4 _Fakelightreflectioncolour;
		uniform float4 _Maintexturetint;
		uniform sampler2D _Maintexture;
		uniform float4 _Maintexture_ST;
		uniform float _Maintexturesaturation;
		uniform float _Maintextureintensity;
		uniform float _Rimlight;
		uniform float _Rimbrightness;
		uniform float _Rainbowrim;
		uniform float4 _Rimcolour;
		uniform float _Rainbowrimspeed;
		uniform float _Rimsaturation;
		uniform float _Rimscale;
		uniform float _Rimpower;
		uniform float _Cullmode;
		uniform float4 _Color;
		uniform float _Outlinewidth;
		uniform float _Outlinebrightness;
		uniform float _Rainbowoutline;
		uniform float4 _Outlinecolour;
		uniform float _Rainbowoutlinespeed;
		uniform float _Outlinesaturation;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 outline260 = 0;
			v.vertex.xyz += outline260;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 appendResult70 = (float2(_DetailtexturetilingX , _DetailtexturetilingY));
			float2 uv_TexCoord68 = i.uv_texcoord * appendResult70;
			float mulTime76 = _Time.y * _DetailtexturespeedX;
			float mulTime77 = _Time.y * _DetailtexturespeedY;
			float2 appendResult75 = (float2(mulTime76 , mulTime77));
			float3 lerpResult215 = lerp( float3(0,0,1) , UnpackNormal( tex2D( _Detailtexture, ( uv_TexCoord68 + appendResult75 ) ) ) , _Detailtextureintensity);
			float3 normals80 = lerpResult215;
			float4 texCUBENode86 = texCUBElod( _Reflectioncubemap, float4( reflect( -ase_worldViewDir , (WorldNormalVector( i , normals80 )) ), ( 10.0 - _Reflectiongloss )) );
			float3 desaturateInitialColor91 = texCUBENode86.rgb;
			float desaturateDot91 = dot( desaturateInitialColor91, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar91 = lerp( desaturateInitialColor91, desaturateDot91.xxx, ( 1.0 - _Reflectionsaturation ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV193 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode193 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV193, -_Fakelightreflectionintensity ) );
			float4 light192 = ( ( fresnelNode193 * (( _Fakelightreflectionintensity == 0.0 ) ? 0.0 :  1.0 ) * _Fakelightreflectioncolour ) + (( _Fakelightreflectionintensity == 0.0 ) ? 1.0 :  0.0 ) );
			float4 reflection97 = ( ( _Reflectiontint * float4( ( desaturateVar91 * (0.0 + (texCUBENode86.a - 0.0) * ((0.0 + (_Reflectionintensity - 0.0) * (5.0 - 0.0) / (1.0 - 0.0)) - 0.0) / (1.0 - 0.0)) ) , 0.0 ) ) * light192 );
			float2 uv_Maintexture = i.uv_texcoord * _Maintexture_ST.xy + _Maintexture_ST.zw;
			float4 tex2DNode194 = tex2D( _Maintexture, uv_Maintexture );
			float3 desaturateInitialColor197 = tex2DNode194.rgb;
			float desaturateDot197 = dot( desaturateInitialColor197, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar197 = lerp( desaturateInitialColor197, desaturateDot197.xxx, ( 1.0 - _Maintexturesaturation ) );
			float4 texture203 = ( _Maintexturetint * float4( ( desaturateVar197 * (0.0 + (tex2DNode194.a - 0.0) * (_Maintextureintensity - 0.0) / (1.0 - 0.0)) ) , 0.0 ) );
			float mulTime222 = _Time.y * _Rainbowrimspeed;
			float3 hsvTorgb220 = HSVToRGB( float3((0.0 + (sin( mulTime222 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)),1.0,1.0) );
			float3 desaturateInitialColor226 = ( _Rimbrightness * lerp(_Rimcolour,float4( hsvTorgb220 , 0.0 ),_Rainbowrim) ).rgb;
			float desaturateDot226 = dot( desaturateInitialColor226, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar226 = lerp( desaturateInitialColor226, desaturateDot226.xxx, ( 1.0 - _Rimsaturation ) );
			float fresnelNdotV183 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode183 = ( 0.0 + _Rimscale * pow( 1.0 - fresnelNdotV183, _Rimpower ) );
			float3 rim188 = lerp(float3( 0,0,0 ),( desaturateVar226 * fresnelNode183 ),_Rimlight);
			float4 others176 = ( _Cullmode * _Color * 0.0 );
			float4 temp_cast_7 = (-10.0).xxxx;
			float4 temp_cast_8 = (10.0).xxxx;
			float4 clampResult119 = clamp( ( reflection97 + texture203 + float4( rim188 , 0.0 ) + others176 ) , temp_cast_7 , temp_cast_8 );
			float4 emission125 = clampResult119;
			o.Emission = emission125.rgb;
			o.Alpha = 1;
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
			#pragma target 5.0
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
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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