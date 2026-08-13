[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$baseUrl = "https://localhost:8443"

function Register-User ($FirstName, $LastName, $Email, $Password) {
    $body = @{
        firstName = $FirstName
        lastName = $LastName
        email = $Email
        password = $Password
        phone = "555" + (Get-Random -Minimum 1000000 -Maximum 9999999)
        registrationNumber = (Get-Random -Minimum 10000 -Maximum 99999).ToString()
        identityNumber = (Get-Random -Minimum 10000000000 -Maximum 99999999999).ToString()
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri "$baseUrl/api/Auth/register" -Method Post -Body $body -ContentType "application/json" | Out-Null
        Write-Host "Registered: $Email"
    } catch {
        Write-Host "Failed to register $Email (might already exist). Error: $_"
    }
}

function Login-User ($Email, $Password) {
    $body = @{
        email = $Email
        password = $Password
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/Auth/login" -Method Post -Body $body -ContentType "application/json"
        return $response.token
    } catch {
        Write-Host "Failed to login $Email. Error: $_"
    }
}

function Create-Idea ($Token, $Title, $Category, $Benefit, $Description) {
    if (-not $Token) { return }
    $body = @{
        title = $Title
        category = $Category
        benefit = $Benefit
        description = $Description
    } | ConvertTo-Json

    $headers = @{
        Authorization = "Bearer $Token"
    }

    try {
        Invoke-RestMethod -Uri "$baseUrl/api/Idea" -Method Post -Headers $headers -Body $body -ContentType "application/json" | Out-Null
        Write-Host "Created Idea: $Title"
    } catch {
        Write-Host "Failed to create idea $Title. Error: $_"
        if ($_.ErrorDetails) {
            Write-Host $_.ErrorDetails.Message
        } elseif ($_.Exception.Response) {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $errBody = $reader.ReadToEnd()
            Write-Host "Error Body: $errBody"
        }
    }
}

# 1. Register Users
Register-User -FirstName "Ali" -LastName "Yilmaz" -Email "ali@test.com" -Password "Password123"
Register-User -FirstName "Ayse" -LastName "Demir" -Email "ayse@test.com" -Password "Password123"

# 2. Login
$tokenAli = Login-User -Email "ali@test.com" -Password "Password123"
$tokenAyse = Login-User -Email "ayse@test.com" -Password "Password123"

# 3. Create Ideas
# IdeaCategory Enum (assuming 0,1,2, etc. Let's send integers based on backend mapping, or just strings if it accepts it. Let's send 0 = Product, 1 = Process...)
Create-Idea -Token $tokenAli -Title "Mobil Uygulamada Karanlık Mod" -Category 1 -Benefit "Kullanıcıların göz yorgunluğunu azaltır ve batarya tasarrufu sağlar." -Description "Mevcut uygulamaya tema desteği eklenerek karanlık mod (dark mode) seçeneği sunulmalıdır."

Create-Idea -Token $tokenAli -Title "Akıllı Otopark Sistemi" -Category 0 -Benefit "Otopark kapasitesi %20 daha verimli kullanılır, çalışanlar yer bulmakla vakit kaybetmez." -Description "Plaka tanıma sistemi ve boş yer göstergeleri kullanılarak entegre bir otomasyon kurulması."

Create-Idea -Token $tokenAyse -Title "Kağıtsız İK Süreçleri" -Category 2 -Benefit "Yılda 50,000 TL kağıt ve baskı tasarrufu." -Description "İzin, masraf ve onay süreçlerinin tamamen dijital platforma taşınarak elektronik imza entegrasyonu yapılması."

Write-Host "Veriler başarıyla eklendi!"
