import type { Metadata } from "next";

import WolomaniaPageClient from "./WolomaniaPageClient";

export const metadata: Metadata = {
  title: "Wolomania I",
  description:
    "Wolomania I — the first AoE2DE War Wagers world championship event. Jim vs Julio Alvarez. 100,000 WOLO winner takes all.",
  alternates: {
    canonical: "/wolomania",
  },
  openGraph: {
    title: "Wolomania I | AoE2DE War Wagers",
    description:
      "The first AoE2DE War Wagers world championship event. July 10, 2026. 100,000 WOLO winner takes all.",
    url: "https://aoe2dewarwagers.com/wolomania",
    siteName: "AoE2DE War Wagers",
    type: "website",
  },
};

export default function WolomaniaPage() {
  return <WolomaniaPageClient />;
}
