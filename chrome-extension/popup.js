// Popup script para controlar a extensão
let isMonitoring = false;
let lastStatus = null;

// Elementos DOM
const startBtn = document.getElementById('startBtn');
const stopBtn = document.getElementById('stopBtn');
const checkNowBtn = document.getElementById('checkNowBtn');
const checkFrontendBtn = document.getElementById('checkFrontendBtn');
const statusIndicator = document.getElementById('statusIndicator');
const statusDot = document.getElementById('statusDot');
const statusText = document.getElementById('statusText');
const currentStatus = document.getElementById('currentStatus');
const lastCheck = document.getElementById('lastCheck');
const interval = document.getElementById('interval');

// Configurações
const soundEnabled = document.getElementById('soundEnabled');
const notificationsEnabled = document.getElementById('notificationsEnabled');
const checkInterval = document.getElementById('checkInterval');

// Inicializar popup
document.addEventListener('DOMContentLoaded', async () => {
  console.log('🚀 Popup carregado');
  
  // Carregar configurações
  await loadSettings();
  
  // Verificar status atual
  await updateStatus();
  
  // Configurar event listeners
  setupEventListeners();
});

// Carregar configurações salvas
async function loadSettings() {
  try {
    const config = await chrome.storage.sync.get({
      soundEnabled: true,
      notificationsEnabled: true,
      checkInterval: 10000
    });
    
    soundEnabled.checked = config.soundEnabled;
    notificationsEnabled.checked = config.notificationsEnabled;
    checkInterval.value = config.checkInterval;
    
    // Atualizar texto do intervalo
    updateIntervalText();
    
  } catch (error) {
    console.error('❌ Erro ao carregar configurações:', error);
  }
}

// Salvar configurações
async function saveSettings() {
  try {
    const config = {
      soundEnabled: soundEnabled.checked,
      notificationsEnabled: notificationsEnabled.checked,
      checkInterval: parseInt(checkInterval.value)
    };
    
    await chrome.storage.sync.set(config);
    console.log('✅ Configurações salvas');
    
  } catch (error) {
    console.error('❌ Erro ao salvar configurações:', error);
  }
}

// Atualizar status da extensão
async function updateStatus() {
  try {
    const response = await chrome.runtime.sendMessage({ action: 'getStatus' });
    
    isMonitoring = response.isMonitoring;
    lastStatus = response.lastStatus;
    
    // Atualizar botões
    startBtn.disabled = isMonitoring;
    stopBtn.disabled = !isMonitoring;
    
    // Atualizar indicador de status
    updateStatusIndicator();
    
    // Atualizar informações
    currentStatus.textContent = lastStatus || '-';
    lastCheck.textContent = new Date().toLocaleTimeString();
    
  } catch (error) {
    console.error('❌ Erro ao atualizar status:', error);
  }
}

// Atualizar indicador de status
function updateStatusIndicator() {
  if (isMonitoring) {
    statusDot.className = 'status-dot active';
    statusText.textContent = 'Monitorando';
  } else {
    statusDot.className = 'status-dot';
    statusText.textContent = 'Desconectado';
  }
}

// Atualizar texto do intervalo
function updateIntervalText() {
  const value = parseInt(checkInterval.value);
  const seconds = value / 1000;
  interval.textContent = `${seconds}s`;
}

// Configurar event listeners
function setupEventListeners() {
  // Botão iniciar
  startBtn.addEventListener('click', async () => {
    try {
      await chrome.runtime.sendMessage({ action: 'startMonitoring' });
      await updateStatus();
      showMessage('✅ Monitoramento iniciado!', 'success');
    } catch (error) {
      console.error('❌ Erro ao iniciar monitoramento:', error);
      showMessage('❌ Erro ao iniciar monitoramento', 'error');
    }
  });
  
  // Botão parar
  stopBtn.addEventListener('click', async () => {
    try {
      await chrome.runtime.sendMessage({ action: 'stopMonitoring' });
      await updateStatus();
      showMessage('🛑 Monitoramento parado!', 'info');
    } catch (error) {
      console.error('❌ Erro ao parar monitoramento:', error);
      showMessage('❌ Erro ao parar monitoramento', 'error');
    }
  });
  
  // Botão verificar agora
  checkNowBtn.addEventListener('click', async () => {
    try {
      await chrome.runtime.sendMessage({ action: 'checkNow' });
      await updateStatus();
      showMessage('🔍 Verificação executada!', 'info');
    } catch (error) {
      console.error('❌ Erro ao verificar:', error);
      showMessage('❌ Erro ao verificar status', 'error');
    }
  });
  
  // Botão verificar frontend
  checkFrontendBtn.addEventListener('click', async () => {
    try {
      const response = await chrome.runtime.sendMessage({ action: 'checkFrontend' });
      console.log('🖥️ Resposta do frontend:', response);
      
      if (response && response.status) {
        showMessage(`🖥️ Frontend: ${response.status}`, 'info');
        await updateStatus();
      } else {
        showMessage('❌ Frontend não encontrado', 'error');
      }
    } catch (error) {
      console.error('❌ Erro ao verificar frontend:', error);
      showMessage('❌ Erro ao verificar frontend', 'error');
    }
  });
  
  // Configurações
  soundEnabled.addEventListener('change', saveSettings);
  notificationsEnabled.addEventListener('change', saveSettings);
  checkInterval.addEventListener('change', () => {
    saveSettings();
    updateIntervalText();
  });
}

// Mostrar mensagem temporária
function showMessage(text, type = 'info') {
  // Criar elemento de mensagem
  const message = document.createElement('div');
  message.className = `message message-${type}`;
  message.textContent = text;
  
  // Adicionar ao container
  const container = document.querySelector('.container');
  container.appendChild(message);
  
  // Remover após 3 segundos
  setTimeout(() => {
    if (message.parentNode) {
      message.parentNode.removeChild(message);
    }
  }, 3000);
}

// Atualizar status a cada segundo quando monitorando
setInterval(() => {
  if (isMonitoring) {
    updateStatus();
  }
}, 1000);
