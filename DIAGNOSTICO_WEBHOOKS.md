# 🔍 DIAGNÓSTICO DOS WEBHOOKS

## 📊 **STATUS ATUAL:**

### **✅ FUNCIONANDO:**
- **`list-agentes`** - Status 200, retorna dados corretos
- **`create-agente`** - Status 200, mas executa workflow errado

### **❌ COM PROBLEMAS:**
- **`delete-agente`** - Status 500 (Internal Server Error)

## 🎯 **PROBLEMAS IDENTIFICADOS:**

### **1. CREATE-AGENTE:**
- **Status:** 200 ✅
- **Problema:** Executa workflow de execução de agente em vez de criação
- **Sintoma:** Retorna dados de workflow complexo com Redis, PostgreSQL, etc.
- **Causa:** Webhook configurado para workflow errado

### **2. DELETE-AGENTE:**
- **Status:** 500 ❌
- **Problema:** Internal Server Error
- **Sintoma:** Retorna HTML de erro
- **Causa:** Workflow não existe ou não está ativo

## 🔧 **SOLUÇÕES NECESSÁRIAS:**

### **1. CORRIGIR CREATE-AGENTE:**
- Importar workflow `create-agente-workflow-original-restaurado.json`
- Ativar o workflow no n8n
- Configurar credenciais PostgreSQL e n8nApi
- Testar criação de agente

### **2. CORRIGIR DELETE-AGENTE:**
- Importar workflow `delete-agente-workflow-por-nome.json`
- Ativar o workflow no n8n
- Configurar credenciais PostgreSQL e n8nApi
- Testar deleção de agente

## 📁 **ARQUIVOS PRONTOS:**

### **CREATE-AGENTE:**
- `create-agente-workflow-original-restaurado.json` - Workflow funcional
- `test-create-agente-real.js` - Script de teste

### **DELETE-AGENTE:**
- `delete-agente-workflow-por-nome.json` - Workflow funcional
- `test-delete-agente-por-nome.js` - Script de teste

### **LIST-AGENTES:**
- `list-agentes-workflow-backup-funcional.json` - Backup funcional
- `test-list-agentes-final.js` - Script de teste

## 🚀 **PRÓXIMOS PASSOS:**

1. **Importar** os workflows corretos no n8n
2. **Configurar** credenciais (PostgreSQL, n8nApi)
3. **Ativar** os workflows
4. **Testar** criação e deleção de agentes
5. **Verificar** se os workflows são clonados corretamente

## 📋 **CHECKLIST:**

- [ ] Importar `create-agente-workflow-original-restaurado.json`
- [ ] Importar `delete-agente-workflow-por-nome.json`
- [ ] Configurar credenciais PostgreSQL
- [ ] Configurar credenciais n8nApi
- [ ] Ativar workflows
- [ ] Testar criação de agente
- [ ] Testar deleção de agente
- [ ] Verificar clonagem de workflows

---
**Status:** 🔧 PRECISA DE CONFIGURAÇÃO  
**Prioridade:** 🚨 ALTA  
**Complexidade:** 📊 MÉDIA
