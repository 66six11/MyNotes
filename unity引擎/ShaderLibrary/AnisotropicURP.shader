Shader "CustomRenderTexture/AnisotropicURP"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex("InputTex", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _AnisoTex("Anisotropic Tex", 2D) = "white" {}
        _AnisoOffset("Anisotropic Offset", Range(0,1)) = 0.0
        _AnisoStrength("Anisotropic Strength", Range(0,2)) = 1.0
        _AnisoColor("Anisotropic Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 normal : TEXCOORD3;
                float3 bitangent : TEXCOORD4;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _MainTex_ST;
                float _Glossiness;
                float _AnisoStrength;
                float4 _AnisoColor;
                float _AnisoOffset;
                TEXTURE2D(_AnisoTex);
                SAMPLER(sampler_AnisoTex);
            CBUFFER_END

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);
                o.normal = normalInput.normalWS;
                o.tangent = normalInput.tangentWS;
                o.bitangent = normalInput.bitangentWS;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float aniso = SAMPLE_TEXTURE2D(_AnisoTex, sampler_AnisoTex, i.uv).r;
                // 向量归一化
                float3 N = normalize(i.normal);
                float3 T = normalize(i.tangent + aniso * N * _AnisoOffset);
                float3 B = normalize(i.bitangent + aniso * N * _AnisoOffset);
                float3 V = GetWorldSpaceNormalizeViewDir(i.worldPos);
                
                // 获取主光源数据（含阴影和衰减）
                Light mainLight = GetMainLight();
                float3 L = mainLight.direction;
                float3 ligjtColor = mainLight.color * mainLight.distanceAttenuation * mainLight.shadowAttenuation;
                float3 H = normalize(L + V);
                
                // 基础颜色
                half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _Color;
                
                // 漫反射计算
                float NdotL = saturate(dot(N, L));
                float3 diffuse = ligjtColor* albedo.rgb * NdotL;
                
                // 各向异性高光（Kajiya-Kay模型）
                float dotTH = dot(B, H) ;
                float sinTH = sqrt(saturate(1 - dotTH * dotTH));
                float spec = pow(sinTH, _Glossiness * 128) * _AnisoStrength;
                float3 specular = _AnisoColor.rgb * ligjtColor * spec;
                
                // 环境光（URP标准方法）
                float3 ambient = SampleSH(N) * albedo.rgb;
                
                // 组合结果
                float3 finalColor = diffuse + ambient + specular;
                return half4(finalColor, 1.0);
            }
            ENDHLSL
        }
    }
}
