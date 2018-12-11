using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class PostProcessingFog : MonoBehaviour 
{
    public enum Fog
    {
        Linear,
        EXP
    }

    [SerializeField]
    Shader curShader;

    [SerializeField]
    Fog fogMode;
    [SerializeField, Range(0f, 3f)]
    float fogDensity = 1.0f;
    [SerializeField]
    Color fogColor = Color.white;
    [SerializeField]
    float fogStart = 0f;
    [SerializeField]
    float fogEnd = 0f;

    Material mat;
    

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (GetMaterial() == null)
        {
            Graphics.Blit(source, destination);
            return;
        }

        if(cam.depthTextureMode != DepthTextureMode.Depth)
        {
            cam.depthTextureMode = DepthTextureMode.Depth;
        }

        mat.SetMatrix("_Rays", createRay());
        mat.SetColor("_FogColor", fogColor);
        mat.SetFloat("_FogDensity", fogDensity);
        mat.SetFloat("_FogStart", fogStart);
        mat.SetFloat("_FogEnd", fogEnd);
        switch(fogMode)
        {
            case Fog.Linear:
                {
                    mat.EnableKeyword("FOG_LINEAR_MODE");
                    mat.DisableKeyword("FOG_EXP_MODE");
                }
                break;
            case Fog.EXP:
                {
                    mat.DisableKeyword("FOG_LINEAR_MODE");
                    mat.EnableKeyword("FOG_EXP_MODE");
                }
                break;
        }

        Graphics.Blit(source, destination, mat);
    }

    Camera cam;
    Transform _CameraTransform;
    Transform cacheCamTrans;
    //Transform cacheCamTrans { get { return _CameraTransform = _CameraTransform ?? (cam == null ? null : cam.transform); }}

    Matrix4x4 createRay()
    {
        if(cam == null)
        {
            cam = GetComponent<Camera>();
        }

        if(cacheCamTrans == null)
        {
            cacheCamTrans = cam.transform;
        }
        //cam = cam ?? GetComponent<Camera>();

        Matrix4x4 rayMatrix = new Matrix4x4();

        float nearHight = cam.nearClipPlane *  Mathf.Tan(cam.fieldOfView * 0.5f * Mathf.Deg2Rad);
        Vector3 nearTop = cacheCamTrans.up * nearHight;
        Vector3 nearRight = cacheCamTrans.right * nearHight * cam.aspect;

        Vector3 bottomLeft = cacheCamTrans.forward - nearTop - nearRight;
        Vector3 bottomRight = cacheCamTrans.forward - nearTop + nearRight;
        Vector3 topLeft = cacheCamTrans.forward + nearTop - nearRight;
        Vector3 topRight = cacheCamTrans.forward + nearTop + nearRight;

        float mapValue = bottomLeft.magnitude / cam.nearClipPlane;

        bottomLeft.Normalize();
        bottomLeft *= mapValue;

        bottomRight.Normalize();
        bottomRight *= mapValue;

        topLeft.Normalize();
        topLeft *= mapValue;

        topRight.Normalize();
        topRight *= mapValue;

        rayMatrix.SetRow(0, bottomLeft);
        rayMatrix.SetRow(1, bottomRight);
        rayMatrix.SetRow(2, topRight);
        rayMatrix.SetRow(3, topLeft);

        return rayMatrix;
    }

    Material GetMaterial()
    {
        if (curShader == null || !curShader.isSupported)
            return null;

        if (mat == null || mat.shader != curShader)
        {
            mat = new Material(curShader);
            mat.hideFlags = HideFlags.DontSave;
        }

        return mat;
    }
}
