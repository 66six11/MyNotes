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

[^1]: [[BRDF推导]]


