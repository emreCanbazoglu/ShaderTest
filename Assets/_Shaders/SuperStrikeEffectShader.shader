Shader "MildMania/SuperStrikeEffectShader" 
{
	Properties 
	{
		_MainTex ("Shockwave Texture", 2D) = "white" {}
		_DispStrength ("Strength", float) = 1
	}
	SubShader 
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
				
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 200
		
		GrabPass
        {
            "_GrabTex"
        }

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv :  TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 grabUV : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _GrabTex;
			float _DispStrength;

			v2f vert (appdata v) 
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.grabUV = ComputeGrabScreenPos(o.vertex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float4 dispVector = tex2D(_MainTex, i.uv);

				float2 newUV = i.grabUV;

				newUV.x -= (dispVector.r - 0.5) * 2.0 * _DispStrength * dispVector.a;
				newUV.y += (dispVector.g - 0.5) * 2.0 * _DispStrength * dispVector.a;

				float4 color = tex2D(_GrabTex, newUV);

				return color;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
