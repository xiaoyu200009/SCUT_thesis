[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$Path,

    # If provided, creates a backup file next to the input.
    [switch]$Backup,

    # Optional encoding name used ONLY when the file has NO BOM.
    # Examples: 'utf-8', 'gbk', 'windows-1252'.
    [string]$AssumeEncoding,

    # Optional output path. If omitted, edits the input file in-place.
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-TextEncodingInfo {
    param([byte[]]$Bytes)

    # Detect BOM
    if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) {
        return [pscustomobject]@{ Encoding = (New-Object System.Text.UTF8Encoding($true)); HadBom = $true; Name = 'utf-8-bom' }
    }
    if ($Bytes.Length -ge 4 -and $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xFE -and $Bytes[2] -eq 0x00 -and $Bytes[3] -eq 0x00) {
        return [pscustomobject]@{ Encoding = (New-Object System.Text.UTF32Encoding($false, $true)); HadBom = $true; Name = 'utf-32le-bom' }
    }
    if ($Bytes.Length -ge 4 -and $Bytes[0] -eq 0x00 -and $Bytes[1] -eq 0x00 -and $Bytes[2] -eq 0xFE -and $Bytes[3] -eq 0xFF) {
        return [pscustomobject]@{ Encoding = (New-Object System.Text.UTF32Encoding($true, $true)); HadBom = $true; Name = 'utf-32be-bom' }
    }
    if ($Bytes.Length -ge 2 -and $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xFE) {
        return [pscustomobject]@{ Encoding = (New-Object System.Text.UnicodeEncoding($false, $true)); HadBom = $true; Name = 'utf-16le-bom' }
    }
    if ($Bytes.Length -ge 2 -and $Bytes[0] -eq 0xFE -and $Bytes[1] -eq 0xFF) {
        return [pscustomobject]@{ Encoding = (New-Object System.Text.UnicodeEncoding($true, $true)); HadBom = $true; Name = 'utf-16be-bom' }
    }

    # No BOM: choose user-specified encoding, otherwise UTF-8 without BOM.
    if ($AssumeEncoding -and $AssumeEncoding.Trim().Length -gt 0) {
        return [pscustomobject]@{ Encoding = [System.Text.Encoding]::GetEncoding($AssumeEncoding); HadBom = $false; Name = "assumed:$AssumeEncoding" }
    }

    return [pscustomobject]@{ Encoding = (New-Object System.Text.UTF8Encoding($false)); HadBom = $false; Name = 'utf-8-nobom(default)' }
}

function Convert-SetextToAtx {
    param([string]$Text)

    # Preserve existing EOL style.
    $eol = if ($Text.Contains("`r`n")) { "`r`n" } else { "`n" }

    # Split including trailing empty line, so final newline is preserved on join.
    $lines = $Text -split "\r\n|\n", -1

    $out = New-Object System.Collections.Generic.List[string]

    $inFence = $false
    $fenceChar = ''
    $fenceLen = 0
    $converted = 0

    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]

        # Fenced code blocks: ``` / ~~~ (any length >= 3)
        if ($line -match '^\s*([`~]{3,})(.*)$') {
            $marker = $Matches[1]
            $char = $marker.Substring(0, 1)
            $len = $marker.Length
            $rest = $Matches[2]

            if (-not $inFence) {
                $inFence = $true
                $fenceChar = $char
                $fenceLen = $len
                $out.Add($line)
                continue
            }

            # Closing fence must use same char, length >= opening, and no non-space trailing text.
            if ($char -eq $fenceChar -and $len -ge $fenceLen -and $rest -match '^\s*$') {
                $inFence = $false
                $fenceChar = ''
                $fenceLen = 0
                $out.Add($line)
                continue
            }
        }

        if (-not $inFence -and ($i + 1) -lt $lines.Length) {
            $next = $lines[$i + 1]

            # Setext underline: only '=' or '-' (and spaces)
            if ($next -match '^\s*(=+|-+)\s*$') {
                $underline = $Matches[1]
                $title = $line

                # Avoid converting blank titles or already-ATX lines.
                if (-not ($title -match '^\s*$') -and -not ($title -match '^\s*#')) {
                    $level = if ($underline[0] -eq '=') { 1 } else { 2 }
                    $prefix = if ($level -eq 1) { '#' } else { '##' }
                    $out.Add("$prefix " + $title.Trim())
                    $converted++
                    $i++
                    continue
                }
            }
        }

        $out.Add($line)
    }

    return [pscustomobject]@{
        Text      = ($out.ToArray() -join $eol)
        Converted = $converted
        Eol       = if ($eol -eq "`r`n") { 'CRLF' } else { 'LF' }
    }
}

$fullPath = [System.IO.Path]::GetFullPath($Path)
if (-not (Test-Path -LiteralPath $fullPath)) {
    throw "File not found: $fullPath"
}

$bytes = [System.IO.File]::ReadAllBytes($fullPath)
$encInfo = Get-TextEncodingInfo -Bytes $bytes
$text = $encInfo.Encoding.GetString($bytes)

# Normalize: Some BOM encodings will include BOM as U+FEFF at start; drop it.
if ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF) {
    $text = $text.Substring(1)
}

$result = Convert-SetextToAtx -Text $text

$target = if ($OutputPath -and $OutputPath.Trim().Length -gt 0) {
    [System.IO.Path]::GetFullPath($OutputPath)
}
else {
    $fullPath
}

if ($Backup -and ($target -eq $fullPath)) {
    $bak = "$fullPath.bak"
    if ($PSCmdlet.ShouldProcess($bak, 'Create backup')) {
        [System.IO.File]::WriteAllBytes($bak, $bytes)
    }
}

# Write with the same encoding selection as read (preserves BOM presence/absence).
if ($PSCmdlet.ShouldProcess($target, 'Write converted Markdown')) {
    [System.IO.File]::WriteAllText($target, $result.Text, $encInfo.Encoding)
}

[pscustomobject]@{
    Input                   = $fullPath
    Output                  = $target
    Encoding                = $encInfo.Name
    EOL                     = $result.Eol
    ConvertedSetextHeadings = $result.Converted
    BackupCreated           = [bool]($Backup -and ($target -eq $fullPath))
}
