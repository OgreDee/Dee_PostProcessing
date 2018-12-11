using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessingFog : MonoBehaviour 
{
    [SerializeField, Range(0f, 3f)]
    float fogDensity = 1.0f;
    [SerializeField]
    Color fogColor = Color.white;
    [SerializeField]
    float fogStart = 0f;
    [SerializeField]
    float fogEnd = 0f;

    Material mat;

    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        mat.SetMatrix("_Rays", createRay());
        mat.SetColor("_FogColor", fogColor);
        mat.SetFloat("_FogDensity", fogDensity);
    }

    Camera camera;
    Transform _CameraTransform;
    Transform cacheCamTrans { get { return _CameraTransform ?? (camera == null ? null : camera.transform); }}

    Matrix4x4 createRay()
    {
        Matrix4x4 rayMatrix = new Matrix4x4();

        float nearHight = camera.nearClipPlane *  Mathf.Tan(camera.fieldOfView * 0.5f * Mathf.Deg2Rad);
        Vector3 nearTop = cacheCamTrans.up * nearHight;
        Vector3 nearRight = cacheCamTrans.right * nearHight * camera.aspect;

        Vector3 bottomLeft = cacheCamTrans.forward - nearTop - nearRight;
        Vector3 bottomRight = cacheCamTrans.forward - nearTop + nearRight;
        Vector3 topLeft = cacheCamTrans.forward + nearTop - nearRight;
        Vector3 topRight = cacheCamTrans.forward + nearTop + nearRight;

        float mapValue = bottomLeft.magnitude / camera.nearClipPlane;

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
        rayMatrix.SetRow(2, topLeft);
        rayMatrix.SetRow(3, topRight);

        return rayMatrix;
    }
}
