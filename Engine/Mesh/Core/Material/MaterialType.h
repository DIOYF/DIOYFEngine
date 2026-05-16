#pragma once

enum EMaterialType
{
    Lambert = 0,
    HalfLambert, // 粗糙表面
    Phong, // 金属
    BlinnPhong, // 金属
    WrapLight, // 模拟皮肤
    Minnaert, // 天鹅绒，月球
    Banded, // 卡通效果
    GradualBanded, // 渐变卡通
    FinalBanded, // 最终的卡通材质
    Fresnel = 100,
    Max,
};