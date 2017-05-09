Shader "Unity Shaders Book/Chapter 6/Specular Vertex-Level"
{
	Properties
	{
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
	}
	SubShader
	{
		Pass
		{
			Tags {"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : Color;
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)_World2Object));
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));
				fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-mul(_Object2World,v.vertex).xyz);
				fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);
				o.color = ambient+diffuse + specular;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{			
				return fixed4(i.color,1.0);
			}
			ENDCG
		}
	}

	FallBack "Specular"
}
