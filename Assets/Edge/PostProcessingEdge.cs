using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class PostProcessingEdge : MonoBehaviour {
    [SerializeField]
    Material mat;
    [SerializeField]
    Camera cam;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(mat == null || cam == null || !mat.shader.isSupported)
        {
            Graphics.Blit(source, destination);
            return;
        }

        if(cam.depthTextureMode != DepthTextureMode.DepthNormals)
        {
            cam.depthTextureMode = DepthTextureMode.DepthNormals;
        }

        Graphics.Blit(source, destination, mat);
    }
}
