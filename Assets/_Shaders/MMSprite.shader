// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "MildMania/Sprite" 
{
    Properties 
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        [PerRendererData] _Color("Tint", Color) = (1,1,1,1)
        [PerRendererData] _AddColor("Color Tint Add", Color) = (0,0,0,0)
        [MaterialToggle]PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
        [PerRendererData]_Outline("Outline", Float) = 0
        [PerRendererData]_OutlineColor("Outline Color", Color) = (1,1,1,1)
        [PerRendererData] _OutlineSize("Outline Size", int) = 1
    }
    
    SubShader
    {
        Tags 
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType" = "Plane"
        }

        ZWrite Off
        Lighting Off 
        Cull Off 
        Fog { Mode Off } 
        Blend SrcAlpha OneMinusSrcAlpha

        LOD 110
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ PIXELSNAP_ON
            #pragma shader_feature ETC1_EXTERNAL_ALPHA
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color : COLOR;
                float2 texcoord  : TEXCOORD0;
            };

            fixed4 _Color;
            fixed4 _AddColor;
            float _Outline;
            fixed4 _OutlineColor;
            int _OutlineSize;

            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color * _Color;
                #ifdef PIXELSNAP_ON
                OUT.vertex = UnityPixelSnap(OUT.vertex);
                #endif

                return OUT;
            }

            sampler2D _MainTex;
            sampler2D _AlphaTex;
            float4 _MainTex_TexelSize;

            fixed4 SampleSpriteTexture(float2 uv)
            {
                fixed4 color = tex2D(_MainTex, uv);

                #if ETC1_EXTERNAL_ALPHA
                // get the color from an external texture (usecase: Alpha support for ETC1 on android)
                color.a = tex2D(_AlphaTex, uv).r;

                #endif
                color.rgb += _AddColor.rgb;
                color.a = tex2D(_MainTex, uv).a;
                return color;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                fixed4 c = SampleSpriteTexture(IN.texcoord) * IN.color;

                // If outline is enabled and there is a pixel, try to draw an outline.
                if (_Outline > 0 && c.a != 0) 
                {
                    float totalAlpha = 1.0;

                    for (int i = 1; i < 2; i++) {
                        fixed4 pixelUp = tex2D(_MainTex, IN.texcoord + fixed2(0, i * _MainTex_TexelSize.y));
                        fixed4 pixelDown = tex2D(_MainTex, IN.texcoord - fixed2(0,i *  _MainTex_TexelSize.y));
                        fixed4 pixelRight = tex2D(_MainTex, IN.texcoord + fixed2(i * _MainTex_TexelSize.x, 0));
                        fixed4 pixelLeft = tex2D(_MainTex, IN.texcoord - fixed2(i * _MainTex_TexelSize.x, 0));

                        totalAlpha = totalAlpha * pixelUp.a * pixelDown.a * pixelRight.a * pixelLeft.a;
                    }

                    if (totalAlpha == 0) {
                        c.rgba = fixed4(1, 1, 1, 1) * _OutlineColor;
                    }
                }

                c.rgb *= c.a;
  
                return c;
            }
            ENDCG

        }
    }
}
