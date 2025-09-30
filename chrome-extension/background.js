// Background script para monitorar o agente
let monitoringInterval = null;
let lastStatus = null;
let isMonitoring = false;

// Configurações padrão
const defaultConfig = {
  checkInterval: 10000, // 10 segundos
  webhookUrl: 'https://n8n.code-iq.com.br/webhook/status-agente1',
  userId: '5', // ID do usuário padrão
  soundEnabled: true,
  notificationsEnabled: true
};

// Inicializar configurações
chrome.runtime.onInstalled.addListener(async () => {
  const config = await chrome.storage.sync.get(defaultConfig);
  await chrome.storage.sync.set(config);
  console.log('🚀 Agente SDR Monitor instalado!');
});

// Função para verificar status do agente
async function checkAgentStatus() {
  try {
    console.log('🔍 Verificando status do agente...');
    
    // Primeiro, tentar verificar via frontend (mais confiável)
    const frontendStatus = await checkFrontendStatus();
    console.log('🖥️ Status do frontend:', frontendStatus);
    
    let currentStatus = 'stopped';
    
    if (frontendStatus) {
      currentStatus = frontendStatus;
    } else {
      // Fallback: verificar via webhook
      console.log('📡 Verificando via webhook...');
      const config = await chrome.storage.sync.get(defaultConfig);
      
      const response = await fetch(config.webhookUrl, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer nLijfP9VBU5MqfyfspK5gYGcnBv0Mt6DmIO9GuEz'
        }
      });

      console.log('📥 Resposta webhook:', response.status, response.statusText);

      if (response.ok) {
        const data = await response.text();
        console.log('📄 Dados webhook:', data);
        
        if (data && data.trim() !== '') {
          try {
            const jsonData = JSON.parse(data);
            console.log('📊 JSON webhook:', jsonData);
            
            if (jsonData && (jsonData.length > 0 || jsonData.status === 'running')) {
              currentStatus = 'running';
            }
          } catch (e) {
            if (data.trim().length > 0) {
              currentStatus = 'running';
            }
          }
        }
      }
    }
    
    console.log(`🎯 Status final detectado: ${currentStatus}`);
    
    // Verificar se houve mudança de status
    if (lastStatus && lastStatus !== currentStatus) {
      console.log(`📢 Mudança detectada: ${lastStatus} → ${currentStatus}`);
      
      if (currentStatus === 'stopped') {
        await showAgentStoppedAlert();
      } else if (currentStatus === 'running') {
        await showAgentStartedAlert();
      }
    }
    
    lastStatus = currentStatus;
    
    // Atualizar badge
    await updateBadge(currentStatus);
    
  } catch (error) {
    console.error('❌ Erro ao verificar status:', error);
    await updateBadge('error');
  }
}

// Função para mostrar alerta quando agente para
async function showAgentStoppedAlert() {
  const config = await chrome.storage.sync.get(defaultConfig);
  
  if (config.notificationsEnabled) {
    chrome.notifications.create({
      type: 'basic',
      iconUrl: 'icons/icon48.png',
      title: '🛑 Agente Parou!',
      message: 'O agente SDR finalizou a execução.',
      priority: 2
    });
  }
  
  if (config.soundEnabled) {
    // Tocar som de alerta
    chrome.tabs.query({active: true, currentWindow: true}, (tabs) => {
      chrome.scripting.executeScript({
        target: { tabId: tabs[0].id },
        function: playAlertSound
      });
    });
  }
}

// Função para mostrar alerta quando agente inicia
async function showAgentStartedAlert() {
  const config = await chrome.storage.sync.get(defaultConfig);
  
  if (config.notificationsEnabled) {
    chrome.notifications.create({
      type: 'basic',
      iconUrl: 'icons/icon48.png',
      title: '▶️ Agente Iniciou!',
      message: 'O agente SDR começou a executar.',
      priority: 1
    });
  }
}

// Função para atualizar badge
async function updateBadge(status) {
  const badgeConfig = {
    'running': { text: '▶', color: '#10b981' },
    'stopped': { text: '⏹', color: '#ef4444' },
    'error': { text: '!', color: '#f59e0b' }
  };
  
  const config = badgeConfig[status] || { text: '?', color: '#6b7280' };
  
  chrome.action.setBadgeText({ text: config.text });
  chrome.action.setBadgeBackgroundColor({ color: config.color });
}

// Função para tocar som (executada na página)
function playAlertSound() {
  const audio = new Audio('data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmwhBSuBzvLZiTYIG2m98OScTgwOUarm7blmGgU7k9n1unEiBS13yO/eizEIHWq+8+OWT');
  audio.play();
}

// Função para iniciar monitoramento
async function startMonitoring() {
  if (isMonitoring) return;
  
  isMonitoring = true;
  console.log('🚀 Iniciando monitoramento do agente...');
  
  const config = await chrome.storage.sync.get(defaultConfig);
  monitoringInterval = setInterval(checkAgentStatus, config.checkInterval);
  
  // Verificação inicial
  await checkAgentStatus();
}

// Função para parar monitoramento
function stopMonitoring() {
  if (!isMonitoring) return;
  
  isMonitoring = false;
  console.log('🛑 Parando monitoramento do agente...');
  
  if (monitoringInterval) {
    clearInterval(monitoringInterval);
    monitoringInterval = null;
  }
  
  chrome.action.setBadgeText({ text: '' });
}

// Função para verificar status via localStorage do frontend
async function checkFrontendStatus() {
  try {
    console.log('🔍 Buscando abas do frontend...');
    
    // Buscar todas as abas ativas
    const allTabs = await chrome.tabs.query({});
    console.log('📋 Total de abas:', allTabs.length);
    
    // Filtrar abas do localhost
    const localhostTabs = allTabs.filter(tab => 
      tab.url && (
        tab.url.includes('localhost:5173') || 
        tab.url.includes('127.0.0.1:5173') ||
        tab.url.includes('localhost') && tab.url.includes('5173')
      )
    );
    
    console.log('🏠 Abas localhost encontradas:', localhostTabs.length);
    localhostTabs.forEach(tab => console.log('  -', tab.url));
    
    if (localhostTabs.length === 0) {
      console.log('❌ Nenhuma aba do frontend encontrada');
      return null;
    }
    
    // Tentar em cada aba encontrada
    for (const tab of localhostTabs) {
      try {
        console.log(`🔍 Verificando aba: ${tab.url}`);
        
        // Executar script na aba do frontend para obter status
        const results = await chrome.scripting.executeScript({
          target: { tabId: tab.id },
          function: () => {
            try {
              console.log('🖥️ Executando script no frontend...');
              
              // Buscar dados do localStorage
              const agentData = localStorage.getItem('agentStatus');
              console.log('📄 agentStatus no localStorage:', agentData);
              
              if (!agentData) {
                return { status: 'stopped', reason: 'No agentStatus in localStorage' };
              }
              
              const agents = JSON.parse(agentData);
              console.log('📊 Agents parsed:', agents);
              
              // Verificar se há algum agente rodando
              for (const [key, agent] of Object.entries(agents)) {
                console.log(`🔍 Verificando agente ${key}:`, agent);
                if (agent.status === 'running') {
                  return { status: 'running', agent: agent, key: key };
                }
              }
              
              return { status: 'stopped', agents: agents };
            } catch (error) {
              console.error('❌ Erro ao verificar localStorage:', error);
              return { status: 'error', error: error.message };
            }
          }
        });
        
        if (results && results[0] && results[0].result) {
          const frontendStatus = results[0].result;
          console.log('🖥️ Status do frontend:', frontendStatus);
          return frontendStatus.status;
        }
      } catch (error) {
        console.log(`❌ Erro na aba ${tab.url}:`, error);
        continue;
      }
    }
    
    console.log('❌ Nenhuma aba válida encontrada');
    return null;
  } catch (error) {
    console.error('❌ Erro ao verificar frontend:', error);
    return null;
  }
}

// Escutar mensagens do popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  switch (request.action) {
    case 'startMonitoring':
      startMonitoring();
      sendResponse({ success: true });
      break;
      
    case 'stopMonitoring':
      stopMonitoring();
      sendResponse({ success: true });
      break;
      
    case 'getStatus':
      sendResponse({ 
        isMonitoring,
        lastStatus,
        config: defaultConfig
      });
      break;
      
    case 'checkNow':
      checkAgentStatus();
      sendResponse({ success: true });
      break;
      
    case 'checkFrontend':
      checkFrontendStatus().then(status => {
        sendResponse({ status });
      });
      return true; // Resposta assíncrona
  }
  
  return true;
});

// Manter o service worker ativo
chrome.runtime.onStartup.addListener(() => {
  console.log('🔄 Service worker iniciado');
});
