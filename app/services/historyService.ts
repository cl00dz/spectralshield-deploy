
import { VerificationHistoryItem } from '../types';

const HISTORY_KEY = 'spectralShieldVerificationHistory';
const MAX_HISTORY_ITEMS = 20;

export const getVerificationHistory = (): VerificationHistoryItem[] => {
  try {
    const historyJson = localStorage.getItem(HISTORY_KEY);
    if (!historyJson) return [];
    return JSON.parse(historyJson);
  } catch (error) {
    console.error("Failed to parse verification history:", error);
    return [];
  }
};

export const addVerificationHistoryItem = (item: VerificationHistoryItem): void => {
  const currentHistory = getVerificationHistory();
  // Add new item to the front and slice to maintain the max limit
  const newHistory = [item, ...currentHistory].slice(0, MAX_HISTORY_ITEMS);
  localStorage.setItem(HISTORY_KEY, JSON.stringify(newHistory));
};

export const clearVerificationHistory = (): void => {
  localStorage.removeItem(HISTORY_KEY);
};
