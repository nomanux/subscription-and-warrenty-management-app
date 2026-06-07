import { Platform } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { initializeApp, getApps, getApp, type FirebaseApp } from 'firebase/app';
import { getAuth, initializeAuth, type Auth } from 'firebase/auth';
import * as firebaseAuth from 'firebase/auth';
import { getFirestore, type Firestore } from 'firebase/firestore';

/**
 * getReactNativePersistence ships only in Firebase's React Native build, so it
 * is absent from the web type definitions. We access it dynamically: it's used
 * on native (for AsyncStorage session persistence) and simply undefined on web.
 */
type RNPersistenceFactory = (storage: unknown) => import('firebase/auth').Persistence;
const getReactNativePersistence = (firebaseAuth as Record<string, unknown>)
  .getReactNativePersistence as RNPersistenceFactory | undefined;

/**
 * Firebase configuration.
 * Values come from environment variables (.env) prefixed with EXPO_PUBLIC_,
 * which Expo inlines into the app at build time. Firebase web API keys are
 * public identifiers (not secrets) — access is controlled by Firebase
 * Security Rules, which we'll define later.
 */
const firebaseConfig = {
  apiKey: process.env.EXPO_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.EXPO_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.EXPO_PUBLIC_FIREBASE_APP_ID,
};

/**
 * Initialize the app only once. On Fast Refresh / hot reload this module can
 * re-run, so we reuse the existing instance instead of re-initializing.
 */
const app: FirebaseApp = getApps().length ? getApp() : initializeApp(firebaseConfig);

/**
 * Auth persistence differs by platform:
 *  - Native (iOS/Android): AsyncStorage keeps the session across app restarts.
 *  - Web: getAuth() uses the browser's built-in persistence.
 * The try/catch handles hot reload, where initializeAuth() would otherwise
 * throw "auth/already-initialized".
 */
function createAuth(): Auth {
  if (Platform.OS === 'web' || !getReactNativePersistence) {
    return getAuth(app);
  }
  try {
    return initializeAuth(app, {
      persistence: getReactNativePersistence(AsyncStorage),
    });
  } catch {
    return getAuth(app);
  }
}

const auth: Auth = createAuth();
const db: Firestore = getFirestore(app);

// Note: file storage is handled by Cloudinary (see src/lib/cloudinary.ts),
// not Firebase Storage. Firebase here provides Auth + Firestore only.
export { app, auth, db };
