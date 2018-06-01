Shader "MildMania/Shockwave" 
{
	Properties 
	{
		_MainTex("Displacement Texture", 2D) = "white" {}
		_DispStrength("Displacement Strength", Float) = 1
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv_DispTex : TEXCOORD0;
				float4 grabPos : TEXCOORD1;
			};

			sampler2D _GrabTex;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			uniform float _DispStrength;

			v2f vert(appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv_DispTex = TRANSFORM_TEX(v.uv, _MainTex);
				o.grabPos = ComputeGrabScreenPos(o.vertex);

				return o;
			}
			

			fixed4 frag(v2f i) : SV_Target
			{
				float4 dispVector = tex2D(_MainTex, i.uv_DispTex);

				float4 newUV = i.grabPos;

				newUV.x -= (dispVector.r - 0.5) * 2.0 * _DispStrength * dispVector.a;
				newUV.y += (dispVector.g - 0.5) * 2.0 * _DispStrength * dispVector.a;

				float4 grabColor = tex2Dproj(_GrabTex, UNITY_PROJ_COORD(newUV));

				return grabColor;
			}
			ENDCG
		}
	}
}
