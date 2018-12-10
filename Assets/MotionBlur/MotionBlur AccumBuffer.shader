Shader "Dee/PostProcessing/MotionBlur"
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
                float4 vertex : SV_POSITION;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform float _BlurAmount;
            
            v2f vert(a2v v)
            {
                v2f o = (v2f)0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            float4 fragRGB(v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                
                return float4(col.rgb, _BlurAmount);
            }
            
            float4 fragA(v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                col.a = 1;
                return col;
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
			#pragma fragment fragRGB
			ENDCG
		}
        
        Pass //1
        {
            ZTest Always
            Cull Off
            Blend One Zero
            ColorMask A

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragA
            ENDCG
        }
	}

}
