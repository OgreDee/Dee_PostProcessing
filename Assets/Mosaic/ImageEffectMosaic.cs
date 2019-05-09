using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ImageEffectAllowedInSceneView]
[ExecuteInEditMode]
public class ImageEffectMosaic : MonoBehaviour
{

    [SerializeField]
    Shader curShader;

    [SerializeField]
    [Range(1,300)]
    int mosaicSize = 1;         //降采样


    Material mat = null;
    int mosaicSizeShaderID;


    // Use this for initialization
    void Start()
    {
        if (SystemInfo.supportsImageEffects == false)
            enabled = false;
    }
    

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mathf.Approximately(mosaicSize, 0) || GetMaterial() == null)
        {
            Graphics.Blit(source, destination);
            return;
        }

        mat.SetFloat(mosaicSizeShaderID, mosaicSize);
        Graphics.Blit(source, destination, GetMaterial());
    }

    Material GetMaterial()
    {
        if (curShader == null || !curShader.isSupported)
            return null;

        if (mat == null || mat.shader != curShader)
        {
            mat = new Material(curShader);
            mat.hideFlags = HideFlags.DontSave;
            mosaicSizeShaderID = Shader.PropertyToID("_MosaicSize");
        }

        return mat;
    }
}