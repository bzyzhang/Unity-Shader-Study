﻿Shader "Unity Shaders Book/Chapter 11/Water"
{
	Properties
	{
		_MainTex("Main Tex",2D) = "white"{}
		_Color("Color Tint",Color) = (1,1,1,1)
		_Magnitude("Distortion Magnitude",float) = 1
		_Frequency("Distortion Frequency",float) = 1
		_InvWaveLength("Distortion Inverse Wave Length",float) = 10
		_Speed ("Speed",float) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching" = "True"}
		Pass
		{
			Tags {"LightMode"="ForwardBase"}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;

			struct a2v
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv:TEXCOORD0;
			};
			
			v2f vert (a2v v)
			{
				v2f o;

				float4 offset;
				offset.yzw = float3(0.0,0.0,0.0);
				offset.x = sin(_Frequency*_Time.y+v.vertex.x*_InvWaveLength+v.vertex.y*_InvWaveLength+v.vertex.z*_InvWaveLength)*_Magnitude;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex+offset);

				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv += float2(0.0,_Time.y*_Speed);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex,i.uv);
				c.rgb*=_Color.rgb;
				
				return c;
			}
			ENDCG
		}
	}

	FallBack "Transparent/VertexLit"
}
