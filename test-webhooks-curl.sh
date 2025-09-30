#!/bin/bash

# 🎯 TESTE COMPLETO DOS WEBHOOKS DO AGENTE1
# Execute este script para testar todos os webhooks

echo "🎯 TESTE COMPLETO DOS WEBHOOKS DO AGENTE1"
echo "=========================================="

# Configurações
BASE_URL="https://n8n.code-iq.com.br/webhook"
USER_ID="SEU_USER_ID"  # Substitua pelo seu ID real
WORKFLOW_ID="eBcColwirndBaFZX"

echo ""
echo "📊 CONFIGURAÇÕES:"
echo "• Base URL: $BASE_URL"
echo "• User ID: $USER_ID"
echo "• Workflow ID: $WORKFLOW_ID"
echo ""

# 1️⃣ TESTE STATUS (ANTES)
echo "1️⃣ TESTANDO STATUS (ANTES DE INICIAR)..."
echo "----------------------------------------"
curl -X GET "$BASE_URL/status-agente1?usuario_id=$USER_ID&workflow_id=$WORKFLOW_ID&action=get_status" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s

echo ""
echo ""

# 2️⃣ TESTE START
echo "2️⃣ TESTANDO START (INICIAR AGENTE)..."
echo "-------------------------------------"
START_RESPONSE=$(curl -X POST "$BASE_URL/start-agente1" \
  -H "Content-Type: application/json" \
  -d "{
    \"action\": \"start\",
    \"agent_type\": \"$WORKFLOW_ID\",
    \"workflow_id\": \"$WORKFLOW_ID\",
    \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",
    \"usuario_id\": \"$USER_ID\",
    \"logged_user\": {
      \"id\": \"$USER_ID\",
      \"name\": \"Teste User\",
      \"email\": \"teste@exemplo.com\"
    }
  }" \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "$START_RESPONSE"

# Extrair execution_id da resposta (se disponível)
EXECUTION_ID=$(echo "$START_RESPONSE" | grep -o '"execution_id":"[^"]*"' | cut -d'"' -f4)
echo "🔍 Execution ID capturado: $EXECUTION_ID"

echo ""
echo ""

# Aguardar um pouco para o agente iniciar
echo "⏳ Aguardando 5 segundos para o agente iniciar..."
sleep 5

# 3️⃣ TESTE STATUS (DURANTE)
echo "3️⃣ TESTANDO STATUS (DURANTE EXECUÇÃO)..."
echo "----------------------------------------"
curl -X GET "$BASE_URL/status-agente1?usuario_id=$USER_ID&workflow_id=$WORKFLOW_ID&action=get_status" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s

echo ""
echo ""

# 4️⃣ TESTE STOP
echo "4️⃣ TESTANDO STOP (PARAR AGENTE)..."
echo "----------------------------------"
curl -X POST "$BASE_URL/stop-agente1" \
  -H "Content-Type: application/json" \
  -d "{
    \"action\": \"stop\",
    \"agent_type\": \"$WORKFLOW_ID\",
    \"workflow_id\": \"$WORKFLOW_ID\",
    \"execution_id\": \"$EXECUTION_ID\",
    \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",
    \"usuario_id\": \"$USER_ID\",
    \"logged_user\": {
      \"id\": \"$USER_ID\",
      \"name\": \"Teste User\",
      \"email\": \"teste@exemplo.com\"
    }
  }" \
  -w "\nStatus: %{http_code}\n" \
  -s

echo ""
echo ""

# Aguardar um pouco para o agente parar
echo "⏳ Aguardando 3 segundos para o agente parar..."
sleep 3

# 5️⃣ TESTE STATUS (APÓS)
echo "5️⃣ TESTANDO STATUS (APÓS PARAR)..."
echo "----------------------------------"
curl -X GET "$BASE_URL/status-agente1?usuario_id=$USER_ID&workflow_id=$WORKFLOW_ID&action=get_status" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s

echo ""
echo ""
echo "✅ TESTE COMPLETO FINALIZADO!"
echo "=============================="
echo ""
echo "📋 RESUMO DOS TESTES:"
echo "• Status inicial: Deve mostrar 'disconnected'"
echo "• Start: Deve retornar execution_id"
echo "• Status durante: Deve mostrar 'running'"
echo "• Stop: Deve parar o agente"
echo "• Status final: Deve mostrar 'disconnected'"
echo ""
echo "🔧 PRÓXIMOS PASSOS:"
echo "• Verificar logs no n8n"
echo "• Verificar dados no Redis"
echo "• Verificar dados no PostgreSQL"
echo "• Testar via frontend"
