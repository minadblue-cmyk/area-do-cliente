# Correção do nó "Prepara Json" no workflow de listar agentes

## Problema atual:
O nó "Prepara Json" está configurado assim:
```json
{
  "success": true,
  "total": 1,
  "data": "={{ $json }}",  // ← PROBLEMA: $json é um array, mas está sendo colocado em "data"
  "message": "Agentes encontrados",
  "timestamp": "={{ new Date().toISOString() }}"
}
```

## Solução:
Altere o nó "Prepara Json" para retornar diretamente o array de agentes:

### Opção 1: Retornar array direto (recomendado)
```json
{
  "assignments": [
    {
      "id": "3187ed9f-27cd-45b1-9132-5040238e8509",
      "name": "success",
      "value": true,
      "type": "boolean"
    },
    {
      "id": "072596d4-4756-4f95-9ec3-53f98adefcf4",
      "name": "total",
      "value": "={{ Array.isArray($json) ? $json.length : 1 }}",
      "type": "number"
    },
    {
      "id": "13bf259e-cd1c-497f-8e44-e895c08bf29c",
      "name": "data",
      "value": "={{ $json }}",  // ← Array de agentes diretamente
      "type": "array"
    },
    {
      "id": "afc2f6e9-08e2-4442-9dfa-ba1718255d43",
      "name": "message",
      "value": "Agentes encontrados",
      "type": "string"
    },
    {
      "id": "1c723801-f017-4ecf-a2c1-a1f200b6f0d5",
      "name": "timestamp",
      "value": "={{ new Date().toISOString() }}",
      "type": "string"
    }
  ]
}
```

### Opção 2: Usar nó "Code" para processar
Se preferir usar um nó "Code", substitua o nó "Prepara Json" por:

```javascript
// Processar agentes do banco
const agentes = $input.all();

console.log('📋 Agentes encontrados:', agentes.length);

// Mapear para o formato esperado pelo frontend
const agentesFormatados = agentes.map(item => {
  const data = item.json;
  
  return {
    id: data.id,
    nome: data.nome,
    workflow_id: data.workflow_id,
    webhook_url: data.webhook_url,
    descricao: data.descricao,
    icone: data.icone || '🤖',
    cor: data.cor || 'bg-blue-500',
    ativo: data.ativo,
    created_at: data.created_at,
    updated_at: data.updated_at
  };
});

console.log('✅ Agentes formatados:', agentesFormatados.length);

// Retornar no formato que o frontend espera
return {
  json: {
    success: true,
    message: 'Agentes encontrados',
    data: agentesFormatados,  // ← Array de agentes
    total: agentesFormatados.length,
    timestamp: new Date().toISOString()
  }
};
```

## Resultado esperado:
Após a correção, o webhook deve retornar:
```json
{
  "success": true,
  "total": 1,
  "data": [
    {
      "id": 7,
      "nome": "Elleven Agente 1 (Maria)",
      "workflow_id": "eBcColwirndBaFZX",
      "webhook_url": "webhook/agente1",
      "descricao": "Agente para prospecção de leads.",
      "icone": "🧠",
      "cor": "bg-pink-500",
      "ativo": true,
      "created_at": "2025-09-17T11:34:49.361Z",
      "updated_at": "2025-09-17T16:33:54.233Z"
    }
  ],
  "message": "Agentes encontrados",
  "timestamp": "2025-09-21T05:56:25.876Z"
}
```

## Como aplicar:
1. Abra o workflow "Lista todos Agentes" no n8n
2. Clique no nó "Prepara Json"
3. Altere o campo "data" para usar `={{ $json }}` (que é um array)
4. Salve e teste o webhook
