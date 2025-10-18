## 球形SDF

```cpp
//球形SDF的表达如下
float SdSphere(float3 p, float3 center, float radius)  
{  
    return distance(p, center) - radius;  
}
```




### 渲染

### 渲染思路

使用从**屏幕像素光线步进**的思路进行
 **所需数据：**
- ​**​深度信息​**​：用于防止超出距离
    
- ​**​屏幕像素坐标​**​：确定光线起始方向（从相机出发穿过像素）
    
- ​**​SDF 函数​**​：计算场景中任意点到表面的最短距离

**计算过程**

像素计算：
- 在片元着色器中，从**相机位置**开始步进，步进方向是**像素世界坐标**
- 每次步进 从sdf函数获取 **距离**，下次步进直接按照该距离步进
- 检测是否击中，若未击中则继续步进

法线计算：

**方式一**：对于球形sdf可以直接用像`中心坐标与素坐标的向量`得到法线方向

**方式二**： 更符合的方案，使用梯度推导法线，在三个方向上分别偏移采样得到梯度

```cpp
// 计算法线函数  
float3 ComputeNormal(float3 p)  
{  
    const float eps = 0.001;  
    return normalize(float3(  
        MetaballSDF(p + float3(eps, 0, 0)) - MetaballSDF(p - float3(eps, 0, 0)),  
        MetaballSDF(p + float3(0, eps, 0)) - MetaballSDF(p - float3(0, eps, 0)),  
        MetaballSDF(p + float3(0, 0, eps)) - MetaballSDF(p - float3(0, 0, eps))  
    ));
}
```

得到这些数据后便可以进行常见的光照计算了

![[Pasted image 20251018142302.png|300]]

### 液化融合

可以走两种不同的渲染方式：
方式一：通过走计算着色器加后处理的方式进行渲染（大量物体）
方式二：在不同物体上给材质，shader间使用全局属性使用脚本进行数据传递

这里使用方式二
```cpp
uniform float4 _BallPositions[10];  
uniform float  _BallRadii[10];  
uniform int    _BallCount;  
uniform float  _SmoothFactor = 0.5;
```
然后shader对每一个球，使用球形sdf平滑求值
```hlsl
float MetaballSDF(float3 position)  
{  
    float sdf = 100000; // 初始化为大值  
  
    if (_BallCount > 0)  
    {   for (int i = 0; i < _BallCount; i++)  
        {   
	        float3 ballPos    = _BallPositions[i].xyz;  
            float  ballRadius = _BallRadii[i];  
            float  sphereSdf  = SdSphere(position, ballPos, ballRadius);  
            sdf               = smin(sdf, sphereSdf, _SmoothFactor);  
        }    
    }   
    else  
    {  
        // 默认球体  
        sdf = SdSphere(position, float3(0, 0, 0), _SphereRadius);  
    }  
    return sdf;  
}

////////////

// 平滑最小值函数（用于融合效果）  
float smin(float a, float b, float k)  
{  
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);  
    return lerp(b, a, h) - k * h * (1.0 - h);  
}
```
方法二需要注意的点是，对与物体（如立方体）渲染的时候，立方体应该尽量大，设置的球半径尽量小，这样在融合时候才不会出现渲染缺失的情况

渲染结果如下
![[Pasted image 20251018150717.png|300]]
