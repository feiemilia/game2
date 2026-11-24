$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$site = Join-Path $root 'web-export'
$index = Join-Path $site 'index.html'
if (-not (Test-Path -LiteralPath $index)) {
    throw "Web export not found: $index. Export the Web preset in Godot first."
}
Set-Location -LiteralPath $site
$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 8000)
$listener.Start()
$base = [IO.Path]::GetFullPath($site).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
Write-Host 'Serving the local Web build at http://127.0.0.1:8000/  (Ctrl+C to stop)'
try {
    while ($true) {
        $client = $listener.AcceptTcpClient()
        $stream = $client.GetStream()
        try {
            $reader = [IO.StreamReader]::new($stream, [Text.Encoding]::ASCII, $false, 1024, $true)
            $requestLine = $reader.ReadLine()
            while ($reader.ReadLine() -ne '') { }
            $parts = $requestLine.Split(' ')
            if ($parts.Length -lt 2 -or $parts[0] -ne 'GET') { throw 'Unsupported HTTP request' }
            $relative = [Uri]::UnescapeDataString(([Uri]::new("http://127.0.0.1" + $parts[1])).AbsolutePath.TrimStart('/'))
            if ([string]::IsNullOrWhiteSpace($relative)) { $relative = 'index.html' }
            $path = [IO.Path]::GetFullPath((Join-Path $site $relative))
            if (-not $path.StartsWith($base, [StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $path -PathType Leaf)) {
                $body = [Text.Encoding]::UTF8.GetBytes('Not Found')
                $header = [Text.Encoding]::ASCII.GetBytes("HTTP/1.1 404 Not Found`r`nContent-Length: $($body.Length)`r`nConnection: close`r`n`r`n")
                $stream.Write($header, 0, $header.Length)
                $stream.Write($body, 0, $body.Length)
                continue
            }
            $mime = switch ([IO.Path]::GetExtension($path).ToLowerInvariant()) {
                '.html' { 'text/html; charset=utf-8' }
                '.js' { 'application/javascript; charset=utf-8' }
                '.wasm' { 'application/wasm' }
                '.json' { 'application/json; charset=utf-8' }
                '.png' { 'image/png' }
                '.svg' { 'image/svg+xml' }
                default { 'application/octet-stream' }
            }
            $stream = [IO.File]::OpenRead($path)
            $header = [Text.Encoding]::ASCII.GetBytes("HTTP/1.1 200 OK`r`nContent-Type: $mime`r`nContent-Length: $($stream.Length)`r`nConnection: close`r`n`r`n")
            $clientStream = $client.GetStream()
            $clientStream.Write($header, 0, $header.Length)
            $stream.CopyTo($clientStream)
            $stream.Dispose()
        } catch {
            Write-Warning $_.Exception.Message
        } finally {
            if ($stream -is [IO.Stream]) { $stream.Dispose() }
            $client.Close()
        }
    }
} finally {
    $listener.Stop()
}
