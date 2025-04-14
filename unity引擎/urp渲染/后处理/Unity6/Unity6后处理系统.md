> [!note]
> unity6中的后处理RenderFeature与之前的流程不同
> 在unity6中，后处理流程使用RDG渲染流程
> 核心方法是RecordRinderGraph
> 另外使用的shader在编写上也有不同，需要利用到` # include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl" `
> 使用其中的
> 
> ```hlsl
> struct Attributes  
> {  
>     uint vertexID : SV_VertexID;  
>     UNITY_VERTEX_INPUT_INSTANCE_ID  
> };
> //这样的方式进行顶点处理
> Varyings Vert(Attributes input)  
> {  
>     Varyings output;  
>     UNITY_SETUP_INSTANCE_ID(input);  
>     UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);  
>   
>     float4 pos = GetFullScreenTriangleVertexPosition(input.vertexID);  
>     float2 uv  = GetFullScreenTriangleTexCoord(input.vertexID);  
>   
>     output.positionCS = pos;  
>     output.texcoord   = DYNAMIC_SCALING_APPLY_SCALEBIAS(uv);  
>   
>     return output;  
> }
> 
> ```



## 编写自定义后处理




