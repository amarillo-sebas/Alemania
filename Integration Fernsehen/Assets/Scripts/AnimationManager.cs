using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 
/// </summary>

public class AnimationManager : MonoBehaviour {
	[Space(5f)]
	[Header("Dependencies")]
	public Animator animator;

	[Space(5f)]
	[Header("Variables")]
	public float animationDelayTime;

	void Start () {
		animator = GetComponent<Animator>();
		StartCoroutine(WaitForAnimation(animationDelayTime));
	}

	IEnumerator WaitForAnimation (float t) {
		yield return new WaitForSeconds(t);
		animator.SetTrigger("Start");
	}
}
