#pragma once
#include "../Core/ActorObject.h"
#include "Engine/Component/Light/ParallelLightComponent.h"

class GParallelLight : public GActorObject
{
    CVARIABLE()
    CParallelLightComponent* ParallelLightComponent;

public:
    
};
