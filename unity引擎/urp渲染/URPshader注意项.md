# 多Pass渲染
> 每一个pass都需要不同的lightmode分配

# 深度写入
> 需要单独的Pass写入深度
> 必须包含顶点着色器

```hlsl
Pass  
{  
    Name "DepthOnly"  
    Tags { "LightMode" = "DepthOnly" }  
  
    ZWrite On  
    ColorMask 0  
    Cull Off  
  
    HLSLPROGRAM  
    #pragma vertex vert  
    #pragma fragment frag  
  
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"  
  
    struct appdata  
    {  
        float4 vertex : POSITION;  
        float2 uv : TEXCOORD0;  
    };  
    struct v2f  
    {     
		float4 vertex : SV_POSITION;  
        float2 uv : TEXCOORD0;  
    };  
    v2f vert(appdata v)  
    {        v2f o;  
        o.vertex = TransformObjectToHClip(v.vertex);  
        o.uv = v.uv;  
        return o;  
    }  
    half4 frag(v2f i) : SV_TARGET  
    {  
        return 0;  
    }    ENDHLSL  
}
```