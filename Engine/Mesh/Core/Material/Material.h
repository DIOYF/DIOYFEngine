#pragma once

#include "MaterialType.h"
#include "Engine/Core/CoreObject/CoreMinimalObject.h"

class CTransformationComponent;

class CMaterial : public CCoreMinimalObject
{
public:
    CMaterial();
    
    void SetBaseColor(const fvector_4d& InBaseColor) {BaseColor = InBaseColor;}
    void SetMaterialType(const EMaterialType& InMaterialType) {MaterialType = InMaterialType;}
    void SetRoughness(const float& InRoughness) {Roughness = InRoughness;}

    FORCEINLINE fvector_4d GetBaseColor() const {return BaseColor; }
    FORCEINLINE EMaterialType GetMaterialType() const {return MaterialType;}
    FORCEINLINE float GetRoughness() const {return Roughness;}

private:
    fvector_4d BaseColor;
    float Roughness;

    EMaterialType MaterialType;
};