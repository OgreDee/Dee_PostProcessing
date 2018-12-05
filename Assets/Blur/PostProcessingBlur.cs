using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ImageEffectAllowedInSceneView]
[ExecuteInEditMode]
public class PostProcessingBlur : MonoBehaviour {

    [SerializeField]
    Shader curShader;

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

        for(int i = 1; i <= iterations; i++)
        {
            mat.SetFloat("_BlurSize", i * blurSpread * (1<<downSample));
            RenderTexture rt0 = RenderTexture.GetTemporary(rtWidth, rtHeigth, 0);
            rt0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(rt, rt0, GetMaterial(), 0);
            RenderTexture.ReleaseTemporary(rt);

            RenderTexture rt1 = RenderTexture.GetTemporary(rtWidth, rtHeigth, 0);
            rt1.filterMode = FilterMode.Bilinear;
            Graphics.Blit(rt0, rt1, GetMaterial(), 1);
            RenderTexture.ReleaseTemporary(rt0);
            rt = rt1;
        }
        Graphics.Blit(rt, destination);
        RenderTexture.ReleaseTemporary(rt);
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
