#pragma once
#include "../../../EngineMinimal.h"

struct FMaterialConstantBuffer
{
    FMaterialConstantBuffer();

    int MaterialType;

    int r1;
    int r2;
    int r3;

    XMFLOAT4 BaseColor;
    float Roughness;
    XMFLOAT4X4 TransformInformation;
    
};

