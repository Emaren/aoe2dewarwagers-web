import type { Metadata } from "next";
import Script from "next/script";

import "./globals.css";
import AppShell from "./AppShell";

export const metadata: Metadata = {
  metadataBase: new URL("https://AoE2DEWarWagers.com"),
  title: {
    default: "AoE2DEWarWagers",
    template: "%s | AoE2DEWarWagers",
  },
  description:
    "AoE2HD tournament lobby with live chat, replay-backed results, rivalry pages, and the trust layer for competitive bets.",
  alternates: {
    canonical: "/",
  },
  openGraph: {
    title: "AoE2DEWarWagers",
    description:
      "Tournament lobby, replay proof, rivalry pages, and live chat for AoE2HD players.",
    url: "https://AoE2DEWarWagers.com",
    siteName: "AoE2DEWarWagers",
    type: "website",
    images: [
      {
        url: "/social/AoE2DEWarWagers-card.png",
        width: 1200,
        height: 630,
        alt: "AoE2DEWarWagers tournament lobby social card",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    site: "@AoE2DEWarWagers",
    creator: "@AoE2DEWarWagers",
    title: "AoE2DEWarWagers",
    description:
      "Tournament lobby, replay proof, rivalry pages, and live chat for AoE2HD players.",
    images: [
      {
        url: "/social/AoE2DEWarWagers-card.png",
        alt: "AoE2DEWarWagers tournament lobby social card",
      },
    ],
  },
  icons: {
    icon: "/favicon.ico",
    apple: "/icons/icon-192x192.png",
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-gray-900 text-white min-h-screen flex flex-col">
        <Script
          defer
          data-domain="AoE2DEWarWagers.com"
          src="https://plausible.io/js/script.js"
        />
        <AppShell>{children}</AppShell>
      </body>
    </html>
  );
}