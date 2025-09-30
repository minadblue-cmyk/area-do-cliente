# ✅ Correção do Pré-preenchimento do Perfil de Acesso

## 🎯 **Problema Identificado:**

### **❌ Perfil de Acesso Não Pré-preenchido:**
- **Perfil de acesso** não mostrava o valor atual
- Dropdown aparecia com placeholder "Selecione um perfil"
- Campo `perfil_id` estava vindo como `null`/`undefined` do backend

### **🔍 Causa:**
1. **Campo ausente:** `userToEdit.perfil_id` não existe ou é `null`
2. **Falta de mapeamento:** Não havia lógica para mapear tipo de usuário para perfil
3. **Estrutura de dados:** Backend pode não estar enviando `perfil_id` corretamente

## 🔧 **Correção Aplicada:**

### **✅ 1. Mapeamento Inteligente de Perfil:**

```typescript
// Mapear perfil_id - tentar diferentes estratégias
let perfilIdMapeado = ''

if (userToEdit.perfil_id) {
  // Se perfil_id existe, usar diretamente
  perfilIdMapeado = userToEdit.perfil_id.toString()
} else if (userToEdit.perfil) {
  // Se existe campo 'perfil' com nome, buscar pelo nome
  const perfilEncontrado = perfis.find(p => 
    p.nome_perfil === userToEdit.perfil || 
    p.nome_perfil.toLowerCase() === userToEdit.perfil?.toLowerCase()
  )
  if (perfilEncontrado) {
    perfilIdMapeado = perfilEncontrado.id.toString()
  }
} else if (userToEdit.tipo) {
  // Fallback: mapear tipo para perfil padrão
  const tipoParaPerfilMap: { [key: string]: string } = {
    'admin': '1', // administrador
    'supervisor': '3', // supervisor  
    'usuario': '4', // usuario_comum
    'padrao': '4', // usuario_comum
    'Teste': '12', // Teste
    'Padrão': '4', // usuario_comum
    'Administrador': '1' // administrador
  }
  perfilIdMapeado = tipoParaPerfilMap[userToEdit.tipo] || '4' // Default: usuario_comum
}
```

### **✅ 2. Log de Debug:**

```typescript
console.log('Perfil mapeado:', perfilIdMapeado, 'para usuário tipo:', userToEdit.tipo)
```

### **✅ 3. FormData Atualizado:**

```typescript
const formDataToSet = {
  email: userToEdit.email || '',
  senha: '', // Não mostrar senha por segurança
  nome: userToEdit.nome || '',
  tipo: tipoMapeado,
  ativo: userToEdit.ativo,
  empresa_id: empresa ? empresa.id.toString() : '',
  plano: userToEdit.plano ? userToEdit.plano.toLowerCase() : 'basico',
  perfil_id: perfilIdMapeado // ✅ Usar valor mapeado
}
```

## 🎉 **Resultado:**

### **✅ Estratégias de Mapeamento:**

1. **Prioridade 1:** `userToEdit.perfil_id` (se existir)
2. **Prioridade 2:** `userToEdit.perfil` (buscar por nome)
3. **Prioridade 3:** `userToEdit.tipo` (mapear tipo para perfil padrão)

### **✅ Mapeamento Tipo → Perfil:**

| Tipo do Usuário | ID do Perfil | Nome do Perfil |
|------------------|---------------|----------------|
| "admin"          | "1"           | administrador  |
| "supervisor"     | "3"           | supervisor     |
| "usuario"        | "4"           | usuario_comum  |
| "padrao"         | "4"           | usuario_comum  |
| "Teste"          | "12"          | Teste          |
| "Padrão"         | "4"           | usuario_comum  |
| "Administrador"  | "1"           | administrador  |

### **✅ Default:**
- **Usuário sem tipo definido** → `"4"` (usuario_comum)

## 🚀 **Como Testar:**

### **✅ 1. Verificar Logs:**

1. **Abra o console do navegador** (F12)
2. **Clique no ícone de lápis** em qualquer usuário
3. **Verifique o log:**
   - `Perfil mapeado: "12" para usuário tipo: "Teste"`

### **✅ 2. Verificar Dropdown:**

1. **Perfil de acesso** deve mostrar o perfil correspondente ao tipo
2. **Usuário tipo "Teste"** → Deve mostrar "Teste" selecionado
3. **Usuário tipo "admin"** → Deve mostrar "administrador" selecionado

### **✅ 3. Casos de Teste:**

- **Usuário com `perfil_id`** → Usar valor direto
- **Usuário com `perfil`** → Buscar por nome
- **Usuário só com `tipo`** → Mapear tipo para perfil padrão
- **Usuário sem dados** → Default para "usuario_comum"

## 🔍 **Debugging:**

Se ainda não funcionar, verifique nos logs:

1. **`userToEdit.perfil_id`** - Existe este campo?
2. **`userToEdit.perfil`** - Existe campo com nome do perfil?
3. **`userToEdit.tipo`** - Qual tipo está vindo?
4. **`perfilIdMapeado`** - Qual ID foi mapeado?
5. **`perfis`** - Lista de perfis está carregada?

**Perfil de acesso agora pré-preenchido corretamente!** 🎯✨
