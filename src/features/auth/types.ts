/**
 * Auth feature types.
 * AuthUser is the lightweight identity returned by Firebase Auth ("who you are").
 * It is deliberately separate from the richer Firestore user-profile document
 * (push tokens, notification prefs, productCount) which lives in its own type.
 */

/** How the user signed in. Mirrors the providers we enable in Firebase. */
export type AuthProvider = 'password' | 'google';

/** The current authenticated identity, mapped from Firebase's User object. */
export interface AuthUser {
  uid: string;
  email: string | null;
  displayName: string | null;
  photoURL: string | null;
  emailVerified: boolean;
  provider: AuthProvider;
}

/** Inputs for the email/password login form. */
export interface LoginInput {
  email: string;
  password: string;
}

/** Inputs for the email/password registration form. */
export interface RegisterInput {
  email: string;
  password: string;
  /** Optional friendly name shown in the UI; set on the Firebase profile. */
  displayName?: string;
}

/** Input for the "forgot password" flow. */
export interface ResetPasswordInput {
  email: string;
}
