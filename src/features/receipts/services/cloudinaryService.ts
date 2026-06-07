import { Platform } from 'react-native';

/**
 * Cloudinary upload (unsigned) for receipt images.
 * Uses the cloud name + unsigned upload preset from env vars. The API secret
 * is never used here — unsigned uploads keep secrets out of the app.
 */

const CLOUD_NAME = process.env.EXPO_PUBLIC_CLOUDINARY_CLOUD_NAME;
const UPLOAD_PRESET = process.env.EXPO_PUBLIC_CLOUDINARY_UPLOAD_PRESET;

export interface UploadedImage {
  secureUrl: string;
  publicId: string;
}

/** True when both cloud name and preset are set. */
export function isCloudinaryConfigured(): boolean {
  return Boolean(CLOUD_NAME && UPLOAD_PRESET);
}

/** Upload a local image URI to Cloudinary and return its hosted URL. */
export async function uploadReceiptImage(localUri: string): Promise<UploadedImage> {
  if (!CLOUD_NAME || !UPLOAD_PRESET) {
    throw new Error(
      'Cloudinary is not set up yet. Add EXPO_PUBLIC_CLOUDINARY_UPLOAD_PRESET to .env.',
    );
  }

  const form = new FormData();
  if (Platform.OS === 'web') {
    // On web the picker gives a blob/data URI — fetch it into a Blob to upload.
    const blob = await (await fetch(localUri)).blob();
    form.append('file', blob);
  } else {
    // On native, append the file descriptor directly.
    form.append('file', { uri: localUri, type: 'image/jpeg', name: 'receipt.jpg' } as any);
  }
  form.append('upload_preset', UPLOAD_PRESET);

  const response = await fetch(
    `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/image/upload`,
    { method: 'POST', body: form },
  );
  const json = await response.json();
  if (!response.ok) {
    throw new Error(json?.error?.message ?? 'Image upload failed');
  }
  return { secureUrl: json.secure_url, publicId: json.public_id };
}
