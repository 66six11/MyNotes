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

使用从屏幕像素光线步进的思路进行
所需数据：
- 深度信息
- 屏幕像素坐标
- SDF函数

计算过程

![[Pasted image 20251018142302.png|300]]

