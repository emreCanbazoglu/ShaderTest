using UnityEngine;
using System.Collections;

public class SuperStrikeEffect : MonoBehaviour
{
    public Material EffectMaterial;
    public MeshRenderer Renderer;

    public float Speed;

    public Vector2 InitialScale;
    public Vector2 FinalScale;

    public float MaxStrength;
    public float MinStrength;

    IEnumerator _shockwaveProgress;

    const float STRENGTH_THRESHOLD = 0.0001f;

    private void Update()
    {
        CheckInput();
    }

    void CheckInput()
    {
        if (Input.GetMouseButtonDown(0))
            ActivateEffect();
    }

    public void ActivateEffect()
    {
        Renderer.enabled = true;

        ResetEffect();

        StartEffectProgress();
    }

    void ResetEffect()
    {
        transform.localScale = InitialScale;

        StartEffectProgress();
    }

    void StartEffectProgress()
    {
        StopEffectProgress();

        _shockwaveProgress = ShockwaveProgress();
        StartCoroutine(_shockwaveProgress);
    }

    void StopEffectProgress()
    {
        if (_shockwaveProgress != null)
            StopCoroutine(_shockwaveProgress);
    }

    IEnumerator ShockwaveProgress()
    {
        Vector2 curScale = InitialScale;
        float curStrength = MaxStrength;

        while (Mathf.Abs(MinStrength - curStrength) > STRENGTH_THRESHOLD)
        {
            curStrength = Mathf.Lerp(curStrength, MinStrength, Time.deltaTime * Speed);

            curScale = Vector2.Lerp(curScale, FinalScale, Time.deltaTime * Speed);

            transform.localScale = curScale;

            UpdateEffect(curStrength);

            yield return null;
        }

        EffectCompleted();
    }

    void UpdateEffect(float curStrength)
    {
        EffectMaterial.SetFloat("_DispStrength", curStrength);
    }

    void EffectCompleted()
    {
        StopEffectProgress();
        Renderer.enabled = false;

    }
}
