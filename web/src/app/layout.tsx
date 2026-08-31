import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Football Mind Gym - Parent Portal',
  description: 'Track your athlete\'s progress and development in the Football Mind Gym',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-gray-50">{children}</body>
    </html>
  );
}