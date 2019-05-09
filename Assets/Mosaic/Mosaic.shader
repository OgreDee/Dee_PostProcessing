Shader "Dee/PostProcessing/Mosaic"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MosaicSize ("MosaicSize", float) = 1
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
			//_MainTex_TexelSize = Vector4(1 / width, 1 / height, width, height)
			half4 _MainTex_TexelSize;

			uniform float _MosaicSize;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = floor(i.uv * _MainTex_TexelSize.zw / _MosaicSize) * _MosaicSize;
				uv.xy = uv.xy * _MainTex_TexelSize.xy;

				fixed4 col = tex2D(_MainTex, uv);

				return col;
			}
			ENDCG
		}
	}
}
