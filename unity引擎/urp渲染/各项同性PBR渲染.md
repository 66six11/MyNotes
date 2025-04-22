---
aliases:
  - BRDF
  - 基于物理的渲染
tags:
  - BRDF
  - PBR
  - Cook-Torrance-BRDF
description: 
日期: 2025-04-21
---



![|300](Pasted%20image%2020250420221503.png)
## 核心原理
>### Cook-Torrance BRDF[^1]
> BRDF直接高光 + 直接光漫反射 + 间接光漫反射模拟 + 间接高光高光模拟
> > [!info] 注意
>  > 在实时渲染中，间接光部分的计算更为重要 
---
### 直接光部分

#### 高光
> BRDF高光
#### 漫反射
> Lambert模型/Blinn-Phong
---
### 间接光部分
> [[IBL基于图像照明|IBL]]环境光

#### 高光
> 反射贴图-基于反射探针

#### 漫反射
> 环境光采样-基于光照探针/[[自适应探针体积APV]]

![[51ce6fd26b8ea72f3c18cf337b96e1d9.png]]

那个 $\hat{\Lambda}$ 公式不是直接从第一个 $\Lambda$ 公式的代换来的 各向异性复杂一些 它考虑了 roughness 在不同方向（t 和 b 方向）都不一样 那个 $\hat{\Lambda}$ 公式是根据各向异性 GGX 的特点 算微平面互相遮挡时推导出来的 里面结合了不同方向的 roughness 和光线（或视线）方向

就是把各向异性那个 $\hat{\Lambda}$ 公式里的 $a_t$ 和 $a_b$ 都换成同一个 $a$。
然后里面就有 $a^2 (t \cdot l)^2 + a^2 (b \cdot l)^2$ 这项，可以把 $a^2$ 提出来变成 $a^2 ((t \cdot l)^2 + (b \cdot l)^2)$。
因为 $t, b, n$ 是正交基，对于向量 $l$ 来说， $(t \cdot l)^2 + (b \cdot l)^2 + (n \cdot l)^2 = |l|^2 = 1$。
所以 $(t \cdot l)^2 + (b \cdot l)^2 = 1 - (n \cdot l)^2$。
代回去就是 $a^2 (1 - (n \cdot l)^2) + (n \cdot l)^2$ 开根号。
你看，结果里就没有 $t \cdot l$ 和 $b \cdot l$ 这些跟方向有关的项了，只剩下 $a$ 和 $n \cdot l$ 了，就变成各项同性的了。

[^1]: [[BRDF推导]]


