Shader "Dee/PostProcessing/Blur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
        
        CGINCLUDE
	        #include "UnityCG.cginc"
	        //高斯核
	        static const half gaussianConvolution[3] =  {0.4026, 0.2442, 0.0545};

	        struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;

				float4 vertex : SV_POSITION;
				float2 offset : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			//UnityCG.cginc中内置的变量，纹理中的单像素尺寸|| it is the size of a texel of the texture
			uniform half4 _MainTex_TexelSize;
			uniform half _BlurSize;

			v2f vert_horizontal (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.offset = _MainTex_TexelSize.xy * half2(1.0 * _BlurSize, 0);
				return o;
			}

			v2f vert_vertical(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.offset = _MainTex_TexelSize.xy * half2(0, 1.0 * _BlurSize);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				col *= gaussianConvolution[0];

				for(int idx = 1; idx < 3; idx++)
				{
					col += tex2D(_MainTex, i.uv + i.offset * idx) * gaussianConvolution[idx];
					col += tex2D(_MainTex, i.uv - i.offset * idx) * gaussianConvolution[idx];
				}

				return col;
			}

        ENDCG


		Pass //0 ,横向模糊
		{
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert_horizontal
			#pragma fragment frag
			ENDCG
		}

		Pass //0 ,纵向模糊
		{
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert_vertical
			#pragma fragment frag
			ENDCG
		}
	}

}
