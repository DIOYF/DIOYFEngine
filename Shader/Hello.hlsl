#include "Light.hlsl"
#include "Material.hlsl"


cbuffer ObjectConstBuffer :register(b0)//b0->b14
{
	float4x4 WorldMatrix;
}

cbuffer ViewportConstBuffer : register(b1)//b0->b14
{
	float4 ViewportPosition;
	float4x4 ViewProjectionMatrix;
}

cbuffer MaterialConstBuffer : register(b2)//b0->b14
{
	int materialType;

	
	float4 BaseColor;
	float MaterialRoughness;
	float4x4 TransformInformation;
}

cbuffer LightConstBuffer : register(b3)//b0->b14
{
	float3 LightIntensity;
	float3 LightDirection;
}


struct MeshVertexIn
{
	float3 Position : POSITION;
	float4 Color : COLOR;
	float3 Normal : NORMAL;
};

struct MeshVertexOut
{
	float4 WorldPosition : POSITION;
	float4 Position : SV_POSITION;
	float4 Color : COLOR;
	float3 Normal : NORMAL;
};

MeshVertexOut VertexShaderMain(MeshVertexIn MV)
{
	MeshVertexOut Out;

	float4 Position = mul(float4(MV.Position, 1.f), WorldMatrix);
	//Out.Position = Position;
	
	Out.WorldPosition = Position;
	Out.Position = mul(Position, ViewProjectionMatrix);

	Out.Normal = mul(MV.Normal, (float3x3)WorldMatrix);

	Out.Color = MV.Color;
	
	return Out;
}

float4 PixelShaderMain(MeshVertexOut MVOut) :SV_TARGET
{
	FMaterial material;
	material.BaseColor = BaseColor;

	
	float4 AmbientLight = {0.15, 0.15, 0.25, 1.0};
	float4 Specular = {0.f, 0.f, 0.f, 1.f};
	
	float3 ModelNormal = normalize(MVOut.Normal);
	float3 normLightDirection = normalize(-LightDirection);
	
	float DotValue = 0;
	
	if(materialType == 0) // lambert
	{
		DotValue = max(dot(ModelNormal, normLightDirection), 0);
		MVOut.Color = material.BaseColor * DotValue + AmbientLight * material.BaseColor;
	}
	else if(materialType == 1) // half_lambert
	{
		float DiffuseReflection = dot(ModelNormal, normLightDirection);
		DotValue = max(DiffuseReflection * 0.5 + 0.5, 0);
		
	}
	else if(materialType == 2) // Phong
	{
		float3 ReflectDirection = -normalize(reflect(normLightDirection, ModelNormal));
		float3 ViewDirection = normalize(ViewportPosition.xyz - MVOut.WorldPosition.xyz );

		
		float DiffuseReflection = dot(ModelNormal, normLightDirection);
		DotValue = max(DiffuseReflection * 0.5 + 0.5, 0);

		if(DotValue > 0.f)
		{
			float MaterialShininess = 1.f - saturate(MaterialRoughness);
			float M = MaterialShininess * 100.f;
			Specular = pow(max(0, dot(ViewDirection, ReflectDirection)),M);
		}
	}
	else if(materialType == 3) // BlinnPhong
	{
		float3 ViewDirection = normalize(ViewportPosition.xyz - MVOut.WorldPosition.xyz );
		float3 HalfDirection = normalize(ViewDirection + normLightDirection);
		
		float DiffuseReflection = dot(ModelNormal, normLightDirection);
		DotValue = max(DiffuseReflection * 0.5 + 0.5, 0);

		if(DotValue > 0.f)
		{
			float MaterialShininess = 1.f - saturate(MaterialRoughness);
			float M = MaterialShininess * 100.f;
			Specular = pow(max(0, dot(ModelNormal, HalfDirection)),M);
		}
	}
	else if(materialType == 4) // WrapLight
	{
		float WrapValue = 1.5f;
		
		float DiffuseReflection = dot(ModelNormal, normLightDirection);
		DotValue = max((DiffuseReflection + WrapValue) / (1.f + WrapValue), 0.f);
	}
	else if(materialType == 5) // Minnaert
	{
		float3 ViewDirection = normalize(ViewportPosition.xyz - MVOut.WorldPosition.xyz );

		float DotLight = max(dot(ModelNormal, normLightDirection), 0.f);
		float DotView = max(dot(ModelNormal, ViewDirection), 0.f);

		float MaterialShininess = 1.f - saturate(MaterialRoughness);
		float M = MaterialShininess * 20.f;
		DotValue = saturate(DotLight * pow(DotLight * DotView, M));
	}
	else if(materialType == 6) // Banded
	{
		float DiffuseReflection = (dot(ModelNormal, normLightDirection)  + 1.f) * 0.5;
		float Layered = 5.f;
		DotValue = floor(DiffuseReflection * Layered) / Layered;
	}
	else if(materialType == 7) // Banded
	{
		float4 Color2 = {0.4f, 0.2f, 0.4f, 1.f};

		float LightDotValue = dot(ModelNormal, normLightDirection);
		
		float DiffuseReflection = (LightDotValue  + 1.f) * 0.5;
		
		float Layered = 4.f;
		DotValue = floor(DiffuseReflection * Layered) / Layered;
		
		material.BaseColor = lerp(material.BaseColor, Color2, LightDotValue);
	}
	else if(materialType == 8) // Banded
	{
		float DiffuseReflection = (dot(ModelNormal, normLightDirection)  + 1.f) * 0.5;
		float Layered = 5.f;

		float3 ViewDirection = normalize(ViewportPosition.xyz - MVOut.WorldPosition.xyz );
		float3 F0 = {0.1f, 0.1f, 0.1f};
		Specular.xyz = FresnelSchlickMethod(F0, ModelNormal, ViewDirection, 5.f);

		DotValue = floor(DiffuseReflection * Layered) / Layered;
	}
	else if(materialType == 100) // Fresnel
	{
		float3 ViewDirection = normalize(ViewportPosition.xyz - MVOut.WorldPosition.xyz );
		float3 F0 = {0.1f, 0.1f, 0.1f};
		Specular.xyz = FresnelSchlickMethod(F0, ModelNormal, ViewDirection, 5.f);
	}
	
	MVOut.Color =
		material.BaseColor * DotValue
		+ AmbientLight * material.BaseColor
		+ Specular * material.BaseColor;
	
	return MVOut.Color;
}