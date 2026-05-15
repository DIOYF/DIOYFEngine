#pragma once

#if defined(_WIN32)
#include "../../Core/Engine.h"
#include "../../Rendering/Engine/Core/RenderingEngine.h"

class CDirectXRenderingEngine;
class CWorld;

class CWindowsEngine :public CEngine
{
    friend class IDirectXDeviceInterfece;
public:
    CWindowsEngine();
    ~CWindowsEngine();

    virtual int PreInit(FWinMainCommandParameters InParameters);

    virtual int Init(FWinMainCommandParameters InParameters);
    virtual int PostInit();

    virtual void Tick(float DeltaTime);

    virtual int PreExit();
    virtual int Exit();
    virtual int PostExit();

    CDirectXRenderingEngine* GetRenderingEngine() { return RenderingEngine; }
public:

    bool InitWindows(FWinMainCommandParameters InParameters);

protected:
    HWND MianWindowsHandle;//主windows句柄

protected:
    CDirectXRenderingEngine* RenderingEngine;
    CWorld* World;
};
#endif