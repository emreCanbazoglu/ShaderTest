using UnityEngine;
using System.Collections;

public class Shockwave : MonoBehaviour
{
    public Vector2 InitialScale;
    public Vector2 FinalScale;

    public float InitialAlpha;
    public float FinalAlpha;

    const float ALPHA_TRESHOLD = 0.02f;

    public SpriteRenderer SpriteRenderer;

    private void Awake()
    {
        transform.localScale = InitialScale;

        Color newColor = SpriteRenderer.color;
        newColor.a = InitialAlpha;

        SpriteRenderer.color = newColor;

        StartCoroutine(ShockwaveProgress());
    }

    IEnumerator ShockwaveProgress()
    {
        Color endColor = SpriteRenderer.color;
        endColor.a = FinalAlpha;

        while (Mathf.Abs(SpriteRenderer.color.a - FinalAlpha) > ALPHA_TRESHOLD)
        {
            SpriteRenderer.color = Color.Lerp(SpriteRenderer.color, endColor, Time.deltaTime);

            transform.localScale = Vector2.Lerp(transform.localScale, FinalScale, Time.deltaTime);

            yield return null;
        }

        DestroyImmediate(gameObject);
    }
}
