#pragma once
#include "../../../../../Interface/DirectXDeviceInterface.h"
#include "../../../RenderingResourcesUpdate.h"

struct FConstantBufferViews :public IDirectXDeviceInterfece_Struct
{
    void CreateConstant(UINT ObjectSize,UINT ObjectCount);

    void Update(int Index, const void* InData);

    void BuildConstantBuffer(
        CD3DX12_CPU_DESCRIPTOR_HANDLE InHandle,
        UINT InConstantBufferNum,
        UINT InHandleOffset = 0);
protected:
    shared_ptr<FRenderingResourcesUpdate> Constant;
};