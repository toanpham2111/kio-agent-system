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
    Write-Host "🧰 Kio: Available Engineering Skills (7 Master Skills)" -ForegroundColor Cyan
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

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SkillsSrcDir = [System.IO.Path]::GetFullPath((Join-Path $ScriptDir "skills"))
$HomeDir = [System.Environment]::GetFolderPath('UserProfile')
$KioConfigDir = Join-Path $HomeDir ".kio"
$ManifestFile = Join-Path $KioConfigDir "manifest.json"

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

# Strict Ownership Verification:
# Compares actual destination with expected Kio skill folder.
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
    $NormalizedActual = [System.IO.Path]::GetFullPath($ActualTarget).TrimEnd('\', '/')
    $NormalizedExpected = $ExpectedSkillPath.TrimEnd('\', '/')
    
    # Strict boundary & exact skill directory match
    if ($NormalizedActual -eq $NormalizedExpected) {
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
    Write-Host "🗑️  Uninstalling Kio Skills..." -ForegroundColor Yellow
    Write-Host "   (Only components strictly verified to belong to Kio will be removed)" -ForegroundColor Yellow
    Write-Host "=================================================================" -ForegroundColor Cyan

    $RemovedCount = 0

    foreach ($TargetDir in $TargetSkillsDirs) {
        if (-not (Test-Path $TargetDir)) { continue }
        Write-Host "🔍 Checking: $TargetDir" -ForegroundColor Yellow

        foreach ($SkillName in $AllKioSkills) {
            $TargetSkill = Join-Path $TargetDir $SkillName
            if (Test-Path $TargetSkill) {
                $Item = Get-Item $TargetSkill -Force
                if ($Item.Attributes -match "ReparsePoint" -or [System.IO.File]::GetAttributes($TargetSkill).HasFlag([System.IO.FileAttributes]::ReparsePoint)) {
                    if (Verify-KioOwnership $TargetSkill $SkillName) {
                        Remove-SafeLink $TargetSkill
                        Remove-From-Manifest $TargetSkill
                        Write-Host "   └── 🗑️ Removed verified Kio link: $SkillName" -ForegroundColor Red
                        $RemovedCount++
                    } else {
                        $ExtTarget = Get-JunctionTarget $TargetSkill
                        Write-Host "   └── 🛡️ PRESERVED: $TargetSkill points to external location '$ExtTarget' (Not touched)" -ForegroundColor Green
                    }
                } else {
                    Write-Host "   └── 🛡️ PRESERVED: $TargetSkill is a regular folder (Not touched)" -ForegroundColor Green
                }
            }
        }
    }

    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "✅ SUCCESS: Kio skills uninstalled ($RemovedCount links removed)." -ForegroundColor Green
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
            Write-Host "⚠️ Unknown skill shortcut: '$T'. Run '.\setup.ps1 -List' to see valid names." -ForegroundColor Red
        }
    }
}

if ($SkillsToInstall.Count -eq 0) {
    Write-Host "No valid skills selected for installation." -ForegroundColor Red
    exit 1
}

# Install selected skills safely
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "⬇️  Kio Skills Installer: Safe & Non-Destructive Mode" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

Init-Manifest

foreach ($TargetDir in $TargetSkillsDirs) {
    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }
    Write-Host "📦 Checking directory: $TargetDir" -ForegroundColor Yellow

    foreach ($SkillName in $SkillsToInstall) {
        $SourceSkillPath = Join-Path $SkillsSrcDir $SkillName
        if (-not (Test-Path $SourceSkillPath)) {
            Write-Host "   └── ⚠️ Skill source not found: $SkillName" -ForegroundColor Red
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
                    Write-Host "   └── 🔄 Updated verified Kio link: $SkillName" -ForegroundColor Green
                } else {
                    $ExtTarget = Get-JunctionTarget $TargetSkill
                    Write-Host "   └── 🛡️ PRESERVED: $TargetSkill points to external location '$ExtTarget' (Skipped, not modified)" -ForegroundColor DarkYellow
                }
            } else {
                Write-Host "   └── 🛡️ PRESERVED: $TargetSkill is a user folder (Skipped, not modified)" -ForegroundColor DarkYellow
            }
        } else {
            New-SafeLink $TargetSkill $SourceSkillPath
            Record-Manifest $TargetSkill $SourceSkillPath
            Write-Host "   └── 🔗 Linked skill: $SkillName" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "✅ SUCCESS: Selected Kio skills installed/updated!" -ForegroundColor Green
Write-Host "   Ownership: Tracked in $ManifestFile" -ForegroundColor Green
Write-Host "   Preserved: All existing user skills untouched." -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Cyan
