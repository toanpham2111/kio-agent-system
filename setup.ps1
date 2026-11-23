# ==============================================================================
# Kio: Open Source AI Skills Installer & Manager for Windows PowerShell
# ------------------------------------------------------------------------------
# Principles:
# 1. Install Skills: Install all 7 skills or specific selected skills.
# 2. Preserve Existing Skills: Never delete or overwrite user's own skills.
# 3. Update Skills: Only refresh junctions that strictly verify to Kio repo.
# 4. Uninstall Kio: Safely remove ONLY components verified to belong to Kio.
# 5. Ownership Manifest: Track all Kio-created junctions in ~/.kio/manifest.json.
# ==============================================================================

param (
    [string]$Skill = "",
    [switch]$List = $false,
    [switch]$Uninstall = $false,
    [switch]$Update = $false,
    [switch]$Help = $false
)

$AllKioSkills = @(
    "kio-core-delivery",
    "kio-frontend-craft",
    "kio-backend-cloud",
    "kio-qa-security",
    "kio-growth-marketing",
    "kio-wordpress-fse",
    "kio-cognitive"
)

function Show-Help {
    Write-Host "Kio Skills Installer & Manager (Windows PowerShell)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\setup.ps1                         Install / update all 7 skills safely"
    Write-Host "  .\setup.ps1 -Skill <name>           Install specific skill(s) (comma-separated)"
    Write-Host "  .\setup.ps1 -List                   List all available skills & shortcuts"
    Write-Host "  .\setup.ps1 -Uninstall              Safely remove Kio skills (preserves user skills)"
    Write-Host "  .\setup.ps1 -Help                   Show this help"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\setup.ps1 -Skill frontend"
    Write-Host "  .\setup.ps1 -Skill frontend,qa,backend"
    Write-Host "  .\setup.ps1 -Uninstall"
}

if ($Help) {
    Show-Help
    exit 0
}

function Show-List {
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "Kio: Available Engineering Skills (7 Master Skills)" -ForegroundColor Cyan
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "1. kio-frontend-craft   (shortcut: frontend, fe)  - UI/UX, 79 styles, 192 palettes, Lenis"
    Write-Host "2. kio-backend-cloud    (shortcut: backend, be)   - REST/GraphQL APIs, RLS, Docker, Cloud"
    Write-Host "3. kio-qa-security      (shortcut: qa, test)      - Test matrix, Unit tests (Vitest/Pytest), Playwright"
    Write-Host "4. kio-core-delivery    (shortcut: core)          - Atomic tasks (2-5m), SDD spec-kit templates"
    Write-Host "5. kio-growth-marketing (shortcut: growth, seo)   - 53 CRO frameworks, technical SEO modules"
    Write-Host "6. kio-wordpress-fse    (shortcut: wp, fse)       - S0-S8 clean Gutenberg block themes pipeline"
    Write-Host "7. kio-cognitive        (shortcut: cognitive)     - First-principles, architecture rationale"
    Write-Host "=================================================================" -ForegroundColor Cyan
}

if ($List) {
    Show-List
    exit 0
}

$HomeDir = [System.Environment]::GetFolderPath('UserProfile')
$KioConfigDir = Join-Path $HomeDir ".kio"
$KioRepoDir = Join-Path $KioConfigDir "repo"
$KioRepoUrl = if ($env:KIO_REPO_URL) { $env:KIO_REPO_URL } else { "https://github.com/toanpham2111/kio-agent-system.git" }
$ManifestFile = Join-Path $KioConfigDir "manifest.json"

$ScriptPath = $PSCommandPath
if (-not $ScriptPath -and $MyInvocation.MyCommand.Path) {
    $ScriptPath = $MyInvocation.MyCommand.Path
}

$UsingManagedRepo = $false
if ($ScriptPath -and (Test-Path $ScriptPath)) {
    $CandidateDir = Split-Path -Parent $ScriptPath
    $CandidateSkills = Join-Path $CandidateDir "skills"
    if (Test-Path (Join-Path $CandidateSkills "kio-frontend-craft")) {
        $ScriptDir = $CandidateDir
        $SkillsSrcDir = [System.IO.Path]::GetFullPath($CandidateSkills)
    } else {
        $UsingManagedRepo = $true
        $ScriptDir = $KioRepoDir
        $SkillsSrcDir = [System.IO.Path]::GetFullPath((Join-Path $KioRepoDir "skills"))
    }
} else {
    $UsingManagedRepo = $true
    $ScriptDir = $KioRepoDir
    $SkillsSrcDir = [System.IO.Path]::GetFullPath((Join-Path $KioRepoDir "skills"))
}

$script:KioUpdateFailed = $false

# Version for piped installs: $env:KIO_REF (tag like v1.2.0, or a branch like main) wins;
# otherwise the newest released v* tag, so a piped install never picks up unreleased work.
function Resolve-KioRef {
    if ($env:KIO_REF) { return $env:KIO_REF }
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $Lines = git ls-remote --tags --refs --sort=-v:refname $KioRepoUrl 'v*' 2>$null
        if ($LASTEXITCODE -eq 0 -and $Lines) {
            $First = @($Lines)[0]
            return ($First -replace '^.*refs/tags/', '').Trim()
        }
    }
    Write-Host "[WARN] Could not list Kio release tags from $KioRepoUrl; falling back to 'main'." -ForegroundColor Yellow
    return "main"
}

function Ensure-KioRepoSource {
    if (-not $UsingManagedRepo -and (Test-Path (Join-Path $SkillsSrcDir "kio-frontend-craft"))) {
        return
    }
    if (-not (Test-Path $KioConfigDir)) {
        New-Item -ItemType Directory -Path $KioConfigDir -Force | Out-Null
    }
    $Ref = Resolve-KioRef
    $ManagedGitDir = Join-Path $KioRepoDir ".git"
    $ManagedCheck = Join-Path $KioRepoDir "skills\kio-frontend-craft"
    if ((Test-Path $ManagedGitDir) -and (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "[UPDATE] Updating managed Kio repository in $KioRepoDir to '$Ref'..." -ForegroundColor Cyan
        $Log = git -C $KioRepoDir fetch --depth 1 --force origin $Ref 2>&1 | Out-String
        $Ok = ($LASTEXITCODE -eq 0)
        if ($Ok) {
            $Log += git -C $KioRepoDir checkout --quiet --force --detach FETCH_HEAD 2>&1 | Out-String
            $Ok = ($LASTEXITCODE -eq 0)
        }
        if ($Ok) {
            if ($Ref -match '^v[0-9]') { git -C $KioRepoDir tag -f $Ref HEAD 2>&1 | Out-Null }
            $Short = (git -C $KioRepoDir rev-parse --short HEAD).Trim()
            Write-Host "     |-- [OK] Now at $Ref ($Short)" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] Could not update $KioRepoDir to '$Ref'." -ForegroundColor Red
            Write-Host $Log -ForegroundColor Red
            Write-Host "   Skills will keep using the copy already on disk. Fix the problem above, or delete $KioRepoDir and run the installer again." -ForegroundColor Red
            $script:KioUpdateFailed = $true
        }
    } elseif (-not (Test-Path $ManagedCheck)) {
        Write-Host "[FETCH] Piped/standalone install detected - fetching Kio '$Ref' to $KioRepoDir..." -ForegroundColor Cyan
        if (Test-Path $KioRepoDir) {
            Remove-Item $KioRepoDir -Recurse -Force
        }
        if (Get-Command git -ErrorAction SilentlyContinue) {
            git clone --quiet --depth 1 --branch $Ref $KioRepoUrl $KioRepoDir
            if ($LASTEXITCODE -ne 0) {
                Write-Host "[ERROR] git clone of '$Ref' from $KioRepoUrl failed." -ForegroundColor Red
                exit 1
            }
        } else {
            if ($env:KIO_ZIP_URL) { $ZipUrl = $env:KIO_ZIP_URL }
            elseif ($Ref -match '^v[0-9]') { $ZipUrl = "https://github.com/toanpham2111/kio-agent-system/archive/refs/tags/$Ref.zip" }
            else { $ZipUrl = "https://github.com/toanpham2111/kio-agent-system/archive/refs/heads/$Ref.zip" }
            $TempZip = Join-Path $KioConfigDir "kio-download.zip"
            $TempExtract = Join-Path $KioConfigDir "kio-extract"
            if (Test-Path $TempExtract) { Remove-Item $TempExtract -Recurse -Force }
            try {
                Invoke-WebRequest -Uri $ZipUrl -OutFile $TempZip -UseBasicParsing -ErrorAction Stop
            } catch {
                Write-Host "[ERROR] Downloading $ZipUrl failed: $($_.Exception.Message)" -ForegroundColor Red
                exit 1
            }
            Expand-Archive -Path $TempZip -DestinationPath $TempExtract -Force
            $InnerFolder = Get-ChildItem -Path $TempExtract -Directory | Select-Object -First 1
            Move-Item -Path $InnerFolder.FullName -Destination $KioRepoDir -Force
            Remove-Item $TempZip -Force -ErrorAction SilentlyContinue
            Remove-Item $TempExtract -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

$TargetSkillsDirs = @(
    (Join-Path $HomeDir ".claude\skills"),
    (Join-Path $HomeDir ".cursor\skills"),
    (Join-Path $HomeDir ".gemini\config\skills"),
    (Join-Path $HomeDir ".codex\skills"),
    (Join-Path $HomeDir ".agents\skills")
)

# Safe Link Helpers (Cross-platform compatibility)
function New-SafeLink ([string]$Path, [string]$Value) {
    if ($IsWindows -or ($null -eq $IsWindows)) {
        try {
            New-Item -ItemType Junction -Path $Path -Value $Value -Force -ErrorAction Stop | Out-Null
            return
        } catch {
            New-Item -ItemType SymbolicLink -Path $Path -Value $Value -Force | Out-Null
        }
    } else {
        New-Item -ItemType SymbolicLink -Path $Path -Value $Value -Force | Out-Null
    }
}

function Remove-SafeLink ([string]$Path) {
    if (-not (Test-Path $Path)) { return }
    $Item = Get-Item $Path -Force
    if ($Item.Attributes -match "ReparsePoint" -or [System.IO.File]::GetAttributes($Path).HasFlag([System.IO.FileAttributes]::ReparsePoint)) {
        if ($IsWindows -or ($null -eq $IsWindows)) {
            try {
                [System.IO.Directory]::Delete($Path)
                return
            } catch {
                Remove-Item $Path -Force -Recurse
            }
        } else {
            Remove-Item $Path -Force -Recurse
        }
    }
}

# Manifest Management
function Init-Manifest {
    if (-not (Test-Path $KioConfigDir)) {
        New-Item -ItemType Directory -Path $KioConfigDir -Force | Out-Null
    }
    if (-not (Test-Path $ManifestFile)) {
        @{ version = "1.0"; managed_links = @() } | ConvertTo-Json -Depth 5 | Set-Content $ManifestFile -Encoding UTF8
    }
}

function Record-Manifest ([string]$LinkPath, [string]$TargetPath) {
    Init-Manifest
    try {
        $Json = Get-Content $ManifestFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $NormalizedLink = [System.IO.Path]::GetFullPath($LinkPath)
        $NormalizedTarget = [System.IO.Path]::GetFullPath($TargetPath)
        
        $Filtered = @()
        if ($Json.managed_links) {
            $Filtered = @($Json.managed_links | Where-Object { $_.link -ne $NormalizedLink })
        }
        $Filtered += @{ link = $NormalizedLink; target = $NormalizedTarget }
        $Json.managed_links = $Filtered
        $Json | ConvertTo-Json -Depth 5 | Set-Content $ManifestFile -Encoding UTF8
    } catch {
        # Silent fallback
    }
}

function Remove-From-Manifest ([string]$LinkPath) {
    if (-not (Test-Path $ManifestFile)) { return }
    try {
        $Json = Get-Content $ManifestFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $NormalizedLink = [System.IO.Path]::GetFullPath($LinkPath)
        if ($Json.managed_links) {
            $Json.managed_links = @($Json.managed_links | Where-Object { $_.link -ne $NormalizedLink })
            $Json | ConvertTo-Json -Depth 5 | Set-Content $ManifestFile -Encoding UTF8
        }
    } catch {
        # Silent fallback
    }
}

function Test-In-Manifest ([string]$LinkPath) {
    if (-not (Test-Path $ManifestFile)) { return $false }
    try {
        $Json = Get-Content $ManifestFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $NormalizedLink = [System.IO.Path]::GetFullPath($LinkPath)
        if ($Json.managed_links) {
            $Match = $Json.managed_links | Where-Object { $_.link -eq $NormalizedLink }
            return ($null -ne $Match)
        }
    } catch {
        return $false
    }
    return $false
}

function Get-JunctionTarget ([string]$Path) {
    if (-not (Test-Path $Path)) { return $null }
    $Item = Get-Item $Path -Force
    if ($Item.Attributes -match "ReparsePoint" -or [System.IO.File]::GetAttributes($Path).HasFlag([System.IO.FileAttributes]::ReparsePoint)) {
        if ($Item.Target) {
            if ($Item.Target -is [array]) {
                return [System.IO.Path]::GetFullPath($Item.Target[0])
            }
            return [System.IO.Path]::GetFullPath($Item.Target)
        }
        if ($Item.LinkTarget) {
            return [System.IO.Path]::GetFullPath($Item.LinkTarget)
        }
    }
    return $null
}

function Test-RecordedKioTarget ([string]$LinkPath, [string]$ActualTarget, [string]$SkillName) {
    if (-not (Test-Path $ManifestFile)) { return $false }
    try {
        $Json = Get-Content $ManifestFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $NormalizedLink = [System.IO.Path]::GetFullPath($LinkPath)
        $NormalizedActual = [System.IO.Path]::GetFullPath($ActualTarget).TrimEnd('\', '/')
        if ($Json.managed_links) {
            foreach ($Entry in $Json.managed_links) {
                if ($Entry.link -eq $NormalizedLink -and $Entry.target) {
                    $RecTarget = [System.IO.Path]::GetFullPath($Entry.target).TrimEnd('\', '/')
                    $Leaf = Split-Path -Leaf $NormalizedActual
                    if ($RecTarget -eq $NormalizedActual -and $Leaf -eq $SkillName) {
                        return $true
                    }
                }
            }
        }
    } catch {
        return $false
    }
    return $false
}

# Strict Ownership Verification:
# Compares actual destination with expected Kio skill folder (local clone, ~/.kio/repo, or recorded manifest target).
# If target points elsewhere, cleans up stale manifest and returns false (PRESERVE).
function Verify-KioOwnership ([string]$LinkPath, [string]$SkillName) {
    if (-not (Test-Path $LinkPath)) { return $false }
    $Item = Get-Item $LinkPath -Force
    if (-not ($Item.Attributes -match "ReparsePoint" -or [System.IO.File]::GetAttributes($LinkPath).HasFlag([System.IO.FileAttributes]::ReparsePoint))) {
        return $false
    }
    
    $ActualTarget = Get-JunctionTarget $LinkPath
    if (-not $ActualTarget) { return $false }
    
    $ExpectedSkillPath = [System.IO.Path]::GetFullPath((Join-Path $SkillsSrcDir $SkillName))
    $ManagedSkillPath = [System.IO.Path]::GetFullPath((Join-Path (Join-Path $KioRepoDir "skills") $SkillName))
    $NormalizedActual = [System.IO.Path]::GetFullPath($ActualTarget).TrimEnd('\', '/')
    $NormalizedExpected = $ExpectedSkillPath.TrimEnd('\', '/')
    $NormalizedManaged = $ManagedSkillPath.TrimEnd('\', '/')
    
    # Strict boundary & exact skill directory match
    if (($NormalizedActual -eq $NormalizedExpected) -or ($NormalizedActual -eq $NormalizedManaged) -or (Test-RecordedKioTarget $LinkPath $ActualTarget $SkillName)) {
        return $true
    } else {
        # Target points elsewhere (user modified link)! Prune stale manifest entry.
        Remove-From-Manifest $LinkPath
        return $false
    }
}

function Resolve-SkillName ([string]$InputName) {
    switch ($InputName.Trim().ToLower()) {
        "frontend" { return "kio-frontend-craft" }
        "fe" { return "kio-frontend-craft" }
        "craft" { return "kio-frontend-craft" }
        "kio-frontend-craft" { return "kio-frontend-craft" }

        "backend" { return "kio-backend-cloud" }
        "be" { return "kio-backend-cloud" }
        "cloud" { return "kio-backend-cloud" }
        "kio-backend-cloud" { return "kio-backend-cloud" }

        "qa" { return "kio-qa-security" }
        "test" { return "kio-qa-security" }
        "security" { return "kio-qa-security" }
        "kio-qa-security" { return "kio-qa-security" }

        "core" { return "kio-core-delivery" }
        "delivery" { return "kio-core-delivery" }
        "sdd" { return "kio-core-delivery" }
        "kio-core-delivery" { return "kio-core-delivery" }

        "growth" { return "kio-growth-marketing" }
        "marketing" { return "kio-growth-marketing" }
        "seo" { return "kio-growth-marketing" }
        "kio-growth-marketing" { return "kio-growth-marketing" }

        "wordpress" { return "kio-wordpress-fse" }
        "wp" { return "kio-wordpress-fse" }
        "fse" { return "kio-wordpress-fse" }
        "kio-wordpress-fse" { return "kio-wordpress-fse" }

        "cognitive" { return "kio-cognitive" }
        "think" { return "kio-cognitive" }
        "why" { return "kio-cognitive" }
        "kio-cognitive" { return "kio-cognitive" }

        default {
            $PathCheck = Join-Path $SkillsSrcDir $InputName
            if (Test-Path $PathCheck) { return $InputName }
            return $null
        }
    }
}

# Uninstall Kio Skills
if ($Uninstall) {
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "[REMOVE] Uninstalling Kio Skills..." -ForegroundColor Yellow
    Write-Host "   (Only components strictly verified to belong to Kio will be removed)" -ForegroundColor Yellow
    Write-Host "=================================================================" -ForegroundColor Cyan

    $RemovedCount = 0

    foreach ($TargetDir in $TargetSkillsDirs) {
        if (-not (Test-Path $TargetDir)) { continue }
        Write-Host "[CHECK] Checking: $TargetDir" -ForegroundColor Yellow

        foreach ($SkillName in $AllKioSkills) {
            $TargetSkill = Join-Path $TargetDir $SkillName
            if (Test-Path $TargetSkill) {
                $Item = Get-Item $TargetSkill -Force
                if ($Item.Attributes -match "ReparsePoint" -or [System.IO.File]::GetAttributes($TargetSkill).HasFlag([System.IO.FileAttributes]::ReparsePoint)) {
                    if (Verify-KioOwnership $TargetSkill $SkillName) {
                        Remove-SafeLink $TargetSkill
                        Remove-From-Manifest $TargetSkill
                        Write-Host "     |-- [REMOVE] Removed verified Kio link: $SkillName" -ForegroundColor Red
                        $RemovedCount++
                    } else {
                        $ExtTarget = Get-JunctionTarget $TargetSkill
                        Write-Host "     |-- [KEEP] PRESERVED: $TargetSkill points to external location '$ExtTarget' (Not touched)" -ForegroundColor Green
                    }
                } else {
                    Write-Host "     |-- [KEEP] PRESERVED: $TargetSkill is a regular folder (Not touched)" -ForegroundColor Green
                }
            }
        }
    }

    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "[OK] SUCCESS: Kio skills uninstalled ($RemovedCount links removed)." -ForegroundColor Green
    Write-Host "   All other user skills remain completely untouched." -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Cyan
    exit 0
}

# Determine which skills to install
$SkillsToInstall = @()
if ([string]::IsNullOrWhiteSpace($Skill) -or $Skill -eq "all") {
    $SkillsToInstall = $AllKioSkills
} else {
    $Tokens = $Skill -split '[, ]+'
    foreach ($T in $Tokens) {
        if ([string]::IsNullOrWhiteSpace($T)) { continue }
        $Resolved = Resolve-SkillName $T
        if ($Resolved) {
            $SkillsToInstall += $Resolved
        } else {
            Write-Host "[WARN] Unknown skill shortcut: '$T'. Run '.\setup.ps1 -List' to see valid names." -ForegroundColor Red
        }
    }
}

if ($SkillsToInstall.Count -eq 0) {
    Write-Host "No valid skills selected for installation." -ForegroundColor Red
    exit 1
}

# Install selected skills safely
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "Kio Skills Installer: Safe & Non-Destructive Mode" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

Ensure-KioRepoSource
Init-Manifest

foreach ($TargetDir in $TargetSkillsDirs) {
    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }
    Write-Host "[DIR] Checking directory: $TargetDir" -ForegroundColor Yellow

    foreach ($SkillName in $SkillsToInstall) {
        $SourceSkillPath = Join-Path $SkillsSrcDir $SkillName
        if (-not (Test-Path $SourceSkillPath)) {
            Write-Host "     |-- [WARN] Skill source not found: $SkillName" -ForegroundColor Red
            continue
        }

        $TargetSkill = Join-Path $TargetDir $SkillName

        if (Test-Path $TargetSkill) {
            $Item = Get-Item $TargetSkill -Force
            if ($Item.Attributes -match "ReparsePoint" -or [System.IO.File]::GetAttributes($TargetSkill).HasFlag([System.IO.FileAttributes]::ReparsePoint)) {
                if (Verify-KioOwnership $TargetSkill $SkillName) {
                    Remove-SafeLink $TargetSkill
                    New-SafeLink $TargetSkill $SourceSkillPath
                    Record-Manifest $TargetSkill $SourceSkillPath
                    Write-Host "     |-- [UPDATE] Updated verified Kio link: $SkillName" -ForegroundColor Green
                } else {
                    $ExtTarget = Get-JunctionTarget $TargetSkill
                    Write-Host "     |-- [KEEP] PRESERVED: $TargetSkill points to external location '$ExtTarget' (Skipped, not modified)" -ForegroundColor DarkYellow
                }
            } else {
                Write-Host "     |-- [KEEP] PRESERVED: $TargetSkill is a user folder (Skipped, not modified)" -ForegroundColor DarkYellow
            }
        } else {
            New-SafeLink $TargetSkill $SourceSkillPath
            Record-Manifest $TargetSkill $SourceSkillPath
            Write-Host "     |-- [LINK] Linked skill: $SkillName" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
if ($script:KioUpdateFailed) {
    Write-Host "[WARN] Links are in place, but the Kio update FAILED (see the error above)." -ForegroundColor Yellow
    Write-Host "   Your skills still point at the previous version on disk." -ForegroundColor Yellow
    Write-Host "=================================================================" -ForegroundColor Cyan
    exit 2
}
Write-Host "[OK] SUCCESS: Selected Kio skills installed/updated!" -ForegroundColor Green
Write-Host "   Ownership: Tracked in $ManifestFile" -ForegroundColor Green
Write-Host "   Preserved: All existing user skills untouched." -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Cyan
