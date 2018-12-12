Shader "Dee/PostProcessing/Edge"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        
        _EdgeOnly("EdgeOnly", Range(0,1)) = 0
        _EdgeColor("EdgeColor", Color) = (0,0,0,1)
        _SampleDistance("SampleDistance", Range(0, 2)) = 1
        _SensitivityDepth("SensitivityDepth", float) = 1
        _SensitivityNormal("SensitivityNormal", float) = 1
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
				float2 uv[5] : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            uniform sampler2D _CameraDepthNormalsTexture;
            
            
            float _EdgeOnly;
            float4 _EdgeColor;
            float _SampleDistance;
			float _SensitivityDepth;
            float _SensitivityNormal;
            
            
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv[0] = TRANSFORM_TEX(v.uv, _MainTex);
                #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0) //因为是一张图片，只有四个顶点，所以使用if不会有性能损耗
                {
                    o.uv[0].y = 1 - o.uv[0].y;
                }
                #endif
                
                o.uv[1] = o.uv[0] + _MainTex_TexelSize.xy * half2(1,1) * _SampleDistance;
                o.uv[2] = o.uv[0] + _MainTex_TexelSize.xy * half2(-1,-1) * _SampleDistance;
                o.uv[3] = o.uv[0] + _MainTex_TexelSize.xy * half2(-1,1) * _SampleDistance;
                o.uv[4] = o.uv[0] + _MainTex_TexelSize.xy * half2(1,-1) * _SampleDistance;
                
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv[0]);
                
                
                
				return col;
			}
			ENDCG
		}
	}
}
