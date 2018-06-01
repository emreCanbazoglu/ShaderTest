// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Amplify_Shockwave"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		_140611devlog4("Displacement Map", 2D) = "white" {}
		_DistortionAmount("Distortion Amount", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		GrabPass{ }

		
		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"


			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord1 : TEXCOORD1;
			};
			
			uniform fixed4 _Color;
			uniform float _EnableExternalAlpha;
			uniform sampler2D _MainTex;
			uniform sampler2D _AlphaTex;
			uniform sampler2D _GrabTexture;
			uniform sampler2D _140611devlog4;
			uniform float4 _140611devlog4_ST;
			uniform float _DistortionAmount;
			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			
			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				float4 clipPos = UnityObjectToClipPos(IN.vertex);
				float4 screenPos = ComputeScreenPos(clipPos);
				OUT.ase_texcoord1 = screenPos;
				
				
				IN.vertex.xyz +=  float3(0,0,0) ; 
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				fixed4 alpha = tex2D (_AlphaTex, uv);
				color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
#endif //ETC1_EXTERNAL_ALPHA

				return color;
			}
			
			fixed4 frag(v2f IN  ) : SV_Target
			{
				float4 screenPos = IN.ase_texcoord1;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 uv_140611devlog4 = IN.texcoord.xy * _140611devlog4_ST.xy + _140611devlog4_ST.zw;
				float4 tex2DNode2 = tex2D( _140611devlog4, uv_140611devlog4 );
				float4 appendResult41 = (float4(( 1.0 - tex2DNode2.r ) , tex2DNode2.g , 0.0 , 0.0));
				float4 temp_cast_0 = (0.0).xxxx;
				float4 temp_cast_1 = (1.0).xxxx;
				float4 temp_cast_2 = (( -1.0 * _DistortionAmount )).xxxx;
				float4 temp_cast_3 = (( _DistortionAmount * 1.0 )).xxxx;
				float4 screenColor1 = tex2D( _GrabTexture, ( ase_grabScreenPosNorm + ( tex2DNode2.a * (temp_cast_2 + (appendResult41 - temp_cast_0) * (temp_cast_3 - temp_cast_2) / (temp_cast_1 - temp_cast_0)) ) ).xy );
				
				fixed4 c = screenColor1;
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=14401
7;29;1906;1004;3132.77;352.5873;1.356107;True;False
Node;AmplifyShaderEditor.SamplerNode;2;-2614.178,-23.89381;Float;True;Property;_140611devlog4;Displacement Map;0;0;Create;False;None;417bf9604c7ba9c44a1d166037457f0b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;40;-2081.198,163.4551;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;22;-2546.511,719.7236;Float;False;Property;_DistortionAmount;Distortion Amount;1;0;Create;True;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-2644.91,619.3237;Float;False;Constant;_Float0;Float 0;1;0;Create;True;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2650.811,850.7238;Float;False;Constant;_Float1;Float 1;1;0;Create;True;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;42;-1783.912,167.5983;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-2298.646,835.8414;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2325.545,451.4414;Float;False;Constant;_Float3;Float 3;2;0;Create;True;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-2302.146,625.0418;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2325.846,352.8415;Float;False;Constant;_Float2;Float 2;2;0;Create;True;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;41;-1613.026,208.1532;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TFHCRemapNode;25;-1368.745,480.2631;Float;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-930.809,-68.85087;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT4;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GrabScreenPosition;14;-2137.599,-284.1515;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-796.4852,-190.7031;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;1;-651.9785,150.1984;Float;False;Global;_GrabScreen0;Grab Screen 0;0;0;Create;True;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMasterNode;0;-338.3994,154.5591;Float;False;True;2;Float;ASEMaterialInspector;0;4;Amplify_Shockwave;0f8ba0101102bb14ebf021ddadce9b49;ASETemplateShaders/Sprites Default;2;SrcAlpha;OneMinusSrcAlpha;0;One;Zero;Off;2;5;Queue=Transparent;IgnoreProjector=True;RenderType=Transparent;PreviewType=Plane;CanUseSpriteAtlas=True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;40;0;2;0
WireConnection;42;0;40;0
WireConnection;23;0;22;0
WireConnection;23;1;21;0
WireConnection;24;0;20;0
WireConnection;24;1;22;0
WireConnection;41;0;42;0
WireConnection;41;1;40;1
WireConnection;25;0;41;0
WireConnection;25;1;26;0
WireConnection;25;2;27;0
WireConnection;25;3;24;0
WireConnection;25;4;23;0
WireConnection;18;0;2;4
WireConnection;18;1;25;0
WireConnection;28;0;14;0
WireConnection;28;1;18;0
WireConnection;1;0;28;0
WireConnection;0;0;1;0
ASEEND*/
//CHKSM=F4A066B543874F0B16446FADD88A2EA660D8D238