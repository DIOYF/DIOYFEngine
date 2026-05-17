#include "Light.hlsl"
#include "Material.hlsl"
#include "PBR.hlsl"


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
	float MaterialRoughness;
	float XXX1;
	float XXX2;
	
	float4 BaseColor;
	float4x4 TransformInformation;
}

cbuffer LightConstBuffer : register(b3)//b0->b14
{
	float3 LightIntensity;
	float XXXX1;
	float3 LightDirection;
	float XXXX2;
}


struct MeshVertexIn
{
	float3 Position : POSITION;
	float4 Color : COLOR;
	float3 Normal : NORMAL;
	float3 UTangent : TANGENT;
};

struct MeshVertexOut
{
	float4 WorldPosition : POSITION;
	float4 Position : SV_POSITION;
	float4 Color : COLOR;
	float3 Normal : NORMAL;
	float3 UTangent : TANGENT;
};

MeshVertexOut VertexShaderMain(MeshVertexIn MV)
{
	MeshVertexOut Out;

	float4 Position = mul(float4(MV.Position, 1.f), WorldMatrix);
	//Out.Position = Position;
	
	Out.WorldPosition = Position;
	Out.Position = mul(Position, ViewProjectionMatrix);

	Out.Normal = mul(MV.Normal, (float3x3)WorldMatrix);
	Out.UTangent = MV.UTangent;

	Out.Color = MV.Color;
	
	return Out;
}

float4 PixelShaderMain(MeshVertexOut MVOut) :SV_TARGET
{
	FMaterial MatConstBuffer;
	MatConstBuffer.BaseColor = BaseColor;

	
	float4 AmbientLight = {0.15, 0.15, 0.25, 1.0};
	float4 Specular = {0.f, 0.f, 0.f, 1.f};
	
	float3 ModelNormal = normalize(MVOut.Normal);
	float3 normLightDirection = normalize(-LightDirection);
	
	float DotValue = 0;
	
	if(materialType == 0) // lambert
	{
		DotValue = max(dot(ModelNormal, normLightDirection), 0);
		MVOut.Color = MatConstBuffer.BaseColor * DotValue + AmbientLight * MatConstBuffer.BaseColor;
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
	else if(materialType == 7) // GradualBanded
	{
		float4 Color2 = {0.4f, 0.2f, 0.4f, 1.f};

		float LightDotValue = dot(ModelNormal, normLightDirection);
		
		float DiffuseReflection = (LightDotValue  + 1.f) * 0.5;
		
		float Layered = 4.f;
		DotValue = floor(DiffuseReflection * Layered) / Layered;
		
		MatConstBuffer.BaseColor = lerp(MatConstBuffer.BaseColor, Color2, LightDotValue);
	}
	else if(materialType == 8) // Banded
	{
		float DiffuseReflection = (dot(ModelNormal, normLightDirection)  + 1.f) * 0.5;
		float3 ReflectDirection = -normalize(reflect(normLightDirection, ModelNormal));
		float Layered = 5.f;

		float3 ViewDirection = normalize(ViewportPosition.xyz - MVOut.WorldPosition.xyz );
		float3 F0 = {0.1f, 0.1f, 0.1f};
		Specular.xyz = FresnelSchlickMethod(F0, ModelNormal, ViewDirection, 5.f);

		DotValue = floor(DiffuseReflection * Layered) / Layered;
		
		if(DotValue > 0.f)
		{
			float MaterialShininess = 1.f - saturate(MaterialRoughness);
			float M = MaterialShininess * 60.f;
			Specular += pow(max(0, dot(ViewDirection, ReflectDirection)),M) / 0.032f;
		}
	}
	else if(materialType == 9) // BackLight
	{
		float3 ReflectDirection = -normalize(reflect(normLightDirection, ModelNormal));
		float3 ViewDirection = normalize(ViewportPosition.xyz - MVOut.WorldPosition.xyz );

		
		float WrapValue = 1.5f;
		
		float DiffuseReflection = dot(ModelNormal, normLightDirection);
		DotValue = max((DiffuseReflection + WrapValue) / (1.f + WrapValue), 0.f);

		if(DotValue > 0.f)
		{
			float MaterialShininess = 1.f - saturate(MaterialRoughness);
			float M = MaterialShininess * 60.f;
			Specular = pow(max(0, dot(ViewDirection, ReflectDirection)),M);
		}
		
		float SSSValue = 1.3f;
		float TransmissionIntensity = 2.f;
		float TransmissionScope = 1.5f;
		
		float3 LightNormalizeDotValue = -normalize(ModelNormal * SSSValue + normLightDirection);

		DotValue += pow(saturate(dot(LightNormalizeDotValue, ViewDirection)), TransmissionScope) * TransmissionIntensity;
		
	}
	else if(materialType == 10) // AnisotropyKajiyaKay
	{
	}
	else if(materialType == 11) // OrenLayar
	{
		float3 ViewDirection = normalize(ViewportPosition.xyz - MVOut.WorldPosition.xyz);

		float NormalLight = saturate(dot(ModelNormal, normLightDirection));//兰伯特
		float NormalView = saturate(dot(ModelNormal, ViewDirection));

		float Phiri = 
			length(ViewDirection - ModelNormal * NormalView) * 
			length(normLightDirection- ModelNormal * NormalLight);

		float ACosNormalView = acos(NormalView);//[0,1]
		float ACosNormalLight = acos(NormalLight);

		float Alpha = max(ACosNormalView, ACosNormalLight);
		float Beta = min(ACosNormalView, ACosNormalLight);

		float MyRoughness = pow(MaterialRoughness, 2);

		float A = 1 - 0.5f * (MyRoughness / (MyRoughness + 0.33f));
		float B = 0.45f * (MyRoughness / (MyRoughness + 0.09f));

		DotValue = NormalLight * (A + B * max(0, Phiri) * sin(Alpha) * tan(Beta));
	}
	else if(materialType == 20) // PBR
	{
		float3 L  = normLightDirection;
		float3 V = normalize(ViewportPosition.xyz - MVOut.WorldPosition.xyz);
		float3 H = normalize(L + V);
		float3 N = ModelNormal;

		float PI = 3.1415926f;

		float Roughness = 0.2f;
		float Metallic = 0.4f;

		float4 D =  GetDistributionGGX(N, H, Roughness);

		float F0 = 0.08;
		F0 = lerp(F0, MatConstBuffer.BaseColor, Metallic);
		float4 F = float4(FresnelSchlickMethod(F0, N, V, 5), 1.0f);

		float4 G = GSmith(N, V, L, Roughness);

		float4 Kd = 1 - F;
		Kd *= 1 - Metallic;

		float3 Diffuse = Kd * GetDiffuseLambert(MatConstBuffer.BaseColor);

		float NoV = saturate(dot(N, V));
		float NoL = saturate(dot(N, L));

		float4 Value = (D * F * G) / (4 * (NoV * NoL));
		Specular = float4(Value.rgb, 1.f);

		float3 Radiance = LightIntensity.xyz;
		float3 Color = (Diffuse + Specular.xyz) * NoL * Radiance;
		
		return float4(Color.xyz, 1.f);
	}
	else if(materialType == 100) // Fresnel
	{
		float3 ViewDirection = normalize(ViewportPosition.xyz - MVOut.WorldPosition.xyz );
		float3 F0 = {0.1f, 0.1f, 0.1f};
		Specular.xyz = FresnelSchlickMethod(F0, ModelNormal, ViewDirection, 5.f);
	}
	
	MVOut.Color =
		MatConstBuffer.BaseColor * DotValue
		+ AmbientLight * MatConstBuffer.BaseColor
		+ Specular * MatConstBuffer.BaseColor;
	
	return MVOut.Color;
}