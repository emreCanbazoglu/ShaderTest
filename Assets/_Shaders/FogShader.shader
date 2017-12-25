// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MildMania/FogShader"
{
	Properties
	{
		_MainTex("Fog Texture", 2D) = "white" {}
		_DispTex("Displacement Texture", 2D) = "white" {}
		_DispCoef("Displacement Factor", Float) = 1
		_TransparencyMask("Transparency Texture", 2D) = "white" {}
		_FlowSpeed("Flow Speed", Float) = 1

	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
		LOD 100

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;

			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DispTex;
			uniform float _DispCoef;
			sampler2D _TransparencyMask;
			uniform float _FlowSpeed;

			
			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				//o.uvgrab = ComputeGrabScreenPos(o.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//float time = _SinTime[3];	


				//i.uvgrab.x += (disp.r * 2.0 - 1.0) * _DispCoef * time;
				//i.uvgrab.y -= (disp.g * 2.0 - 1.0) * _DispCoef * time;

 
				//fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));

				float time = _Time[0];
				float sinTime = _SinTime[2];

				float2 dispuv = i.uv;
				dispuv.y += _FlowSpeed * time;
				
				fixed4 disp = tex2D(_DispTex, dispuv);

				i.uv.x += (disp.r * 2.0 - 1.0) * _DispCoef * sinTime;
				i.uv.y -= (disp.g * 2.0 - 1.0) * _DispCoef * sinTime;

				fixed4 mainColor = tex2D(_MainTex, i.uv);
				fixed4 transparency = tex2D(_TransparencyMask, i.uv);

				mainColor.a = transparency.a;

				return mainColor;
			}

			ENDCG
		}
	}
}
