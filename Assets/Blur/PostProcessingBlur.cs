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
    [SerializeField]
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
        int rtWidth = source.width >> downSample;
        int rtHeigth = source.height >> downSample;

        //深度值可选0,16,24 (越大越占内存)
        RenderTexture rt = RenderTexture.GetTemporary(rtWidth, rtHeigth, 0);
        Graphics.Blit(source, rt);
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
