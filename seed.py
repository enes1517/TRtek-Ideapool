import urllib.request
import json
import ssl
import random

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

BASE_URL = 'https://localhost:8443'

def register_user(first, last, email, pwd):
    data = {
        "firstName": first,
        "lastName": last,
        "email": email,
        "password": pwd,
        "phone": str(random.randint(5000000000, 5999999999)),
        "registrationNumber": str(random.randint(10000, 99999)),
        "identityNumber": str(random.randint(10000000000, 99999999999))
    }
    req = urllib.request.Request(f'{BASE_URL}/api/Auth/register', data=json.dumps(data).encode(), headers={'Content-Type': 'application/json'})
    try:
        with urllib.request.urlopen(req, context=ctx) as r:
            print(f"Registered {email}")
    except Exception as e:
        print(f"Failed to register {email}: {e}")

def login_user(email, pwd):
    req = urllib.request.Request(f'{BASE_URL}/api/Auth/login', data=json.dumps({"email":email, "password":pwd}).encode(), headers={'Content-Type': 'application/json'})
    try:
        with urllib.request.urlopen(req, context=ctx) as r:
            resp = json.loads(r.read())
            return resp['token']
    except Exception as e:
        print(f"Failed to login {email}: {e}")
        return None

def create_idea(token, title, cat, ben, desc):
    if not token: return
    data = {
        "title": title,
        "category": cat,
        "benefit": ben,
        "description": desc
    }
    req = urllib.request.Request(f'{BASE_URL}/api/Idea', data=json.dumps(data).encode(), headers={'Content-Type': 'application/json', 'Authorization': f'Bearer {token}'})
    try:
        with urllib.request.urlopen(req, context=ctx) as r:
            print(f"Created Idea: {title}")
    except Exception as e:
        print(f"Failed to create idea {title}: {e}")

# Register new users to avoid collisions
register_user("Ahmet", "Kaya", "ahmet@test.com", "Password123")
register_user("Zeynep", "Çelik", "zeynep@test.com", "Password123")

token_ahmet = login_user("ahmet@test.com", "Password123")
token_zeynep = login_user("zeynep@test.com", "Password123")

create_idea(token_ahmet, "Mobil Uygulamada Karanlık Mod", 1, "Kullanıcıların göz yorgunluğunu azaltır ve batarya tasarrufu sağlar.", "Mevcut uygulamaya tema desteği eklenerek karanlık mod (dark mode) seçeneği sunulmalıdır.")
create_idea(token_ahmet, "Akıllı Otopark Sistemi", 0, "Otopark kapasitesi %20 daha verimli kullanılır, çalışanlar yer bulmakla vakit kaybetmez.", "Plaka tanıma sistemi ve boş yer göstergeleri kullanılarak entegre bir otomasyon kurulması.")
create_idea(token_zeynep, "Kağıtsız İK Süreçleri", 2, "Yılda 50,000 TL kağıt ve baskı tasarrufu.", "İzin, masraf ve onay süreçlerinin tamamen dijital platforma taşınarak elektronik imza entegrasyonu yapılması.")
create_idea(token_zeynep, "Mola Alanlarında Yeni Otomatlar", 3, "Çalışan memnuniyetinde artış.", "Dinlenme alanlarına sağlıklı atıştırmalık otomatlarının eklenmesi.")

print("Veriler başarıyla eklendi!")
