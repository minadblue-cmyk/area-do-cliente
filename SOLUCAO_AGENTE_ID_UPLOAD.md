# ✅ Solução: Incluir agente_id no Upload de Leads

## 🎯 **Problema Identificado:**

### **❌ agente_id não disponível no fluxo de upload:**
- O frontend não envia `agente_id` no payload de upload
- O n8n não tem como saber qual agente usar para os leads
- Necessário incluir `agente_id` baseado no perfil do usuário

## 🔧 **Solução Proposta:**

### **✅ 1. Modificar Frontend (Upload/index.tsx):**

```typescript
// Função para obter agente_id do usuário logado
async function getAgenteIdForUser(userId: number): Promise<number | null> {
  try {
    // Carregar atribuições de agentes
    await loadAgentesAtribuicoes()
    
    // Encontrar agente atribuído para o usuário
    const atribuicao = agentesAtribuicoes.find(a => a.usuario_id === userId)
    
    if (atribuicao) {
      console.log(`✅ Agente encontrado para usuário ${userId}:`, atribuicao.agente_id)
      return atribuicao.agente_id
    }
    
    console.log(`⚠️ Nenhum agente atribuído para usuário ${userId}`)
    return null
  } catch (error) {
    console.error('❌ Erro ao buscar agente_id:', error)
    return null
  }
}

// Modificar função de upload
async function handleUpload() {
  if (!file || !userData || extractedData.length === 0) return
  
  setUploading(true)
  try {
    // Obter agente_id do usuário
    const agenteId = await getAgenteIdForUser(parseInt(userData.id))
    
    if (!agenteId) {
      push({ 
        kind: 'error', 
        message: 'Nenhum agente atribuído para seu usuário. Entre em contato com o administrador.' 
      })
      return
    }
    
    // Criar payload com agente_id
    const payload = {
      // Dados do usuário logado
      logged_user: {
        id: userData.id,
        name: userData.name,
        email: userData.mail
      },
      // Dados extraídos do Excel
      data: extractedData,
      // ✅ AGENTE_ID INCLUÍDO
      agente_id: agenteId,
      // Metadados do arquivo
      file_info: {
        name: file.name,
        size: file.size,
        type: file.type,
        lastModified: file.lastModified
      }
    }

    console.log('📦 Payload de upload com agente_id:', payload)

    await callWebhook('webhook-upload', { 
      method: 'POST', 
      data: payload,
      headers: {
        'Content-Type': 'application/json'
      }
    })
    
    // ... resto da função
  } catch (error) {
    console.error('❌ Erro no upload:', error)
    push({ kind: 'error', message: 'Erro ao fazer upload do arquivo.' })
  } finally {
    setUploading(false)
  }
}
```

### **✅ 2. Modificar n8n - Processar agente_id:**

```javascript
// No n8n, modificar o processamento dos dados
return items.map(item => {
  const json = item.json || {}
  
  // Obter agente_id do payload principal
  const agenteId = json.agente_id || json.logged_user?.agente_id || 81 // fallback
  
  // Processar cada lead com agente_id
  return json.data.map(lead => ({
    json: {
      ...lead,
      agente_id: agenteId,  // ✅ AGENTE_ID INCLUÍDO
      client_id: json.logged_user?.id || 1, // usar ID do usuário como client_id
      data_processamento: new Date().toISOString()
    }
  }))
})
```

### **✅ 3. Query SQL Atualizada (já corrigida):**

```sql
INSERT INTO public.lead (
  telefone, nome, canal, estagio_funnel, pergunta_index,
  data_criacao, data_ultima_interacao, client_id,
  nome_cliente, fonte_prospec, idade, profissao, estado_civil,
  filhos, qtd_filhos, data_insercao, status, agente_id  -- ✅ INCLUÍDO
)
VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18
)
ON CONFLICT (telefone, client_id) DO UPDATE
SET
  -- ... outros campos ...
  agente_id = COALESCE(EXCLUDED.agente_id, lead.agente_id)  -- ✅ INCLUÍDO
RETURNING *;
```

### **✅ 4. Parâmetros Atualizados:**

```
{{$json.telefone}}, 
{{$json.nome}}, 
{{$json.canal || 'whatsapp'}}, 
{{$json.estagio_funnel || 'topo'}}, 
{{$json.pergunta_index !== undefined && $json.pergunta_index !== null ? $json.pergunta_index : 0}}, 
{{$json.data_processamento || $now.toISO()}}, 
{{$json.data_processamento || $now.toISO()}}, 
{{$json.client_id}}, 
{{$json.nome_cliente || $json.nome}}, 
{{$json.fonte_prospec}}, 
{{$json.idade}}, 
{{$json.profissao}}, 
{{$json.estado_civil}}, 
{{$json.filhos}}, 
{{$json.qtd_filhos}}, 
{{$json.data_processamento}}, 
{{$json.status || 'novo'}}, 
{{$json.agente_id}}  -- ✅ AGENTE_ID DO PAYLOAD
```

## 🎉 **Resultado Esperado:**

### **✅ Payload de Upload:**
```json
{
  "logged_user": {
    "id": "6",
    "name": "Usuário Elleve Padrão",
    "email": "rmacedo2005@hotmail.com"
  },
  "agente_id": 81,  // ✅ INCLUÍDO
  "data": [
    {
      "nome": "Roger Macedo da Silva",
      "telefone": "5551984033242",
      "profissao": "Analista de Suporte",
      // ... outros campos
    }
  ],
  "file_info": {
    "name": "leads.xlsx",
    "size": 12345,
    "type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  }
}
```

### **✅ Lead Inserido:**
```json
{
  "id": 16015,
  "nome": "Roger Macedo da Silva",
  "telefone": "5551984033242",
  "client_id": 6,
  "agente_id": 81,  // ✅ CORRETO
  "status": "new"
}
```

## 🚀 **Implementação:**

1. **Frontend:** Modificar `src/pages/Upload/index.tsx` para incluir `agente_id`
2. **n8n:** Atualizar processamento para usar `agente_id` do payload
3. **Teste:** Fazer upload e verificar se `agente_id` é inserido corretamente

**Agora o agente_id será incluído automaticamente baseado no perfil do usuário! 🚀**
