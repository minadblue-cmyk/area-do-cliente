# 🔍 Debug - Campo Tipo de Usuário

## ❌ **Problema:**
O campo "Tipo de Usuário" não vem preenchido quando clica para editar um usuário.

## ✅ **Solução:**
**NÃO precisamos de novo webhook!** O problema está no mapeamento dos dados.

## 🔧 **Como debugar:**

### **✅ Passo 1: Abra o console do navegador (F12)**

### **✅ Passo 2: Clique em editar um usuário**

### **✅ Passo 3: Verifique os logs no console:**

```javascript
// Logs esperados:
console.log('Usuário para edição:', {
  id: 123,
  email: "teste@email.com",
  nome: "João Silva",
  tipo: "gestor", // ← Este é o valor que vem do backend
  empresa: "Minha Empresa",
  perfil_id: 2,
  // ... outros campos
})

console.log('Tipo do usuário (raw):', "gestor", 'Tipo:', "string")

console.log('Mapeamento de tipo:', "gestor", '->', "gestor")
```

## ✅ **PROBLEMA IDENTIFICADO E CORRIGIDO!**

### **🎯 Problema encontrado:**
Os valores do backend não estavam mapeados no `tipoMap`:

```javascript
// Valores que vêm do backend:
"gestor" ✅ (já mapeado)
"usuario_comum" ❌ (não estava mapeado)
"Usuário (Padrão)" ❌ (não estava mapeado)  
"Administrador" ✅ (já mapeado)
```

### **✅ Solução aplicada:**
Adicionados os mapeamentos faltantes:

```typescript
const tipoMap: { [key: string]: string } = {
  'usuario': 'usuario',
  'gestor': 'gestor', 
  'admin': 'admin',
  'Administrador': 'admin',
  // Valores que vêm do backend:
  'usuario_comum': 'usuario', // usuario_comum -> Usuário (Padrão)
  'Usuário (Padrão)': 'usuario' // Usuário (Padrão) -> Usuário (Padrão)
}
```

## 🔧 **Correções possíveis:**

### **✅ Se o tipo vem como `null`:**
```typescript
// No backend, garantir que o campo tipo seja sempre enviado
SELECT id, email, nome, COALESCE(tipo, 'usuario') as tipo, empresa_id 
FROM users WHERE id = ?
```

### **✅ Se o tipo vem com valor diferente:**
```typescript
// Adicionar no tipoMap
const tipoMap: { [key: string]: string } = {
  'usuario': 'usuario',
  'gestor': 'gestor', 
  'admin': 'admin',
  'Gestor': 'gestor', // ← Adicionar variações
  'Administrador': 'admin',
  'Admin': 'admin', // ← Adicionar variações
  // ... outros valores
}
```

### **✅ Se o tipo vem como número:**
```typescript
// Converter para string antes do mapeamento
const tipoString = userToEdit.tipo?.toString() || 'usuario'
tipoMapeado = tipoMap[tipoString] || 'usuario'
```

## 🎯 **Teste agora:**

1. **Abra o console** (F12)
2. **Clique em editar** um usuário
3. **Verifique os logs** acima
4. **Reporte o resultado** dos logs

## 📊 **Exemplo de logs corretos:**

```javascript
Usuário para edição: {id: 123, tipo: "gestor", ...}
Tipo do usuário (raw): gestor Tipo: string
Mapeamento de tipo: gestor -> gestor
FormData a ser definido: {tipo: "gestor", ...}
```

**Com esses logs, saberemos exatamente onde está o problema!** 🎯✨
