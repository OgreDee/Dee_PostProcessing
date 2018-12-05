//筛选提取高于阈值的色，我们只对这一部分进行处理，为了实现衍射效果，我们对图片进行模糊处理，然后和原图叠加就是泛光效果了
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ImageEffectAllowedInSceneView]
[ExecuteInEditMode]
public class PostProcessingBloom : MonoBehaviour {

    [SerializeField]
    Shader curShader;

    [SerializeField, Range(0,1)]
    float threshold = 0f;
    [SerializeField, Range(0.5f, 3)]
    float intensity = 1f;

    [SerializeField]
    int downSample = 1;         //降采样
    [SerializeField, Range(0,5)]
    int iterations = 1;         //模糊次数
    [SerializeField, Range(0.5f, 3f)]
    float blurSpread = 1f;      //模糊范围


    Material mat = null;

	// Use this for initialization
	void Start () {
        if (SystemInfo.supportsImageEffects == false)
            enabled = false;
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (GetMaterial() == null)
        {
            Graphics.Blit(source, destination);
            return;
        }

        int rtWidth = source.width >> downSample;
        int rtHeigth = source.height >> downSample;
        

        //深度值可选0,16,24 (越大越占内存)
        RenderTexture rt = RenderTexture.GetTemporary(rtWidth, rtHeigth, 0);
        rt.filterMode = FilterMode.Bilinear;
        Graphics.Blit(source, rt);

        // 提取高亮部分
        mat.SetFloat("_Threshold", threshold);
        mat.SetFloat("_Intensity", intensity);
        RenderTexture splitRT = RenderTexture.GetTemporary(rtWidth, rtHeigth, 0);
        splitRT.filterMode = FilterMode.Bilinear;
        Graphics.Blit(rt, splitRT, mat, 0); 
        RenderTexture.ReleaseTemporary(rt);

        // 模糊
        for (int i = 1; i <= iterations; i++)
        {
            mat.SetFloat("_BlurSize", i * blurSpread * (1 << downSample));
            RenderTexture rt0 = RenderTexture.GetTemporary(rtWidth, rtHeigth, 0);
            rt0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(splitRT, rt0, GetMaterial(), 1);
            RenderTexture.ReleaseTemporary(splitRT);

            RenderTexture rt1 = RenderTexture.GetTemporary(rtWidth, rtHeigth, 0);
            rt1.filterMode = FilterMode.Bilinear;
            Graphics.Blit(rt0, rt1, GetMaterial(), 2);
            RenderTexture.ReleaseTemporary(rt0);
            splitRT = rt1;
        }

        // 叠加
        mat.SetTexture("_BloomTex", splitRT);
        Graphics.Blit(source, destination, mat, 3);

        RenderTexture.ReleaseTemporary(splitRT);

    }

    Material GetMaterial()
    {
        if (curShader == null || !curShader.isSupported)
            return null;

        if(mat == null || mat.shader != curShader)
        {
            mat = new Material(curShader);
            mat.hideFlags = HideFlags.DontSave;
        }

        return mat;
    }
}
