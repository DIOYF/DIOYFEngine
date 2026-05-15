#pragma once
#include "../Core/Engine.h"

#if defined(_WIN32)
class CWindowsEngine;
#else
class CEngine;
#endif

//提供渲染内容的接口
class IDirectXDeviceInterfece
{
public:
    ComPtr<ID3D12Fence> GetFence();
    ComPtr<ID3D12Device> GetD3dDevice();

    ComPtr<ID3D12GraphicsCommandList> GetGraphicsCommandList();
    ComPtr<ID3D12CommandAllocator> GetCommandAllocator();
    ComPtr<ID3D12CommandQueue> GetCommandQueue();

    UINT64 GetCurrentFenceIndex();
    HWND GetMianWindowsHandle();

#if defined(_WIN32)
    CWindowsEngine* GetEngine();
#else
    CEngine* GetEngine();
#endif
};

//提供渲染内容的接口
struct IDirectXDeviceInterfece_Struct
{
public:
    ComPtr<ID3D12Fence> GetFence();
    ComPtr<ID3D12Device> GetD3dDevice();

    ComPtr<ID3D12GraphicsCommandList> GetGraphicsCommandList();
    ComPtr<ID3D12CommandAllocator> GetCommandAllocator();
    ComPtr<ID3D12CommandQueue> GetCommandQueue();

    UINT64 GetCurrentFenceIndex();
    HWND GetMianWindowsHandle();

#if defined(_WIN32)
    CWindowsEngine* GetEngine();
#else
    CEngine* GetEngine();
#endif

private:
    IDirectXDeviceInterfece Interfece;
};