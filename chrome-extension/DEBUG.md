# 🔍 DEBUG DA EXTENSÃO

## ❌ PROBLEMA ATUAL
- Extensão mostra "Frontend não encontrado"
- Não consegue acessar a aba localhost:5173

## 🔧 CORREÇÕES APLICADAS

### 1. Permissões Adicionadas
- `http://localhost:*/*`
- `https://localhost:*/*`
- `scripting`
- `tabs`

### 2. Busca Melhorada
- Busca todas as abas primeiro
- Filtra por localhost:5173
- Logs detalhados

## 🚀 COMO TESTAR

### Passo 1: Recarregar Extensão
1. Vá para `chrome://extensions/`
2. Clique no botão de atualizar (🔄) na extensão
3. Confirme que não há erros

### Passo 2: Verificar Logs
1. Vá para `chrome://extensions/`
2. Clique em "Detalhes" na extensão
3. Clique em "Inspecionar visualizações: background page"
4. Abra o Console (F12)

### Passo 3: Testar Frontend
1. Abra a extensão (clique no ícone)
2. Clique em "Verificar Frontend"
3. Verifique os logs no console

### Passo 4: Verificar Abas
No console da extensão, você deve ver:
```
🔍 Buscando abas do frontend...
📋 Total de abas: X
🏠 Abas localhost encontradas: 1
  - http://localhost:5173/upload
```

## 🐛 SE AINDA NÃO FUNCIONAR

### Verificar Permissões
1. Vá para `chrome://extensions/`
2. Clique em "Detalhes" na extensão
3. Verifique se as permissões estão corretas:
   - ✅ Acessar dados do site
   - ✅ Gerenciar abas
   - ✅ Executar scripts

### Verificar URL
- Certifique-se de que está em `http://localhost:5173/upload`
- Não use `https://` (use `http://`)

### Verificar localStorage
1. Abra o DevTools da página (F12)
2. Vá para Application > Local Storage
3. Verifique se existe `agentStatus`

## 📞 PRÓXIMOS PASSOS
Se ainda não funcionar, me envie:
1. Screenshot dos logs do console da extensão
2. Screenshot das permissões da extensão
3. URL exata da página
