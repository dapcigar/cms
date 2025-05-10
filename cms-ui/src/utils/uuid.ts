/**
 * Generate a UUID v4
 * This is a browser-safe implementation that works across different environments
 */
export function generateUUID(): string {
  // Use native crypto.randomUUID if available
  if (typeof window !== 'undefined' && 
      window.crypto && 
      typeof window.crypto.randomUUID === 'function') {
    return window.crypto.randomUUID();
  }
  
  // Fallback implementation for older browsers
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}
