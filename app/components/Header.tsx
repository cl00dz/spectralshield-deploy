
import React from 'react';
import { ShieldCheckIcon } from './icons';

export const Header: React.FC = () => {
  return (
    <header className="text-center">
      <div className="inline-flex items-center justify-center gap-3 mb-2">
        <ShieldCheckIcon className="w-10 h-10 text-cyan-400" />
        <h1 className="text-4xl md:text-5xl font-bold font-orbitron text-gray-100 tracking-wide">
          SpectralShield
        </h1>
      </div>
      <p className="max-w-2xl mx-auto text-base text-gray-400">
        Embed a unique, verifiable spectral signature into your audio files.
      </p>
    </header>
  );
};
