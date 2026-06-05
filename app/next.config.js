/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  typescript: {
    // The app uses TS 4.6 with newer @types packages — skip check in build
    ignoreBuildErrors: true,
  },
}

module.exports = nextConfig
