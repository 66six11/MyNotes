> [!note]
> unity6中的后处理RenderFeature与之前的流程不同
> 在unity6中，后处理流程使用RDG渲染流程
> 核心方法是RecordRinderGraph
> 另外使用的shader在编写上也有不同，需要利用到



## 编写自定义后处理