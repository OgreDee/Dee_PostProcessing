Shader "Dee/ImageEffect/Color"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _Saturation("Saturation", Range(0,1)) = 1 //饱和度
        _Brightness("Brightness", Range(0,5)) = 1 //亮度
        _Contrast("_Contrast", Range(0.5,5)) = 1 //对比度
        
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
            CGINCLUDE
            void apply_saturation(inout float3 rgb, in float saturation)
            {
                float gray = dot(rgb, half3(0.2126, 0.7152, 0.0722));
                
                rgb.rgb = lerp(float3(gray, gray, gray), rgb.rgb, saturation);
            }
            
            void apply_saturation_withHSV(inout float3 rgb, in float saturation)
            {
                //convert hsv
                
                //convert rgb
            }
            
            ENDCG
            
            
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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
            half _Saturation;
            half _Brightness;
            half _Contrast;
            
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				// just invert the colors
				//col.rgb = 1 - col.rgb;
                
                //亮度
                col.rgb = col.rgb * _Brightness;
                //饱和度
                apply_saturation(col.rgb, _Saturation);
                //对比度
                col.rgb = lerp(half3(0.5,0.5,0.5), col.rgb, _Contrast);
                                
				return col;
			}
			ENDCG
		}
	}
}
