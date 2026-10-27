import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = { title: "Soumojit Basu | Quantitative Research & Analytics", description: "Portfolio of Soumojit Basu — quantitative finance, operations research, machine learning and analytics." };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="en"><body>{children}</body></html>; }
