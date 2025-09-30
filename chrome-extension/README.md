# 🤖 Agente SDR Monitor - Extensão Chrome

Uma extensão para Chrome que monitora o status do agente SDR em tempo real e alerta quando a execução para.

## 🚀 Funcionalidades

- **Monitoramento em tempo real** do status do agente
- **Alertas visuais e sonoros** quando o agente para
- **Notificações do sistema** para avisos importantes
- **Badge no ícone** da extensão mostrando status atual
- **Configurações personalizáveis** (intervalo, sons, notificações)
- **Interface intuitiva** no popup da extensão

## 📦 Instalação

### 1. Preparar os ícones
Você precisa criar os ícones da extensão nas seguintes resoluções:
- `icons/icon16.png` (16x16px)
- `icons/icon32.png` (32x32px) 
- `icons/icon48.png` (48x48px)
- `icons/icon128.png` (128x128px)

### 2. Instalar no Chrome
1. Abra o Chrome e vá para `chrome://extensions/`
2. Ative o "Modo do desenvolvedor" (canto superior direito)
3. Clique em "Carregar sem compactação"
4. Selecione a pasta `chrome-extension`
5. A extensão será instalada e aparecerá na barra de ferramentas

## ⚙️ Configuração

### Configurações Padrão
- **Intervalo de verificação:** 10 segundos
- **Webhook URL:** `https://n8n.code-iq.com.br/webhook/status-agente1`
- **Usuário ID:** 5 (padrão)
- **Som habilitado:** Sim
- **Notificações habilitadas:** Sim

### Personalizar Configurações
1. Clique no ícone da extensão
2. Ajuste as configurações no popup:
   - Intervalo de verificação (5s a 1min)
   - Habilitar/desabilitar som
   - Habilitar/desabilitar notificações

## 🎯 Como Usar

### 1. Iniciar Monitoramento
- Clique no ícone da extensão
- Clique em "▶️ Iniciar Monitoramento"
- O badge ficará verde com "▶" quando monitorando

### 2. Status do Agente
- **Verde (▶):** Agente rodando
- **Vermelho (⏹):** Agente parado
- **Amarelo (!):** Erro na verificação

### 3. Alertas
- **Notificação:** Aparece quando agente para/inicia
- **Som:** Toca um beep quando agente para
- **Badge:** Muda cor conforme status

## 🔧 Arquivos da Extensão

```
chrome-extension/
├── manifest.json          # Configuração da extensão
├── background.js          # Script de monitoramento
├── popup.html             # Interface do popup
├── popup.js               # Lógica do popup
├── styles.css             # Estilos do popup
├── icons/                 # Ícones da extensão
│   ├── icon16.png
│   ├── icon32.png
│   ├── icon48.png
│   └── icon128.png
└── README.md              # Este arquivo
```

## 🛠️ Desenvolvimento

### Modificar Configurações
Edite o arquivo `background.js` na seção `defaultConfig`:

```javascript
const defaultConfig = {
  checkInterval: 10000, // Intervalo em ms
  webhookUrl: 'https://n8n.code-iq.com.br/webhook/status-agente1',
  userId: '5',
  soundEnabled: true,
  notificationsEnabled: true
};
```

### Adicionar Novos Alertas
Modifique as funções `showAgentStoppedAlert()` e `showAgentStartedAlert()` no `background.js`.

### Personalizar Interface
Edite os arquivos `popup.html`, `popup.js` e `styles.css` para modificar a interface.

## 🐛 Solução de Problemas

### Extensão não monitora
- Verifique se o webhook está funcionando
- Confirme as permissões da extensão
- Verifique o console do Chrome (F12)

### Alertas não funcionam
- Verifique se as notificações estão habilitadas
- Confirme as permissões de notificação
- Teste o som do navegador

### Badge não atualiza
- Recarregue a extensão
- Verifique o console para erros
- Confirme a conexão com o webhook

## 📝 Logs

A extensão registra logs no console do Chrome:
- `🚀` - Inicialização
- `🔍` - Verificação de status
- `📢` - Mudança de status
- `✅` - Sucesso
- `❌` - Erro

Para ver os logs:
1. Vá para `chrome://extensions/`
2. Clique em "Detalhes" na extensão
3. Clique em "Inspecionar visualizações: background page"

## 🔄 Atualizações

Para atualizar a extensão:
1. Modifique os arquivos necessários
2. Vá para `chrome://extensions/`
3. Clique no botão de atualizar (🔄) na extensão

## 📞 Suporte

Para suporte ou sugestões, verifique:
- Console do Chrome para erros
- Logs da extensão
- Status do webhook n8n
- Configurações da extensão
