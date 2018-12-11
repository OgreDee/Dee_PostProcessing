Shader "Dee/PostProcessing/Fog"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile __ FOG_EXP_MODE FOG_LINEAR_MODE
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 ray : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;

			uniform sampler2D _CameraDepthTexture;
			uniform float4x4 _Rays;
			uniform float _FogDensity;
			uniform float4 _FogColor;
			uniform float _FogStart;
			uniform float _FogEnd;


			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = o.uv.xy;

				int index = 0;
				if(v.vertex.x < 0.5 && v.vertex.y < 0.5)
				{
					index = 0;
				}
				else if(v.vertex.x > 0.5 && v.vertex.y < 0.5)
				{
					index = 1;
				}
				else if(v.vertex.x > 0.5 && v.vertex.y > 0.5)
				{
					index = 2;
				}
				else
				{
					index = 3;
				}

				#if UNITY_UV_STARTS_AT_TOP
				if(_MainTex_TexelSize.y < 0) //因为是一张图片，只有四个顶点，所以使用if不会有性能损耗
				{
					o.uv.w = 1 - o.uv.w;
					index = 3 - index;
				}
				#endif

				o.ray = _Rays[index];

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv.zw));
				float3 worldPos = _WorldSpaceCameraPos.xyz + depth * i.ray.xyz;
				float v = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
				#if FOG_EXP_MODE
				float factor = exp(-_FogDensity * worldPos.y);
				#else 
				float factor = saturate(v * _FogDensity);
				#endif

				fixed4 col = tex2D(_MainTex, i.uv);
				return lerp(col, _FogColor, saturate(factor));
			}
			ENDCG
		}
	}
}
