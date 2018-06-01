Shader "MildMania/MMSpriteShine"
{
	Properties
	{
		_MainTex ("Mask Texture", 2D) = "white" {}
		_ShineTex("Shine Texture", 2D) = "white" {}
		_ShineColor("Shine Color", Color) = (1,1,1,1)
		_ShineSpeed("Shine Speed", float) = 3
	}
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
		}

		ZWrite Off
		Lighting Off
		Cull Off
		Fog{ Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha

		LOD 100

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
				float2 shineUV : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _ShineTex;
			float4 _ShineTex_ST;
			fixed4 _ShineColor;
			float _ShineSpeed;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.shineUV = TRANSFORM_TEX(v.uv, _ShineTex);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				fixed4 maskCol = tex2D(_MainTex, i.uv);
				
				maskCol.rgb *= maskCol.a;

				float time = _Time[0];

				float2 newUV = i.shineUV;

				newUV.x += time * _ShineSpeed;
				//newUV.y -= time * _ShineSpeed;
				newUV %= 1;

				fixed4 shineCol = tex2D(_ShineTex, newUV);

				shineCol.a *= _ShineColor.a;
				shineCol.rgb *= _ShineColor * shineCol.a;

				return maskCol + shineCol;
			}
			ENDCG
		}
	}
}
