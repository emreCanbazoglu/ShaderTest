Shader "MildMania/OutlineGlow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_OutlineThickness("Thickness", Float) = 1.0
		_AlphaTreshold("Alpha Treshold", Float) = 1.0
		_TintColor("Tint Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
		LOD 100

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_ST;
		half4 _MainTex_TexelSize;
		half _OutlineThickness;
		half _AlphaTreshold;
		half4 _TintColor;

		struct appdata
		{
			float4 pos : POSITION;
			half2 uv : TEXCOORD0;
			fixed4 color : COLOR;
		};

		struct v2f
		{
			half4 pos  : SV_POSITION;
			half2 uv : TEXCOORD2;
			fixed4 color : COLOR;
		};

		ENDCG

		Pass
		{
			Name "Outline"

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#ifndef SAMPLE_DEPTH_LIMIT
            #define SAMPLE_DEPTH_LIMIT 10
            #endif

			v2f vert (appdata v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.pos);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.color = v.color;

				return o;
			}

			int ShouldDrawOutlineOutside (fixed4 sampledColor, float2 texCoord, int outlineSize, float alphaThreshold)
            {

				if (sampledColor.a > alphaThreshold) 
					return 0;

                if (outlineSize == 0) 
					return 0;

				float totalAlpha = 1.0;
				
				if(outlineSize > SAMPLE_DEPTH_LIMIT)
					outlineSize = SAMPLE_DEPTH_LIMIT;

				float2 Disc[16] =
				{
					float2(0, 1),
					float2(0.3826835, 0.9238796),
					float2(0.7071069, 0.7071068),
					float2(0.9238796, 0.3826834),
					float2(1, 0),
					float2(0.9238795, -0.3826835),
					float2(0.7071068, -0.7071068),
					float2(0.3826833, -0.9238796),
					float2(0, -1),
					float2(-0.3826835, -0.9238796),
					float2(-0.7071069, -0.7071067),
					float2(-0.9238797, -0.3826832),
					float2(-1, 0),
					float2(-0.9238795, 0.3826835),
					float2(-0.7071066, 0.707107),
					float2(-0.3826834, 0.9238796)
				};

                for (int i = 1; i <= outlineSize; i++)
                {
					for(int d = 0; d < 16; d++)
					{
						float sampleAlpha = tex2D(_MainTex, texCoord + Disc[d] * _MainTex_TexelSize * outlineSize).a;

						if(sampleAlpha > alphaThreshold)
							return 1;
					}

                    /*float2 pixelUpTexCoord = texCoord + float2(0, i * _MainTex_TexelSize.y);
                    fixed pixelUpAlpha = tex2D(_MainTex, pixelUpTexCoord).a;
                    if (pixelUpAlpha > alphaThreshold) 
						return 1;

                    float2 pixelDownTexCoord = texCoord - float2(0, i * _MainTex_TexelSize.y);
                    fixed pixelDownAlpha = tex2D(_MainTex, pixelDownTexCoord).a;
                    if (pixelDownAlpha > alphaThreshold) 
						return 1;

                    float2 pixelRightTexCoord = texCoord + float2(i * _MainTex_TexelSize.x, 0);
                    fixed pixelRightAlpha = tex2D(_MainTex, pixelRightTexCoord).a;
                    if (pixelRightAlpha > alphaThreshold) 
						return 1;

                    float2 pixelLeftTexCoord = texCoord - float2(i * _MainTex_TexelSize.x, 0);
                    fixed pixelLeftAlpha = tex2D(_MainTex, pixelLeftTexCoord).a;
                    if (pixelLeftAlpha > alphaThreshold) 
						return 1;*/
                }

                return 0;
            }

			fixed4 SampleSpriteTexture(float2 uv)
            {
                fixed4 color = tex2D(_MainTex, uv);

                return color;
            }
			
			fixed4 frag (v2f i) : SV_Target
			{
                fixed4 color = SampleSpriteTexture(i.uv);
                color.rgb *= color.a;
 
                int shouldDrawOutline = ShouldDrawOutlineOutside(color, i.uv, _OutlineThickness, _AlphaTreshold);

				color = lerp(color, _TintColor * _TintColor.a, shouldDrawOutline);

  
                return color;
			}
			ENDCG
		}
	}
}
