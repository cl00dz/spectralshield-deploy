
export interface SignatureResult {
  spectralSignature: string;
  uniqueIdentifier: string;
}

export interface VerificationResult {
  isValid: boolean;
  reason: string;
  watermarkText?: string;
}

export interface VerificationHistoryItem extends VerificationResult {
  fileName: string;
  identifier: string;
  timestamp: string; // ISO string
}

export interface AppError {
  key: string;
  context?: Record<string, string | number>;
}
