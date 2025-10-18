![[Pasted image 20251018173136.png]]

### 各向同性PBR所需公式：
#### 直接光 BRDF：

- 菲涅尔项（Fresnel Term）

Schlick近似（此次使用）：
$$F = F_0 + (1 - F_0)(1 - \cos\theta)^5$$

- Cook-Torrance物理模型：
$$F_{\text{CT}} = \frac{1}{2}\left(\frac{g - c}{g + c}\right)^2 \left[1 + \left(\frac{c(g + c) - 1}{c(g - c) + 1}\right)^2\right]$$
其中：
 $$c = |\mathbf{i} \cdot \mathbf{n}|$$
 $$g = \sqrt{\left(\frac{n_t}{n_i}\right)^2 - 1 + c^2}$$

- 法线分布函数（Normal Distribution Function）

GGX/Trowbridge-Reitz分布：
$$D_{\text{GGX}} = \frac{\alpha^2}{\pi[(\mathbf{n} \cdot \mathbf{h})^2(\alpha^2 - 1) + 1]^2}$$

- 几何函数（Geometry Function）

Smith联合遮蔽阴影函数：
$$G_{\text{Smith}} = \frac{0.5}{\lambda_V + \lambda_L}$$
其中：
 $$\lambda_V = (\mathbf{n} \cdot \mathbf{l}) \sqrt{(\mathbf{n} \cdot \mathbf{v})^2(1 - \alpha^2) + \alpha^2}$$
$$\lambda_L = (\mathbf{n} \cdot \mathbf{v}) \sqrt{(\mathbf{n} \cdot \mathbf{l})^2(1 - \alpha^2) + \alpha^2}$$

分离式Smith函数：
$$G_1(\mathbf{v}, \mathbf{m}, \mathbf{n}, \alpha^2) = \chi\left(\frac{\mathbf{v} \cdot \mathbf{m}}{\mathbf{v} \cdot \mathbf{n}}\right) \cdot \frac{2}{1 + \sqrt{1 + \alpha^2\left(\frac{1}{(\mathbf{v} \cdot \mathbf{n})^2} - 1\right)}}$$

 - BRDF核心方程

Cook-Torrance微表面模型：
$$f_r(\mathbf{i}, \mathbf{o}) = \frac{F(\mathbf{i}, \mathbf{h}_r) \cdot D(\mathbf{n}, \mathbf{h}_r) \cdot G(\mathbf{i}, \mathbf{o}, \mathbf{n}, \mathbf{h}_r)}{4|\mathbf{n} \cdot \mathbf{i}||\mathbf{n} \cdot \mathbf{o}|}$$

- 各项同性可见性函数（V）

优化形式：
$$V = \frac{0.5}{(\mathbf{n} \cdot \mathbf{l})[(\mathbf{n} \cdot \mathbf{v})(1 - \alpha) + \alpha] + (\mathbf{n} \cdot \mathbf{v})\sqrt{(1 - \alpha)^2(\mathbf{n} \cdot \mathbf{l})^2 + \alpha^2}}$$

- 基础反射率计算

金属度插值：
$$F_0 = \text{lerp}(0.04, \text{albedo}, \text{metallic})$$

符号说明

| 符号 | 含义 |
|------|------|
| $$\mathbf{i}$$ | 入射光方向 |
| $$\mathbf{o}$$ | 观察方向 |
| $$\mathbf{n}$$ | 表面法线 |
| $$\mathbf{h}_r$$ | 半角向量：$$\mathbf{h}_r = \frac{\mathbf{i} + \mathbf{o}}{\|\mathbf{i} + \mathbf{o}\|}$$ |
| $$\alpha$$ | 粗糙度参数：$$\alpha = \text{roughness}^2$$ |
| $$F_0$$ | 基础反射率 |
| $$\theta$$ | 入射角：$$\cos\theta = \mathbf{i} \cdot \mathbf{n}$$ |

关键关系

- **粗糙度转换**：$$\alpha = \text{roughness}^2$$
- **半角向量**：$$\mathbf{h}_r = \text{normalize}(\mathbf{i} + \mathbf{o})$$
- **分母修正项**：$$4(\mathbf{n} \cdot \mathbf{i})(\mathbf{n} \cdot \mathbf{o})$$

只计算BRDF直接光得到
![[Pasted image 20251018175459.png]]


#### 间接光
一般更真实的作法是通过IBL图像照明，但实时渲染中则使用预计算得到的数据
所需数据：
- 反射探针
- 环境光

 间接光 = 环境漫反射 + 环境镜面反射 
$$I_{\text{indirect}} = I_{\text{diffuse}} + I_{\text{specular}}$$


在u6版本前 环境光一半需要手动放置光照探针获取，但u6给出了新的解决方案，可以使用自适应探针体积获取

**如何与金属度/粗糙度融合**




**环境漫反射**
$$I_{\text{diffuse}} = A \times C_{\text{albedo}} \times (1 - F_{\text{indirect}}) \times (1 - M)$$

$A$ = 环境光强度（来自自适应探针）
$C_{\text{albedo}}$ = 材质基础颜色（col.rgb）
$F_{\text{indirect}}$ = 间接菲涅尔项（indirectfresnel）
$M$ = 金属度（Metallic）

**环境镜面反射**
$$I_{\text{specular}} = E \times F_{\text{fresnel}}$$
当获取反射探针时候得到的是反射探针贴图，通过不同的mipmap来模拟粗糙度，得到的颜色
```cpp
float3 envColor      = GlossyEnvironmentReflection(reflectionDir, input.worldpos, Roughness, 1.0h,  
                    input.normalizedScreenSpaceUV);
```
$E$ = 环境反射颜色（envColor）
$F_{\text{fresnel}}$ = 菲涅尔项（fresnel） 




**菲涅尔项计算** 

$$F_{\text{fresnel}} = \text{lerp}(F_0, R, t) \times \frac{1}{\alpha^2 + 1}$$

$$R = F_0 + (1 - \text{roughness})$ $t = (1 - \mathbf{n} \cdot \mathbf{v})^4$$

$$\alpha = \text{roughness}^2$$

**间接菲涅尔项** 
$$F_{\text{indirect}} = F_0 + \text{saturate}(\mathbf{r} - F_D) \times (1 - \mathbf{n} \cdot \mathbf{v})^5$$

$$\mathbf{r} = (1 - \text{roughness}, 1 - \text{roughness}, 1 - \text{roughness})$$ 

$F_D$ = Schlick_Fresnel项（FD）

只计算间接光得到结果：
![[Pasted image 20251018175605.png]]

二者相加即可得到正确的pbr光照
![[Pasted image 20251018173136.png]]