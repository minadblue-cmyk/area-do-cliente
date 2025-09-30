#!/bin/bash

# Teste final usando curl para enviar dados ao webhook

echo "🧪 Teste Final - Enviando dados para o webhook via curl"
echo ""

# URL do webhook
WEBHOOK_URL="https://n8n.code-iq.com.br/webhook/create-agente"

# Dados de teste
DADOS='{
  "agent_name": "Agente Vendas Premium",
  "agent_type": "vendas-premium", 
  "agent_id": 8,
  "user_id": 5,
  "icone": "💼",
  "cor": "bg-green-500",
  "descricao": "Agente para vendas premium"
}'

echo "📤 Dados sendo enviados:"
echo "$DADOS" | jq .
echo ""

echo "🌐 Enviando para: $WEBHOOK_URL"
echo ""

# Enviar requisição
curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$DADOS" \
  -w "\n\n📊 Status Code: %{http_code}\n⏱️  Tempo Total: %{time_total}s\n" \
  -s

echo ""
echo "✅ Teste concluído!"
