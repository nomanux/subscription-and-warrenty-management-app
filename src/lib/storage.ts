import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * Typed, error-safe wrapper around AsyncStorage.
 * Centralizes JSON (de)serialization and error handling so the rest of the
 * app deals in plain objects. This is the single seam we'd replace if we ever
 * swapped the local storage engine (e.g. to SQLite).
 */

/** Read and parse a JSON value. Returns null if missing or unparseable. */
export async function getItem<T>(key: string): Promise<T | null> {
  try {
    const raw = await AsyncStorage.getItem(key);
    return raw ? (JSON.parse(raw) as T) : null;
  } catch (error) {
    console.warn(`[storage] failed to read "${key}"`, error);
    return null;
  }
}

/** Serialize and store a JSON value. Throws on failure so callers can react. */
export async function setItem<T>(key: string, value: T): Promise<void> {
  try {
    await AsyncStorage.setItem(key, JSON.stringify(value));
  } catch (error) {
    console.warn(`[storage] failed to write "${key}"`, error);
    throw error;
  }
}

/** Remove a stored value. Swallows errors (nothing to recover). */
export async function removeItem(key: string): Promise<void> {
  try {
    await AsyncStorage.removeItem(key);
  } catch (error) {
    console.warn(`[storage] failed to remove "${key}"`, error);
  }
}
