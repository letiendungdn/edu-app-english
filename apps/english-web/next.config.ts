import type { NextConfig } from "next";
import path from "path";

const apiUrl = process.env.API_URL ?? "http://localhost:3000";
const monorepoRoot = path.join(__dirname, "../..");

const nextConfig: NextConfig = {
  output: "standalone",
  outputFileTracingRoot: monorepoRoot,
  turbopack: {
    root: monorepoRoot,
  },
  transpilePackages: ["@edu/vocab-images"],
  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: `${apiUrl}/api/english/:path*`,
      },
    ];
  },
};

export default nextConfig;
