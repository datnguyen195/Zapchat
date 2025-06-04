# 📊 Google Sheets Translation Management Guide

## 🎯 **Overview**

Hệ thống quản lý translation sử dụng Google Sheets làm source of truth, với local cache để support offline.

## 🏗️ **Setup Process**

### **1. Tạo Google Sheet**

#### **Format Required:**

```
| key                | en                    | vi                           | ja                    |
|--------------------|----------------------|------------------------------|----------------------|
| app.name           | ZapChat              | ZapChat                      | ザップチャット           |
| app.welcome        | Welcome to ZapChat   | Chào mừng đến với ZapChat    | ZapChatへようこそ        |
| auth.login         | Login                | Đăng nhập                    | ログイン               |
| auth.email         | Email                | Email                        | メール                 |
| user.profile       | Profile              | Hồ sơ                        | プロフィール            |
| settings.language  | Language             | Ngôn ngữ                     | 言語                   |
```

#### **Rules:**

- **Cột đầu tiên PHẢI là `key`**
- Keys sử dụng dot notation: `section.subsection.item`
- Language codes là ISO 639-1: `en`, `vi`, `ja`, `ko`, etc.
- Cells có thể empty (sẽ fallback to English)

### **2. Publish Google Sheet**

#### **Step by step:**

1. Mở Google Sheet
2. Click **File** → **Share** → **Publish to web**
3. Chọn **Link tab** → **Comma-separated values (.csv)**
4. Click **Publish**
5. Copy link, sẽ có format:
   ```
   https://docs.google.com/spreadsheets/d/SHEET_ID/export?format=csv&gid=GID
   ```

#### **Extract IDs:**

- **SHEET_ID**: Phần giữa `/d/` và `/export`
- **GID**: Tham số `gid` trong URL (default là `0`)

### **3. Environment Configuration**

Update `.env`:

```env
GOOGLE_SHEETS_ID=1abc123def456ghi789jkl012mno345pqr678stu
GOOGLE_SHEETS_GID=0
```

### **4. Testing**

#### **Verify Sheet Access:**

```bash
curl "https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID/export?format=csv&gid=0"
```

Phải return CSV data với header là `key,en,vi,...`

## 🔄 **How It Works**

### **Priority System:**

1. **Remote Cache** (từ Google Sheets) - Highest priority
2. **Local Bundle** (JSON files) - Fallback
3. **English Bundle** - Final fallback
4. **Empty translations** - Emergency fallback

### **Sync Strategy:**

- **Auto-sync**: Khi mở app (không block startup)
- **Cache duration**: 6 hours (configurable)
- **Debug mode**: Always sync
- **Production**: Respect cache duration

### **Error Handling:**

- Network failure → Use cached translations
- Malformed CSV → Use bundled translations
- Missing keys → Return key string
- Missing language → Fallback to English

## 📱 **Usage Examples**

### **Basic Usage:**

```dart
final t = AppLocalizations.of(context);

// Section-based access (recommended)
Text(t.app('welcome'))        // app.welcome
Text(t.auth('login'))         // auth.login
Text(t.settings('language'))  // settings.language

// Direct access
Text(t.t('user.profile'))     // user.profile

// With parameters (if implemented)
Text(t.t('welcome.user', params: {'name': 'John'}))
```

### **Management Page:**

```dart
Navigator.push(context, MaterialPageRoute(
  builder: (context) => TranslationManagementPage(),
));
```

## 🛠️ **Development Workflow**

### **Adding New Translations:**

1. **Update Google Sheet:**

   - Add new row with key in dot notation
   - Fill translations for all languages
   - Save sheet (auto-publishes)

2. **In App:**

   - Open Translation Management page
   - Tap "Force Sync" to pull latest
   - Verify new translations appear

3. **Code Usage:**
   ```dart
   // Add to appropriate section getter
   Text(t.newSection('newKey'))  // newSection.newKey
   ```

### **Best Practices:**

#### **Key Naming:**

```
✅ Good:
- auth.login
- user.profile.name
- error.network.timeout

❌ Bad:
- loginButton
- userName123
- ERROR_MSG
```

#### **Translation Guidelines:**

- Keep keys semantic, not UI-specific
- Use consistent terminology across languages
- Test with longest language (German/Finnish)
- Consider RTL languages if supporting Arabic/Hebrew

## 🔧 **Advanced Configuration**

### **Custom Sync Intervals:**

```dart
// In translation_sync_service.dart
static const Duration _cacheDuration = Duration(hours: 2); // Custom interval
```

### **Multiple Sheets Support:**

```dart
// Different sheets for different features
static String get _authSheetId => Environment.authSheetsId;
static String get _mainSheetId => Environment.mainSheetsId;
```

### **Selective Language Loading:**

```dart
// Only load specific languages
final supportedLanguages = ['en', 'vi'];
if (supportedLanguages.contains(languageCode)) {
  // Process language
}
```

## 🐛 **Troubleshooting**

### **Common Issues:**

#### **"Failed to fetch translations"**

- ✅ Check internet connection
- ✅ Verify Google Sheet is published
- ✅ Confirm SHEET_ID and GID are correct
- ✅ Test CSV URL in browser

#### **"Empty CSV data received"**

- ✅ Ensure sheet has data
- ✅ Check first column is named 'key'
- ✅ Verify publish settings include all sheets

#### **"Key column not found"**

- ✅ First column must be exactly 'key' (case-sensitive)
- ✅ No extra spaces or special characters

#### **Translations not updating**

- ✅ Force sync from management page
- ✅ Clear cache and try again
- ✅ Restart app after sync

### **Debug Commands:**

```dart
// Clear all cached translations
await TranslationSyncService.clearCache();

// Force immediate sync
await TranslationSyncService.forceSync();

// Check available languages
final languages = await TranslationSyncService.getAvailableLanguages();
```

## 📈 **Analytics & Monitoring**

### **Log Messages to Watch:**

```
✅ "Translation sync completed successfully"
⚠️  "Falling back to bundled translations"
❌ "Translation sync failed"
🔍 "Translation key not found: key.name"
```

### **Performance Metrics:**

- Sync frequency
- Cache hit ratio
- Fallback usage
- Failed key lookups

## 🚀 **Production Deployment**

### **Pre-deployment Checklist:**

- [ ] All required translations completed in sheet
- [ ] Sheet published publicly
- [ ] Environment variables configured
- [ ] Test sync in staging environment
- [ ] Verify fallback translations exist in bundle
- [ ] Test offline functionality

### **Monitoring:**

- Set up alerts for sync failures
- Monitor translation cache size
- Track translation key not found errors
- Regular sheet backup recommended

## 🔐 **Security Considerations**

- Google Sheets are public when published
- Don't include sensitive data in translations
- Consider access control for sheet editing
- Regular audit of translation content
- Backup sheet data periodically

---

**🎉 Happy translating! Your international users will thank you!**
