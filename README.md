# Dee后处理

## 高斯模糊
#### 实现思路

> 首先降采样，然后分别在横、纵两个方向使用高斯核对图片进行过滤

![image](https://github.com/OgreDee/Dee_PostProcessing/blob/master/pic/PostPressing_Blur.jpg)
> [参考](https://blog.csdn.net/u011047171/article/details/47977441)

> 概率论-正态分布

## 调整亮度、对比度、饱和度

> 亮度修改: color*亮度值

> 对比度: lerp(splitColor,color, 对比度)

> 饱和度: 偏离灰度越大，饱和度约高，越靠近约低, lerap(grayCol, col, 饱和度值)

> 下图是调高了亮度， 增加对比度、饱和度后的效果

![image](https://github.com/OgreDee/Dee_PostProcessing/blob/master/pic/PostPressing_Color.png)

## 泛光

#### 实现思路
> 首先降采样，提取亮度高于阈值的部分，对过滤的图片进行模糊（实现衍射），最后把处理的图片和原图叠加

![image](https://github.com/OgreDee/Dee_PostProcessing/blob/master/pic/PostPressing_Bloom.png)

## 运动模糊
### 累积缓存

#### 实现思路
> 存储前一帧的图像,渲染时，RenderTexture.MarkRestoreExpected()恢复, 与当前帧blend
混合使用了两个PASS, 第一个blend, 第二个重置alpha

> 效果图如下
![image](https://github.com/OgreDee/Dee_PostProcessing/blob/master/pic/PostProcessing_MotionBlur.png)

### 速度缓存

> (待加)
