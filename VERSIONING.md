# 📱 MagiNews iOS - Versiyonlama Rehberi

## 🏷️ Semantik Versiyonlama (SemVer)

### Format: `MAJOR.MINOR.PATCH`

- **MAJOR** (X.0.0): Büyük değişiklikler, uyumsuz API değişiklikleri
- **MINOR** (0.X.0): Yeni özellikler, geriye uyumlu değişiklikler  
- **PATCH** (0.0.X): Hata düzeltmeleri, küçük iyileştirmeler

## 📋 Versiyon Geçmişi

### v0.2.0 - Core Features Release
- ✅ Tam haber uygulama yapısı
- ✅ NewsArticle, NewsCategory, UserPreferences modelleri
- ✅ HomeView ile ana ekran tasarımı
- ✅ NewsRowView ile haber listesi görünümü
- ✅ NewsDetailView ile detaylı haber okuma
- ✅ Kategori filtreleme ve arama sistemi
- ✅ Modern SwiftUI tasarım desenleri
- ✅ Kapsamlı README dokümantasyonu

### v0.1.0 - Initial Release
- ✅ Temel Xcode proje yapısı
- ✅ iOS uygulama iskeleti
- ✅ Test dosyaları (Unit & UI Tests)
- ✅ Git repository kurulumu

## 🚀 Gelecek Versiyonlar

### v0.3.0 - Data Layer & API
- [ ] API entegrasyonu
- [ ] Offline cache sistemi
- [ ] Veri senkronizasyonu
- [ ] Error handling

### v0.4.0 - Enhanced Features
- [ ] Kullanıcı tercihleri
- [ ] Dark mode desteği
- [ ] Push bildirimleri
- [ ] Sosyal paylaşım

### v1.0.0 - Production Ready
- [ ] App Store optimizasyonu
- [ ] Analytics entegrasyonu
- [ ] Crash reporting
- [ ] Performance optimizasyonu

## 📝 Commit Mesaj Standartları

### Format: `type(scope): description`

**Types:**
- `feat`: Yeni özellik
- `fix`: Hata düzeltmesi
- `docs`: Dokümantasyon
- `style`: Kod formatı
- `refactor`: Kod yeniden düzenleme
- `test`: Test ekleme/düzenleme
- `chore`: Genel bakım

**Examples:**
```
feat(ui): add news list view
fix(api): resolve network timeout issue
docs(readme): update installation guide
refactor(core): optimize data loading
```

## 🔄 Versiyon Güncelleme Adımları

1. **Kod değişikliklerini yap**
2. **Commit mesajı ile commit yap**
3. **Uygun versiyon numarasını belirle**
4. **Tag oluştur:** `git tag -a vX.Y.Z -m "Description"`
5. **Tag'i push et:** `git push origin vX.Y.Z`
6. **GitHub'da Release oluştur**

## 📊 Versiyon Kontrol Komutları

```bash
# Mevcut tag'leri listele
git tag -l

# Son commit'leri görüntüle
git log --oneline -10

# Belirli tag'den sonraki değişiklikleri görüntüle
git log v0.2.0..HEAD --oneline

# Tag'leri GitHub'a push et
git push origin --tags
```

---

**Not:** Her önemli özellik veya düzeltme sonrası versiyon güncellemesi yapılmalıdır.
