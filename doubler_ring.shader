// Copyright (c) 2019 @Feyris77
// Released under the MIT license
// https://opensource.org/licenses/mit-license.php
Shader "Unlit/Double_Ring"
{
	Properties
	{
		[IntRange] _Tessellation("Particle Amount", Range(1, 32)) = 8
		_Size("Particle Size", float) = 0.1
		_Speed("Speed", float) = 1
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Transparent-1"}
		LOD 100
		Blend One One
		ZWrite off

		Pass
		{
			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma hull Hull
			#pragma domain Domain
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2h {
				float4 pos : SV_POSITION;
				float2 uv  : TEXCOORD0;
			};

			struct h2d
			{
				float4 pos : SV_POSITION;
				float2 uv  : TEXCOORD0;
			};

			struct h2dc
			{
				float Edges[3] : SV_TessFactor;
				float Inside : SV_InsideTessFactor;
			};

			struct d2g
			{
				float4 pos : SV_POSITION;
				float2 uv  : TEXCOORD0;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 col : TEXCOORD1;
			};


			uniform float _Tessellation, _Size, _Speed;

			#define ADD_VERT(u, v) \
                o.uv = float2(u, v); \
                o.pos = vp + float4(u*ar, v, 0, 0)*_Size; \
                TriStream.Append(o);

			float2 rot(float2 p, float r)
			{
				float c = cos(r);
				float s = sin(r);
				return mul(p, float2x2(c, -s, s, c));
			}

			float3 rand3D(float3 p)
			{
				p = float3(dot(p,float3(127.1, 311.7, 74.7)),
							dot(p,float3(269.5, 183.3,246.1)),
							dot(p,float3(113.5,271.9,124.6)));
				return frac(sin(p) * 43758.5453123);
			}

			v2h vert(appdata_base  v)
			{
				v2h o;
				o.pos = v.vertex;
				o.uv = v.texcoord;
				return o;
			}

			h2dc HullConst(InputPatch<v2h, 3> i)
			{
				h2dc o;
				float3 retf;
				float  ritf, uitf;
				ProcessTriTessFactorsAvg(_Tessellation.xxx, 1, retf, ritf, uitf);
				o.Edges[0] = retf.x;
				o.Edges[1] = retf.y;
				o.Edges[2] = retf.z;
				o.Inside = ritf;
				return o;
			}

			[domain("tri")]
			[partitioning("integer")]
			[outputtopology("triangle_cw")]
			[outputcontrolpoints(3)]
			[patchconstantfunc("HullConst")]
			h2d Hull(InputPatch<v2h, 3> IN, uint id : SV_OutputControlPointID)
			{
				h2d o;
				o.pos = IN[id].pos;
				o.uv = IN[id].uv;
				return o;
			}

			[domain("tri")]
			d2g Domain(h2dc hs_const_data,  OutputPatch<h2d, 3> i, float3 bary: SV_DomainLocation)
			{
				d2g o;
				o.pos = i[0].pos * bary.x + i[1].pos * bary.y + i[2].pos * bary.z;
				o.uv = i[0].uv * bary.x + i[1].uv * bary.y + i[2].uv * bary.z;
				return o;
			}

			[maxvertexcount(3)]
			void geom(point d2g IN[1],inout TriangleStream<g2f> TriStream)
			{
				g2f o;
				float3 pos = rand3D(IN[0].pos.xyz) * 2 - 1;
				float3 rand0 = rand3D(pos.yxz) * 2 - 1;
				float3 rand1 = rand3D(pos.zyx) * 2 - 1;
				float3 rand3 = rand3D(pos.xyz);
				float3 rand2 = rand3D(pos.xyz) - 0.5;
				float PI=acos(-1);
				float t = _Time.y * .05 * _Speed;
				pos.z = sin(rand0 * t);//Circle
				pos.x = cos(rand0 * t);//Circle
				pos.y = (0.2 * rand0); //y軸つぶし
				pos.y=clamp(pos.y,-0.05,0.05);//枠線強調
				pos.y += pos.x * sin(t) * 0.5;//上下運動

				o.col = float4((sin(abs(pos) * 10) * 0.57 + 0.6) * .001, 1);

				float ar = -UNITY_MATRIX_P[0][0] / UNITY_MATRIX_P[1][1]; //Aspect Ratio
				float4 vp = UnityObjectToClipPos(float4(pos, 1));
				ADD_VERT(0.0,  1.0);
				ADD_VERT(-0.9, -0.5);
				ADD_VERT(0.9, -0.5);
				TriStream.RestartStrip();
			}

			float4 frag(g2f i) : SV_Target
			{
				return saturate(.5 - length(i.uv)) * clamp(i.col / pow(length(i.uv), 2), 0, 2);
			}
			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma hull Hull
			#pragma domain Domain
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2h {
				float4 pos : SV_POSITION;
				float2 uv  : TEXCOORD0;
			};

			struct h2d
			{
				float4 pos : SV_POSITION;
				float2 uv  : TEXCOORD0;
			};

			struct h2dc
			{
				float Edges[3] : SV_TessFactor;
				float Inside : SV_InsideTessFactor;
			};

			struct d2g
			{
				float4 pos : SV_POSITION;
				float2 uv  : TEXCOORD0;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 col : TEXCOORD1;
			};


			uniform float _Tessellation, _Size, _Speed;

			#define ADD_VERT(u, v) \
                o.uv = float2(u, v); \
                o.pos = vp + float4(u*ar, v, 0, 0)*_Size; \
                TriStream.Append(o);

			float2 rot(float2 p, float r)
			{
				float c = cos(r);
				float s = sin(r);
				return mul(p, float2x2(c, -s, s, c));
			}

			float3 rand3D(float3 p)
			{
				p = float3(dot(p,float3(127.1, 311.7, 74.7)),
							dot(p,float3(269.5, 183.3,246.1)),
							dot(p,float3(113.5,271.9,124.6)));
				return frac(sin(p) * 43758.5453123);
			}

			v2h vert(appdata_base  v)
			{
				v2h o;
				o.pos = v.vertex;
				o.uv = v.texcoord;
				return o;
			}

			h2dc HullConst(InputPatch<v2h, 3> i)
			{
				h2dc o;
				float3 retf;
				float  ritf, uitf;
				ProcessTriTessFactorsAvg(_Tessellation.xxx, 1, retf, ritf, uitf);
				o.Edges[0] = retf.x;
				o.Edges[1] = retf.y;
				o.Edges[2] = retf.z;
				o.Inside = ritf;
				return o;
			}

			[domain("tri")]
			[partitioning("integer")]
			[outputtopology("triangle_cw")]
			[outputcontrolpoints(3)]
			[patchconstantfunc("HullConst")]
			h2d Hull(InputPatch<v2h, 3> IN, uint id : SV_OutputControlPointID)
			{
				h2d o;
				o.pos = IN[id].pos;
				o.uv = IN[id].uv;
				return o;
			}

			[domain("tri")]
			d2g Domain(h2dc hs_const_data,  OutputPatch<h2d, 3> i, float3 bary: SV_DomainLocation)
			{
				d2g o;
				o.pos = i[0].pos * bary.x + i[1].pos * bary.y + i[2].pos * bary.z;
				o.uv = i[0].uv * bary.x + i[1].uv * bary.y + i[2].uv * bary.z;
				return o;
			}

			[maxvertexcount(3)]
			void geom(point d2g IN[1],inout TriangleStream<g2f> TriStream)
			{
				g2f o;
				float3 pos = rand3D(IN[0].pos.xyz) * 2 - 1;
				float3 rand0 = rand3D(pos.yxz) * 2 - 1;
				float3 rand1 = rand3D(pos.zyx) * 2 - 1;
				float3 rand3 = rand3D(pos.xyz);
				float3 rand2 = rand3D(pos.xyz) - 0.5;
				float PI=acos(-1);
				float t = _Time.y * .05 * _Speed;
				pos.z = sin(rand0  * t);//Circle
				pos.x = cos(rand0 * t);//Circle
				pos.y = (0.2 * rand0); //y軸つぶし
				pos.y=clamp(pos.y,-0.05,0.05);
				pos.y -= pos.x * sin(t) * 0.5;//上下運動
				o.col = float4((sin(abs(pos) * 10) * 0.57 + 0.6) * .001, 1);
				float ar = -UNITY_MATRIX_P[0][0] / UNITY_MATRIX_P[1][1]; //Aspect Ratio
				float4 vp = UnityObjectToClipPos(float4(pos, 1));
				ADD_VERT(0.0,  1.0);
				ADD_VERT(-0.9, -0.5);
				ADD_VERT(0.9, -0.5);
				TriStream.RestartStrip();
			}

			float4 frag(g2f i) : SV_Target
			{
				return saturate(.5 - length(i.uv)) * clamp(i.col / pow(length(i.uv), 2), 0, 2);
			}
			ENDCG
		}
	}
}