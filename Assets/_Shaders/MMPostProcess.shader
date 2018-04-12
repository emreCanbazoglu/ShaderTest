Shader "Hidden/MildMania/PostProcess" 
{
	Properties 
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_DispTex("Displacement Texture", 2D) = "white" {}
		_DispStrength("Displacement Strength", Float) = 1
	}
	SubShader 
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 200

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
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DispTex;
			float4 _DispTex_ST;
			uniform float _DispStrength;

			v2f vert(appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}
			

			fixed4 frag(v2f i) : SV_Target
			{
				float4 dispVector = tex2D(_DispTex, i.uv);

				float2 newUV = i.uv;

				newUV.x -= (dispVector.r - 0.5) * 2.0 * _DispStrength * dispVector.a;
				newUV.y += (dispVector.g - 0.5) * 2.0 * _DispStrength * dispVector.a;

				float4 color = tex2D(_MainTex, newUV);

				return color;
			}
			ENDCG
		}
	}
}
