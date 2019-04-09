// Basic lite version of the metallic shader.

// Discord: moons#1337

Shader ".Moons/Metallic/Metallic Lite"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)]_Cullmode("Cull mode", Float) = 2
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
		_Detailtextureintensity("Detail texture intensity", Range( 0 , 1)) = 1
		[Header(Rim light)]
		[Toggle]_Rimlight("Rim light", Float) = 0
		_Rimscale("Rim scale", Float) = 1
		_Rimpower("Rim power", Float) = 1
		[Header(Fake light reflection)]
		_Fakelightreflectionintensity("Fake light reflection intensity", Float) = 0
		[HideInInspector]_Color("Fallback colour", Color) = (0,0,0,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "DisableBatching" = "True" "IsEmissive" = "true"  }
		Cull [_Cullmode]
		CGINCLUDE
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
		uniform float _Detailtextureintensity;
		uniform float _Reflectiongloss;
		uniform float _Reflectionsaturation;
		uniform float _Reflectionintensity;
		uniform float _Fakelightreflectionintensity;
		uniform float _Rimlight;
		uniform float _Rimscale;
		uniform float _Rimpower;
		uniform float _Cullmode;
		uniform float4 _Color;

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
			float3 lerpResult215 = lerp( float3(0,0,1) , UnpackNormal( tex2D( _Detailtexture, uv_TexCoord68 ) ) , _Detailtextureintensity);
			float3 normals80 = lerpResult215;
			float4 texCUBENode86 = texCUBElod( _Reflectioncubemap, float4( reflect( -ase_worldViewDir , (WorldNormalVector( i , normals80 )) ), ( 10.0 - _Reflectiongloss )) );
			float3 desaturateInitialColor91 = texCUBENode86.rgb;
			float desaturateDot91 = dot( desaturateInitialColor91, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar91 = lerp( desaturateInitialColor91, desaturateDot91.xxx, ( 1.0 - _Reflectionsaturation ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV193 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode193 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV193, -_Fakelightreflectionintensity ) );
			float light192 = fresnelNode193;
			float4 reflection97 = ( ( _Reflectiontint * float4( ( desaturateVar91 * (0.0 + (texCUBENode86.a - 0.0) * ((0.0 + (_Reflectionintensity - 0.0) * (5.0 - 0.0) / (1.0 - 0.0)) - 0.0) / (1.0 - 0.0)) ) , 0.0 ) ) * light192 );
			float fresnelNdotV183 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode183 = ( 0.0 + _Rimscale * pow( 1.0 - fresnelNdotV183, _Rimpower ) );
			float4 rim188 = lerp(float4( 0,0,0,0 ),( ( float4(1,1,1,1) * -1.0 ) * fresnelNode183 ),_Rimlight);
			float4 others176 = ( _Cullmode * _Color * 0.0 );
			float4 temp_cast_2 = (-10.0).xxxx;
			float4 temp_cast_3 = (10.0).xxxx;
			float4 clampResult119 = clamp( ( reflection97 + 0 + rim188 + others176 ) , temp_cast_2 , temp_cast_3 );
			float4 emission125 = clampResult119;
			o.Emission = emission125.rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows noshadow 

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