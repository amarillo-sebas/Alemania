using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 
/// </summary>

public class PatitasManager : MonoBehaviour {
	[Space(5f)]
	[Header("Dependencies")]
	public AnimationManager[] animatorScripts;

	[Space(5f)]
	[Header("Variables")]
	public float animationsOffset;
	private float _offset;

	void Start () {
		animatorScripts = GetComponentsInChildren<AnimationManager>();
		foreach (AnimationManager am in animatorScripts) {
			am.animationDelayTime = _offset;
			_offset += animationsOffset;
		}
	}
}
