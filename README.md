# MesajCell

Kurumsal mesajlaşma uygulaması. Flutter ile geliştirilmiş, gerçek zamanlı kanal/DM mesajlaşması, bildirimler, profil yönetimi ve organizasyon üyesi yönetimi içerir.

---

## İçindekiler

- [Gereksinimler](#gereksinimler)
- [Kurulum](#kurulum)
- [Ortam Değişkenleri](#ortam-değişkenleri)
- [Proje Yapısı](#proje-yapısı)
- [Mimari](#mimari)
- [Özellikler](#özellikler)
- [API Referansı](#api-referansı)
- [Socket Eventleri](#socket-eventleri)
- [Kullanılan Paketler](#kullanılan-paketler)

---

## Gereksinimler

| Araç | Sürüm |
|---|---|
| Flutter | 3.x (stable) |
| Dart | ^3.11.5 |
| Android SDK | API 21+ |
| Xcode | 14+ (iOS) |

---

## Kurulum

```bash
# 1. Repoyu klonlayın
git clone https://github.com/alikemalcimsit/coder-nights.git
cd coder-nights

# 2. Bağımlılıkları yükleyin
flutter pub get

# 3. .env dosyasını oluşturun (bkz. Ortam Değişkenleri)

# 4. Uygulamayı çalıştırın
flutter run

# APK derlemek için
flutter build apk --release
```

---

## Ortam Değişkenleri

Projenin kök dizininde `.env` dosyası oluşturun:

```env
BASE_URL=https://coder-nights.onrender.com
```

> `.env` dosyası `pubspec.yaml`'daki `flutter.assets` listesine eklidir, başka bir işlem gerekmez.

---

## Proje Yapısı

```
lib/
├── main.dart                        # Uygulama giriş noktası
├── router/
│   └── app_router.dart              # GoRouter yönlendirme
├── features/
│   ├── core/
│   │   ├── app_dio.dart             # Dio interceptor (Bearer token)
│   │   ├── app_logger.dart          # Logger wrapper
│   │   ├── app_session.dart         # Token + kullanıcı oturumu (singleton)
│   │   ├── base_dio_service.dart    # Hata işleme
│   │   └── socket_service.dart      # Socket.io singleton
│   └── utility/
│       ├── const/                   # Renkler, string'ler
│       ├── notifier/                # ThemeNotifier
│       └── theme/                   # AppTheme (light/dark)
└── product/
    ├── auth/                        # Giriş, OTP doğrulama
    ├── register/                    # Admin & üye kayıt
    ├── welcome/                     # Karşılama ekranı
    ├── home/                        # Sohbet listesi (kanallar + DM)
    ├── channel/                     # Kanal/DM görünümü, mesajlar
    ├── notification/                # Bildirim paneli
    ├── people/                      # Organizasyon üye listesi + DM başlat
    ├── settings/                    # Profil & uygulama ayarları
    └── shell/                       # Bottom nav bar + sayfa yönetimi
```

---

## Mimari

Uygulama **Feature-first** klasör yapısıyla **BLoC/Cubit** pattern üzerine inşa edilmiştir.

```
feature/
  model/      ← veri modelleri (fromJson / toJson)
  service/    ← HTTP istekleri (Dio)
  cubit/      ← iş mantığı + state
  view/       ← UI (StatelessWidget / StatefulWidget)
```

### Temel Servisler

| Sınıf | Görevi |
|---|---|
| `AppSession` | Access token, refresh token, userId, fullName, orgId, role'ü bellekte ve SharedPreferences'ta tutar |
| `AppDio.create()` | Her istekte `Authorization: Bearer <token>` ekler |
| `SocketService.instance` | Socket.io singleton; `message:new/edit/delete`, `user:typing`, `user:status` eventlerini broadcast stream'lerle yayar |

---

## Özellikler

### Kimlik Doğrulama

- **GSM ile giriş** → OTP doğrulama (6 haneli kod)
- **Admin kayıt** — yeni şirket kurulumu
- **Üye kayıt** — davet linki ile katılım (`/register?invite_token=&org_name=`)
- JWT çözümleme: `sub` alanı int veya string olarak gelebilir, her ikisi de desteklenir
- `AppSession.fullName` OTP doğrulaması sırasında kaydedilir

### Ana Ekran — Sohbetler

- Kanal ve DM listesi
- Arama (isim/açıklama)
- Okunmamış mesaj sayacı (kanal başına badge)
- Kanala uzun basınca **Bildirim Tercihi** seçimi (Tümü / Sadece Bahsetmeler / Sessiz)
- 🔔 Bildirim ikonu — okunmamış varsa kırmızı nokta

### Kanal / Sohbet Ekranı

#### Mesajlar
- Gerçek zamanlı mesaj listesi (Socket `message:new`)
- Sonsuz scroll ile geçmiş yükleme (`loadMore`)
- Mesaj baloncukları: sağ (ben) / sol (diğeri)
- Dosya/görsel eki gönderme (image_picker / file_picker)

#### Mesaj İşlemleri (uzun basınca menü)

| Eylem | Kısıtlama |
|---|---|
| Yanıtla | Tüm mesajlar |
| Düzenle | Sadece kendi mesajları |
| Sil | Kendi mesajları + kanal admini |
| Reaksiyon Ekle | Silinmemiş mesajlar |
| Sabitle | Silinmemiş tüm mesajlar (sunucu yetki kontrolü yapar) |

#### Mesaj Arama

- AppBar'daki 🔍 ikonuna basılınca arama moduna geçilir
- Eşleşen mesajlar filtrelenerek listelenir
- Eşleşen metin **sarı arka planla** vurgulanır
- `←` ile normal moda dönülür

#### @Mention Otomatik Tamamlama

- `@` yazılınca kanal üyeleri listesi önerisi açılır
- Seçilen kişi `@AdSoyad ` olarak mesaj kutusuna eklenir

#### Sabitlenmiş Mesajlar

- AppBar'daki 📌 ikonuyla sağ panel açılır
- Panel: mesaj içeriği, gönderen, sabitleyen kişi ve saat gösterilir
- Mesaja tıklayınca panel kapanır ve ilgili mesaja scroll edilir
- Sabitleme sonucu snackBar ile bildirilir

#### Yazıyor Göstergesi

- Socket `user:typing` eventi ile animasyonlu `...` gösterimi

### Bildirimler

- `message:new` socket eventi sürekli dinlenir
- Bahsetme (`@fullName`) veya sunucudan gelen `mentions[]` array'inde userId varsa:
  - Bildirim paneline **yerel kayıt** eklenir (API çağrısı gerekmez)
  - AppBar'da kırmızı nokta badge güncellenir
  - SnackBar ile `"Ali seni etiketledi"` gösterilir
- Kendi gönderdiğin mesajlar sayılmaz (`sender_id == myId` kontrolü)
- Panel açılınca `GET /api/v1/users/notifications` çağrılır
- Tüm bildirimler `PATCH /api/v1/users/notifications/read` ile okundu işaretlenir

### Kişiler Tab

- Bottom bar 3. tab → organizasyondaki tüm üyeler
- İsme göre arama
- Çevrimiçi (yeşil) / Çevrimdışı (gri) badge
- Kişiye tıklayınca DM kanalı oluşturulur (`POST /api/v1/channels/dm`) ve sohbet ekranı açılır

### Profil Güncelleme ("Siz" Ekranı)

- Profil kartı: gerçek isim, e-posta, durum badge (renk kodlu)
- Profil fotoğrafı URL varsa `NetworkImage` ile gösterilir, yoksa baş harfler
- ✏️ butonu → **"Profil Düzenle"** bottom sheet:
  - Ad Soyad (zorunlu)
  - E-posta (zorunlu, `@` kontrolü)
  - Profil Fotoğrafı URL (isteğe bağlı)
  - Durum seçici: Çevrimiçi / Uzakta / Meşgul / Çevrimdışı
- `PATCH /api/v1/users/me` ile kaydedilir
- Başarılıda `AppSession.fullName` güncellenir (mention tespiti için)
- Karanlık mod / otomatik tema toggle

---

## API Referansı

**Base URL:** `https://coder-nights.onrender.com`

Tüm istekler `Authorization: Bearer <access_token>` header'ı gerektirir.

### Kimlik Doğrulama

| Method | Endpoint | Açıklama |
|---|---|---|
| POST | `/api/v1/auth/send-otp` | GSM'e OTP gönder |
| POST | `/api/v1/auth/verify-otp` | OTP doğrula, token al |
| POST | `/api/v1/auth/logout` | Oturumu kapat |
| POST | `/api/v1/auth/register-admin` | Admin & şirket kaydı |

### Kullanıcı

| Method | Endpoint | Açıklama |
|---|---|---|
| GET | `/api/v1/users/me` | Profil bilgileri |
| PATCH | `/api/v1/users/me` | Profil güncelle |
| GET | `/api/v1/users/notifications` | Bildirim listesi |
| PATCH | `/api/v1/users/notifications/read` | Tümünü okundu işaretle |

**PATCH `/api/v1/users/me` istek gövdesi:**
```json
{
  "full_name": "Ali Kemal Cimsit",
  "email": "ali@sirket.com",
  "profile_photo_url": "https://example.com/avatar.jpg",
  "presence_status": "ONLINE"
}
```

**GET `/api/v1/users/me` yanıt örneği:**
```json
{
  "success": true,
  "data": {
    "id": "uuid-user-id",
    "full_name": "Ali Kemal",
    "gsm_number": "+905551234567",
    "email": "ali@sirket.com",
    "role": "ORG_ADMIN",
    "org_id": "uuid-org-id",
    "presence_status": "ONLINE",
    "profile_photo_url": null,
    "created_at": "2026-05-14T10:00:00.000Z"
  }
}
```

### Organizasyon

| Method | Endpoint | Açıklama |
|---|---|---|
| GET | `/api/v1/org` | Organizasyon bilgisi |
| GET | `/api/v1/org/users` | Tüm üyeler |

### Kanallar

| Method | Endpoint | Açıklama |
|---|---|---|
| GET | `/api/v1/channels` | Kanal listesi |
| POST | `/api/v1/channels` | Yeni kanal oluştur |
| GET | `/api/v1/channels/public` | Herkese açık kanallar |
| POST | `/api/v1/channels/dm` | DM kanalı oluştur/getir |
| GET | `/api/v1/channels/:id/members` | Kanal üyeleri |
| POST | `/api/v1/channels/:id/members` | Üye ekle |
| DELETE | `/api/v1/channels/:id/members/:userId` | Üye çıkar |

### Mesajlar

| Method | Endpoint | Açıklama |
|---|---|---|
| GET | `/api/v1/channels/:id/messages` | Mesaj listesi (sayfalama) |
| POST | `/api/v1/channels/:id/messages` | Mesaj gönder (REST fallback) |
| PUT | `/api/v1/channels/:id/messages/:msgId` | Mesaj düzenle (REST fallback) |
| DELETE | `/api/v1/channels/:id/messages/:msgId` | Mesaj sil (REST fallback) |
| POST | `/api/v1/channels/:id/pin/:msgId` | Mesaj sabitle |
| GET | `/api/v1/channels/:id/pinned` | Sabitlenmiş mesajlar |

---

## Socket Eventleri

### Dinlenen (Sunucudan Gelen)

| Event | Payload Alanları |
|---|---|
| `message:new` | `channel_id`, `content`, `sender_id`, `sender_name`, `mentions[]`, `reply_to_message_id` |
| `message:edit` | `id`, `channel_id`, `content` |
| `message:delete` | `id`, `channel_id` |
| `user:typing` | `channel_id`, `user_id`, `full_name`, `is_typing` |
| `user:status` | `user_id`, `presence_status` |

### Yayımlanan (İstemciden Gönderilen)

| Event | Payload Alanları |
|---|---|
| `message:send` | `channel_id`, `content`, `message_type`, `reply_to_message_id?` |
| `message:edit` | `id`, `channel_id`, `content` |
| `message:delete` | `id`, `channel_id` |
| `channel:join` | `channel_id` |
| `channel:leave` | `channel_id` |
| `user:typing` | `channel_id`, `is_typing` |
| `user:status` | `presence_status` |
| `message:read` | `channel_id`, `message_id` |

---

## Kullanılan Paketler

| Paket | Sürüm | Kullanım |
|---|---|---|
| `flutter_bloc` | ^9.1.1 | State management (Cubit pattern) |
| `dio` | ^5.8.0+1 | HTTP istekleri |
| `socket_io_client` | ^2.0.3 | Gerçek zamanlı mesajlaşma |
| `go_router` | ^14.6.1 | Sayfa yönlendirme |
| `shared_preferences` | ^2.3.2 | Token kalıcılığı |
| `provider` | ^6.1.2 | Tema yönetimi |
| `easy_localization` | ^3.0.7 | Dil desteği |
| `google_fonts` | ^6.2.1 | Tipografi |
| `flutter_dotenv` | ^5.2.1 | Ortam değişkenleri |
| `image_picker` | ^1.1.2 | Galeri/kamera erişimi |
| `file_picker` | ^8.1.2 | Dosya seçimi |
| `url_launcher` | ^6.3.0 | Harici link açma |
| `logger` | ^2.5.0 | Konsol loglama |
| `pretty_dio_logger` | ^1.4.0 | HTTP istek/yanıt loglama |

