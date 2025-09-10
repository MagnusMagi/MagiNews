# Product Requirements Document (PRD)

## 1. Ürün Özeti

### Ürün Adı
MagiNews AI

### Amaç
MagiNews AI, kullanıcıların dünya çapında en önemli haberleri kaliteli ve hızlı bir şekilde takip etmelerini sağlayan, yapay zeka destekli bir haber uygulamasıdır. Reuters gibi güvenilir bir haber kaynağı platformu olarak konumlanırken, AI yetenekleriyle farklılaşır. Kullanıcılar, haber akışlarını kişiselleştirebilir, özetler oluşturabilir ve içerikleri daha anlamlı bir şekilde tüketebilir.

### Hedef Kitle
- 18-45 yaş arası, teknolojiye meraklı bireyler.
- Günlük haber takibini önemseyen, zaman yönetimine önem veren kişiler.
- Türkiye ve global haber okuyucuları.

### Gelir Modeli
- Aylık abonelik: 2 USD/ay.

---

## 2. Özellikler

### a. Çekirdek Özellikler
1. **Haber Akışı**
   - Zengin metin ve görsellerle desteklenmiş haber akışı.
   - Kategorilere ayrılmış haberler: Dünya, Türkiye, Ekonomi, Teknoloji, Spor vb.
   - **Haber Sağlayıcı:** NewsAPI (API Key: `27e71136ac154aa9b81fbd8d4e2af3de`).

2. **AI Destekli Haber Özeti**
   - Haberlerin kısa özetlerini oluşturur.
   - "Okuma Süresi" etiketi ile kullanıcıya zaman kazandırır.
   - Özetleme dili: Türkçe ve İngilizce.

3. **Kişiselleştirme**
   - Kullanıcı ilgi alanlarına göre haber önerileri.
   - Haber kaynaklarını filtreleme yeteneği.

4. **Gelişmiş Arama**
   - Anahtar kelimeye göre haber bulma.
   - Tarihe, kategoriye veya kaynaklara göre filtreleme.

5. **Bildirimler**
   - "Son Dakika" bildirimleri.
   - Kullanıcı tercihine göre kategori tabanlı bildirimler.

6. **Haber Okuma Modları**
   - Gece modu.
   - Okuma modu (yalın metin ve optimize edilmiş görünüm).

### b. AI İle Farklılaşma Özellikleri
1. **AI Asistan**
   - Kullanıcı sorularına haberlerle alakalı yanıt verir (ör. "Bugün Türkiye'deki hava durumu nasıl?").
   - **Gemini Generative AI API** ile entegre (API Key: `AIzaSyC_jEpMuYiO7pIxSAE-CU4d8e51GeZ2E3k`).

2. **Sesli Haberler**
   - AI, haberleri seslendirerek kullanıcıya sunar.
   - Sesli özetler ve tam metin okuma.

3. **Duygu Analizi**
   - Haberlerin tonunu (pozitif/negatif) analiz ederek kullanıcının ruh haline uygun içerik önerir.
   - **Service Account**: `maginewsapi@gen-lang-client-0742332648.iam.gserviceaccount.com`.

4. **Metin ve Görsel Entegrasyonu**
   - Haberle ilişkili görselleri ve videoları analiz ederek kullanıcıya özet sunar.

---

## 3. Teknik Gereksinimler

### a. Platform
- **iOS**: iPhone ve iPad desteği (iOS 15 ve üzeri).

### b. Teknolojiler
- **Frontend**: Swift, UIKit/SwiftUI.
- **Backend**: Python/Django veya Node.js.
- **Veritabanı**: PostgreSQL veya MongoDB.
- **AI Modülleri**: OpenAI veya Gemini Generative AI API (özetleme ve NLP).

### c. Entegrasyonlar
- Haber API'leri: NewsAPI.
- AI API'leri: Gemini Generative AI.
- Ödeme Sistemi: Apple Pay, Stripe.
- Bildirim Hizmeti: Firebase Cloud Messaging (FCM).

### d. Güvenlik
- Kullanıcı verilerinin şifrelenmesi.
- GDPR ve KVKK uyumluluğu.

---

## 4. Kullanıcı Deneyimi (UX)

### a. Kullanıcı Akışı
1. Kullanıcı kayıt olur veya giriş yapar.
2. İlgi alanlarını seçer (ör. spor, ekonomi).
3. Ana haber akışını keşfeder.
4. Haberlerin özetlerini okur veya tam metinle devam eder.
5. AI asistanı ile etkileşim kurar.
6. Ayarlar sekmesinden mod ve bildirim tercihlerini özelleştirir.

### b. Tasarım Prensipleri
- Minimalist, temiz bir arayüz.
- Görsel olarak zengin, okunabilir haber kartları.
- Tek elle kullanım kolaylığı.

---

## 5. Rekabet Analizi

### Rakipler
- **Reuters**
  - Avantaj: Güvenilir haber kaynağı.
  - Dezavantaj: Yapay zeka desteği sınırlı.

- **Flipboard**
  - Avantaj: İlgi alanlarına göre kişiselleştirme.
  - Dezavantaj: Özetleme ve AI desteği zayıf.

- **Bundle (Yerel Rakip)**
  - Avantaj: Türk kullanıcı kitlesine odaklanma.
  - Dezavantaj: Farklılaştırıcı AI özelliklerinin eksikliği.

---

## 6. Gelir Modeli

- **Aylık Abonelik**: 2 USD.
  - İlk ay ücretsiz deneme.
  - Öğrenci indirimi (%50).

- **Ekstra Gelir Kaynakları**
  - Premium AI hizmetleri (daha ayrıntılı özetler veya kişisel analizler).
  - Reklamsız deneyim (premium abonelik).

---

## 7. Roadmap

### Faz 1: Çekirdek Özellikler (3 Ay)
- Haber akışı.
- AI destekli özetleme.
- Kişiselleştirme.

### Faz 2: AI İnovasyonları (6 Ay)
- AI asistan.
- Sesli haberler.

### Faz 3: Global Lansman (9 Ay)
- Çoklu dil desteği.
- Genişletilmiş haber kaynakları.

---

## 8. Başarı Kriterleri (KPIs)
- Uygulama indirilme sayısı: 100.000 (ilk yıl).
- Aylık aktif kullanıcı (MAU): %30 artış (her çeyrek).
- Abonelik dönüşüm oranı: %10.
- Kullanıcı memnuniyeti: 4.5/5 (App Store değerlendirmesi).