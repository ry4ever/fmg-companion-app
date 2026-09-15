'use client';

import { WeeklySchedule, CompletionGridProps } from '@/types/models';
import { useMemo } from 'react';

export function CompletionGrid({ weeklySchedule, athleteName }: CompletionGridProps) {
  if (!weeklySchedule) {
    return (
      <div className="card p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">{athleteName}'s Weekly Progress</h3>
        <p className="text-gray-500">No schedule data available.</p>
      </div>
    );
  }

  const days = useMemo(() => [
    { key: 'monday', label: 'Mon', date: weeklySchedule.days.monday },
    { key: 'tuesday', label: 'Tue', date: weeklySchedule.days.tuesday },
    { key: 'wednesday', label: 'Wed', date: weeklySchedule.days.wednesday },
    { key: 'thursday', label: 'Thu', date: weeklySchedule.days.thursday },
    { key: 'friday', label: 'Fri', date: weeklySchedule.days.friday },
    { key: 'saturday', label: 'Sat', date: weeklySchedule.days.saturday },
    { key: 'sunday', label: 'Sun', date: weeklySchedule.days.sunday },
  ], [weeklySchedule]);

  const completedCount = days.filter(d => d.date.completed).length;
  const progressPercent = Math.round((completedCount / 7) * 100);

  return (
    <div className="card p-6">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">
            {athleteName}'s Weekly Progress
          </h3>
          <p className="text-sm text-gray-500 mt-1">
            {progressPercent}% of weekly sessions completed
          </p>
        </div>
        <span className="text-sm font-medium text-brand-600">
          {completedCount}/7 sessions
        </span>
      </div>

      <div className="h-2 bg-gray-100 rounded-full mb-6">
        <div
          className="h-2 rounded-full bg-brand-600 transition-all duration-300"
          style={{ width: `${progressPercent}%` }}
        />
      </div>

      <div className="grid grid-cols-7 gap-2">
        {days.map(({ key, label, date }) => (
          <div key={key} className="flex flex-col items-center">
            <span className={`text-xs font-medium mb-2 ${
              date.completed ? 'text-green-600' : 'text-gray-500'
            }`}>{label}</span>
            <div className={`w-12 h-12 rounded-xl flex items-center justify-center transition-colors ${
              date.completed
                ? 'bg-green-100 border-2 border-green-400'
                : 'bg-gray-100 border-2 border-gray-200'
            }`}>
              {date.completed ? (
                <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                </svg>
              ) : (
                <span className="text-gray-400 text-sm font-medium">{date.session_id ? '⏳' : '—'}</span>
              )}
            </div>
            {date.session_id && (
              <p className="text-xs text-gray-500 mt-1 text-center truncate w-16">
                {date.session_id.replace('session_', '').replace(/_/g, ' ')}
              </p>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
