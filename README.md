# TrTek Fikir Havuzu (Idea Pool)

TrTek Fikir Havuzu, şirket içi çalışanların yeni fikirler önerebildiği, mevcut fikirleri oylayabildiği ve çok boyutlu (fizibilite, etki vb.) değerlendirebildiği modern, dinamik ve çapraz platform (cross-platform) bir sistemdir.

## Mimari Yaklaşım ve Tasarım Desenleri (Design Patterns)

Proje, yazılım mühendisliği prensiplerine uygun, sürdürülebilir, ölçeklenebilir ve test edilebilir bir yaklaşımla geliştirilmiştir:

- **N-Tier Architecture (Çok Katmanlı Mimari):** API, Services, Repositories ve Entities katmanlarına ayrılmış, Extension methodlar kullanılmış, sorumlulukların net olarak belirlendiği bir yapı (Separation of Concerns) oluşturulmuştur.
- **Unit of Work Pattern:** Veritabanı işlemlerinin tek bir işlem bütünlüğü (transaction) içinde ele alınmasını sağlayan Unit of Work deseni `RepositoryManager` sınıfı üzerinden uygulanmıştır. Tüm veri değişiklikleri tek bir `SaveAsync()` çağrısı ile toplu halde commit edilir.
- **Repository Pattern:** Veritabanına erişim katmanını soyutlamak için kullanılmıştır (`IRepositoryBase` -> `RepositoryBase`).
- **Dependency Injection (DI):** Servislerin ve yöneticilerin bağımlılıklarının dışarıdan (constructor üzerinden) enjekte edildiği, gevşek bağlı (loosely coupled) yapı.
- **DTO (Data Transfer Object) Pattern:** Veritabanı varlıklarının (Entities) doğrudan dışarıya açılmasını önlemek için AutoMapper kullanılarak DTO dönüşümleri sağlanır.

## Proje Bileşenleri

Proje birbirinden bağımsız ancak tam entegre çalışan iki ana bölümden ve bunları barındıran bir kapsayıcı (Docker) altyapıdan oluşur:

1. **IdeaPool (Backend API):** ASP.NET Core ile yazılmış, tüm iş mantığını, veri yönetimini ve güvenliği sağlayan omurga.
2. **IdeaPoolMobile (Frontend Uygulaması):** Flutter ile tasarlanmış; tek bir kod tabanı üzerinden aynı anda Web tarayıcılarında, Android (APK) ve iOS cihazlarda pürüzsüz çalışabilen modern kullanıcı arayüzü.

## Kullanılan Teknolojiler

**Backend (Sunucu Tarafı):**
- **Platform:** .NET 8 (C#) & ASP.NET Core Web API
- **Veritabanı:** PostgreSQL (Entity Framework Core ile Code-First entegrasyonu)
- **Güvenlik:** JWT (JSON Web Token) kimlik doğrulaması & Role-Based Access Control
- **Mapping:** AutoMapper
- **Dokümantasyon:** Swagger (OpenAPI)

**Frontend (Kullanıcı Arayüzü):**
- **Platform:** Flutter (Dart)
- **State Management:** Riverpod (`flutter_riverpod`)
- **Navigasyon:** GoRouter (Ağaç yapılı, deep-link destekli modern routing)
- **Tasarım:** Material Design 3, Google Fonts (Inter)
- **Paketler:** File Picker (doküman seçimi), SVG desteği, URL Launcher, HTTP Client

**Altyapı (DevOps):**
- Docker & Docker Compose
- Nginx (Web İstemci Sunucusu ve Reverse Proxy)

## Ana Özellikler (Features)

* **Yetkilendirme:** JWT tabanlı güvenli giriş, kayıt olma ve şifre işlemleri.
* **Fikir Havuzu Akışı (Feed):** Platforma eklenen tüm fikirlerin kronolojik veya popülerliğe göre listelendiği, anlık arama (search) yapılabilen ana akış.
* **Kapsamlı Fikir Ekleme:** Başlık, içerik, kategori (Departman), etkilenecek çalışan sayısı, tahmini bütçe gibi detayların yanı sıra ek belge/dosya yükleme (PDF, Görsel vb.) desteği.
* **Etkileşim (Oylama & Yorum):** Herhangi bir fikri Yukarı (Upvote) veya Aşağı (Downvote) oylama, fikirler hakkında yorum yazarak tartışmalara katılma.
* **Yönetici Değerlendirmesi:** Yöneticilerin; fikirleri _Fizibilite, Yenilikçilik, Finansal Etki_ gibi parametrelere göre 10 üzerinden puanladığı "Değerlendirme (Evaluation)" modülü.
* **Kişisel Profil Yönetimi:** Kullanıcının geçmişte paylaştığı fikirleri, favoriye eklediklerini ve hesap güvenlik ayarlarını (Şifre değiştirme) yönettiği alan.
* **Yönetici (Admin) Paneli:** Kullanıcı yetkilerini (Admin / User), aktif/pasif durumlarını ve sistem kategorilerini yapılandırma yeteneği.

## Kurulum ve Çalıştırma (Lokal Ortam)

Projeyi kendi bilgisayarınızda çalıştırmak için ekstra bir bağımlılık kurmanıza (SDK, veritabanı vb.) gerek yoktur. Her şey Docker ile izole olarak saniyeler içinde ayağa kalkar.

### Gereksinimler
- Bilgisayarınızda **Docker Desktop** kurulu ve çalışıyor (Running) durumda olmalıdır.

### Adımlar

1. Terminali (veya komut satırını) açın ve projenin ana klasörüne gidin (`docker-compose.yml` dosyasının bulunduğu yer).
   ```bash
   cd "TrTek Fikir Havuzu"
   ```

2. Tüm servisleri (API, Veritabanı, Web Arayüzü) arka planda inşa edip başlatmak için aşağıdaki komutu çalıştırın:
   ```bash
   docker-compose up -d --build
   ```

3. Kurulum tamamlandığında aşağıdaki adreslerden sisteme erişebilirsiniz:
   - **Web Uygulaması (Frontend):** [https://localhost:8443](https://localhost:8443) (Sertifika uyarısı verirse "Gelişmiş ayarlar" kısmından güvenli kabul edip devam edebilirsiniz)
   - **Web Uygulaması Alternatif:** [http://localhost:8080](http://localhost:8080)
   - **Backend API Swagger Paneli:** [http://localhost:5139/swagger](http://localhost:5139/swagger)

> **Servisleri Durdurmak İçin:** Arka planda çalışan sistemi tamamen kapatmak isterseniz yine aynı dizinde `docker-compose down` komutunu çalıştırmanız yeterlidir.

## Android APK Olarak Derleme

Platform aynı zamanda tam bir mobil uygulama olarak çalışır. Android cihazlar için kurulum dosyası (.apk) üretmek isterseniz:

1. Sisteminizde [Flutter SDK](https://docs.flutter.dev/get-started/install) kurulu olmalıdır.
2. Terminal ile `IdeaPoolMobile` klasörüne girin:
   ```bash
   cd IdeaPoolMobile
   ```
3. Uygulamanın en gerekli ve güncel paketlerini çekin:
   ```bash
   flutter pub get
   ```
4. Release (üretim) modunda derlemeyi başlatın:
   ```bash
   flutter build apk --release
   ```
5. İşlem bittikten sonra APK dosyasını `IdeaPoolMobile/build/app/outputs/flutter-apk/app-release.apk` dizininde bulabilirsiniz. Bu dosyayı telefonunuza gönderip direkt kurabilirsiniz.

## Geliştirici Yönergeleri

- **Frontend (Flutter):** Projenin Flutter kısmı **Feature-Based (Özellik Odaklı)** yapıdadır. Yeni bir modül eklerken `lib/features` altına o modüle özel (örn. `auth`, `idea`, `profile`) bir klasör açıp kendi `views`, `providers`, `widgets` klasörlerini oluşturun.
- **Ortak Bileşenler:** Uygulama genelinde kullanılacak bağımsız bileşenler (butonlar, text inputlar, renk paleti vb.) `lib/core` klasöründedir.
- **Backend (API):** Veritabanı ile ilgili işlemleri `Repositories` katmanında `RepositoryBase`'den türeterek oluşturun. Verileri API'ye sunmadan önce mutlaka `Services` katmanında iş mantığından geçirin ve AutoMapper ile DTO'lara dönüştürün. Controller'lar doğrudan Repository'leri çağırmamalıdır.
