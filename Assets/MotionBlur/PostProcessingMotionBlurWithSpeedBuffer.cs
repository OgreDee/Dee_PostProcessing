//
// 累积缓存实现的运动模糊: 对之前的几帧图像进行均值过滤，然后和本帧叠加
//
//
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ImageEffectAllowedInSceneView]
[ExecuteInEditMode]
public class PostProcessingMotionBlurWithSpeedBuffer : MonoBehaviour {
    [SerializeField]
    Camera cam;

    [SerializeField]
    Shader curShader;


    [SerializeField, Range(0f, 0.9f)]
    float blurSize; 

    Material mat = null;

	// Use this for initialization
	void Start () {
        if (SystemInfo.supportsImageEffects == false)
            enabled = false;
	}
	
	// Update is called once per frame
	void Update () {
		
	}



    private void OnDestroy()
    {
    }


    Matrix4x4 previourMatrix_VP;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (cam == null || GetMaterial() == null)
        {
            Graphics.Blit(source, destination);
            return;
        }

        if(cam.depthTextureMode != DepthTextureMode.Depth)
        {
            cam.depthTextureMode = DepthTextureMode.Depth;
        }


        mat.SetMatrix("_PreviourMatrix_VP", previourMatrix_VP);
        //设置当前变换矩阵(Clip->View->World)
        previourMatrix_VP = cam.projectionMatrix * cam.cameraToWorldMatrix;
        mat.SetMatrix("_CurMatrix_PV", previourMatrix_VP.inverse);
        //设置前帧变换矩阵

        mat.SetFloat("_BlurSize", blurSize);
        Graphics.Blit(source, destination, mat);
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
