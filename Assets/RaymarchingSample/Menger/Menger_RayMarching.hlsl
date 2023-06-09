#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

float mod(float x, float y)
{
    return x - y * floor(x / y);
}
float2 mod(float2 x, float2 y)
{
    return x - y * floor(x / y);
}
float3 mod(float3 x, float3 y)
{
    return x - y * floor(x / y);
}
float4 mod(float4 x, float4 y)
{
    return x - y * floor(x / y);
}

inline float sdBox(float3 p, float3 b )
{
    float3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

inline float crosscube(float3 p,float3 s)
{
    float3 a = float3(s.x*1./3.,s.x*1./3.,s.x*4./3.);
    float d = sdBox(p,a.xyz);
    float d2 = sdBox(p,a.yzx);
    float d3 = sdBox(p,a.zxy);

    return min(min(d,d2),d3);
}

inline float menger(float3 p, float3 s,int loop)
{
    float d = sdBox(p,s);
    float td = crosscube(p,s);
    d = max(d,-td);

    for(int i = 0; i < loop; i++)
    {
        s *= 1./3.;
        float m = s.x * 2.;
        p = mod(p-m*0.5,m)-m*0.5;
        td = crosscube(p,s);
        d = max(d,-td);
    }
    return d;
}

//距離関数
//ここを書き換えれば色々3Dオブジェクトを表現出来る
float DistanceFunction(float3 p)
{
    float3 pos = p;
    return menger(pos,float3(0.5f,0.5f,0.5f),4);
}

// 法線を計算する
float3 CalcNormal(float3 p)
{
    // 距離関数の勾配を取って正規化すると法線が計算できる
    float2 ep = float2(0, 0.001);
    return normalize(
        float3(
            DistanceFunction(p + ep.yxx) - DistanceFunction(p),
            DistanceFunction(p + ep.xyx) - DistanceFunction(p),
            DistanceFunction(p + ep.xxy) - DistanceFunction(p)
        )
    );
}

// マーチングループの本体
void RayMarching_float(
    float3 RayPosition,
    float3 RayDirection,
    out bool Hit,
    out float3 HitPosition,
    out float3 HitNormal)
{
    float3 pos = RayPosition;
 
    // 各ピクセルごとに64回のループをまわす
    for (int i = 0; i < 64; ++i)
    {
        // 距離関数の分だけレイを進める
        float d = DistanceFunction(pos);
        pos += d * RayDirection;
 
        // 距離関数がある程度小さければ衝突していると見なす
        if (d < 0.001)
        {
            Hit = true;
            HitPosition = pos;
            HitNormal = CalcNormal(pos);
            return;
        }
    }
}