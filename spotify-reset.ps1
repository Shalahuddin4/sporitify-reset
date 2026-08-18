function spotify-reset {

    Clear-Host

    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "           SPOTIFY RESET TOOL" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # ========================================
    # 1. CHECK WINGET
    # ========================================

    Write-Host "[1/7] Checking winget..." -ForegroundColor Yellow

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "[ERROR] winget tidak ditemukan." -ForegroundColor Red
        return
    }

    Write-Host "[OK] winget tersedia." -ForegroundColor Green


    # ========================================
    # 2. UNINSTALL SPOTIFY
    # ========================================

    Write-Host ""
    Write-Host "[2/7] Uninstalling Spotify..." -ForegroundColor Yellow

    winget uninstall --id Spotify.Spotify `
        --silent `
        --accept-source-agreements `
        --disable-interactivity

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Spotify berhasil di-uninstall." -ForegroundColor Green
    }
    else {
        Write-Host "[INFO] Spotify tidak ditemukan. Melanjutkan..." -ForegroundColor DarkYellow
    }

    Start-Sleep -Seconds 3


    # ========================================
    # 3. INSTALL SPOTIFY
    # ========================================

    Write-Host ""
    Write-Host "[3/7] Installing Spotify..." -ForegroundColor Yellow

    winget install --id Spotify.Spotify `
        --force `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements `
        --disable-interactivity

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Spotify gagal di-install." -ForegroundColor Red
        Write-Host "Exit code: $LASTEXITCODE" -ForegroundColor DarkRed
        return
    }

    Write-Host "[OK] Spotify berhasil di-install." -ForegroundColor Green


    # ========================================
    # FIND SPOTIFY.EXE
    # ========================================

    Write-Host ""
    Write-Host "Finding Spotify executable..." -ForegroundColor DarkCyan

    $spotifyPaths = @(
        "$env:APPDATA\Spotify\Spotify.exe",
        "$env:LOCALAPPDATA\Spotify\Spotify.exe",
        "$env:ProgramFiles\Spotify\Spotify.exe",
        "${env:ProgramFiles(x86)}\Spotify\Spotify.exe"
    )

    $spotifyExe = $spotifyPaths |
        Where-Object { Test-Path $_ } |
        Select-Object -First 1

    if (-not $spotifyExe) {
        Write-Host "[ERROR] Spotify.exe tidak ditemukan." -ForegroundColor Red
        return
    }

    Write-Host "[OK] Spotify ditemukan:" -ForegroundColor Green
    Write-Host $spotifyExe


    # ========================================
    # 4. OPEN SPOTIFY FOR 60 SECONDS
    # ========================================

   
Write-Host ""
Write-Host "[4/7] Opening Spotify..." -ForegroundColor Yellow

try {

    Start-Process -FilePath $spotifyExe

    Write-Host ""
    Write-Host "Spotify sedang dijalankan." -ForegroundColor Cyan
    Write-Host "Silakan login jika diperlukan." -ForegroundColor Cyan
    Write-Host ""

    for ($i = 60; $i -ge 1; $i--) {

       Write-Host "`rSpotify will close in: $i seconds   " -NoNewline -ForegroundColor Yellow

        Start-Sleep -Seconds 1
    }

    Write-Host ""
    Write-Host ""
    Write-Host "[OK] 60 detik selesai." -ForegroundColor Green

}
catch {

    Write-Host "[ERROR] Gagal menjalankan Spotify." -ForegroundColor Red
    Write-Host $_ -ForegroundColor Red
    return
}


    # ========================================
    # CLOSE SPOTIFY
    # ========================================

    Write-Host ""
    Write-Host "Closing Spotify..." -ForegroundColor Yellow

    Get-Process -Name "Spotify" -ErrorAction SilentlyContinue |
        Stop-Process -Force

    Start-Sleep -Seconds 3

    Write-Host "[OK] Spotify ditutup." -ForegroundColor Green


    # ========================================
    # CHECK PREFS
    # ========================================

    Write-Host ""
    Write-Host "[5/7] Checking Spotify configuration..." -ForegroundColor Yellow

    $prefsPath = "$env:APPDATA\Spotify\prefs"

    if (-not (Test-Path $prefsPath)) {

        Write-Host "[ERROR] Spotify prefs tidak ditemukan." -ForegroundColor Red
        Write-Host ""
        Write-Host "Path yang dicek:" -ForegroundColor DarkYellow
        Write-Host $prefsPath
        Write-Host ""
        Write-Host "Spotify mungkin belum selesai initialization." -ForegroundColor DarkYellow
        Write-Host "Process dihentikan untuk mencegah error Spicetify." -ForegroundColor DarkYellow

        return
    }

    Write-Host "[OK] Spotify prefs ditemukan." -ForegroundColor Green


    # ========================================
    # 6. INSTALL SPICETIFY CLI
    # ========================================

    Write-Host ""
    Write-Host "[6/7] Installing Spicetify CLI..." -ForegroundColor Yellow

    try {

        $spicetifyScript = Invoke-RestMethod `
            -Uri "https://raw.githubusercontent.com/spicetify/cli/main/install.ps1"

        if ([string]::IsNullOrWhiteSpace($spicetifyScript)) {
            throw "Script Spicetify kosong atau gagal di-download."
        }

        Invoke-Expression $spicetifyScript

    }
    catch {

        Write-Host "[ERROR] Instalasi Spicetify gagal." -ForegroundColor Red
        Write-Host $_ -ForegroundColor Red
        return
    }


    # ========================================
    # REFRESH PATH
    # ========================================

    $env:Path = `
        [System.Environment]::GetEnvironmentVariable("Path", "User") `
        + ";" `
        + [System.Environment]::GetEnvironmentVariable("Path", "Machine")


    if (-not (Get-Command spicetify -ErrorAction SilentlyContinue)) {

        Write-Host ""
        Write-Host "[ERROR] Spicetify tidak ditemukan setelah instalasi." -ForegroundColor Red
        return
    }

    Write-Host "[OK] Spicetify CLI berhasil di-install." -ForegroundColor Green


    # ========================================
    # 7. COMPLETE
    # ========================================

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "          PROCESS COMPLETE" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Spotify reset       : SUCCESS" -ForegroundColor Green
    Write-Host "Spotify prefs       : FOUND" -ForegroundColor Green
    Write-Host "Spicetify CLI       : INSTALLED" -ForegroundColor Green

    Write-Host ""
}
