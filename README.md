# 📱 MagiNews iOS

Modern ve kullanıcı dostu bir iOS haber uygulaması. SwiftUI ve SwiftData kullanılarak geliştirilmiştir.

## ✨ Özellikler

- 📰 Kategorilere göre haber filtreleme
- 🔍 Gelişmiş arama fonksiyonu
- 💾 Offline okuma için yerel depolama
- 🔖 Haberleri yer imlerine ekleme
- 📱 Modern ve responsive tasarım
- 🌙 Dark mode desteği (gelecek sürümde)
- 🔔 Push bildirimleri (gelecek sürümde)

## 🏗️ Teknik Detaylar

- **Platform**: iOS 17.0+
- **Framework**: SwiftUI
- **Veri Depolama**: SwiftData
- **Mimari**: MVVM Pattern
- **Minimum iOS**: 17.0

## 🚀 Kurulum

### Gereksinimler
- Xcode 15.0+
- iOS 17.0+ Simulator veya cihaz
- macOS 14.0+

### Adımlar
1. Projeyi klonlayın:
```bash
git clone https://github.com/MagnusMagi/MagiNews.git
cd MagiNews
```

2. Xcode'da `MagiNewsIOS.xcodeproj` dosyasını açın

3. Simulator veya cihaz seçin

4. Build edin ve çalıştırın (⌘+R)

## 📁 Proje Yapısı

```
MagiNewsIOS/
├── Models/
│   └── NewsModels.swift          # Veri modelleri
├── Views/
│   ├── HomeView.swift            # Ana ekran
│   ├── NewsRowView.swift         # Haber satırı
│   └── NewsDetailView.swift      # Haber detayı
├── MagiNewsIOSApp.swift          # Ana uygulama
└── Assets.xcassets/              # Görsel kaynaklar
```

## 🔧 Geliştirme

### Yeni Özellik Ekleme
1. Feature branch oluşturun: `git checkout -b feature/yeni-ozellik`
2. Kodunuzu yazın ve test edin
3. Commit yapın: `git commit -m "feat: yeni özellik eklendi"`
4. Branch'i push edin: `git push origin feature/yeni-ozellik`
5. Pull Request oluşturun

### Commit Mesaj Standartları
- `feat`: Yeni özellik
- `fix`: Hata düzeltmesi
- `docs`: Dokümantasyon
- `style`: Kod formatı
- `refactor`: Kod yeniden düzenleme

## 📱 Ekran Görüntüleri

*Ekran görüntüleri buraya eklenecek*

## 🗺️ Yol Haritası

### v0.2.0 - Core Features
- [x] Temel haber modelleri
- [x] Ana ekran tasarımı
- [x] Haber listesi görünümü
- [ ] API entegrasyonu
- [ ] Offline cache sistemi

### v0.3.0 - Enhanced Features
- [ ] Kullanıcı tercihleri
- [ ] Dark mode
- [ ] Bildirimler
- [ ] Sosyal paylaşım

### v1.0.0 - Production Ready
- [ ] App Store optimizasyonu
- [ ] Analytics entegrasyonu
- [ ] Crash reporting
- [ ] Performance optimizasyonu

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Branch'inizi push edin (`git push origin feature/AmazingFeature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 👨‍💻 Geliştirici

**Magnus Magi** - [GitHub](https://github.com/MagnusMagi)

## 🙏 Teşekkürler

- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - Modern UI framework
- [SwiftData](https://developer.apple.com/documentation/swiftdata) - Veri persistance
- [SF Symbols](https://developer.apple.com/sf-symbols/) - Icon set

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!