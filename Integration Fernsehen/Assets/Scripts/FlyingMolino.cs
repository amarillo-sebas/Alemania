using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 
/// </summary>

public class FlyingMolino : MonoBehaviour {
	[Space(5f)]
	[Header("Variables")]
	public bool fly = false;
	private Vector3 _movementVector = new Vector3(0.1f, 0.05f, 0f);

	void Start () {
		
	}

	private float _counter = 0f;
	private Vector3 point = Vector3.zero;
	void Update () {
		if (fly) {
			if (_counter <= Time.time) {
				_counter = Time.time + 0.25f;

				point = transform.position + (_movementVector * 30f);
				point += Random.insideUnitSphere * 2f;
				//transform.position = point;
				//point *= 2f;
			}

			float d = Vector3.Distance(transform.position, point);
			transform.position = Vector3.Lerp(transform.position, point, Time.deltaTime * 0.5f);
			//transform.position = Vector3.Lerp(transform.position, targetP, Time.deltaTime * 10f);

			/*Vector3 mov = transform.position;

			mov.x += Random.Range(-0.1f, 0.1f);
			mov.y += Random.Range(-0.1f, 0.1f);

			//float p = Mathf.PerlinNoise(mov.x, mov.y);
			//mov.x = p;
			//mov.y = p;

			mov += _movementVector;

			transform.position = mov;*/
			//transform.Translate(mov * Time.deltaTime);
		}
	}
}
