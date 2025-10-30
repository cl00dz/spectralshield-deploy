import React, { useState } from 'react';
import { SignatureResult } from '../types';
import { CheckCircleIcon, ClipboardIcon, DownloadIcon, KeyIcon, FingerprintIcon } from './icons';

interface ResultDisplayProps {
  result: SignatureResult;
  audioFile: File;
}

export const ResultDisplay: React.FC<ResultDisplayProps> = ({ result, audioFile }) => {
  const [copiedKey, setCopiedKey] = useState<'signature' | 'identifier' | null>(null);

  const handleCopy = (text: string, key: 'signature' | 'identifier') => {
    navigator.clipboard.writeText(text);
    setCopiedKey(key);
    setTimeout(() => setCopiedKey(null), 2000);
  };

  const CopyButton: React.FC<{ textToCopy: string, copyKey: 'signature' | 'identifier' }> = ({ textToCopy, copyKey }) => (
    <button onClick={() => handleCopy(textToCopy, copyKey)} className="text-gray-400 hover:text-cyan-400 transition-colors">
      {copiedKey === copyKey ? <CheckCircleIcon className="w-5 h-5 text-green-400" /> : <ClipboardIcon className="w-5 h-5" />}
    </button>
  );

  return (
    <div className="bg-gray-800/50 backdrop-blur-sm border border-cyan-500/20 rounded-2xl shadow-2xl shadow-cyan-500/10 p-6 md:p-8 space-y-6 animate-fade-in">
      <h2 className="text-2xl font-bold text-center text-cyan-300">Signature Generated Successfully</h2>
      
      <div className="space-y-4">
        <div>
          <label className="text-sm font-semibold text-cyan-400 flex items-center gap-2 mb-1">
            <FingerprintIcon className="w-5 h-5"/>
            Unique Identifier
          </label>
          <div className="flex items-center gap-2 bg-gray-900/70 p-3 rounded-lg border border-gray-700">
            <p className="flex-grow font-mono text-sm text-gray-300 truncate">{result.uniqueIdentifier}</p>
            <CopyButton textToCopy={result.uniqueIdentifier} copyKey="identifier" />
          </div>
        </div>

        <div>
          <label className="text-sm font-semibold text-cyan-400 flex items-center gap-2 mb-1">
            <KeyIcon className="w-5 h-5"/>
            Spectral Signature
          </label>
          <div className="flex items-start gap-2 bg-gray-900/70 p-3 rounded-lg border border-gray-700">
            <p className="flex-grow font-mono text-sm text-gray-300 break-all">{result.spectralSignature}</p>
            <CopyButton textToCopy={result.spectralSignature} copyKey="signature" />
          </div>
        </div>
      </div>
      
      <div className="pt-6 border-t border-cyan-500/20">
        <div className="bg-cyan-900/50 border border-cyan-700 rounded-lg p-3 flex items-center gap-3 text-left">
          <DownloadIcon className="w-6 h-6 text-cyan-400 flex-shrink-0" />
          <p className="text-sm text-cyan-300">
            A zip package containing the original audio and signature file has been downloaded automatically.
          </p>
        </div>
      </div>
    </div>
  );
};