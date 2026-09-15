'use client';

import { ConversationStarterProps } from '@/types/models';

const archetypeMessages: Record<string, (name: string) => string> = {
  'The Calm Operator': (name: string) =>
    `${name} worked on Nerves = Performance this week. Ask them: "What pressure situation did you visualize handling calmly, and how did it feel?"`,
  'The Resilient Bounceback': (name: string) =>
    `${name} practiced Back To Your Best this week. On the drive home, avoid analyzing mistakes. Simply ask: "What was your favorite visual rep this week, and how did it feel?"`,
  'The Sharp Decision-Maker': (name: string) =>
    `${name} trained as a Sharp Decision-Maker. Ask: "What was the toughest decision you made on the pitch this week, and what did you learn?"`,
  'The Unshakable Competitor': (name: string) =>
    `${name} worked on UNSHAKABLE focus this week. Ask: "When did you feel most locked in this week, and what triggered that state?"`,
};

const archetypeColors: Record<string, string> = {
  'The Calm Operator': 'bg-blue-100 text-blue-800 border-blue-200',
  'The Resilient Bounceback': 'bg-green-100 text-green-800 border-green-200',
  'The Sharp Decision-Maker': 'bg-purple-100 text-purple-800 border-purple-200',
  'The Unshakable Competitor': 'bg-orange-100 text-orange-800 border-orange-200',
};

export function ConversationStarter({ archetype, athleteName }: ConversationStarterProps) {
  const message = archetypeMessages[archetype]?.(athleteName) ||
    `${athleteName} trained hard this week. Ask them about their favorite moment!`;

  const colorClass = archetypeColors[archetype] || 'bg-gray-100 text-gray-800 border-gray-200';

  return (
    <div className="card p-6">
      <div className="flex items-start gap-4">
        <div className={`flex-shrink-0 px-3 py-1 rounded-full text-sm font-medium border ${colorClass}`}>
          {archetype}
        </div>
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-gray-900 mb-2">This Week's Conversation Starter</h3>
          <p className="text-gray-700 leading-relaxed">{message}</p>
        </div>
      </div>
    </div>
  );
}
