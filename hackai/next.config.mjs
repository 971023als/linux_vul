/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "standalone",
  reactStrictMode: true,
  // 정적 배포를 위한 이미지 최적화 비활성화 (외부 이미지 없음)
  images: {
    unoptimized: true,
  },
};

export default nextConfig;
