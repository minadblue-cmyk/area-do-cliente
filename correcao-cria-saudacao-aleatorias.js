// === CÓDIGO CORRIGIDO PARA "Cria frases de saudação aleatórias" ===

// CORREÇÃO: Acessar dados diretamente do Loop, não do Preserva Dados
const dadosLoop = $('Loop').item.json || {};
const base = dadosLoop;

console.log("=== PROCESSANDO LEAD NO LOOP ===");
console.log("Dados do Loop:", dadosLoop);
console.log(`ID: ${base.id}`);
console.log(`Nome: ${base.nome_cliente}`);
console.log(`Posição no lote: ${base.posicao_lote}`);

// ===== Saudação por horário (SP) =====
function saudacaoSP() {
  const horas = parseInt(new Intl.DateTimeFormat("pt-BR", {
    timeZone: "America/Sao_Paulo", hour: "numeric", hour12: false
  }).format(new Date()), 10);
  if (horas >= 5 && horas < 12) return "Bom dia";
  if (horas >= 12 && horas < 19) return "Boa tarde";
  return "Boa noite";
}

// ===== Helpers =====
const pick = (arr) => arr[Math.floor(Math.random() * arr.length)];

function variacoesProfissao(p) {
  p = String(p || "").toLowerCase();
  const v = {
    advogado: ["área jurídica","advocacia","direito"],
    advogada: ["área jurídica","advocacia","direito"],
    medico: ["medicina","área médica","saúde"],
    "médico": ["medicina","área médica","saúde"],
    medica: ["medicina","área médica","saúde"],
    "médica": ["medicina","área médica","saúde"],
    engenheiro: ["engenharia","área técnica"],
    engenheira: ["engenharia","área técnica"],
    professor: ["educação","ensino","área educacional"],
    professora: ["educação","ensino","área educacional"],
    contador: ["contabilidade","área contábil"],
    contadora: ["contabilidade","área contábil"],
    administrador: ["administração","gestão"],
    administradora: ["administração","gestão"],
    empresario: ["empreendedorismo","negócios"],
    "empresária": ["empreendedorismo","negócios"],
    comerciante: ["comércio","vendas"],
    vendedor: ["vendas","área comercial"],
    vendedora: ["vendas","área comercial"]
  };
  return v[p] || [p || "sua área de atuação", "sua área de atuação"];
}

function normalizaFonte(b) {
  let f = b.fonte_prospec || b.canal || b.fonte || b.utm_source || "um parceiro de confiança";
  if (typeof f === "string") f = f.replace(/_/g, " ").trim();
  return f;
}

function corpoMensagem({ fonteTxt, profissao, qtd_filhos }) {
  const prof = pick(variacoesProfissao(profissao));

  const aberturas = [
    "Sou Cleber Frank, da Elleve Consórcios. Estou entrando em contato porque",
    "Cleber Frank aqui, da Elleve Consórcios. Estou te procurando porque",
    "Aqui é o Cleber, represento a Elleve Consórcios, e recebi seu contato através de",
    "Meu nome é Cleber Frank, da Elleve Consórcios, e tive a recomendação de falar com você por",
    "Faço parte da equipe da Elleve Consórcios e soube sobre você através de"
  ];
  const indicacoes = [
    `${fonteTxt} me passou seu contato`,
    `${fonteTxt} comentou sobre você comigo`,
    `fui indicado por ${fonteTxt} a procurar você`,
    `recebi seu telefone de ${fonteTxt}`,
    `${fonteTxt} achou que faria sentido conversarmos`
  ];
  const conexoes = [
    `Como você atua com ${prof}, acredito que pode se interessar por oportunidades de investimento sólidas`,
    `Muitos profissionais de ${prof} têm buscado mais estabilidade financeira`,
    `Sua experiência em ${prof} geralmente vem acompanhada de interesse em investimentos seguros`
  ];

  const familia = (qtd_filhos > 0)
    ? [
        `Pensando na família, esse tipo de investimento ajuda a garantir tranquilidade para o futuro`,
        `Com ${qtd_filhos} ${qtd_filhos === 1 ? "filho" : "filhos"}, faz sentido priorizar segurança e previsibilidade`,
        `É uma forma de proteger e planejar o futuro de quem você ama`
      ]
    : [];

  const fechamentos = [
    "Posso te explicar rapidamente como funciona, o que acha?",
    "Se fizer sentido, te mostro em poucos minutos os principais pontos",
    "Que tal conversarmos um pouco sobre isso? Prometo ser breve"
  ];

  const fam = familia.length ? " " + pick(familia) + "." : "";
  return `${pick(aberturas)} ${pick(indicacoes)}. ${pick(conexoes)}.${fam} ${pick(fechamentos)}`;
}

// ===== Montagem final =====
const nomeCliente = base.nome_cliente || base.nome || base.name || "Cliente";
const profissao   = base.profissao || base.ocupacao || base.cargo || "sua área de atuação";
const qtd_filhos  = (base.qtd_filhos != null ? parseInt(base.qtd_filhos, 10) : (base.filhos != null ? parseInt(base.filhos, 10) : 0)) || 0;
const fonteTxt    = normalizaFonte(base);

const saudacao = saudacaoSP();
const corpo    = corpoMensagem({ fonteTxt, profissao, qtd_filhos });
const mensagem = `${saudacao}, ${nomeCliente}! ${corpo}`;

console.log(`Mensagem gerada: ${mensagem.substring(0, 50)}...`);

return [{
  json: {
    ...base,
    mensagem,
    dados_processados: {
      saudacao,
      nome_processado: nomeCliente,
      profissao_processada: profissao,
      fonte_processada: fonteTxt,
      qtd_filhos_processada: qtd_filhos,
      tamanho_mensagem: mensagem.length
    }
  }
}];
