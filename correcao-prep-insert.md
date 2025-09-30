# Correção para o Nó "Prep_Insert" - Acentuação

## Problema Identificado
No nó "Prep_Insert", o `type` está sendo definido como `agent.agentType` que já vem desacentuado (ex: "joo" em vez de "joao"), e isso está sendo usado para gerar os webhooks.

## Código Corrigido

```javascript
// ✅ Code - Run Once for All Items (coloque após um Merge "Wait for all")

function j(nameList){
  const names = Array.isArray(nameList) ? nameList : [nameList];
  for (const n of names) {
    try { const v = $(n).first().json; if (v) return v; } catch {}
  }
  return null;
}
function numFromName(obj){
  const s = obj?.name || '';
  const m = s.match(/-(\d+)(?!.*\d)/); // último número após hífen
  return m ? Number(m[1]) : null;
}

// Função para normalizar nome preservando acentos
function normalizarNomeParaWebhook(nome) {
  return nome
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '') // Remove espaços
    .replace(/[^a-z0-9áàâãéèêíìîóòôõúùûç]/g, '') // Remove caracteres especiais exceto acentos
    .replace(/[áàâã]/g, 'a')
    .replace(/[éèê]/g, 'e')
    .replace(/[íìî]/g, 'i')
    .replace(/[óòôõ]/g, 'o')
    .replace(/[úùû]/g, 'u')
    .replace(/ç/g, 'c');
}

// fontes dos dados
const agent = j(['Normalização','Normalizar Dados']) || {};
const body  = j('Webhook Create Agente')?.body || {}; // onde estão nome/descricao/icone/cor/ativo

// IDs dos 4 workflows (use as ativações porque já executaram)
const start  = j('Ativa o Workflow');   // Start
const status = j('Ativa o Workflow1');  // Status (list-agente)
const lista  = j('Ativa o Workflow2');  // Lista
const stop   = j('Ativa o Workflow3');  // Stop

// counters oficiais; se faltar, extrai do "name" do workflow
const cStart  = j('PREPARAR WORKFLOW CLONADO - Start')?.counter            ?? numFromName(start);
const cStatus = j('PREPARAR WORKFLOW CLONADO - Status')?.counter           ?? numFromName(status);
const cLista  = j('PREPARAR WORKFLOW CLONADO - Lista-Prospecção')?.counter ?? numFromName(lista);
const cStop   = j('PREPARAR WORKFLOW CLONADO - Stop')?.counter             ?? numFromName(stop);

// CORREÇÃO: Normalizar type preservando acentos
const agentName = agent.agentName ?? body?.nome ?? 'agentePadrao';
const type = normalizarNomeParaWebhook(agentName);

const mk = (p,n) => n != null ? `webhook/${p}${n}-${type}` : null;

const workflow = {
  start_id:  start?.id  ? String(start.id)  : null,
  status_id: status?.id ? String(status.id) : null,
  lista_id:  lista?.id  ? String(lista.id)  : null,
  stop_id:   stop?.id   ? String(stop.id)   : null,
};
const webhook = {
  start_url:  mk('start',  cStart),
  status_url: mk('status', cStatus),
  lista_url:  mk('lista',  cLista),
  stop_url:   mk('stop',   cStop),
};

// payload único para Postgres/front
const out = {
  success: true,
  agentId:   agent.agentId ?? body?.agentId ?? null,
  agentName: agent.agentName ?? body?.nome ?? null,
  type,
  workflow,
  webhook,
  // campos que o Postgres precisa (evita referenciar outros nós no mapeamento)
  nome:       agent.agentName ?? body?.nome ?? null,
  descricao:  body?.descricao ?? null,
  icone:      body?.icone ?? null,
  cor:        body?.cor ?? null,
  ativo:      body?.ativo ?? true,
};

// sinaliza faltas (sem quebrar)
const missing = [];
Object.entries(workflow).forEach(([k,v]) => { if (!v) missing.push(k); });
Object.entries(webhook).forEach(([k,v]) => { if (!v) missing.push(k); });
if (missing.length) { out.success = false; out.missing = missing; }

return [{ json: out }];
```

## Principais Mudanças

1. **Adicionada função `normalizarNomeParaWebhook()`** - Mesma função usada nos outros nós
2. **Corrigida definição do `type`**:
   - ❌ **Antes**: `const type = agent.agentType || 'agentePadrao';`
   - ✅ **Agora**: `const type = normalizarNomeParaWebhook(agentName);`
3. **Usa o nome real do agente** em vez do `agentType` já desacentuado

## Resultado Esperado

Após a correção:
- ✅ **"João"** → `type: "joao"` (não mais `"joo"`)
- ✅ **Webhooks corretos**: `webhook/start6-joao`, `webhook/status6-joao`, etc.
- ✅ **Banco de dados**: Salvará os webhooks com acentos preservados
