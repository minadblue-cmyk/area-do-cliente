# 📋 Configuração do Fluxo de Edição de Empresas

## 🎯 **OBJETIVO**
Configurar o fluxo completo de edição de empresas no n8n, incluindo listagem, busca por ID e atualização.

## 📝 **SCRIPTS SQL CRIADOS**

### **1. Adicionar campo `updated_at`**
- **Arquivo:** `35_adicionar_updated_at.sql`
- **Função:** Adiciona campo de timestamp de atualização
- **Execute primeiro** este script no PostgreSQL

### **2. Query de Atualização**
- **Arquivo:** `34_query_update_empresa.sql`
- **Função:** Query SQL para atualizar empresa
- **Parâmetros:** 22 parâmetros ($1 a $22)

### **3. Query de Listagem**
- **Arquivo:** `36_query_list_empresas.sql`
- **Função:** Listar todas as empresas
- **Status:** ✅ Funcionando

### **4. Query de Busca por ID**
- **Arquivo:** `37_query_get_empresa_by_id.sql`
- **Função:** Buscar empresa específica por ID
- **Parâmetro:** $1 = {{ $json.body.id }}

## 🔧 **CONFIGURAÇÃO NO N8N**

### **Webhook de Edição:**
- **URL:** `https://n8n.code-iq.com.br/webhook/edit-company`
- **Método:** POST
- **Status:** ⚠️ Retorna resposta vazia

### **Webhook de Listagem:**
- **URL:** `https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-company`
- **Método:** GET
- **Status:** ✅ Funcionando

## 🛠️ **PASSOS PARA CONFIGURAR**

### **1. Execute os Scripts SQL:**
```sql
-- Execute em ordem:
35_adicionar_updated_at.sql
```

### **2. Configure o n8n:**
- **Node PostgreSQL** para edição
- **Operation:** Update ou Execute Query
- **Query:** Use `34_query_update_empresa.sql`
- **Parâmetros:** Configure os 22 parâmetros

### **3. Teste o Fluxo:**
- Listar empresas ✅
- Buscar por ID ⚠️
- Editar empresa ⚠️

## 🎯 **PRÓXIMOS PASSOS**

1. **Configurar webhook de busca por ID**
2. **Corrigir webhook de edição**
3. **Testar fluxo completo**
4. **Integrar com frontend**

## 📊 **STATUS ATUAL**

- ✅ **Criação de empresas:** Funcionando
- ✅ **Listagem de empresas:** Funcionando
- ⚠️ **Edição de empresas:** Precisa configuração
- ⚠️ **Busca por ID:** Precisa implementar
