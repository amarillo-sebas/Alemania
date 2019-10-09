using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 
/// </summary>

public class MolinoEmitter : MonoBehaviour {
	[Space(5f)]
	[Header("Dependencies")]
	public GameObject[] molinoPrefabs;
	public Transform[] pivots;

	[Space(5f)]
	[Header("Variables")]
	public float minRate;
	public float maxRate;
	private float _counter = 0f;

	void Update () {
		if (_counter <= Time.time) {
			float r = Random.Range(minRate, maxRate);
			_counter = Time.time + r;
			EmitMolino();
		}
	}

	void EmitMolino () {
		int r = Random.Range(0, molinoPrefabs.Length);
		int rp = Random.Range(0, pivots.Length);
		GameObject m = Instantiate(molinoPrefabs[r], pivots[rp].position, pivots[rp].rotation);
		m.transform.Rotate(new Vector3 (0f, 180f, 0f));
		m.transform.localScale *= 0.35f;
		FlyingMolino fm = m.GetComponentInChildren<FlyingMolino>();
		if (fm) fm.fly = true;
	}
}
