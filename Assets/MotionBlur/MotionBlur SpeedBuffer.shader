Shader "Dee/PostProcessing/MotionBlur SpeedBuffer"
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
	        struct a2v
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };
                        
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 depthUV : TEXCOORD1;
                
                float4 vertex : SV_POSITION;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TexelSize;
            
            sampler2D _CameraDepthTexture;
            uniform float4x4 _PreviourMatrix_VP;
            uniform float4x4 _CurMatrix_PV;
            uniform float _BlurSize;
            
            v2f vert(a2v v)
            {
                v2f o = (v2f)0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                o.depthUV = v.vertex;
                
                #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0)
                {
                    o.depthUV.y = 1 - o.depthUV.y;
                }
                #endif
                
                return o;
            }
            
            float4 frag(v2f i) : SV_Target
            {
                //采样深度
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.depthUV);
				depth = Linear01Depth(depth);
				//return float4(depth, depth, depth, 1);
                //构建NDC坐标
                float4 ndc = float4(i.uv.x * 2 - 1, i.uv.x * 2 - 1, depth * 2 - 1, 1);
                //倒推世界坐标
                float4 worldPos = mul(_CurMatrix_PV, ndc);
                worldPos.xyzw = worldPos.xyzw / worldPos.w; 
                //计算前一帧，这个位置的NDC坐标
                float4 previours = mul(_PreviourMatrix_VP, worldPos);
                //得到裁剪后的齐次坐标
                //previours.xyzw = previours.xyzw / previours.w;
                
                //计算移动速度
                float2 velocity = (ndc.xy - previours.xy / previours.w) / 2;
                
                float4 col = tex2D(_MainTex, i.uv);
                
                col += tex2D(_MainTex, i.uv + velocity * 0.5 * _BlurSize);
                col += tex2D(_MainTex, i.uv + velocity * _BlurSize);
                
                return col / 3;
            }
        ENDCG


		Pass //0 
		{
			ZTest Always
			Cull Off
            Blend SrcAlpha OneMinusSrcAlpha 
            ColorMask RGB

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}

}
