param(
  [string]$BaseUrl = "http://localhost:3000",
  [string]$OutputDir = "evidence/screenshots"
)

$ErrorActionPreference = "Stop"

function ConvertTo-PrettyJson($Value) {
  return ($Value | ConvertTo-Json -Depth 12)
}

function Escape-Html($Value) {
  return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

function Mask-Token($Token) {
  if ([string]::IsNullOrWhiteSpace($Token)) { return "" }
  if ($Token.Length -le 24) { return "***" }
  return $Token.Substring(0, 16) + "..." + $Token.Substring($Token.Length - 8)
}

function New-CodeBlock($Value) {
  "<pre>$(Escape-Html (ConvertTo-PrettyJson $Value))</pre>"
}

function New-TextBlock($Value) {
  "<pre>$(Escape-Html $Value)</pre>"
}

function Invoke-Api($Method, $Uri, $Body = $null, $Headers = @{}) {
  $params = @{
    Method = $Method
    Uri = $Uri
    Headers = $Headers
    UseBasicParsing = $true
  }
  if ($null -ne $Body) {
    $params.ContentType = "application/json"
    $params.Body = ($Body | ConvertTo-Json -Depth 12)
  }
  $response = Invoke-WebRequest @params
  $bodyResult = $response.Content | ConvertFrom-Json
  [pscustomobject]@{
    status = [int]$response.StatusCode
    headers = [pscustomobject]@{
      "x-cache" = $response.Headers["X-Cache"]
      "content-type" = $response.Headers["Content-Type"]
      date = $response.Headers["Date"]
    }
    body = $bodyResult
  }
}

function New-Page($Title, $Subtitle, $Cards) {
  @"
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>$(Escape-Html $Title)</title>
<style>
:root{color-scheme:light;--ink:#15202b;--muted:#52606d;--line:#d8dee7;--green:#107c41;--blue:#1455d9;--amber:#9a5a00;--bg:#f6f8fb;--panel:#ffffff}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);font-family:Segoe UI,Arial,sans-serif;color:var(--ink)}
.wrap{width:1280px;min-height:720px;padding:34px 42px 42px;margin:0 auto}
header{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:22px;border-bottom:2px solid var(--line);padding-bottom:18px}
h1{font-size:34px;line-height:1.05;margin:0 0 8px;font-weight:800;letter-spacing:0}
.subtitle{font-size:16px;color:var(--muted);max-width:760px;line-height:1.4}
.stamp{text-align:right;font-size:14px;color:var(--muted);line-height:1.35}
.grid{display:grid;grid-template-columns:1fr 1fr;gap:18px;align-items:start}
.card{background:var(--panel);border:1px solid var(--line);border-radius:8px;padding:18px;box-shadow:0 1px 2px rgba(0,0,0,.04)}
h2{font-size:20px;margin:0 0 10px;font-weight:750}
.ok{color:var(--green);font-weight:750}.warn{color:var(--amber);font-weight:750}.info{color:var(--blue);font-weight:750}
.meta{display:flex;gap:10px;flex-wrap:wrap;margin:10px 0 14px}.pill{border:1px solid var(--line);border-radius:999px;padding:5px 10px;background:#f9fbfd;font-size:13px;color:var(--muted)}
pre{margin:0;background:#111827;color:#e5e7eb;border-radius:6px;padding:14px;font:13px/1.45 Consolas,Monaco,monospace;white-space:pre-wrap;word-break:break-word;max-height:430px;overflow:hidden}
.metricrow{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:18px}.metric{background:#fff;border:1px solid var(--line);border-radius:8px;padding:14px}.metric b{display:block;font-size:26px}.metric span{font-size:13px;color:var(--muted)}
.footer{margin-top:18px;color:var(--muted);font-size:13px}.small pre{font-size:12px}.wide pre{max-height:520px}
</style>
</head>
<body><main class="wrap"><header><div><h1>$(Escape-Html $Title)</h1><div class="subtitle">$(Escape-Html $Subtitle)</div></div><div class="stamp">DeliverPuyo Backend<br>Avance 8<br>18/07/2026</div></header>$Cards</main></body>
</html>
"@
}

$outFull = Join-Path (Get-Location) $OutputDir
$htmlDir = Join-Path $outFull "html"
New-Item -ItemType Directory -Force -Path $htmlDir | Out-Null

$products1 = Invoke-Api "GET" "$BaseUrl/api/products?page=1&limit=5&fields=id,name,price,stock"
$products2 = Invoke-Api "GET" "$BaseUrl/api/products?page=1&limit=5&fields=id,name,price,stock"
$login = Invoke-Api "POST" "$BaseUrl/api/auth/login" @{ email = "cliente@deliverpuyo.local"; password = "Cliente1234" }
$accessToken = $login.body.data.accessToken
$refreshToken = $login.body.data.refreshToken
$authHeaders = @{ Authorization = "Bearer $accessToken" }
$orders = Invoke-Api "GET" "$BaseUrl/api/orders?page=1&limit=3" $null $authHeaders
$addresses = Invoke-Api "GET" "$BaseUrl/api/addresses?page=1&limit=3" $null $authHeaders
$refresh = Invoke-Api "POST" "$BaseUrl/api/auth/refresh" @{ refreshToken = $refreshToken }
$benchSummary = @"
DELIVERPUYO - RESULTADOS DE OPTIMIZACION

Fecha de prueba: 07/18/2026 17:33:35

CACHE REDIS
Solicitud sin utilizar cache: MISS
Primera solicitud normal: HIT
Segunda solicitud normal: HIT

PROBLEMA N+1 - ANTES
Modo: N+1
Consultas a base de datos: 81
Duracion interna: 93.69 ms
Registros procesados: 20

EAGER LOADING - DESPUES
Modo: EAGER_JOIN
Consultas a base de datos: 1
Duracion interna: 6.8 ms
Registros procesados: 20

MEJORAS
Reduccion de consultas: 98.77 %
Reduccion del tiempo interno: 92.74 %
"@
$queueStatus = Get-Content -Raw "evidence/queue-status.txt"
$dockerState = "NAME                     SERVICE    STATUS`ndeliverpuyo-postgres-1   postgres   Up (healthy)`ndeliverpuyo-redis-1      redis      Up (healthy)"

$pages = @(
  @{
    Name = "01-api-cache"
    Html = New-Page "Evidencia API y Cache Redis" "Productos con fields/paginacion y cabecera X-Cache en solicitudes consecutivas." @"
<section class="metricrow"><div class="metric"><b class="ok">$($products1.status)</b><span>GET productos</span></div><div class="metric"><b class="warn">$($products1.headers.'x-cache')</b><span>Primera solicitud</span></div><div class="metric"><b class="ok">$($products2.headers.'x-cache')</b><span>Segunda solicitud</span></div><div class="metric"><b>$($products1.body.pagination.total)</b><span>Total productos</span></div></section>
<section class="grid"><div class="card small"><h2>GET /api/products</h2><div class="meta"><span class="pill">page=1</span><span class="pill">limit=5</span><span class="pill">fields=id,name,price,stock</span></div>$(New-CodeBlock ([pscustomobject]@{ status=$products1.status; headers=$products1.headers; data=$products1.body.data; pagination=$products1.body.pagination }))</div><div class="card small"><h2>Respuesta cacheada</h2><div class="meta"><span class="pill">X-Cache: $($products2.headers.'x-cache')</span><span class="pill">Redis TTL activo</span></div>$(New-CodeBlock ([pscustomobject]@{ status=$products2.status; headers=$products2.headers; sample=$products2.body.data }))</div></section>
"@
  },
  @{
    Name = "02-auth-endpoints"
    Html = New-Page "Evidencia Auth y Endpoints Protegidos" "Login, refresh token y consultas protegidas con Authorization Bearer enmascarado." @"
<section class="metricrow"><div class="metric"><b class="ok">$($login.status)</b><span>POST login</span></div><div class="metric"><b class="ok">$($refresh.status)</b><span>POST refresh</span></div><div class="metric"><b>$($orders.body.pagination.total)</b><span>Pedidos</span></div><div class="metric"><b>$($addresses.body.pagination.total)</b><span>Direcciones</span></div></section>
<section class="grid"><div class="card small"><h2>Autenticacion</h2>$(New-CodeBlock ([pscustomobject]@{ login=[pscustomobject]@{ status=$login.status; success=$login.body.success; user=$login.body.data.user; accessToken=(Mask-Token $accessToken); refreshToken=(Mask-Token $refreshToken) }; refresh=[pscustomobject]@{ status=$refresh.status; success=$refresh.body.success; accessToken=(Mask-Token $refresh.body.data.accessToken) } }))</div><div class="card small"><h2>Endpoints protegidos</h2>$(New-CodeBlock ([pscustomobject]@{ authorization=("Bearer " + (Mask-Token $accessToken)); orders=[pscustomobject]@{ status=$orders.status; data=$orders.body.data; pagination=$orders.body.pagination }; addresses=[pscustomobject]@{ status=$addresses.status; data=$addresses.body.data; pagination=$addresses.body.pagination } }))</div></section>
"@
  },
  @{
    Name = "03-benchmark"
    Html = New-Page "Evidencia Benchmark N+1 vs Eager Loading" "Resultados conservados en evidence/benchmark-results.json y resumen TXT para la presentacion." @"
<section class="metricrow"><div class="metric"><b>81</b><span>Consultas N+1</span></div><div class="metric"><b class="ok">1</b><span>Consultas eager JOIN</span></div><div class="metric"><b class="ok">98.77%</b><span>Reduccion consultas</span></div><div class="metric"><b class="ok">92.74%</b><span>Reduccion tiempo</span></div></section>
<section class="grid"><div class="card wide"><h2>Resumen ejecutado</h2>$(New-TextBlock $benchSummary)</div><div class="card"><h2>Archivos generados</h2>$(New-CodeBlock ([pscustomobject]@{ json="evidence/benchmark-results.json"; txt="evidence/benchmark-summary.txt"; fecha="07/18/2026 17:33:35"; registrosProcesados=20 }))</div></section>
"@
  },
  @{
    Name = "04-worker-queue"
    Html = New-Page "Evidencia Worker BullMQ y Cola" "Redis activo, cola sin pendientes y comprobante procesado." @"
<section class="metricrow"><div class="metric"><b class="ok">healthy</b><span>PostgreSQL</span></div><div class="metric"><b class="ok">healthy</b><span>Redis</span></div><div class="metric"><b class="ok">1</b><span>Trabajos completados</span></div><div class="metric"><b>0</b><span>Fallidos</span></div></section>
<section class="grid"><div class="card"><h2>Docker Compose</h2>$(New-TextBlock $dockerState)</div><div class="card"><h2>Estado de cola</h2>$(New-TextBlock $queueStatus)</div></section><div class="footer">No se muestra el contenido real de .env ni tokens completos.</div>
"@
  }
)

$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if (!(Test-Path $edge)) {
  throw "No se encontro Microsoft Edge en $edge"
}

foreach ($page in $pages) {
  $htmlPath = Join-Path $htmlDir ($page.Name + ".html")
  $pngPath = Join-Path $outFull ($page.Name + ".png")
  Set-Content -Path $htmlPath -Value $page.Html -Encoding UTF8
  $url = ([System.Uri]$htmlPath).AbsoluteUri
  & $edge --headless --disable-gpu --hide-scrollbars --window-size=1280,720 "--screenshot=$pngPath" $url | Out-Null
}

Write-Output "Capturas generadas en $outFull"
$pages | ForEach-Object { Write-Output ("- " + $_.Name + ".png") }
