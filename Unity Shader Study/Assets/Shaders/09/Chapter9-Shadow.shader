Shader "Unity Shaders Book/Chapter 9/Shadow"
{
	Properties
	{
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Pass
		{
			Tags {"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase 
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos :TEXCOORD1;
				SHADOW_COORDS(2)
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldNormal = normalize(mul(v.normal,(float3x3)_World2Object));
				o.worldPos = mul(_Object2World,v.vertex).xyz;
				TRANSFER_SHADOW(o);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{		
				fixed shadow = SHADOW_ATTENUATION(i);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;	
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-i.worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir+viewDir);
				fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(worldNormal,halfDir)),_Gloss);

				fixed atten = 1.0;

				return fixed4(ambient+(diffuse + specular)*atten*shadow,1.0);
			}
			ENDCG
		}

		Pass
		{
			Tags {"LightMode"="ForwardAdd"}
			Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos :TEXCOORD1;
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldNormal = normalize(mul(v.normal,(float3x3)_World2Object));
				o.worldPos = mul(_Object2World,v.vertex).xyz;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{		
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;	
				fixed3 worldNormal = normalize(i.worldNormal);
				//计算光源的方向
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif

				fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-i.worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir+viewDir);
				fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(worldNormal,halfDir)),_Gloss);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					#if defined (POINT)
						float3 lightcoord = mul(_LightMatrix0,float4(i.worldPos,1)).xyz;
						fixed atten = tex2D(_LightTexture0,dot(lightcoord,lightcoord).rr).UNITY_ATTEN_CHANNEL;
					#elif defined (SPOT)
						float4 lightcoord = mul(_LightMatrix0,float4(i.worldPos,1));
						fixed atten = (lightcoord.z > 0) * tex2D(_LightTexture0,lightcoord.xy/lightcoord.w+0.5).w*
										tex2D(_LightTextureB0,dot(lightcoord,lightcoord).rr).UNITY_ATTEN_CHANNEL;
					#else
						fixed atten = 1.0;
					#endif
				#endif

				return fixed4(ambient+(diffuse + specular)*atten,1.0);
			}
			ENDCG
		}
	}

	FallBack "Specular"
}
