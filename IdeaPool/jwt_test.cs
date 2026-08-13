using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

class Program
{
    static void Main()
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("trtek-fikir-havuzu-super-secret-key-min32chars!"));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var claims = new List<Claim>
        {
            new Claim("userId", "1"),
            new Claim("permission", "FikirDegerlendirme"),
            new Claim("permission", "KullaniciYetkiEkleme"),
            new Claim("permission", "KullaniciYetkiSilme")
        };
        var token = new JwtSecurityToken(
            issuer: "TRtekIdeaPool",
            audience: "TRtekIdeaPoolClient",
            claims: claims,
            expires: DateTime.UtcNow.AddDays(7),
            signingCredentials: creds);
        var tokenString = new JwtSecurityTokenHandler().WriteToken(token);
        
        var parts = tokenString.Split('.');
        var payload = parts[1];
        payload = payload.PadRight(payload.Length + (4 - payload.Length % 4) % 4, '=');
        var decoded = Encoding.UTF8.GetString(Convert.FromBase64String(payload));
        Console.WriteLine(decoded);
    }
}
