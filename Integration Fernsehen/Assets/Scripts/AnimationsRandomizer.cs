using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 
/// </summary>

public class AnimationsRandomizer : MonoBehaviour {
	[Space(5f)]
	[Header("Dependencies")]
	public Animator[] animators;

	[Space(5f)]
	[Header("Variables")]
	public bool randomStartingPosition;
	public float minSpeed;
	public float maxSpeed;

	void Start () {
		animators = GetComponentsInChildren<Animator>();
		foreach (Animator a in animators) {
			if (randomStartingPosition) a.Play(0, 0, Random.Range(0f, 1f));
			a.speed = Random.Range(minSpeed, maxSpeed);
			a.SetFloat("Blend", Random.Range(0f, 1f));
		}
	}
}
