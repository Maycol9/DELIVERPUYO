import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  compress: true,
  poweredByHeader: false,
  async headers() {
    return [
      {
        source: '/api/:path*',
        headers: [
          { key: 'Access-Control-Allow-Origin', value: '*' },
          { key: 'Access-Control-Allow-Methods', value: 'GET,POST,OPTIONS' },
          {
            key: 'Access-Control-Allow-Headers',
            value: 'Content-Type, Authorization, X-Bypass-Cache',
          },
        ],
      },
    ];
  },
};

export default nextConfig;
