// Toony Colors Pro+Mobile 2
// (c) 2014-2019 Jean Moreno

Shader "Toony Colors Pro 2/User/Nio"
{
	Properties
	{
	[TCP2HeaderHelp(BASE, Base Properties)]
		//TOONY COLORS
		_Color ("Color", Color) = (1,1,1,1)
		_HColor ("Highlight Color", Color) = (0.785,0.785,0.785,1.0)
		_SColor ("Shadow Color", Color) = (0.195,0.195,0.195,1.0)

		//DIFFUSE
		_MainTex ("Main Texture", 2D) = "white" {}
	[TCP2Separator]

		//TOONY COLORS RAMP
		[TCP2Header(RAMP SETTINGS)]

		_RampThreshold ("Ramp Threshold", Range(0,1)) = 0.5
		_RampSmooth ("Ramp Smoothing", Range(0.001,1)) = 0.1
	[TCP2Separator]

	[Header(Masks)]
		[NoScaleOffset]
		_Mask1 ("Mask 1 (Specular)", 2D) = "black" {}
	[TCP2Separator]

	[TCP2HeaderHelp(NORMAL MAPPING, Normal Bump Map)]
		//BUMP
		_BumpMap ("Normal map (RGB)", 2D) = "bump" {}
	[TCP2Separator]

	[TCP2HeaderHelp(AMBIENT OCCLUSION, Ambient Occlusion)]
		//AMBIENT OCCLUSION
		_OcclusionMap ("Occlusion (Alpha)", 2D) = "white" {}
	[TCP2Separator]

	[TCP2HeaderHelp(SKETCH, Sketch)]
		//SKETCH
		_SketchTex ("Sketch (Alpha)", 2D) = "white" {}
		_SketchColor ("Sketch Color (RGB)", Color) = (0,0,0,1)
		_SketchHalftoneMin ("Sketch Halftone Min", Range(0,1)) = 0.2
		_SketchHalftoneMax ("Sketch Halftone Max", Range(0,1)) = 1.0
	[TCP2Separator]

	[TCP2HeaderHelp(TRANSPARENCY)]
		//Alpha Testing
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
	[TCP2Separator]


		//Avoid compile error if the properties are ending with a drawer
		[HideInInspector] __dummy__ ("unused", Float) = 0
	}

	SubShader
	{

		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
		Cull Off

		CGPROGRAM

		#pragma surface surf ToonyColorsCustom noambient vertex:vert addshadow exclude_path:deferred exclude_path:prepass
		#pragma target 3.0

		//================================================================
		// VARIABLES

		fixed4 _Color;
		sampler2D _MainTex;
		sampler2D _Mask1;
		sampler2D _BumpMap;
		sampler2D _OcclusionMap;
		fixed _Cutoff;

		#define UV_MAINTEX uv_MainTex

		struct Input
		{
			half2 uv_MainTex;
			half2 uv_BumpMap;
			half4 sketchUv;
			fixed3 ambient;
		};

		//================================================================
		// CUSTOM LIGHTING

		//Lighting-related variables
		fixed4 _HColor;
		fixed4 _SColor;
		half _RampThreshold;
		half _RampSmooth;
		sampler2D _SketchTex;
		float4 _SketchTex_ST;
		fixed4 _SketchColor;
		fixed _SketchHalftoneMin;
		fixed _SketchHalftoneMax;

		// Instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		//Custom SurfaceOutput
		struct SurfaceOutputCustom
		{
			half atten;
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			half Specular;
			fixed Gloss;
			fixed Alpha;
			half2 ScreenUVs;
		};

		inline half4 LightingToonyColorsCustom (inout SurfaceOutputCustom s, half3 viewDir, UnityGI gi)
		{
		#define IN_NORMAL s.Normal
	
			half3 lightDir = gi.light.dir;
		#if defined(UNITY_PASS_FORWARDBASE)
			half3 lightColor = _LightColor0.rgb;
			half atten = s.atten;
		#else
			half3 lightColor = gi.light.color.rgb;
			half atten = 1;
		#endif

			IN_NORMAL = normalize(IN_NORMAL);
			fixed ndl = max(0, dot(IN_NORMAL, lightDir));
			#define NDL ndl

			#define		RAMP_THRESHOLD	_RampThreshold
			#define		RAMP_SMOOTH		_RampSmooth

			fixed3 ramp = smoothstep(RAMP_THRESHOLD - RAMP_SMOOTH*0.5, RAMP_THRESHOLD + RAMP_SMOOTH*0.5, NDL);
		#if !(POINT) && !(SPOT)
			ramp *= atten;
		#endif
			//Sketch
			#define SKETCH_RGB	sketch
			fixed sketch = tex2D(_SketchTex, s.ScreenUVs).a;
			sketch = smoothstep(sketch - 0.2, sketch, clamp(ramp, _SketchHalftoneMin, _SketchHalftoneMax));	//Gradient halftone
		#if !defined(UNITY_PASS_FORWARDBASE)
			_SColor = fixed4(0,0,0,1);
		#endif
			_SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha
			ramp = lerp(_SColor.rgb, _HColor.rgb, ramp);
			fixed4 c;
			c.rgb = s.Albedo * lightColor.rgb * ramp;
			c.a = s.Alpha;
			c.rgb *= lerp(_SketchColor.rgb, fixed3(1,1,1), sketch);

		#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
			c.rgb += s.Albedo * gi.indirect.diffuse;
		#endif

			return c;
		}

		void LightingToonyColorsCustom_GI(inout SurfaceOutputCustom s, UnityGIInput data, inout UnityGI gi)
		{
			gi = UnityGlobalIllumination(data, 1.0, IN_NORMAL);

			s.atten = data.atten;	//transfer attenuation to lighting function
			gi.light.color = _LightColor0.rgb;	//remove attenuation
		}

		//Adjust screen UVs relative to object to prevent screen door effect
		inline void ObjSpaceUVOffset(inout float2 screenUV, in float screenRatio)
		{
			// UNITY_MATRIX_P._m11 = Camera FOV
			float4 objPos = float4(-UNITY_MATRIX_T_MV[3].x * screenRatio * UNITY_MATRIX_P._m11, -UNITY_MATRIX_T_MV[3].y * UNITY_MATRIX_P._m11, UNITY_MATRIX_T_MV[3].z, UNITY_MATRIX_T_MV[3].w);

			float offsetFactorX = 0.5;
			float offsetFactorY = offsetFactorX * screenRatio;
			offsetFactorX *= _SketchTex_ST.x;
			offsetFactorY *= _SketchTex_ST.y;

			if (unity_OrthoParams.w < 1)	//don't scale with orthographic camera
			{
				//adjust uv scale
				screenUV -= float2(offsetFactorX, offsetFactorY);
				screenUV *= objPos.z;	//scale with cam distance
				screenUV += float2(offsetFactorX, offsetFactorY);

				// sign(UNITY_MATRIX_P[1].y) is different in Scene and Game views
				screenUV.x -= objPos.x * offsetFactorX * sign(UNITY_MATRIX_P[1].y);
				screenUV.y -= objPos.y * offsetFactorY * sign(UNITY_MATRIX_P[1].y);
			}
			else
			{
				// sign(UNITY_MATRIX_P[1].y) is different in Scene and Game views
				screenUV.x += objPos.x * offsetFactorX * sign(UNITY_MATRIX_P[1].y);
				screenUV.y += objPos.y * offsetFactorY * sign(UNITY_MATRIX_P[1].y);
			}
		}

		//Vertex input
		struct appdata_tcp2
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
			float4 texcoord1 : TEXCOORD1;
			float4 texcoord2 : TEXCOORD2;
			float4 tangent : TANGENT;
	#if UNITY_VERSION >= 550
			UNITY_VERTEX_INPUT_INSTANCE_ID
	#endif
		};

		//================================================================
		// VERTEX FUNCTION

		void vert(inout appdata_tcp2 v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			float3 worldN = UnityObjectToWorldNormal(v.normal);

			//Sketch
			float4 pos = UnityObjectToClipPos(v.vertex);
			o.sketchUv = ComputeScreenPos(pos);
			o.sketchUv.xy = TRANSFORM_TEX(o.sketchUv, _SketchTex);
	#if defined(UNITY_PASS_FORWARDBASE)
			o.ambient = ShadeSH9(float4(worldN,1.0));
	#endif
		}

		//================================================================
		// SURFACE FUNCTION

		void surf(Input IN, inout SurfaceOutputCustom o)
		{
			fixed4 mainTex = tex2D(_MainTex, IN.UV_MAINTEX);

			//Masks
			fixed4 mask1 = tex2D(_Mask1, IN.UV_MAINTEX);
			o.Albedo = mainTex.rgb * _Color.rgb;
			o.Emission = 0;	//needed so that surface shader takes emission into account if o.Emission is written inside an #if/#endif block
			o.Alpha = mainTex.a * _Color.a;
	
			//Cutout (Alpha Testing)
			clip (o.Alpha - _Cutoff);

			//Sketch
			float2 screenUV = IN.sketchUv.xy / IN.sketchUv.w;
			float screenRatio = _ScreenParams.y / _ScreenParams.x;
			screenUV.y *= screenRatio;
			ObjSpaceUVOffset(screenUV, screenRatio);
			o.ScreenUVs = screenUV;

			//Normal map
			half4 normalMap = tex2D(_BumpMap, IN.uv_BumpMap.xy);
			o.Normal = UnpackNormal(normalMap);

			//Custom Ambient
			half3 customAmbient = IN.ambient;	//either Dir_Ambient or regular Unity SH ambient
			//Occlusion Map
			fixed occlusion = tex2D(_OcclusionMap, IN.UV_MAINTEX).a;
			customAmbient *= occlusion;
			o.Emission += customAmbient * o.Albedo;
		}

		ENDCG
	}

	Fallback "Diffuse"
	CustomEditor "TCP2_MaterialInspector_SG"
}
