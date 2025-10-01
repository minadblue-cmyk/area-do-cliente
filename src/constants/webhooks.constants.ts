export interface WebhookCfg {
  id: string;
  name: string;
  url: string;
}

// URLs base dos serviços - com fallback para ambiente de produção
const N8N_LAVO_URL = import.meta.env.VITE_N8N_LAVO_URL || 'https://n8n-lavo-n8n.15gxno.easypanel.host'
const N8N_CODE_IQ_URL = import.meta.env.VITE_N8N_CODE_IQ_URL || 'https://n8n.code-iq.com.br'

// ============================================================================
// WEBHOOKS ESSENCIAIS - APENAS OS NECESSÁRIOS
// ============================================================================

export const WEBHOOKS: WebhookCfg[] = [
  // 🔐 AUTENTICAÇÃO E USUÁRIOS - CONFIRMADOS
  { 
    id: 'webhook/list-users', 
    name: 'Listar Usuários', 
    url: `${N8N_LAVO_URL}/webhook/list-users` 
  },
  { 
    id: 'webhook-criar-usuario', 
    name: 'Criar Usuário', 
    url: `${N8N_CODE_IQ_URL}/webhook/create-user` 
  },
  { 
    id: 'webhook-login', 
    name: 'Login do Usuário', 
    url: `${N8N_CODE_IQ_URL}/webhook/login` 
  },

  // 🔑 PERMISSÕES E PERFIS - CONFIRMADOS
  { 
    id: 'webhook/list-permission', 
    name: 'Listar Permissões', 
    url: `${N8N_LAVO_URL}/webhook/list-permission` 
  },
  { 
    id: 'webhook/list-profile', 
    name: 'Listar Perfis', 
    url: `${N8N_LAVO_URL}/webhook/list-profile` 
  },

  // 📊 DASHBOARD - CONFIRMADO
  { 
    id: 'webhook-dashboard', 
    name: 'Dashboard', 
    url: `${N8N_LAVO_URL}/webhook/dashboard` 
  },

  // 🤖 AGENTES - CONFIRMADOS
  { 
    id: 'webhook/list-agentes', 
    name: 'Listar Agentes', 
    url: `${N8N_CODE_IQ_URL}/webhook/list-agentes` 
  },
  { 
    id: 'webhook/list-agente-atribuicoes', 
    name: 'Listar Atribuições de Agentes', 
    url: `${N8N_CODE_IQ_URL}/webhook/list-agente-atribuicoes` 
  },
  { 
    id: 'webhook/create-agente', 
    name: 'Criar Agente', 
    url: `${N8N_CODE_IQ_URL}/webhook/create-agente` 
  },

  // 📁 UPLOAD - CONFIRMADO
  { 
    id: 'webhook-upload', 
    name: 'Upload de Arquivo', 
    url: `${N8N_CODE_IQ_URL}/webhook/upload` 
  },

  // 🏢 EMPRESAS - CONFIRMADOS
  { 
    id: 'webhook/list-company', 
    name: 'Listar Empresas', 
    url: `${N8N_LAVO_URL}/webhook/list-company` 
  },
  { 
    id: 'webhook-criar-empresa', 
    name: 'Criar Empresa', 
    url: `${N8N_CODE_IQ_URL}/webhook/create-company` 
  },

  // 💬 SAUDAÇÕES - CONFIRMADOS
  { 
    id: 'webhook-listar-saudacao', 
    name: 'Listar Saudações', 
    url: `${N8N_LAVO_URL}/webhook/listar-saudacao` 
  },
  { 
    id: 'webhook-salvar-saudacao', 
    name: 'Salvar Saudação', 
    url: `${N8N_LAVO_URL}/webhook/salvar-saudacao` 
  },
  { 
    id: 'webhook-agente-recebimento', 
    name: 'Selecionar Saudação', 
    url: `${N8N_CODE_IQ_URL}/webhook/seleciona-saudacao` 
  },
  { 
    id: 'webhook-deletar-saudacao', 
    name: 'Deletar Saudação', 
    url: `${N8N_LAVO_URL}/webhook/deletar-saudacao` 
  }

  // ❌ REMOVIDOS: Todos os webhooks que não existem no n8n
  // - webhook-login, webhook-me, webhook/list-user-profiles
  // - webhook-criar-usuario, webhook/edit-users, webhook/delete-users
  // - webhook/assign-user-profiles, webhook/delete-profile
  // - webhook/create-agente, webhook/update-agente, webhook/delete-agente
  // - webhook/atribuir-agente-usuario, webhook/remover-atribuicao-agente
  // - webhook-upload, webhook-criar-empresa, webhook/edit-company, webhook/delete-company
  // - webhook-listar-saudacao, webhook-salvar-saudacao, webhook-agente-recebimento
];

export const DEFAULT_WEBHOOKS: Record<string, string> = WEBHOOKS.reduce((acc, w) => {
  acc[w.id] = w.url;
  return acc;
}, {} as Record<string, string>);

// Função para gerar webhooks dinâmicos de agentes
export const getAgentWebhooks = (agentId: string) => [
  {
    id: `webhook/start-${agentId}`,
    name: `Webhook Start ${agentId}`,
    url: `${N8N_CODE_IQ_URL}/webhook-test/start-${agentId}`
  },
  {
    id: `webhook/stop-${agentId}`,
    name: `Webhook Stop ${agentId}`,
    url: `${N8N_CODE_IQ_URL}/webhook/stop-${agentId}`
  },
  {
    id: `webhook/status-${agentId}`,
    name: `Webhook Status ${agentId}`,
    url: `${N8N_CODE_IQ_URL}/webhook/status-${agentId}`
  },
  {
    id: `webhook/lista-${agentId}`,
    name: `Webhook Lista ${agentId}`,
    url: `${N8N_CODE_IQ_URL}/webhook/lista-${agentId}`
  },
]

export function addAgentWebhook(webhookId: string, webhookUrl: string, agentName: string) {
  const newWebhook: WebhookCfg = {
    id: webhookId,
    name: `Webhook ${agentName}`,
    url: webhookUrl
  }

  const existingIndex = WEBHOOKS.findIndex(w => w.id === webhookId)
  if (existingIndex >= 0) {
    WEBHOOKS[existingIndex] = newWebhook
  } else {
    WEBHOOKS.push(newWebhook)
  }

  return newWebhook
}

export function addAgentWebhooks(agentId: string, agentName: string) {
  const agentWebhooks = getAgentWebhooks(agentId)

  agentWebhooks.forEach(webhook => {
    addAgentWebhook(webhook.id, webhook.url, `${agentName} - ${webhook.name}`)
  })

  return agentWebhooks
}