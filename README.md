# DIOYFEngine

DIOYFEngine 是一个基于 DirectX12 C++ 的图形引擎练习项目，当前主要面向 Windows 平台开发，项目中包含基础引擎框架、平台层代码，以及独立的 `simple_library` 公共库模块。

## 项目结构

```text
DIOYFEngine
├─ Engine/                     # 引擎主体代码
│  ├─ Core/                    # 核心对象与基础引擎接口
│  ├─ Platform/Windows/        # Windows 平台实现
│  └─ Rendering/               # 渲染相关代码
├─ simple_library/             # 通用基础库
│  ├─ public/                  # 对外头文件
│  └─ private/                 # 具体实现
├─ Shader/                     # 着色器文件
├─ DIOYFEngine.sln             # Visual Studio 解决方案
└─ DIOYFEngine.vcxproj         # Visual Studio C++ 项目文件
```

## 开发环境

- Windows
- Visual Studio 2022
- MSVC v143 工具集
- Windows 10 SDK

## 构建方式

1. 使用 Visual Studio 打开 `DIOYFEngine.sln`
2. 选择目标配置，例如：
   - `Debug | x64`
   - `Release | x64`
3. 执行“生成解决方案”

## 当前构建约定

项目中的大量头文件使用了从仓库根目录开始的包含方式，例如：

```cpp
#include "simple_library/public/simple_math/simple_math.h"
```

因此项目配置中需要将项目根目录加入附加包含目录：

```xml
<AdditionalIncludeDirectories>$(ProjectDir);%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
```




