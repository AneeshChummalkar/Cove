import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";

export const metadata: Metadata = {
  title: "Cove",
  description: "A desktop-first personal AI runtime.",
};

const navItems = [
  { href: "/features", label: "Features" },
  { href: "/pricing", label: "Pricing" },
  { href: "/security", label: "Security" },
];

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <header className="site-header">
          <Link href="/" className="brand" aria-label="Cove home">
            Cove
          </Link>
          <nav className="nav" aria-label="Primary navigation">
            {navItems.map((item) => (
              <Link href={item.href} key={item.href}>
                {item.label}
              </Link>
            ))}
            <Link href="/download" className="nav-download">
              Download Cove
            </Link>
            <Link href="/signin" className="nav-sign-in">
              Sign In
            </Link>
          </nav>
        </header>
        <main>{children}</main>
      </body>
    </html>
  );
}
