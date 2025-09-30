# Sua chave de API do n8n
$apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlYTFiNjVlMy01YzNlLTQ0MWYtYmQ4OS0xNDMzMGFmYTcxZGQiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzU3NTU5ODc5fQ.eBj-NuMEosvbmc_UBwJfrdIKC8wnLXznpTO4wtddUfI"

# Endpoint da API
$url = "https://n8n.code-iq.com.br/api/v1/workflows"

# Requisição GET
$response = Invoke-RestMethod -Uri $url -Headers @{ "X-N8N-API-KEY" = $apiKey } -Method Get

# Exibir resultado formatado
$response | ConvertTo-Json -Depth 5

