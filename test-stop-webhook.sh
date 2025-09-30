#!/bin/bash

# 🧪 TESTE DO WEBHOOK STOP VIA CURL
# Execute com: bash test-stop-webhook.sh

echo "🧪 TESTE DO WEBHOOK STOP"
echo "========================"
echo ""

# Configurações
WEBHOOK_URL="https://n8n.code-iq.com.br/webhook/stop-agente1"
EXECUTION_ID="TESTE_$(date +%s)"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)

echo "📊 URL: $WEBHOOK_URL"
echo "📊 Execution ID: $EXECUTION_ID"
echo "📊 Timestamp: $TIMESTAMP"
echo ""

# Payload de teste
PAYLOAD=$(cat <<EOF
{
  "action": "stop",
  "agent_type": "eBcColwirndBaFZX",
  "workflow_id": "eBcColwirndBaFZX",
  "execution_id": "$EXECUTION_ID",
  "timestamp": "$TIMESTAMP",
  "usuario_id": "5",
  "logged_user": {
    "id": "5",
    "name": "Teste User",
    "email": "teste@exemplo.com"
  }
}
EOF
)

echo "📊 Payload:"
echo "$PAYLOAD" | jq .
echo ""

echo "🚀 Enviando requisição..."
echo ""

# Fazer requisição
RESPONSE=$(curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "User-Agent: Teste-Webhook-Stop/1.0" \
  -d "$PAYLOAD" \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "📥 Resposta:"
echo "$RESPONSE"
echo ""

# Verificar resultado
HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1 | grep -o '[0-9]*$')
RESPONSE_BODY=$(echo "$RESPONSE" | head -n -1)

echo "🎯 RESULTADO DO TESTE:"
echo "======================"
echo "Status HTTP: $HTTP_STATUS"

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ SUCESSO: Webhook funcionando!"
    
    # Tentar parsear JSON
    if echo "$RESPONSE_BODY" | jq . >/dev/null 2>&1; then
        SUCCESS=$(echo "$RESPONSE_BODY" | jq -r '.success // false')
        MESSAGE=$(echo "$RESPONSE_BODY" | jq -r '.message // "N/A"')
        
        echo "✅ Success: $SUCCESS"
        echo "✅ Message: $MESSAGE"
        
        if [ "$SUCCESS" = "true" ]; then
            echo "✅ WEBHOOK STOP FUNCIONANDO PERFEITAMENTE!"
        else
            echo "⚠️ Webhook respondeu mas com erro"
        fi
    else
        echo "⚠️ Resposta não é JSON válido"
    fi
else
    echo "❌ ERRO: Webhook com problemas"
    echo "❌ Status: $HTTP_STATUS"
fi

echo ""
echo "🔧 PRÓXIMOS PASSOS:"
echo "• Se sucesso: Testar via frontend"
echo "• Se erro: Verificar configuração no n8n"
echo "• Verificar logs do n8n"
echo "• Verificar se workflow está ativo"
