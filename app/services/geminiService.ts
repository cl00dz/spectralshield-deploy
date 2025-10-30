// NOTE: This service is responsible for local cryptographic operations.
// It does not use any AI or external services for its core functionality.

import { SignatureResult, VerificationResult } from '../types';

// This is the new data structure we will encode in the unique identifier.
interface AudioSignaturePayload {
  metadata: {
    name: string;
    size: number;
    type: string;
  };
  watermark: string;
  contentHash: string; // A hash of the original file content + watermark text
}

// --- Hardening Measures ---

// A static, non-obvious key used for obfuscation. This makes the encoding process non-standard.
// An attacker would need to find this key in the minified source to reverse-engineer the identifier.
const OBFUSCATION_KEY = '5p3c7r4l-5h13ld-v1-s3cr37';

// A simple XOR cipher to obfuscate the JSON payload before Base64 encoding.
// This prevents someone from simply Base64-decoding the identifier to see its structure.
const xorCipher = (input: string, key: string): string => {
  let output = '';
  for (let i = 0; i < input.length; i++) {
    // XOR the character code of the input with the character code of the key.
    // The key is repeated if it's shorter than the input.
    const charCode = input.charCodeAt(i) ^ key.charCodeAt(i % key.length);
    output += String.fromCharCode(charCode);
  }
  return output;
};

// --- Watermarking Logic ---

// A unique byte sequence to act as a marker for our signature.
// "SSWV1" stands for SpectralShield Watermark Version 1.
const WATERMARK_MARKER = new TextEncoder().encode('SSWV1');

/**
 * Checks if a file buffer already contains our watermark marker at the end.
 * @param buffer The ArrayBuffer of the file.
 * @returns true if the watermark is present, false otherwise.
 */
const hasWatermark = (buffer: ArrayBuffer): boolean => {
  if (buffer.byteLength < WATERMARK_MARKER.length) {
    return false;
  }
  const endOfFile = new Uint8Array(buffer, buffer.byteLength - WATERMARK_MARKER.length);
  for (let i = 0; i < WATERMARK_MARKER.length; i++) {
    if (endOfFile[i] !== WATERMARK_MARKER[i]) {
      return false;
    }
  }
  return true;
};

/**
 * Appends the watermark marker to a buffer.
 * @param buffer The original file ArrayBuffer.
 * @returns A new ArrayBuffer with the watermark appended.
 */
const addWatermark = (buffer: ArrayBuffer): ArrayBuffer => {
  const newBuffer = new Uint8Array(buffer.byteLength + WATERMARK_MARKER.length);
  newBuffer.set(new Uint8Array(buffer), 0);
  newBuffer.set(WATERMARK_MARKER, buffer.byteLength);
  return newBuffer.buffer;
};

/**
 * Removes the watermark marker from a buffer if it exists.
 * @param buffer The potentially watermarked ArrayBuffer.
 * @returns An ArrayBuffer of the original content.
 */
const stripWatermark = (buffer: ArrayBuffer): ArrayBuffer => {
  if (hasWatermark(buffer)) {
    return buffer.slice(0, buffer.byteLength - WATERMARK_MARKER.length);
  }
  return buffer;
};


/**
 * Custom error for when a file already has a watermark.
 */
export class AlreadyWatermarkedError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'AlreadyWatermarkedError';
  }
}

// --- End Hardening Measures ---


// Helper to generate a UUID-like string.
const generateUUID = (): string => {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
};

// Helper to check for Web Crypto API availability in a secure context.
const checkCryptoAvailability = () => {
    if (typeof crypto === 'undefined' || !crypto.subtle || typeof crypto.subtle.digest !== 'function') {
      throw new Error(
        "Web Crypto API is not available. This feature requires a secure context (like HTTPS or localhost). Please ensure the application is accessed securely.",
      );
    }
  };

// Use Web Crypto API for a robust, browser-native hashing function.
const calculateHash = async (buffer: ArrayBuffer, text: string): Promise<string> => {
  const textEncoder = new TextEncoder();
  const textBytes = textEncoder.encode(text);
  
  const combinedBuffer = new Uint8Array(buffer.byteLength + textBytes.byteLength);
  combinedBuffer.set(new Uint8Array(buffer), 0);
  combinedBuffer.set(textBytes, buffer.byteLength);

  const hashBuffer = await crypto.subtle.digest('SHA-256', combinedBuffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
};

// Encode and obfuscate the signature payload into a verifiable identifier string.
const encodeIdentifier = (payload: AudioSignaturePayload): string => {
  // 1. Stringify the JSON payload.
  const jsonPayload = JSON.stringify(payload);
  // 2. Obfuscate the JSON string with our XOR cipher.
  const obfuscatedPayload = xorCipher(jsonPayload, OBFUSCATION_KEY);
  // 3. Base64 encode the obfuscated string. This makes it look like a standard token, but it's not.
  const base64Payload = btoa(obfuscatedPayload);
  // 4. Combine with a version prefix and a UUID to create the final identifier.
  const uuid = generateUUID();
  return `ss-v1-${base64Payload}.${uuid}`;
};

// Decode and de-obfuscate the identifier to retrieve the original signature payload.
const decodeIdentifier = (identifier: string): AudioSignaturePayload | null => {
  // 1. Check for our custom version prefix.
  if (!identifier.startsWith('ss-v1-')) {
    return null; // Not a valid identifier from this app.
  }

  try {
    // 2. Extract the payload and UUID parts.
    const parts = identifier.substring(6).split('.');
    if (parts.length < 2) {
      return null; // Structurally malformed.
    }
    const base64Payload = parts[0];
    
    // 3. Base64 decode the payload.
    const obfuscatedPayload = atob(base64Payload);
    // 4. De-obfuscate the result using the same XOR cipher and key.
    const jsonPayload = xorCipher(obfuscatedPayload, OBFUSCATION_KEY);
    // 5. Parse the de-obfuscated string back into a JSON object.
    const data = JSON.parse(jsonPayload);

    // 6. Validate the structure of the decoded object to ensure it's what we expect.
    if (data.metadata && typeof data.watermark === 'string' && data.contentHash &&
        data.metadata.name && typeof data.metadata.size === 'number' && data.metadata.type) {
        return data as AudioSignaturePayload;
    }
    return null; // Structurally correct but content is wrong.
  } catch (e) {
    // Errors during atob(), JSON.parse(), or xorCipher() indicate a corrupted/invalid identifier.
    console.error("Failed to decode identifier due to corruption or tampering:", e);
    throw new Error("The provided identifier appears to be corrupted or is not a valid signature ID.");
  }
};

export const generateSignatureAndId = async (
  audioFile: File,
  watermarkText: string
): Promise<{ signatureResult: SignatureResult; watermarkedFile: Blob }> => {
  checkCryptoAvailability();
  const originalBuffer = await audioFile.arrayBuffer();

  // PRE-DETECTION STEP: Check if the file is already watermarked.
  if (hasWatermark(originalBuffer)) {
    throw new AlreadyWatermarkedError(`File "${audioFile.name}" already contains a SpectralShield signature.`);
  }

  // Hash is calculated on the ORIGINAL, un-watermarked content.
  const contentHash = await calculateHash(originalBuffer, watermarkText);

  const payload: AudioSignaturePayload = {
    metadata: {
      name: audioFile.name,
      size: audioFile.size,
      type: audioFile.type,
    },
    watermark: watermarkText,
    contentHash,
  };
  
  const uniqueIdentifier = encodeIdentifier(payload);

  // Add the watermark to the buffer to create the new downloadable file.
  const watermarkedBuffer = addWatermark(originalBuffer);
  const watermarkedFile = new Blob([watermarkedBuffer], { type: audioFile.type });

  return {
    signatureResult: {
      spectralSignature: contentHash,
      uniqueIdentifier,
    },
    watermarkedFile,
  };
};

export const verifySignature = async (
  verificationFile: File,
  uniqueIdentifier: string
): Promise<VerificationResult> => {
  checkCryptoAvailability();
  // decodeIdentifier can now throw for corrupted IDs.
  // This will be caught by the handler in App.tsx.
  const decodedPayload = decodeIdentifier(uniqueIdentifier);

  if (!decodedPayload) {
    return {
      isValid: false,
      reason: "The provided identifier is malformed or invalid. It may be incomplete or from a different system."
    };
  }
  
  const watermarkedBuffer = await verificationFile.arrayBuffer();
  
  // A valid signed file MUST have our watermark.
  if (!hasWatermark(watermarkedBuffer)) {
    return {
        isValid: false,
        reason: "Verification failed. The file does not appear to contain a SpectralShield signature."
    };
  }
  
  // Strip the watermark to get the original content for hashing and metadata comparison.
  const originalBuffer = stripWatermark(watermarkedBuffer);

  // Check original file metadata (size and type). Filename is ignored to allow for renamed file verification.
  if (
    decodedPayload.metadata.size !== originalBuffer.byteLength ||
    decodedPayload.metadata.type !== verificationFile.type
  ) {
    return {
      isValid: false,
      reason: "Verification failed. The file metadata (original size, type) does not match the signature. The file may have been re-encoded or is incorrect."
    };
  }

  const newContentHash = await calculateHash(originalBuffer, decodedPayload.watermark);

  if (newContentHash === decodedPayload.contentHash) {
    const wasRenamed = decodedPayload.metadata.name !== verificationFile.name;
    const reason = wasRenamed
      ? `Signature is valid. Original filename: "${decodedPayload.metadata.name}".`
      : "Signature is valid. The file content and signature match perfectly.";

    return {
      isValid: true,
      reason: reason,
      watermarkText: decodedPayload.watermark,
    };
  } else {
    return {
      isValid: false,
      reason: "Verification failed. The file's content has been altered, or this is not the correct file for this identifier."
    };
  }
};