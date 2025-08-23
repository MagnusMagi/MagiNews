# 📱 MagiNews iOS - Versiyonlama Rehberi

## 🏷️ Semantik Versiyonlama (SemVer)

### Format: `MAJOR.MINOR.PATCH`

- **MAJOR** (X.0.0): Büyük değişiklikler, uyumsuz API değişiklikleri
- **MINOR** (0.X.0): Yeni özellikler, geriye uyumlu değişiklikler  
- **PATCH** (0.0.X): Hata düzeltmeleri, küçük iyileştirmeler

## 📋 Versiyon Geçmişi

### v0.1.0 - Initial Release
- ✅ Temel Xcode proje yapısı
- ✅ iOS uygulama iskeleti
- ✅ Test dosyaları (Unit & UI Tests)
- ✅ Git repository kurulumu

## 🚀 Gelecek Versiyonlar

### v0.2.0 - Core Features
- [ ] Ana ekran tasarımı
- [ ] Haber listesi görünümü
- [ ] Temel navigasyon

### v0.3.0 - Data Layer
- [ ] API entegrasyonu
- [ ] Veri modelleri
- [ ] Cache sistemi

### v1.0.0 - Production Ready
- [ ] Tam özellik seti
- [ ] Hata yönetimi
- [ ] Performance optimizasyonu
- [ ] App Store hazırlığı

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
git log v0.1.0..HEAD --oneline

# Tag'leri GitHub'a push et
git push origin --tags
```

---

**Not:** Her önemli özellik veya düzeltme sonrası versiyon güncellemesi yapılmalıdır.
