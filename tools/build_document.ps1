$ErrorActionPreference = 'Stop'
& python (Join-Path $PSScriptRoot 'build_document.py')
if ($LASTEXITCODE -ne 0) { throw 'Document build failed; inspect the saved compiler logs.' }
