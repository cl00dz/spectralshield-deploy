
import React from 'react';
import { VerificationHistoryItem } from '../types';
import { CheckCircleIcon, XCircleIcon, TrashIcon, TextIcon } from './icons';

interface VerificationHistoryProps {
  history: VerificationHistoryItem[];
  onClear: () => void;
}

export const VerificationHistory: React.FC<VerificationHistoryProps> = ({ history, onClear }) => {
  const formatDate = (isoString: string) => new Date(isoString).toLocaleString(undefined, {
    year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit'
  });

  return (
    <div className="mt-12 max-w-2xl mx-auto space-y-4 animate-fade-in">
      <div className="flex justify-between items-center">
        <h3 className="text-xl font-semibold text-gray-300">Verification History</h3>
        <button
          onClick={onClear}
          className="flex items-center gap-2 text-sm text-gray-400 hover:text-red-400 transition-colors p-2 rounded-lg hover:bg-red-500/10"
          title="Clear all verification history"
        >
          <TrashIcon className="w-4 h-4" />
          Clear All
        </button>
      </div>
      <div className="space-y-3 max-h-96 overflow-y-auto pr-2 rounded-lg bg-black/10 p-1 animate-stagger-in">
        {history.map((item, index) => (
          <div
            key={item.timestamp + index}
            style={{ animationDelay: `${index * 50}ms` }}
            className={`p-4 rounded-lg border-l-4 bg-gray-800/60 backdrop-blur-sm
              ${item.isValid ? 'border-green-500' : 'border-red-500'}`}
          >
            <div className="flex items-start gap-4">
              <div>
                {item.isValid ? (
                  <CheckCircleIcon className="w-6 h-6 text-green-400 flex-shrink-0 mt-1" />
                ) : (
                  <XCircleIcon className="w-6 h-6 text-red-400 flex-shrink-0 mt-1" />
                )}
              </div>
              <div className="flex-grow overflow-hidden">
                <div className="flex justify-between items-baseline">
                  <p className="font-semibold text-white truncate" title={item.fileName}>{item.fileName}</p>
                  <p className="text-xs text-gray-500 flex-shrink-0 ml-4">{formatDate(item.timestamp)}</p>
                </div>
                <p className={`text-sm ${item.isValid ? 'text-green-300' : 'text-red-300'}`}>
                  {item.reason}
                </p>
                {item.isValid && item.watermarkText && (
                  <div className="mt-2 bg-gray-900/50 p-2 rounded-md border border-gray-700 flex items-center gap-2">
                     <TextIcon className="w-4 h-4 text-gray-400 flex-shrink-0"/>
                     <p className="text-sm text-gray-300 font-medium truncate" title={item.watermarkText}>
                        {item.watermarkText}
                     </p>
                  </div>
                )}
                <p className="text-xs text-gray-500 mt-2 font-mono truncate" title={item.identifier}>
                  ID: {item.identifier}
                </p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
