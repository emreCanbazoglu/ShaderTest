using UnityEngine;

public class ShockwaveController : MonoBehaviour
{
    public GameObject ShockwavePrefab;

    private void Update()
    {
        CheckInput();
    }

    void CheckInput()
    {
        if (Input.GetMouseButtonDown(0))
            CreateShockwave();
    }

    void CreateShockwave()
    {
        Vector2 worldPos = Camera.main.ScreenToWorldPoint(Input.mousePosition);

        Instantiate(ShockwavePrefab, worldPos, Quaternion.identity);
    }
}
