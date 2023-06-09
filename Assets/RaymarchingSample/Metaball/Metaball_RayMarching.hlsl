float smoothMin(float d1, float d2, float k)
{
    float h = exp(-k * d1) + exp(-k * d2);
    return -log(h) / k;
}

float Sphere(float3 p,float3 s)
{
    return length(p) - s;
}

//距離関数
//ここを書き換えれば色々3Dオブジェクトを表現出来る
float DistanceFunction(float3 p)
{
    return smoothMin(Sphere(p + 0.1f,0.2f),Sphere(p - 0.1,0.2f),8.0f);
}

// マーチングループの本体
void RayMarching_float(
    float3 RayPosition,
    float3 RayDirection,
    out bool Hit,
    out float3 HitPosition)
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
            return;
        }
    }
}