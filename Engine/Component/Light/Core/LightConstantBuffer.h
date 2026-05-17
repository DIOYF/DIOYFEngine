#pragma once
#include "../../../EngineMinimal.h"

struct FLightConstantBuffer
{
    FLightConstantBuffer();

    XMFLOAT3 LightIntensity;
    float XXX;
    XMFLOAT3 LightDirection;
    float XXX2;
};