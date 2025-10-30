

import React, { useState, useCallback, useEffect } from 'react';
import { Header } from './components/Header';
import { FileUpload } from './components/FileUpload';
import { Loader } from './components/Loader';
import { generateSignatureAndId, verifySignature, AlreadyWatermarkedError } from './services/geminiService';
import { VerificationHistoryItem } from './types';
import { ShieldIcon, TextIcon, AlertTriangleIcon, FingerprintIcon, ScanSearchIcon, InfoIcon } from './components/icons';
import { getVerificationHistory, addVerificationHistoryItem, clearVerificationHistory } from './services/historyService';
import { VerificationHistory } from './components/VerificationHistory';
import { BatchVerificationResults } from './components/BatchVerificationResults';

const App: React.FC = () => {
  const [mode, setMode] = useState<'generate' | 'verify'>('generate');

  // Generator state
  const [audioFiles, setAudioFiles] = useState<File[]>([]);
  const [watermarkTexts, setWatermarkTexts] = useState<string[]>([]);
  const [generationSummary, setGenerationSummary] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [generationProgress, setGenerationProgress] = useState<number>(0);
  const [generationStatus, setGenerationStatus] = useState<string>('');

  // Verifier state
  const [verificationFiles, setVerificationFiles] = useState<File[]>([]);
  const [verificationIdTexts, setVerificationIdTexts] = useState<string[]>([]);
  const [idFormatError, setIdFormatError] = useState<string | null>(null);
  const [batchVerificationResults, setBatchVerificationResults] = useState<VerificationHistoryItem[] | null>(null);
  const [isVerifying, setIsVerifying] = useState<boolean>(false);
  const [verificationError, setVerificationError] = useState<string | null>(null);
  const [verificationHistory, setVerificationHistory] = useState<VerificationHistoryItem[]>([]);
  
  const [showHistory, setShowHistory] = useState(false);

  useEffect(() => {
    // Load history and decide if it should be shown
    if (mode === 'verify') {
      const history = getVerificationHistory();
      setVerificationHistory(history);
      setShowHistory(history.length > 0);
    } else {
      setShowHistory(false);
    }
  }, [mode]);

  // Real-time validation for identifier format
  useEffect(() => {
    if (mode !== 'verify' || verificationIdTexts.length === 0) {
        setIdFormatError(null);
        return;
    }
    const ids = verificationIdTexts.filter(Boolean);
    const hasInvalidId = ids.some(id => !id.trim().startsWith('ss-v1-'));
    setIdFormatError(hasInvalidId ? "One or more identifiers have an invalid format. Ensure each ID starts with 'ss-v1-'." : null);
  }, [verificationIdTexts, mode]);

  const resetAllState = () => {
    setAudioFiles([]);
    setWatermarkTexts([]);
    setGenerationSummary(null);
    setError(null);
    setIsLoading(false);
    setVerificationFiles([]);
    setVerificationIdTexts([]);
    setIdFormatError(null);
    setBatchVerificationResults(null);
    setVerificationError(null);
    setIsVerifying(false);
    setGenerationProgress(0);
    setGenerationStatus('');
  };

  const switchMode = (newMode: 'generate' | 'verify') => {
    if (mode === newMode) return;
    setMode(newMode);
    resetAllState();
  };
  
  // Unified file selection handler to ensure consistent logic for both modes
  const handleFileSelection = (selectedFiles: File[]) => {
    if (mode === 'generate') {
      setAudioFiles(selectedFiles);
      setWatermarkTexts(Array(selectedFiles.length).fill(''));
      setGenerationSummary(null);
      setError(null);
    } else { // verify
      setVerificationFiles(selectedFiles);
      setVerificationIdTexts(Array(selectedFiles.length).fill(''));
      setBatchVerificationResults(null);
      setVerificationError(null);
    }
  };

  const handleWatermarkTextChange = (index: number, text: string) => {
    const newTexts = [...watermarkTexts];
    newTexts[index] = text;
    setWatermarkTexts(newTexts);
  };

  const handleGenerate = useCallback(async () => {
    if (audioFiles.length === 0) { setError('Please upload at least one audio file.'); return; }
    if (watermarkTexts.some(text => !text.trim())) { setError('Please provide a watermark text for every file.'); return; }

    setIsLoading(true); setError(null); setGenerationSummary(null);
    setGenerationProgress(0);
    setGenerationStatus('Initializing...');

    const JSZip = (window as any).JSZip;
    if (!JSZip) {
        setError("Could not create zip package. Required library is missing.");
        setIsLoading(false); return;
    }
    const zip = new JSZip();
    let successCount = 0;
    const errors: string[] = [];

    for (let i = 0; i < audioFiles.length; i++) {
      const file = audioFiles[i];
      const watermarkText = watermarkTexts[i];
      setGenerationStatus(`Processing ${i + 1}/${audioFiles.length}: ${file.name}`);
      try {
        const { signatureResult, watermarkedFile } = await generateSignatureAndId(file, watermarkText);
        const signatureContent = `SpectralShield Signature Package\n\n` +
                                `Original File: ${file.name}\n` +
                                `Timestamp: ${new Date().toISOString()}\n\n` +
                                `--- UNIQUE IDENTIFIER ---\n${signatureResult.uniqueIdentifier}\n\n` +
                                `--- SPECTRAL SIGNATURE ---\n${signatureResult.spectralSignature}\n`;
        
        zip.file(`${file.name}.signature.txt`, signatureContent);
        zip.file(file.name, watermarkedFile);
        successCount++;
      } catch (err) {
        if (err instanceof AlreadyWatermarkedError) {
          errors.push(err.message + ' To verify it, please use the Verify tab.');
        } else {
          errors.push(err instanceof Error ? err.message : `Failed to process ${file.name}.`);
        }
      }
      const progress = Math.round(((i + 1) / audioFiles.length) * 100);
      setGenerationProgress(progress);
    }

    if (successCount > 0) {
      setGenerationStatus('Compressing files...');
      const zipBlob = await zip.generateAsync({ type: "blob" });
      const url = URL.createObjectURL(zipBlob);
      const a = document.createElement('a');
      a.href = url; a.download = `SpectralShield_Batch_${new Date().getTime()}.zip`;
      document.body.appendChild(a); a.click(); document.body.removeChild(a);
      URL.revokeObjectURL(url);
    }
    
    let summary = `Processed ${audioFiles.length} file(s). Successful: ${successCount}. Failed/Skipped: ${errors.length}.`;
    if (successCount > 0) summary += ' A zip package has been downloaded.';
    setGenerationSummary(summary);
    if (errors.length > 0) setError(errors.join('\n'));
    
    setIsLoading(false); setAudioFiles([]); setWatermarkTexts([]);
    setTimeout(() => {
      setGenerationProgress(0);
      setGenerationStatus('');
    }, 2000);
  }, [audioFiles, watermarkTexts]);

  // Verifier handlers
  const handleVerificationIdTextChange = (index: number, text: string) => {
    const newIds = [...verificationIdTexts];
    newIds[index] = text;
    setVerificationIdTexts(newIds);
    setBatchVerificationResults(null);
    setVerificationError(null);
  };

  const handleVerify = useCallback(async () => {
    const ids = verificationIdTexts.map(id => id.trim());
    if (verificationFiles.length === 0) { setVerificationError('Please upload audio file(s) to verify.'); return; }
    if (ids.some(id => !id)) {
      setVerificationError(`Please provide a unique identifier for every file.`);
      return;
    }

    setIsVerifying(true); setVerificationError(null); setBatchVerificationResults(null);
    const results: VerificationHistoryItem[] = [];

    for (let i = 0; i < verificationFiles.length; i++) {
      const file = verificationFiles[i];
      const id = ids[i];
      let result: VerificationHistoryItem;

      try {
        const verification = await verifySignature(file, id);
        result = { ...verification, fileName: file.name, identifier: id, timestamp: new Date().toISOString() };
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'An unexpected error occurred.';
        result = { isValid: false, reason: errorMessage, fileName: file.name, identifier: id, timestamp: new Date().toISOString() };
      }
      results.push(result);
      addVerificationHistoryItem(result);
    }
    
    setBatchVerificationResults(results);
    const updatedHistory = getVerificationHistory();
    setVerificationHistory(updatedHistory);
    setShowHistory(updatedHistory.length > 0);
    setIsVerifying(false);
    setVerificationFiles([]); setVerificationIdTexts([]);
  }, [verificationFiles, verificationIdTexts]);

  const handleClearHistory = () => {
    if (window.confirm('Are you sure you want to clear the verification history? This action cannot be undone.')) {
      clearVerificationHistory();
      const updatedHistory = getVerificationHistory();
      setVerificationHistory(updatedHistory);
      setShowHistory(updatedHistory.length > 0);
    }
  };

  const canGenerate = audioFiles.length > 0 && watermarkTexts.length === audioFiles.length && watermarkTexts.every(text => text.trim().length > 0) && !isLoading;
  const canVerify = verificationFiles.length > 0 && verificationIdTexts.length === verificationFiles.length && verificationIdTexts.every(text => text.trim().length > 0) && !isVerifying && !idFormatError;

  return (
    <div className="min-h-screen bg-gray-900/50 text-gray-300 selection:bg-cyan-400 selection:text-black">
      <div className="container mx-auto px-4 py-8 md:py-16 animate-fade-in">
        <Header />
        
        {/* Sleek Mode Switcher */}
        <div className="mt-10 mb-6 max-w-sm mx-auto">
          <div className="relative flex p-1 bg-gray-800/80 rounded-full border border-gray-700">
            <span
              className={`absolute top-1 left-1 w-1/2 h-[calc(100%-8px)] bg-cyan-500 rounded-full transition-transform duration-300 ease-in-out`}
              style={{ transform: mode === 'generate' ? 'translateX(0%)' : 'translateX(96%)' }}
            ></span>
            <button onClick={() => switchMode('generate')} className="relative z-10 w-1/2 py-2 text-sm font-semibold rounded-full transition-colors">
              Generate
            </button>
            <button onClick={() => switchMode('verify')} className="relative z-10 w-1/2 py-2 text-sm font-semibold rounded-full transition-colors">
              Verify
            </button>
          </div>
        </div>

        {/* Main Content Card */}
        <main className={`relative max-w-2xl mx-auto bg-gray-900/50 backdrop-blur-xl border rounded-2xl shadow-2xl overflow-hidden transition-all duration-500
          ${mode === 'generate' ? 'border-cyan-500/30 shadow-cyan-500/10' : 'border-purple-500/30 shadow-purple-500/10'}`}>
          
          <div className="p-6 md:p-8 space-y-8">
            {mode === 'generate' ? (
              <>
                <Section title="1. Upload Audio Files" icon={<ShieldIcon className="w-5 h-5" />}>
                  <FileUpload onFilesChange={handleFileSelection} files={audioFiles} onError={setError} acceptedMimeTypes={['audio/mpeg', 'audio/wav']} maxSizeMb={50} maxFiles={10} descriptionText="MP3 or WAV only (Max 10 files, 50MB each)" />
                </Section>
                
                {audioFiles.length > 0 && (
                  <Section title="2. Define Watermarks" icon={<TextIcon className="w-5 h-5" />}>
                    <div className="space-y-3 max-h-48 overflow-y-auto pr-2">
                      {audioFiles.map((file, index) => (
                        <div key={file.name + index} className="flex items-center gap-4 p-2 bg-gray-800/40 rounded-lg animate-fade-in">
                          <p className="flex-1 text-gray-300 truncate font-medium text-sm" title={file.name}>
                            {file.name}
                          </p>
                          <input
                            type="text"
                            value={watermarkTexts[index] || ''}
                            onChange={(e) => handleWatermarkTextChange(index, e.target.value)}
                            placeholder="Watermark text..."
                            aria-label={`Watermark for ${file.name}`}
                            className="w-2/3 md:w-1/2 bg-gray-800/70 border border-gray-700 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500"
                          />
                        </div>
                      ))}
                    </div>
                  </Section>
                )}
              </>
            ) : (
              <>
                <Section title="1. Upload Audio Files to Verify" icon={<ScanSearchIcon className="w-5 h-5" />}>
                  <FileUpload onFilesChange={handleFileSelection} files={verificationFiles} onError={setVerificationError} acceptedMimeTypes={['audio/mpeg', 'audio/wav']} maxSizeMb={50} maxFiles={10} descriptionText="MP3 or WAV only (Max 10 files, 50MB each)" />
                </Section>
                
                {verificationFiles.length > 0 && (
                  <Section title="2. Enter Unique Identifiers" icon={<FingerprintIcon className="w-5 h-5" />}>
                     <div className="space-y-3 max-h-48 overflow-y-auto pr-2">
                      {verificationFiles.map((file, index) => (
                        <div key={file.name + index} className="flex items-center gap-4 p-2 bg-gray-800/40 rounded-lg animate-fade-in">
                          <p className="flex-1 text-gray-300 truncate font-medium text-sm" title={file.name}>
                            {file.name}
                          </p>
                          <input
                            type="text"
                            value={verificationIdTexts[index] || ''}
                            onChange={(e) => handleVerificationIdTextChange(index, e.target.value)}
                            placeholder="Paste identifier..."
                            aria-label={`Identifier for ${file.name}`}
                            className="w-2/3 md:w-1/2 bg-gray-800/70 border border-gray-700 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                          />
                        </div>
                      ))}
                    </div>
                    {idFormatError && <ErrorMessage message={idFormatError} isWarning />}
                  </Section>
                )}
              </>
            )}
          </div>
          
          {/* Action Footer */}
          <div className="px-6 md:px-8 py-5 bg-black/20 border-t border-white/10">
            {mode === 'generate' && generationSummary && <InfoMessage message={generationSummary} />}
            {mode === 'generate' && error && <ErrorMessage message={error} />}
            {mode === 'verify' && verificationError && <ErrorMessage message={verificationError} />}
            
            <button
              onClick={mode === 'generate' ? handleGenerate : handleVerify}
              disabled={mode === 'generate' ? !canGenerate : !canVerify}
              className={`w-full font-bold text-lg py-3 px-6 rounded-lg transition-all duration-300 ease-in-out transform flex items-center justify-center gap-3 disabled:cursor-not-allowed relative overflow-hidden
                ${(mode === 'generate' ? canGenerate : canVerify)
                  ? `bg-cyan-500 text-white hover:bg-cyan-400 shadow-lg shadow-cyan-500/20 hover:shadow-cyan-400/30 active:scale-95`
                  : 'bg-gray-700 text-gray-500'
                }`}
            >
              {/* Progress Bar background layer */}
              {isLoading && audioFiles.length > 1 && (
                <div 
                  className="absolute top-0 left-0 h-full bg-cyan-400/70 transition-all duration-500 ease-out"
                  style={{ width: `${generationProgress}%` }}
                ></div>
              )}

              {/* Content layer */}
              <div className="relative z-10 flex items-center justify-center w-full">
                {(isLoading && audioFiles.length <= 1) || isVerifying ? <Loader /> : null}

                {mode === 'generate'
                  ? (isLoading
                    ? (audioFiles.length > 1 
                        ? <span className="text-base font-medium truncate px-2">{generationStatus || 'Generating...'}</span> 
                        : 'Generating...')
                    : `Generate ${audioFiles.length > 1 ? `All (${audioFiles.length}) Signatures` : 'Signature'}`)
                  : (isVerifying
                    ? 'Verifying...'
                    : `Verify ${verificationFiles.length > 1 ? `All (${verificationFiles.length}) Signatures` : 'Signature'}`)
                }
              </div>
            </button>
          </div>
        </main>
        
        {mode === 'verify' && batchVerificationResults && (
           <BatchVerificationResults results={batchVerificationResults} />
        )}

        {mode === 'verify' && showHistory && (
          <VerificationHistory history={verificationHistory} onClear={handleClearHistory} />
        )}

      </div>
    </div>
  );
};

const Section: React.FC<{ title: string; icon: React.ReactNode; children: React.ReactNode }> = ({ title, icon, children }) => (
  <div className="space-y-3">
    <h2 className="text-lg font-semibold text-gray-200 flex items-center gap-3">
      {icon} {title}
    </h2>
    {children}
  </div>
);

const ErrorMessage: React.FC<{ message: string; isWarning?: boolean }> = ({ message, isWarning }) => (
  <div className={`mt-2 flex items-start gap-3 text-sm p-3 rounded-lg border
    ${isWarning ? 'text-yellow-300 bg-yellow-900/30 border-yellow-500/20' : 'text-red-300 bg-red-900/30 border-red-500/20'}
  `}>
    <AlertTriangleIcon className="w-5 h-5 flex-shrink-0 mt-0.5" />
    <span className="whitespace-pre-wrap">{message}</span>
  </div>
);

const InfoMessage: React.FC<{ message: string }> = ({ message }) => (
  <div className="mb-4 flex items-start gap-3 text-sm text-cyan-300 bg-cyan-900/30 border border-cyan-500/20 p-3 rounded-lg">
    <InfoIcon className="w-5 h-5 flex-shrink-0 mt-0.5" />
    <span>{message}</span>
  </div>
);

export default App;