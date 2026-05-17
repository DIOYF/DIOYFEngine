#pragma once
#include "../../../EngineMinimal.h"

struct FMaterialConstantBuffer
{
    FMaterialConstantBuffer();

    int MaterialType;
    float Roughness;
    int r2;
    int r3;

    XMFLOAT4 BaseColor;
    XMFLOAT4X4 TransformInformation;
    
};

