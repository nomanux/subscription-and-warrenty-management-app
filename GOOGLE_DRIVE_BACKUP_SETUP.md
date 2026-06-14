# Google Drive Backup Configuration Guide

## Overview
Warantee app includes automatic Google Drive backup/restore functionality. Your warranty data is backed up to a "Warantee Backups" folder in your Google Drive and can be restored anytime.

---

## ✅ What's Already Configured

### 1. **Firebase OAuth Setup**
- ✅ Firebase project created: `warrenty-management-b9396`
- ✅ OAuth clients configured in `android/app/google-services.json`
- ✅ Debug SHA-1 fingerprint registered
- ✅ Google Sign-In enabled

### 2. **Google Drive API**
- ✅ Drive API enabled in Google Cloud Console
- ✅ Using least-privilege `drive.file` scope (only manages files this app creates)
- ✅ No special verification needed (non-sensitive scope)

### 3. **App Code**
- ✅ GoogleAuthService (handles sign-in)
- ✅ DriveBackupService (handles backup/restore)
- ✅ Automatic daily backup on app open
- ✅ Manual backup/restore buttons in Profile → Backup & Restore

---

## 🚀 How to Use

### **Step 1: Sign in with Google**
1. Open **Warantee** app
2. Go to **Profile** (bottom right)
3. Scroll down to **Backup & Restore**
4. Tap **"Connect Google Account"**
5. Select your Gmail account
6. Grant permission to access Google Drive

### **Step 2: Backup Your Data**
**Manual Backup:**
1. Profile → Backup & Restore
2. Tap **"Back up now"**
3. Confirm the action
4. See success message ✅

**Automatic Backup:**
- Runs automatically once per day when you open the app
- No action needed from you
- Silent (won't bother you)

### **Step 3: Verify Backup**
1. Open your **Google Drive** (drive.google.com)
2. Look for **"Warantee Backups"** folder
3. Inside, you'll see timestamped JSON files:
   - `warantee-backup-2026-06-13T08-22-45.json`
   - Each file is a complete snapshot of your warranties

### **Step 4: Restore Data (If Needed)**
1. Profile → Backup & Restore
2. Tap **"Restore from Drive"**
3. Confirm the action
4. Your latest backup will be merged into your app
5. All warranties restored ✅

---

## 📋 What Gets Backed Up

Each backup includes:
```
{
  "schemaVersion": 1,
  "exportedAt": "2026-06-13T08:22:45.025954Z",
  "count": 10,
  "products": [
    {
      "id": "warranty-1",
      "productName": "iPhone 15",
      "category": "Electronics",
      "purchaseDate": "2025-06-13",
      "warrantyDurationMonths": 24,
      "expiryDate": "2027-06-13",
      "shopName": "Apple Store",
      "location": "Downtown",
      "receipt": { ... },
      "warrantyCard": { ... },
      "visitingCard": { ... }
    },
    ...
  ]
}
```

---

## 🔄 Sync Behavior

### **Manual Backup**
- Uploads all current warranties as a new file
- Creates timestamped JSON in "Warantee Backups" folder
- Updates "Last backed up" timestamp

### **Automatic Daily Backup**
- Runs once per 24 hours on app open
- Silent (no notifications)
- Only if connected to Google
- Skips if already backed up today
- Never interrupts your workflow

### **Restore**
- Downloads your latest backup file
- Merges warranties by ID (if ID matches, updates; else adds new)
- Preserves existing data not in backup
- Perfect for switching devices

---

## 🛡️ Security & Privacy

- ✅ Uses OAuth 2.0 (secure authentication)
- ✅ `drive.file` scope (minimal permissions)
- ✅ Only accesses files this app creates
- ✅ Encrypted in transit (HTTPS)
- ✅ Stored in your personal Google Drive
- ✅ You control what to sync

---

## ⚙️ Troubleshooting

### **"Access blocked" Error**
**Cause:** Google account not added as test user in OAuth consent screen
**Fix:**
1. Go to Google Cloud Console
2. Project: warrenty-management-b9396
3. OAuth consent screen → Test users
4. Add your Gmail address
5. Try again in app

### **"No backup found" Error**
**Cause:** First time or all backups deleted
**Fix:**
- Tap "Back up now" first
- Wait 3-5 seconds
- Then try "Restore from Drive"

### **"Permission denied" Error**
**Cause:** Need to re-authorize
**Fix:**
1. Profile → Backup & Restore
2. Scroll down to "Google Account"
3. Tap "Disconnect"
4. Sign in again
5. Grant permissions again

### **Backup Not Appearing in Drive**
**Cause:** Folder might be hidden or file not synced
**Fix:**
1. Open Google Drive (drive.google.com)
2. Press Ctrl+H (or Cmd+H) to show hidden files
3. Look for "Warantee Backups" folder
4. If still missing, try "Back up now" again

---

## 📊 Backup Frequency

| Scenario | Frequency |
|----------|-----------|
| Manual backup | On demand |
| Automatic backup | Once per 24 hours |
| Check backup status | Anytime in Profile |
| Last backup shown | In Backup & Restore screen |

---

## ✨ Best Practices

1. **Sign in early** - Do it once, auto-backup handles the rest
2. **Check "Last backed up"** - Verify your data is being saved
3. **Restore before big changes** - If you're editing lots of warranties, backup first
4. **Multiple devices?** - Sign in on all devices, they'll sync via Drive
5. **Switched phones?** - Sign in and restore, warranties back instantly

---

## 🔗 Related Documentation

- **App Privacy**: All data stored locally on device + your Google Drive
- **Google Drive**: Your personal account, you control access
- **Firebase**: Warranty data also in Firestore (separate from Drive backups)

---

## Need Help?

If backups aren't working:
1. Verify Gmail is signed in (Profile → Backup & Restore)
2. Check "Last backed up" timestamp
3. Open Google Drive app and look for "Warantee Backups" folder
4. Try "Back up now" button manually
5. Check internet connection

---

**Version:** 1.0  
**Last Updated:** 2026-06-13  
**App Version:** Warantee 1.0.0
