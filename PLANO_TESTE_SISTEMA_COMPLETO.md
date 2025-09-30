# 🧪 Plano de Teste Completo do Sistema

## 🎯 Objetivo
Confirmar o funcionamento total dos agentes e lista de prospecção com diferentes usuários antes de implementar o sistema de recontato.

## 📋 Scripts de Teste Criados

### **1. Análise Inicial do Sistema**
- **`teste-sistema-completo-usuarios.sql`** - Verifica usuários, agentes e leads disponíveis

### **2. Testes de Webhook Start**
- **`teste-webhook-start-usuario-6.ps1`** - Testa reserva de leads para usuário 6 (agente 5)
- **`teste-webhook-start-usuario-7.ps1`** - Testa reserva de leads para usuário 7 (agente 6)

### **3. Testes de Lista de Prospecção**
- **`teste-lista-prospeccao-usuario-6.ps1`** - Testa lista do usuário 6
- **`teste-lista-prospeccao-usuario-7.ps1`** - Testa lista do usuário 7

### **4. Verificação Final**
- **`verificar-leads-reservados-apos-testes.sql`** - Analisa resultados dos testes

## 🚀 Ordem de Execução

### **Passo 1: Análise Inicial**
```sql
-- Execute: teste-sistema-completo-usuarios.sql
```
**Verificar:**
- ✅ Usuários e agentes disponíveis
- ✅ Leads disponíveis para teste
- ✅ Leads já reservados
- ✅ Permissões de acesso

### **Passo 2: Teste Webhook Start - Usuário 6**
```powershell
# Execute: teste-webhook-start-usuario-6.ps1
```
**Verificar:**
- ✅ Leads reservados para agente 5
- ✅ Permissões criadas corretamente
- ✅ Campo `contatado` definido como `true`

### **Passo 3: Teste Webhook Start - Usuário 7**
```powershell
# Execute: teste-webhook-start-usuario-7.ps1
```
**Verificar:**
- ✅ Leads reservados para agente 6
- ✅ Isolamento entre agentes
- ✅ Permissões específicas do usuário

### **Passo 4: Teste Lista de Prospecção - Usuário 6**
```powershell
# Execute: teste-lista-prospeccao-usuario-6.ps1
```
**Verificar:**
- ✅ Lista retorna apenas leads do agente 5
- ✅ Campo `contatado` = `true`
- ✅ Permissões respeitadas

### **Passo 5: Teste Lista de Prospecção - Usuário 7**
```powershell
# Execute: teste-lista-prospeccao-usuario-7.ps1
```
**Verificar:**
- ✅ Lista retorna apenas leads do agente 6
- ✅ Isolamento total entre usuários
- ✅ Dados corretos

### **Passo 6: Verificação Final**
```sql
-- Execute: verificar-leads-reservados-apos-testes.sql
```
**Verificar:**
- ✅ Isolamento entre agentes
- ✅ Permissões funcionando
- ✅ Campo `contatado` correto
- ✅ Leads disponíveis para novos agentes

## 🔍 Critérios de Sucesso

### **✅ Webhook Start**
- [ ] Leads reservados corretamente por agente
- [ ] Permissões de acesso criadas
- [ ] Campo `contatado` definido como `true`
- [ ] Isolamento entre agentes

### **✅ Lista de Prospecção**
- [ ] Retorna apenas leads do agente correto
- [ ] Campo `contatado` = `true` em todos os leads
- [ ] Permissões respeitadas
- [ ] Dados completos e corretos

### **✅ Sistema Geral**
- [ ] Isolamento total entre usuários
- [ ] Performance adequada
- [ ] Sem erros de permissão
- [ ] Fluxo completo funcionando

## 🚨 Pontos de Atenção

1. **Isolamento de Dados**: Cada agente deve ver apenas seus leads
2. **Campo Contatado**: Deve ser `true` em todos os leads da lista
3. **Permissões**: Devem ser criadas e respeitadas corretamente
4. **Performance**: Queries devem executar rapidamente
5. **Consistência**: Dados devem estar consistentes entre webhook e lista

## 📊 Relatório de Teste

Após executar todos os testes, documentar:
- ✅ **Sucessos**: O que funcionou perfeitamente
- ⚠️ **Problemas**: Issues encontrados e soluções
- 📈 **Performance**: Tempo de resposta das queries
- 🔒 **Segurança**: Isolamento e permissões funcionando

## 🎯 Próximo Passo

Se todos os testes passarem, podemos prosseguir com a implementação do sistema de recontato manual.
