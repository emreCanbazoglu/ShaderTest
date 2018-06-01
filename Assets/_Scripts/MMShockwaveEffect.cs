using UnityEngine;

[ExecuteInEditMode]
public class MMShockwaveEffect : MonoBehaviour
{
    public RenderTexture EffectTexture;
    public float EffectStrength;

    Material _shockwaveMat;

    private void Awake()
    {
        InitMaterial();
        InitRenderTexture();
    }

    void InitMaterial()
    {
        Shader shader = Shader.Find("Hidden/MildMania/PostProcess");

        _shockwaveMat = new Material(shader);
    }

    void InitRenderTexture()
    {
        EffectTexture.width = Screen.width / 4;
        EffectTexture.height = Screen.height / 4;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_shockwaveMat == null)
            InitMaterial();

        _shockwaveMat.SetTexture("_DispTex", EffectTexture);
        _shockwaveMat.SetFloat("_DispStrength", EffectStrength);

        Graphics.Blit(source, destination, _shockwaveMat);
    }
}
