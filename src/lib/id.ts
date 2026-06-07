/**
 * Generate a unique identifier for local records.
 * RFC4122-style v4 UUID using Math.random — sufficient for on-device IDs.
 * (When we move to Firestore, document IDs can come from Firestore instead.)
 */
export function generateId(): string {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (char) => {
    const random = (Math.random() * 16) | 0;
    const value = char === 'x' ? random : (random & 0x3) | 0x8;
    return value.toString(16);
  });
}
