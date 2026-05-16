#include "MaterialConstantBuffer.h"
#include "Engine/Math/EngineMath.h"

FMaterialConstantBuffer::FMaterialConstantBuffer()
    : MaterialType(0)  
    , BaseColor(0.5f, 0.5f, 0.5f, 1.f)
    , Roughness(0.2f)
    , TransformInformation(EngineMath::IdentityMatrix4x4())
{
}
