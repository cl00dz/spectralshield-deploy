import React, { useState } from 'react';
import { UploadCloudIcon, MusicIcon, XCircleIcon } from './icons';

interface FileUploadProps {
  onFilesChange: (files: File[]) => void;
  files: File[];
  onError: (message: string | null) => void;
  acceptedMimeTypes?: string[];
  maxSizeMb?: number;
  maxFiles?: number;
  descriptionText?: string;
}

export const FileUpload: React.FC<FileUploadProps> = ({ onFilesChange, files, onError, acceptedMimeTypes, maxSizeMb, maxFiles, descriptionText }) => {
  const [isDragging, setIsDragging] = useState(false);

  const handleFilesSelect = (selectedFiles: FileList | null) => {
    onError(null);
    if (!selectedFiles || selectedFiles.length === 0) return;

    if (maxFiles && selectedFiles.length > maxFiles) {
      onError(`You can only upload a maximum of ${maxFiles} files at a time.`);
      onFilesChange([]); // Clear selection
      return;
    }

    const validFiles: File[] = [];
    const errors: string[] = [];
    for (const file of Array.from(selectedFiles)) {
      if (acceptedMimeTypes && !acceptedMimeTypes.includes(file.type)) {
        errors.push(`Invalid type for ${file.name}. Only ${acceptedMimeTypes.join(', ')} are allowed.`);
      } else if (maxSizeMb && file.size > maxSizeMb * 1024 * 1024) {
        errors.push(`File too large: ${file.name} (Max ${maxSizeMb}MB)`);
      } else {
        validFiles.push(file);
      }
    }

    if (errors.length > 0) onError(errors.join('\n'));
    onFilesChange(validFiles);
  };
  
  const handleDragEnter = (e: React.DragEvent<HTMLLabelElement>) => { e.preventDefault(); e.stopPropagation(); setIsDragging(true); };
  const handleDragLeave = (e: React.DragEvent<HTMLLabelElement>) => { e.preventDefault(); e.stopPropagation(); setIsDragging(false); };
  const handleDragOver = (e: React.DragEvent<HTMLLabelElement>) => { e.preventDefault(); e.stopPropagation(); };
  const handleDrop = (e: React.DragEvent<HTMLLabelElement>) => {
    e.preventDefault(); e.stopPropagation(); setIsDragging(false);
    handleFilesSelect(e.dataTransfer.files);
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    handleFilesSelect(e.target.files);
    e.target.value = ''; // Allow re-uploading
  };

  const clearFiles = () => { onFilesChange([]); onError(null); };

  if (files.length > 0) {
    return (
      <div className="bg-gray-800/50 border border-cyan-500/30 rounded-lg p-4 flex items-center justify-between">
        <div className="flex items-center gap-3 overflow-hidden">
          <MusicIcon className="w-5 h-5 text-cyan-400 flex-shrink-0" />
          <span className="truncate text-gray-300 font-medium">{files.length} file(s) selected</span>
        </div>
        <button onClick={clearFiles} className="text-gray-400 hover:text-red-400 transition-colors flex items-center gap-1.5 text-sm p-1 rounded-md hover:bg-red-500/10">
          <XCircleIcon className="w-4 h-4" />
          Clear
        </button>
      </div>
    );
  }

  return (
    <label
      onDragEnter={handleDragEnter}
      onDragLeave={handleDragLeave}
      onDragOver={handleDragOver}
      onDrop={handleDrop}
      className={`relative block w-full border border-gray-700 rounded-lg p-8 text-center cursor-pointer transition-all duration-300 group
        ${isDragging ? 'bg-cyan-900/30 scale-105 animate-pulse-glow' : 'hover:border-gray-500 bg-gray-800/50'}
      `}
    >
      <div className="flex flex-col items-center justify-center space-y-2 text-gray-400 transition-transform duration-300 group-hover:scale-105">
        <UploadCloudIcon className="w-10 h-10" />
        <span className="font-medium text-gray-300">
          <span className="text-cyan-400">Click to upload</span> or drag and drop
        </span>
        <span className="text-xs text-gray-500">{descriptionText || 'MP3, WAV, OGG, or FLAC'}</span>
      </div>
      <input
        type="file"
        multiple
        accept={acceptedMimeTypes ? acceptedMimeTypes.join(',') : "audio/*"}
        onChange={handleInputChange}
        className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
      />
    </label>
  );
};
