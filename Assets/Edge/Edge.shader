Shader "Dee/PostProcessing/Edge"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        
        _EdgeOnly("EdgeOnly", Range(0,1)) = 0
        _EdgeColor("EdgeColor", Color) = (0,0,0,1)
        _EdgeBGColor("EdgeBGColor", Color) = (0,0,0,1)
        
        _SampleDistance("SampleDistance", Range(0, 5)) = 1
        _SensitivityDepth("SensitivityDepth", Range(0,5)) = 1
        _SensitivityNormal("SensitivityNormal", Range(0,5)) = 1
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
            float4 _EdgeBGColor;
            
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
			
            half evaluateEdge(fixed4 l, fixed4 r)
            {
                //法线深度图(xy存法线, zw存深度)
                float ld = DecodeFloatRG(l.zw);
                float rd = DecodeFloatRG(r.zw);
                
                //比对法线、深度
                half2 diffNormal = abs(l.xy - r.xy) * _SensitivityNormal;
                int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;
                int isSameDepth = abs(ld - rd) * _SensitivityDepth < 0.1 * ld;
                //int isSameDepth = 1;
                
                return lerp(1, 0, isSameNormal * isSameDepth);
            }
            
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv[0]);
                
                fixed4 p1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
                fixed4 p2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
                fixed4 p3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
                fixed4 p4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);
                
                half edge = evaluateEdge(p1, p2) * evaluateEdge(p3, p4);
                float4 c = lerp(col, _EdgeColor, edge);
                
                return c;
			}
			ENDCG
		}
	}
}
