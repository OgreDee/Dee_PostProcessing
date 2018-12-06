//
// 累积缓存实现的运动模糊: 对之前的几帧图像进行均值过滤，然后和本帧叠加
//
//
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ImageEffectAllowedInSceneView]
[ExecuteInEditMode]
public class PostProcessingMotionBlurWithAccumBuffer : MonoBehaviour {

    [SerializeField]
    Shader curShader;

    [SerializeField, Range(0f, 0.9f)]
    float blurAmount;       //
    [SerializeField]
    int downSample;

    Material mat = null;

	// Use this for initialization
	void Start () {
        if (SystemInfo.supportsImageEffects == false)
            enabled = false;
	}
	
	// Update is called once per frame
	void Update () {
		
	}


    private RenderTexture accumulationTexture;

    private void OnDestroy()
    {
#if UNITY_EDITOR
        DestroyImmediate(accumulationTexture);
#else
        Destroy(accumulationTexture);
#endif
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

        //初始化累积缓存的纹理
        if (accumulationTexture == null)
        {
            accumulationTexture = new RenderTexture(rtWidth, rtHeigth, 0);
            accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
            accumulationTexture.filterMode = FilterMode.Bilinear;
            Graphics.Blit(source, accumulationTexture);
        }

        //表明渲染纹理恢复预期操作。
        //当在移动图形仿真模式，当Unity执行渲染还原操作时发出警告。当渲染纹理没有清除或者首先丢弃它(DiscardContents)时还原发生。
        //在很多移动 Gpu 和多 GPU 系统上，这是一个高负荷的操作，最好避免。
        //但是，如果你的渲染效果必须要渲染纹理还原，你可以调用该函数表明那是必须的，还原时预期的，并且在这里Unity将不会发出警告。
        accumulationTexture.MarkRestoreExpected();

        mat.SetFloat("_BlurAmount", 1 - blurAmount);
        Graphics.Blit(source, accumulationTexture, mat);
        Graphics.Blit(accumulationTexture, destination);
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
