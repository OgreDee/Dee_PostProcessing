# Dee后处理

## 简单后期

### 高斯模糊
#### 实现思路

> 首先降采样，然后分别在横、纵两个方向使用高斯核对图片进行过滤

![image](https://github.com/OgreDee/Dee_PostProcessing/blob/master/pic/PostPressing_Blur.jpg)
> [参考](https://blog.csdn.net/u011047171/article/details/47977441)

> 概率论-正态分布

### 调整亮度、对比度、饱和度

> 亮度修改: color*亮度值

> 对比度: lerp(splitColor,color, 对比度)

> 饱和度: 偏离灰度越大，饱和度约高，越靠近约低, lerap(grayCol, col, 饱和度值)

> 下图是调高了亮度， 增加对比度、饱和度后的效果

![image](https://github.com/OgreDee/Dee_PostProcessing/blob/master/pic/PostPressing_Color.png)

### 泛光

#### 实现思路
> 首先降采样，提取亮度高于阈值的部分，对过滤的图片进行模糊（实现衍射），最后把处理的图片和原图叠加

![image](https://github.com/OgreDee/Dee_PostProcessing/blob/master/pic/PostPressing_Bloom.png)

### 运动模糊
#### 累积缓存

##### 实现思路
> 存储前一帧的图像,渲染时，RenderTexture.MarkRestoreExpected()恢复, 与当前帧blend
混合使用了两个PASS, 第一个blend, 第二个重置alpha

> 效果图如下
![image](https://github.com/OgreDee/Dee_PostProcessing/blob/master/pic/PostProcessing_MotionBlur.png)

#### 速度缓存
##### 实现思路
> (1)保存上一帧的VP矩阵(世界坐标转视坐标转裁剪坐标)
> (2)shader中获取深度depth,倒推NDC坐标(uv.x * 2 - 1, uv.y *2 - 1, depth*2 - 1, 1), 应用当前Matrix_PV倒推世界坐标,然后应用上一帧的VP矩阵得到上一帧这个世界坐标点的NDC坐标，用两次ndc坐标的距离计算速度。

> 这种实现只对相机运动，RenderObject没有运动的情况有效果。

## 基于深度和法线纹理的后期
### 了解深度图

> [Unity Shader - 深度图基础及应用](https://www.jianshu.com/p/80a932d1f11e)

> [Unity Shader中的ComputeScreenPos函数](https://www.jianshu.com/p/df878a386bec)

> [神奇的深度图：复杂的效果，不复杂的原理](https://zhuanlan.zhihu.com/p/27547127?refer=chenjiadong)

> [全面认识Depth - 这里有关于Depth的一切](https://zhuanlan.zhihu.com/p/25095708)

### 雾
### 实现思路
> 依然是根据深度获取世界坐标，雾计算方式：线性、指数、指数平方。

> linear: (dmax - z) / (dmax - dmin)      dmax、dmin雾的最大、小距离

> exponential: e^(-d*|z|) d为浓度

> 指数平方: e^(-(d-|z|)^2) d为浓度

