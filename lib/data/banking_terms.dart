/// Termos bancários e financeiros — "termo do dia".
///
/// Lista educativa organizada por categoria, com foco em termos usados em
/// Moçambique (M-Pesa, e-Mola, mKesh, etc.) e conceitos gerais de banca e
/// finanças pessoais.
class BankingTerm {
  final String termo;
  final String definicao;
  final String categoria;
  const BankingTerm(this.termo, this.definicao, this.categoria);
}

const catFundamentos = 'Fundamentos';
const catContasCartoes = 'Contas e cartões';
const catCredito = 'Crédito e empréstimos';
const catDinheiroMovel = 'Dinheiro móvel';
const catPoupanca = 'Poupança e investimento';
const catSeguros = 'Seguros';
const catCambio = 'Câmbio e internacional';
const catRegulacao = 'Regulação e segurança';
const catDigital = 'Banca digital';
const catFinancasPessoais = 'Finanças pessoais';
const catPagamentos = 'Pagamentos';
const catImpostos = 'Impostos e Estado';
const catEmpresas = 'Empresas e negócios';
const catImobiliario = 'Imobiliário';
const catMacro = 'Macroeconomia';
const catMercados = 'Mercados financeiros';

const List<BankingTerm> bankingTerms = [
  // ---------- Fundamentos ----------
  BankingTerm('Saldo',
      'A quantia de dinheiro disponível numa conta num determinado momento '
      '— soma de tudo o que entrou menos tudo o que saiu.',
      catFundamentos),
  BankingTerm('Taxa de juro',
      'A percentagem que pagas (num empréstimo) ou recebes (numa poupança) '
      'sobre o valor emprestado/depositado, normalmente por ano. É só a parte '
      'do juro — não inclui comissões, ao contrário da TAEG.',
      catFundamentos),
  BankingTerm('Juro simples',
      'Juro calculado sempre sobre o valor inicial, sem se acumular sobre '
      'juros anteriores — cresce de forma linear, mais devagar que o juro '
      'composto.',
      catFundamentos),
  BankingTerm('Juro composto',
      'Juro calculado não só sobre o valor inicial, mas também sobre os '
      'juros já acumulados anteriormente — faz o dinheiro crescer (ou a '
      'dívida aumentar) mais rápido ao longo do tempo.',
      catFundamentos),
  BankingTerm('Inflação',
      'O aumento generalizado dos preços ao longo do tempo, que faz o teu '
      'dinheiro valer menos — o mesmo valor compra menos coisas no futuro.',
      catFundamentos),
  BankingTerm('Liquidez',
      'A facilidade com que consegues transformar um bem em dinheiro '
      'disponível na hora — dinheiro em conta é muito líquido; um imóvel, '
      'muito pouco.',
      catFundamentos),
  BankingTerm('Activo',
      'Qualquer coisa que possuis e que tem valor económico — dinheiro, uma '
      'casa, acções, um carro. O oposto de passivo (o que deves).',
      catFundamentos),
  BankingTerm('Passivo',
      'Aquilo que deves a alguém — um empréstimo, uma factura por pagar, '
      'uma dívida. O oposto de activo.',
      catFundamentos),
  BankingTerm('Património líquido',
      'A diferença entre tudo o que possuis (activos) e tudo o que deves '
      '(passivos) — mede a tua real situação financeira.',
      catFundamentos),
  BankingTerm('Solvência',
      'A capacidade de uma pessoa ou empresa pagar todas as suas dívidas — '
      'estar "solvente" é ter mais activos do que passivos.',
      catFundamentos),

  // ---------- Contas e cartões ----------
  BankingTerm('IBAN',
      'International Bank Account Number. Um código internacional que '
      'identifica de forma única a tua conta bancária, usado sobretudo em '
      'transferências internacionais.',
      catContasCartoes),
  BankingTerm('NIB',
      'Número de Identificação Bancária. Semelhante ao IBAN, mas usado só '
      'dentro do país para identificar a conta ao fazeres transferências '
      'nacionais.',
      catContasCartoes),
  BankingTerm('Extracto bancário',
      'O documento (em papel ou digital) que lista todos os movimentos — '
      'entradas e saídas de dinheiro — de uma conta, num determinado '
      'período.',
      catContasCartoes),
  BankingTerm('Levantamento',
      'Acto de retirar dinheiro de uma conta — seja num caixa automático, '
      'balcão, ou num agente de dinheiro móvel como o M-Pesa.',
      catContasCartoes),
  BankingTerm('Depósito',
      'Acto de colocar dinheiro numa conta — pode ser em numerário, cheque, '
      'ou transferência de outra conta.',
      catContasCartoes),
  BankingTerm('Transferência bancária',
      'Movimento de dinheiro de uma conta para outra, sem passar por '
      'numerário físico — pode ser entre contas do mesmo banco ou de bancos '
      'diferentes.',
      catContasCartoes),
  BankingTerm('Cartão de débito',
      'Cartão ligado directamente à tua conta bancária — quando pagas com '
      'ele, o dinheiro sai logo da tua conta, só podes gastar o que já '
      'tens.',
      catContasCartoes),
  BankingTerm('Cartão de crédito',
      'Cartão que te deixa gastar dinheiro emprestado pelo banco, até um '
      'limite, que depois pagas (com ou sem juros, dependendo do prazo).',
      catContasCartoes),
  BankingTerm('Conta à ordem',
      'Conta bancária do dia a dia, usada para movimentos frequentes '
      '(receber salário, pagar contas) — o dinheiro está sempre disponível.',
      catContasCartoes),
  BankingTerm('Conta poupança',
      'Conta pensada para guardar dinheiro a médio/longo prazo, geralmente '
      'com uma taxa de juro melhor do que a conta à ordem, mas com menos '
      'movimentos.',
      catContasCartoes),
  BankingTerm('Titular da conta',
      'A pessoa em nome de quem a conta bancária está aberta — o dono legal '
      'do dinheiro nela guardado.',
      catContasCartoes),
  BankingTerm('Cheque',
      'Um documento que autoriza o banco a pagar uma quantia específica a '
      'alguém, retirando o valor da conta de quem o assina.',
      catContasCartoes),
  BankingTerm('Domiciliação bancária',
      'Autorização dada a uma entidade (ex.: empresa de electricidade) para '
      'debitar automaticamente um valor da tua conta todos os meses.',
      catContasCartoes),
  BankingTerm('Comissão de manutenção',
      'Valor cobrado periodicamente pelo banco só por teres a conta aberta, '
      'independentemente de a usares.',
      catContasCartoes),
  BankingTerm('Cartão pré-pago',
      'Cartão carregado antecipadamente com um valor fixo — só podes gastar '
      'o que carregaste, sem ligação directa a uma conta bancária.',
      catContasCartoes),

  // ---------- Crédito e empréstimos ----------
  BankingTerm('TAEG',
      'Taxa Anual Efectiva Global. É a taxa "verdadeira" de um crédito — '
      'junta os juros a todas as comissões e encargos, para dares um valor '
      'único que permite comparar propostas de empréstimos diferentes de '
      'forma justa.',
      catCredito),
  BankingTerm('Plafond',
      'O limite máximo que podes gastar ou levantar num determinado período '
      '(por exemplo, o limite diário de levantamento no multibanco ou de '
      'transferência no M-Pesa).',
      catCredito),
  BankingTerm('Spread',
      'A diferença entre a taxa de juro que o banco cobra a quem pede '
      'emprestado e a taxa que paga a quem deposita. É parte de como o '
      'banco ganha dinheiro.',
      catCredito),
  BankingTerm('Moratória',
      'Um período em que o pagamento de uma dívida (ou só dos juros) fica '
      'suspenso ou adiado, normalmente por acordo entre o banco e o '
      'cliente.',
      catCredito),
  BankingTerm('Amortização',
      'O processo de ir pagando uma dívida aos poucos, reduzindo o valor em '
      'dívida a cada prestação, até ficar a zero.',
      catCredito),
  BankingTerm('Prestação',
      'Cada pagamento periódico (normalmente mensal) que fazes para pagar '
      'um empréstimo — inclui uma parte de capital e uma parte de juros.',
      catCredito),
  BankingTerm('Score de crédito',
      'Uma pontuação que reflecte o quão "de confiança" és para pagar '
      'dívidas, com base no teu histórico financeiro — influencia se um '
      'banco te empresta dinheiro e a que taxa.',
      catCredito),
  BankingTerm('Garantia (colateral)',
      'Um bem (casa, carro, etc.) que o devedor oferece ao banco como '
      'segurança — se não pagar o empréstimo, o banco pode ficar com o '
      'bem.',
      catCredito),
  BankingTerm('Fiador/avalista',
      'Pessoa que se compromete a pagar a dívida de outra se esta não '
      'conseguir — usado para dar mais garantia ao banco num empréstimo.',
      catCredito),
  BankingTerm('Incumprimento',
      'Quando alguém não paga uma dívida no prazo acordado — pode levar a '
      'juros de mora, penhora de bens, ou entrada em listas de crédito '
      'malparado.',
      catCredito),
  BankingTerm('Crédito malparado',
      'Empréstimos que não estão a ser pagos como deveriam — um indicador '
      'importante da saúde financeira de bancos e de quem pediu emprestado.',
      catCredito),
  BankingTerm('Microcrédito',
      'Empréstimos de valor pequeno, geralmente destinados a pessoas ou '
      'pequenos negócios sem acesso ao crédito bancário tradicional.',
      catCredito),
  BankingTerm('Período de carência',
      'Tempo, no início de um empréstimo, em que só pagas juros (ou nada), '
      'sem começares ainda a amortizar o capital.',
      catCredito),
  BankingTerm('Taxa de juro fixa',
      'Taxa de juro de um empréstimo que se mantém igual do início ao fim '
      'do contrato, independentemente do que aconteça ao mercado.',
      catCredito),
  BankingTerm('Taxa de juro variável',
      'Taxa de juro de um empréstimo que pode subir ou descer ao longo do '
      'tempo, normalmente ligada a um indicador de referência do mercado.',
      catCredito),

  // ---------- Dinheiro móvel ----------
  BankingTerm('Dinheiro móvel',
      'Serviço financeiro (como o M-Pesa, e-Mola ou mKesh) que permite '
      'guardar, enviar e receber dinheiro através do telemóvel, sem '
      'precisares de uma conta bancária tradicional.',
      catDinheiroMovel),
  BankingTerm('Agente',
      'Pessoa ou estabelecimento autorizado a fazer depósitos e '
      'levantamentos de dinheiro móvel em nome do operador (ex.: agentes '
      'M-Pesa espalhados pela cidade).',
      catDinheiroMovel),
  BankingTerm('Carteira móvel (e-wallet)',
      'A "conta" digital dentro da app ou SIM do operador (M-Pesa, e-Mola, '
      'mKesh) onde o teu dinheiro fica guardado antes de o usares.',
      catDinheiroMovel),
  BankingTerm('Cash in',
      'Acto de depositar dinheiro físico na tua carteira móvel, através de '
      'um agente autorizado.',
      catDinheiroMovel),
  BankingTerm('Cash out',
      'Acto de retirar dinheiro da tua carteira móvel em numerário, através '
      'de um agente autorizado.',
      catDinheiroMovel),
  BankingTerm('USSD',
      'Tecnologia usada para aceder a serviços de dinheiro móvel através de '
      'códigos curtos (ex.: marcar *150#), sem precisares de internet nem '
      'de smartphone.',
      catDinheiroMovel),
  BankingTerm('Interoperabilidade',
      'A capacidade de enviar dinheiro entre operadores diferentes (ex.: de '
      'M-Pesa para e-Mola) ou entre carteira móvel e conta bancária.',
      catDinheiroMovel),

  // ---------- Poupança e investimento ----------
  BankingTerm('Fundo de emergência',
      'Dinheiro guardado à parte, só para imprevistos (doença, perda de '
      'emprego, reparações urgentes) — recomenda-se cobrir pelo menos 3 a 6 '
      'meses de despesas.',
      catPoupanca),
  BankingTerm('Depósito a prazo',
      'Depósito que ficas obrigado a manter no banco durante um período '
      'fixo, em troca de uma taxa de juro geralmente melhor do que uma '
      'conta normal.',
      catPoupanca),
  BankingTerm('Acções',
      'Pequenas partes de uma empresa que podes comprar — se a empresa vai '
      'bem, o valor da acção tende a subir, e podes receber parte dos '
      'lucros (dividendos).',
      catPoupanca),
  BankingTerm('Obrigações',
      'Uma forma de emprestares dinheiro a uma empresa ou ao Estado, que se '
      'compromete a devolver-to com juros, numa data futura definida.',
      catPoupanca),
  BankingTerm('Dividendo',
      'Parte dos lucros de uma empresa distribuída aos accionistas, '
      'proporcional ao número de acções que cada um possui.',
      catPoupanca),
  BankingTerm('Diversificação',
      'Estratégia de espalhar o dinheiro por vários tipos de investimento '
      'diferentes, para reduzir o risco de perder tudo se um deles correr '
      'mal.',
      catPoupanca),
  BankingTerm('Rentabilidade',
      'O ganho (ou perda) que um investimento gera, normalmente expresso '
      'em percentagem do valor investido.',
      catPoupanca),
  BankingTerm('Risco financeiro',
      'A possibilidade de um investimento perder valor ou não gerar o '
      'retorno esperado — geralmente, quanto maior o retorno possível, '
      'maior o risco.',
      catPoupanca),
  BankingTerm('Bolsa de valores',
      'O mercado onde se compram e vendem acções e outros títulos '
      'financeiros de empresas cotadas publicamente.',
      catPoupanca),

  // ---------- Seguros ----------
  BankingTerm('Apólice de seguro',
      'O contrato que define as condições de um seguro — o que está '
      'coberto, quanto custa, e em que situações a seguradora paga.',
      catSeguros),
  BankingTerm('Prémio de seguro',
      'O valor que pagas periodicamente (mensal, anual) à seguradora para '
      'manter o seguro activo.',
      catSeguros),
  BankingTerm('Franquia',
      'A parte de um sinistro que fica sempre a teu cargo, mesmo tendo '
      'seguro — a seguradora só paga o valor acima desse limite.',
      catSeguros),
  BankingTerm('Sinistro',
      'O evento coberto pelo seguro que efectivamente aconteceu (um '
      'acidente, um roubo, um incêndio) e que dá origem a um pedido de '
      'indemnização.',
      catSeguros),
  BankingTerm('Beneficiário',
      'A pessoa que recebe o valor de uma apólice de seguro (por exemplo, '
      'de vida) quando o evento coberto acontece.',
      catSeguros),

  // ---------- Câmbio e internacional ----------
  BankingTerm('Taxa de câmbio',
      'O valor de uma moeda expresso noutra — quanto custa, por exemplo, '
      '1 dólar americano em meticais, num determinado momento.',
      catCambio),
  BankingTerm('Remessa internacional',
      'Envio de dinheiro de um país para outro, normalmente feito por '
      'trabalhadores emigrantes a enviar dinheiro para a família.',
      catCambio),
  BankingTerm('SWIFT',
      'Código internacional que identifica um banco específico, usado para '
      'garantir que uma transferência internacional chega ao banco certo.',
      catCambio),
  BankingTerm('Desvalorização cambial',
      'Quando uma moeda perde valor face a outras — torna as importações '
      'mais caras e pode ajudar as exportações.',
      catCambio),

  // ---------- Regulação e segurança ----------
  BankingTerm('KYC',
      'Know Your Customer — o processo em que o banco/operador confirma a '
      'tua identidade (documento, morada, etc.) antes de te deixar abrir '
      'conta ou usar certos serviços.',
      catRegulacao),
  BankingTerm('PIN',
      'Personal Identification Number — o código secreto usado para '
      'confirmares a tua identidade ao usar um cartão ou fazeres uma '
      'operação no M-Pesa.',
      catRegulacao),
  BankingTerm('OTP',
      'One-Time Password — um código temporário, enviado por SMS ou app, '
      'usado uma única vez para confirmar uma operação sensível (login, '
      'transferência, etc.).',
      catRegulacao),
  BankingTerm('Banco Central',
      'A instituição responsável por regular o sistema financeiro de um '
      'país, controlar a moeda e supervisionar os bancos — em Moçambique, '
      'é o Banco de Moçambique.',
      catRegulacao),
  BankingTerm('Branqueamento de capitais',
      'Processo ilegal de disfarçar dinheiro obtido de forma criminosa como '
      'se fosse dinheiro lícito — os bancos são obrigados a vigiar e '
      'reportar movimentos suspeitos.',
      catRegulacao),
  BankingTerm('Fraude financeira',
      'Qualquer esquema enganoso que tenta roubar dinheiro ou dados de '
      'alguém — desde SMS falsas a pedir dados bancários, até esquemas de '
      'investimento fictícios.',
      catRegulacao),
  BankingTerm('Sigilo bancário',
      'Obrigação legal do banco de manter confidenciais as informações '
      'financeiras dos seus clientes, só as podendo partilhar em situações '
      'muito específicas.',
      catRegulacao),

  // ---------- Banca digital ----------
  BankingTerm('Internet banking',
      'Acesso à tua conta bancária através de um site ou app, para '
      'consultares saldo, fazeres transferências e pagamentos sem ires a '
      'um balcão.',
      catDigital),
  BankingTerm('Fintech',
      'Empresas que usam tecnologia para oferecer serviços financeiros de '
      'forma nova ou mais acessível — desde carteiras digitais a apps de '
      'investimento.',
      catDigital),
  BankingTerm('Autenticação biométrica',
      'Confirmar a tua identidade usando uma característica única do teu '
      'corpo — impressão digital, reconhecimento facial — em vez de uma '
      'password.',
      catDigital),
  BankingTerm('Notificação push',
      'Mensagem instantânea enviada pela app do banco/operador para o teu '
      'telemóvel, avisando de um movimento na conta em tempo real.',
      catDigital),
  BankingTerm('QR Code de pagamento',
      'Código quadrado que podes ler com a câmara do telemóvel para pagar '
      'ou receber dinheiro rapidamente, sem introduzir números manualmente.',
      catDigital),

  // ---------- Finanças pessoais ----------
  BankingTerm('Orçamento (budget)',
      'Um plano que define quanto vais gastar (e em quê) num determinado '
      'período, com base no que ganhas — a base de qualquer controlo '
      'financeiro pessoal.',
      catFinancasPessoais),
  BankingTerm('Educação financeira',
      'O conhecimento e as competências que te ajudam a gerir bem o teu '
      'dinheiro — poupar, investir, evitar dívidas desnecessárias.',
      catFinancasPessoais),
  BankingTerm('Custo de vida',
      'O total que uma pessoa gasta, em média, para viver num determinado '
      'lugar — inclui renda, comida, transporte, etc.',
      catFinancasPessoais),
  BankingTerm('Rendimento disponível',
      'O dinheiro que sobra do teu salário depois de pagares impostos e '
      'despesas obrigatórias — o que realmente podes gastar ou poupar.',
      catFinancasPessoais),
  BankingTerm('Bola de neve de dívidas',
      'Estratégia de pagar primeiro as dívidas mais pequenas, para ganhar '
      'motivação, antes de atacar as maiores — uma técnica popular de '
      'gestão de dívidas.',
      catFinancasPessoais),
  BankingTerm('Regra 50/30/20',
      'Método simples de orçamento: 50% do rendimento para necessidades, '
      '30% para desejos, 20% para poupança/dívidas — um ponto de partida, '
      'não uma regra rígida.',
      catFinancasPessoais),
  BankingTerm('Poder de compra',
      'A quantidade de bens ou serviços que consegues comprar com uma certa '
      'quantia de dinheiro — diminui com a inflação.',
      catFinancasPessoais),
  BankingTerm('Meta financeira',
      'Um objectivo concreto de dinheiro que queres alcançar (ex.: juntar '
      '50.000 MT para um carro) — dá direcção às tuas decisões de poupança.',
      catFinancasPessoais),
  BankingTerm('Custo de oportunidade',
      'O que perdes ao escolheres uma opção em vez de outra — por exemplo, '
      'o juro que deixas de ganhar ao gastares dinheiro em vez de o '
      'investires.',
      catFinancasPessoais),

  // ---------- Fundamentos (continuação) ----------
  BankingTerm('Capital',
      'O valor original de dinheiro investido ou emprestado, antes de se '
      'somarem quaisquer juros.',
      catFundamentos),
  BankingTerm('Valor nominal',
      'O valor "de face" impresso ou declarado de algo (uma nota, uma '
      'obrigação) — pode ser diferente do seu valor real de mercado.',
      catFundamentos),
  BankingTerm('Valor de mercado',
      'O preço pelo qual um bem ou activo realmente se venderia hoje, que '
      'pode ser maior ou menor que o seu valor nominal ou de compra.',
      catFundamentos),
  BankingTerm('Poder liberatório',
      'A capacidade legal de uma moeda ser aceite como forma válida de '
      'pagamento de uma dívida, num determinado país.',
      catFundamentos),
  BankingTerm('Massa monetária',
      'O total de dinheiro em circulação numa economia num dado momento — '
      'inclui notas, moedas e depósitos bancários.',
      catFundamentos),
  BankingTerm('Deflação',
      'O oposto da inflação — uma descida generalizada e sustentada dos '
      'preços, que pode parecer boa mas costuma sinalizar problemas na '
      'economia.',
      catFundamentos),
  BankingTerm('Recessão',
      'Um período em que a economia de um país encolhe (produz menos, '
      'emprega menos) durante vários meses seguidos.',
      catFundamentos),

  // ---------- Contas e cartões (continuação) ----------
  BankingTerm('Conta conjunta',
      'Conta bancária partilhada por duas ou mais pessoas (ex.: casal), '
      'onde qualquer titular pode normalmente movimentar o dinheiro.',
      catContasCartoes),
  BankingTerm('Cartão de coordenadas',
      'Cartão físico com uma grelha de códigos, usado como camada extra de '
      'segurança para confirmar operações no internet banking.',
      catContasCartoes),
  BankingTerm('Limite de crédito',
      'O valor máximo que podes gastar num cartão de crédito, definido '
      'pelo banco com base no teu perfil e histórico financeiro.',
      catContasCartoes),
  BankingTerm('Data de vencimento (cartão)',
      'O mês/ano em que um cartão bancário deixa de ser válido e precisa '
      'de ser renovado.',
      catContasCartoes),
  BankingTerm('CVV',
      'Card Verification Value — os 3 dígitos no verso do cartão, usados '
      'para confirmar que quem está a pagar online tem o cartão físico em '
      'mãos.',
      catContasCartoes),
  BankingTerm('Contactless',
      'Tecnologia que permite pagar aproximando o cartão ou telemóvel do '
      'terminal, sem precisar de o inserir nem introduzir o PIN em compras '
      'pequenas.',
      catContasCartoes),
  BankingTerm('Encerramento de conta',
      'Processo formal de fechar uma conta bancária, geralmente exigindo '
      'saldo zero e ausência de dívidas pendentes.',
      catContasCartoes),

  // ---------- Crédito e empréstimos (continuação) ----------
  BankingTerm('Crédito habitação',
      'Empréstimo de longo prazo destinado especificamente à compra, '
      'construção ou remodelação de uma casa, geralmente com a própria casa '
      'como garantia.',
      catCredito),
  BankingTerm('Crédito pessoal',
      'Empréstimo sem destino específico obrigatório — podes usar o '
      'dinheiro para o que precisares, ao contrário do crédito habitação.',
      catCredito),
  BankingTerm('Leasing',
      'Contrato em que pagas para usar um bem (carro, equipamento) por um '
      'período, com opção de o comprares no final por um valor residual.',
      catCredito),
  BankingTerm('Consolidação de dívidas',
      'Juntar várias dívidas diferentes num único empréstimo, geralmente '
      'para conseguir uma prestação mensal mais baixa ou mais fácil de '
      'gerir.',
      catCredito),
  BankingTerm('Juros de mora',
      'Juros extra cobrados quando não pagas uma prestação ou dívida no '
      'prazo combinado, como penalização pelo atraso.',
      catCredito),
  BankingTerm('Central de risco de crédito',
      'Base de dados onde os bancos registam quanto cada pessoa deve, '
      'usada para avaliar se vale a pena emprestar-lhe mais dinheiro.',
      catCredito),
  BankingTerm('Penhora',
      'Acto legal de tomar posse de um bem de alguém (por ordem judicial) '
      'para pagar uma dívida não paga.',
      catCredito),

  // ---------- Dinheiro móvel (continuação) ----------
  BankingTerm('Código de agente',
      'Número único que identifica um agente de dinheiro móvel, usado para '
      'confirmar que estás a fazer a operação com o agente certo.',
      catDinheiroMovel),
  BankingTerm('Saldo M-Pesa',
      'O valor disponível na tua carteira M-Pesa, separado do saldo da tua '
      'conta bancária tradicional, se tiveres uma.',
      catDinheiroMovel),
  BankingTerm('Pagamento por código USSD',
      'Forma de pagar ou transferir dinheiro móvel marcando um código '
      'curto no telefone (ex.: *150#), sem precisar de uma app.',
      catDinheiroMovel),
  BankingTerm('Limite de transacção',
      'O valor máximo permitido numa única operação de dinheiro móvel '
      '(depósito, levantamento ou transferência).',
      catDinheiroMovel),
  BankingTerm('Recarga (top-up)',
      'Acto de adicionar saldo de chamadas/dados a um número de telefone, '
      'muitas vezes feito directamente a partir da carteira de dinheiro '
      'móvel.',
      catDinheiroMovel),

  // ---------- Poupança e investimento (continuação) ----------
  BankingTerm('Juro composto anualizado',
      'A forma padrão de expressar o retorno de um investimento como se '
      'fosse sempre por um ano inteiro, para facilitar comparações.',
      catPoupanca),
  BankingTerm('Carteira de investimentos',
      'O conjunto de todos os investimentos que uma pessoa possui — '
      'acções, obrigações, poupanças, imóveis, etc.',
      catPoupanca),
  BankingTerm('Fundo de investimento',
      'Um "cesto" de dinheiro de vários investidores, gerido por '
      'profissionais, que compra uma variedade de activos em nome de '
      'todos.',
      catPoupanca),
  BankingTerm('Plano de reforma/pensão',
      'Poupança de longo prazo, muitas vezes com benefícios fiscais, '
      'pensada para garantir rendimento depois de deixares de trabalhar.',
      catPoupanca),
  BankingTerm('Valorização',
      'O aumento do valor de um bem ou investimento ao longo do tempo.',
      catPoupanca),
  BankingTerm('Desvalorização (activo)',
      'A perda de valor de um bem ou investimento ao longo do tempo.',
      catPoupanca),

  // ---------- Seguros (continuação) ----------
  BankingTerm('Seguro de vida',
      'Seguro que paga um valor aos beneficiários definidos se o titular '
      'falecer durante o período do contrato.',
      catSeguros),
  BankingTerm('Seguro automóvel',
      'Seguro que cobre danos ou responsabilidades relacionadas com um '
      'veículo — obrigatório por lei na maioria dos países, pelo menos na '
      'cobertura básica.',
      catSeguros),
  BankingTerm('Cobertura',
      'O conjunto de situações e riscos que uma apólice de seguro '
      'realmente protege — o que está incluído no contrato.',
      catSeguros),
  BankingTerm('Exclusão (seguro)',
      'Situações que uma apólice de seguro explicitamente NÃO cobre — '
      'importante ler sempre antes de assinar.',
      catSeguros),

  // ---------- Câmbio e internacional (continuação) ----------
  BankingTerm('Câmbio fixo',
      'Regime em que o valor de uma moeda é mantido artificialmente ligado '
      'a outra moeda (ou a um valor fixo) pelo Banco Central.',
      catCambio),
  BankingTerm('Câmbio flutuante',
      'Regime em que o valor de uma moeda varia livremente conforme a '
      'oferta e procura no mercado, sem intervenção fixa do Estado.',
      catCambio),
  BankingTerm('Reservas cambiais',
      'Moeda estrangeira (normalmente dólares ou euros) guardada pelo '
      'Banco Central de um país, usada para estabilizar a sua própria '
      'moeda.',
      catCambio),
  BankingTerm('Casa de câmbio',
      'Estabelecimento autorizado a trocar uma moeda por outra, fora do '
      'circuito bancário tradicional.',
      catCambio),

  // ---------- Regulação e segurança (continuação) ----------
  BankingTerm('Autenticação de dois factores (2FA)',
      'Sistema de segurança que exige duas provas diferentes de identidade '
      '(ex.: password + código SMS) antes de autorizar uma operação.',
      catRegulacao),
  BankingTerm('Phishing',
      'Tentativa de fraude em que alguém finge ser o teu banco/operador '
      '(por SMS, email ou chamada) para te enganar e obteres dados '
      'sensíveis como o PIN.',
      catRegulacao),
  BankingTerm('Engenharia social',
      'Técnica de manipulação psicológica usada por burlões para te '
      'convencerem a revelar informação confidencial ou a fazeres uma '
      'transferência.',
      catRegulacao),
  BankingTerm('Garantia de depósitos',
      'Mecanismo que protege parte do dinheiro dos clientes de um banco, '
      'caso este entre em falência — nem todos os países/valores estão '
      'cobertos.',
      catRegulacao),
  BankingTerm('Auditoria financeira',
      'Revisão independente das contas de uma empresa ou instituição, para '
      'confirmar que são precisas e cumprem a lei.',
      catRegulacao),

  // ---------- Banca digital (continuação) ----------
  BankingTerm('API bancária (open banking)',
      'Tecnologia que permite a apps de terceiros aceder (com a tua '
      'autorização) a dados ou serviços do teu banco, de forma seguras.',
      catDigital),
  BankingTerm('Carteira digital (digital wallet)',
      'App que guarda cartões, dinheiro ou outros meios de pagamento no '
      'telemóvel, para pagares sem usar o cartão físico.',
      catDigital),
  BankingTerm('Criptomoeda',
      'Moeda digital descentralizada (como a Bitcoin), que não depende de '
      'um banco central e funciona através de tecnologia blockchain.',
      catDigital),
  BankingTerm('Blockchain',
      'Um registo digital público e partilhado, onde as transacções ficam '
      'gravadas de forma que ninguém as consegue alterar depois — a base '
      'das criptomoedas.',
      catDigital),

  // ---------- Pagamentos ----------
  BankingTerm('POS (Point of Sale)',
      'O terminal onde passas o cartão ou aproximas o telemóvel para pagar '
      'numa loja — a máquina de pagamento.',
      catPagamentos),
  BankingTerm('Pagamento recorrente',
      'Cobrança automática que se repete periodicamente (ex.: mensalidade '
      'de um serviço de streaming), autorizada uma vez pelo cliente.',
      catPagamentos),
  BankingTerm('Estorno (chargeback)',
      'Devolução de um valor pago com cartão, normalmente pedida quando há '
      'um erro, fraude, ou um produto/serviço não foi entregue.',
      catPagamentos),
  BankingTerm('Compensação bancária',
      'O processo, muitas vezes invisível ao cliente, através do qual os '
      'bancos acertam entre si os valores de transferências e pagamentos '
      'feitos entre contas de bancos diferentes.',
      catPagamentos),
  BankingTerm('Referência de pagamento',
      'Código único gerado para identificar um pagamento específico (por '
      'exemplo, de uma factura), usado para confirmar automaticamente que '
      'foi pago.',
      catPagamentos),

  // ---------- Impostos e Estado ----------
  BankingTerm('IVA',
      'Imposto sobre o Valor Acrescentado — um imposto cobrado sobre a '
      'maioria dos bens e serviços que compras, incluído no preço final.',
      catImpostos),
  BankingTerm('IRPS',
      'Imposto sobre o Rendimento das Pessoas Singulares — o imposto que '
      'incide sobre o salário e outros rendimentos de uma pessoa.',
      catImpostos),
  BankingTerm('NUIT',
      'Número Único de Identificação Tributária — o número que te '
      'identifica perante o fisco em Moçambique, necessário para muitas '
      'operações financeiras.',
      catImpostos),
  BankingTerm('Retenção na fonte',
      'Quando uma parte do teu rendimento (salário, por exemplo) é '
      'automaticamente descontada e entregue ao Estado como imposto, antes '
      'mesmo de receberes o dinheiro.',
      catImpostos),
  BankingTerm('Isenção fiscal',
      'Situação em que uma pessoa, produto ou operação fica legalmente '
      'dispensada de pagar um determinado imposto.',
      catImpostos),

  // ---------- Empresas e negócios ----------
  BankingTerm('Conta empresarial',
      'Conta bancária aberta em nome de uma empresa, separada das contas '
      'pessoais dos seus donos.',
      catEmpresas),
  BankingTerm('Fluxo de caixa (cash flow)',
      'O movimento de dinheiro que entra e sai de um negócio num '
      'determinado período — mesmo negócios lucrativos podem ter '
      'problemas se o fluxo de caixa for mau.',
      catEmpresas),
  BankingTerm('Capital social',
      'O dinheiro ou bens que os donos de uma empresa investem nela '
      'inicialmente, para a pôr a funcionar.',
      catEmpresas),
  BankingTerm('Balanço',
      'Documento contabilístico que mostra, numa data específica, tudo o '
      'que uma empresa possui (activos) e tudo o que deve (passivos).',
      catEmpresas),
  BankingTerm('Facturação',
      'O total de vendas ou serviços prestados por uma empresa, geralmente '
      'medido num determinado período (mês, ano).',
      catEmpresas),

  // ---------- Fundamentos (extra) ----------
  BankingTerm('Moeda fiduciária',
      'Dinheiro que tem valor porque o Estado o declara legal, não por '
      'estar ligado a um bem físico como o ouro.', catFundamentos),
  BankingTerm('Padrão-ouro',
      'Sistema antigo em que o valor de uma moeda era directamente ligado '
      'a uma quantidade fixa de ouro.', catFundamentos),
  BankingTerm('Valor temporal do dinheiro',
      'Ideia de que 100 MT hoje valem mais do que 100 MT daqui a um ano, '
      'porque podes investir esse dinheiro entretanto.', catFundamentos),
  BankingTerm('Taxa de desconto',
      'Taxa usada para calcular quanto vale hoje um valor que só vais '
      'receber no futuro.', catFundamentos),
  BankingTerm('Ponto base',
      'Uma centésima parte de 1% — usado para descrever pequenas mudanças '
      'em taxas de juro (100 pontos base = 1%).', catFundamentos),
  BankingTerm('Anuidade',
      'Uma série de pagamentos iguais feitos em intervalos regulares, '
      'como uma prestação de crédito ou uma pensão mensal.', catFundamentos),
  BankingTerm('Barter (escambo)',
      'Troca directa de bens ou serviços sem uso de dinheiro.',
      catFundamentos),
  BankingTerm('Meio de troca',
      'Uma das funções do dinheiro — serve para trocares por bens e '
      'serviços sem precisares de escambo.', catFundamentos),
  BankingTerm('Reserva de valor',
      'Função do dinheiro que permite guardares poder de compra para o '
      'futuro, em vez de o gastares já.', catFundamentos),
  BankingTerm('Unidade de conta',
      'Função do dinheiro que permite medir e comparar o valor de coisas '
      'diferentes numa mesma escala (preços).', catFundamentos),
  BankingTerm('Custo fixo',
      'Despesa que não muda com o nível de actividade — ex.: a renda de '
      'uma loja é igual quer venda muito ou pouco.', catFundamentos),
  BankingTerm('Custo variável',
      'Despesa que muda conforme o nível de actividade — ex.: matéria-'
      'prima usada numa fábrica.', catFundamentos),
  BankingTerm('Ponto de equilíbrio',
      'O nível de vendas em que uma actividade deixa de dar prejuízo e '
      'começa a dar lucro.', catFundamentos),
  BankingTerm('Margem de lucro',
      'A percentagem que sobra das vendas depois de pagos todos os '
      'custos.', catFundamentos),
  BankingTerm('Depreciação',
      'Perda de valor de um bem (ex.: um carro, uma máquina) ao longo do '
      'tempo, por uso ou desgaste.', catFundamentos),
  BankingTerm('Amortização (contabilística)',
      'Distribuição do custo de um bem ao longo dos anos em que é usado, '
      'em vez de o contar tudo de uma vez.', catFundamentos),
  BankingTerm('Provisão',
      'Valor reservado por uma empresa ou banco para cobrir uma perda '
      'futura provável (ex.: um cliente que pode não pagar).', catFundamentos),
  BankingTerm('Solvabilidade',
      'Capacidade de uma instituição financeira cumprir as suas '
      'obrigações a longo prazo com os recursos que tem.', catFundamentos),
  BankingTerm('Alavancagem financeira',
      'Uso de dinheiro emprestado para aumentar o potencial retorno de um '
      'investimento — também aumenta o risco.', catFundamentos),
  BankingTerm('Ponto de break-even',
      'Sinónimo de ponto de equilíbrio — onde as receitas igualam '
      'exactamente os custos.', catFundamentos),

  // ---------- Contas e cartões (extra) ----------
  BankingTerm('Conta à ordem em moeda estrangeira',
      'Conta bancária que guarda o saldo numa moeda diferente da moeda '
      'nacional, útil para quem recebe ou paga em dólares/euros.',
      catContasCartoes),
  BankingTerm('Cartão virtual',
      'Cartão gerado apenas digitalmente, sem plástico físico, usado para '
      'compras online com mais segurança.', catContasCartoes),
  BankingTerm('Bloqueio de cartão',
      'Suspensão temporária de um cartão, feita pelo titular ou pelo '
      'banco, para impedir o seu uso (ex.: em caso de perda).',
      catContasCartoes),
  BankingTerm('Cancelamento de cartão',
      'Anulação definitiva de um cartão, que deixa de poder ser usado '
      'mesmo que seja depois encontrado.', catContasCartoes),
  BankingTerm('Assinatura digital',
      'Confirmação electrónica de uma operação, com o mesmo valor legal '
      'de uma assinatura em papel.', catContasCartoes),
  BankingTerm('Cofre bancário',
      'Espaço seguro alugado num banco para guardar objectos de valor '
      '(documentos, joias, dinheiro).', catContasCartoes),
  BankingTerm('Ordem de pagamento',
      'Instrução dada ao banco para pagar um valor específico a alguém, '
      'numa data definida.', catContasCartoes),
  BankingTerm('Aviso de débito',
      'Notificação enviada pelo banco a informar que um valor foi '
      'retirado da tua conta.', catContasCartoes),
  BankingTerm('Aviso de crédito',
      'Notificação enviada pelo banco a informar que um valor entrou na '
      'tua conta.', catContasCartoes),
  BankingTerm('Cartão suplementar',
      'Cartão adicional ligado à mesma conta ou cartão principal, '
      'normalmente dado a um familiar.', catContasCartoes),
  BankingTerm('Multibanco',
      'Rede de caixas automáticos e terminais de pagamento partilhada '
      'entre vários bancos.', catContasCartoes),
  BankingTerm('Caixa automático (ATM)',
      'Máquina que permite levantar dinheiro, consultar saldo e fazer '
      'outras operações sem ires a um balcão.', catContasCartoes),
  BankingTerm('Balcão bancário',
      'O espaço físico de atendimento presencial de uma agência '
      'bancária.', catContasCartoes),
  BankingTerm('Gestor de conta',
      'Funcionário do banco responsável por acompanhar um cliente '
      'específico e ajudá-lo com os seus produtos financeiros.',
      catContasCartoes),
  BankingTerm('Conta domiciliada',
      'Conta escolhida para receber automaticamente o salário ou outros '
      'pagamentos recorrentes.', catContasCartoes),
  BankingTerm('Cartão de coordenadas bancárias',
      'Documento com IBAN/NIB e outros dados usados para receberes '
      'transferências de terceiros.', catContasCartoes),
  BankingTerm('Talão de depósito',
      'Comprovativo, em papel ou digital, de que um depósito foi '
      'efectivamente feito.', catContasCartoes),
  BankingTerm('Cheque sem cobertura',
      'Cheque emitido sem que haja saldo suficiente na conta para o '
      'pagar — é ilegal em muitos países.', catContasCartoes),
  BankingTerm('Cheque visado',
      'Cheque em que o banco garante antecipadamente que há fundos, '
      'dando mais confiança a quem o recebe.', catContasCartoes),
  BankingTerm('Extracto integrado',
      'Extracto que junta movimentos de várias contas ou produtos '
      'financeiros num único documento.', catContasCartoes),

  // ---------- Crédito e empréstimos (extra) ----------
  BankingTerm('Crédito rotativo',
      'Linha de crédito que fica disponível de novo à medida que vais '
      'pagando, sem precisares de pedir um novo empréstimo.', catCredito),
  BankingTerm('Crédito automóvel',
      'Empréstimo destinado especificamente à compra de um veículo.',
      catCredito),
  BankingTerm('Refinanciamento',
      'Substituir um empréstimo antigo por um novo, geralmente para '
      'conseguir melhores condições.', catCredito),
  BankingTerm('Pré-aprovação de crédito',
      'Avaliação inicial do banco que indica se, em princípio, vais '
      'conseguir um empréstimo, antes da análise final.', catCredito),
  BankingTerm('Simulação de crédito',
      'Cálculo prévio de quanto pagarias por mês num empréstimo, com base '
      'no valor, prazo e taxa de juro.', catCredito),
  BankingTerm('Prazo do empréstimo',
      'O tempo total definido para pagares um crédito por completo.',
      catCredito),
  BankingTerm('Capital em dívida',
      'O valor que ainda falta pagar de um empréstimo, sem contar os '
      'juros futuros.', catCredito),
  BankingTerm('Plano de pagamento',
      'Calendário que define quando e quanto vais pagar de um '
      'empréstimo, até ao fim.', catCredito),
  BankingTerm('Reestruturação de dívida',
      'Renegociação das condições de uma dívida (prazo, taxa, valor da '
      'prestação) para a tornar mais fácil de pagar.', catCredito),
  BankingTerm('Crédito ao consumo',
      'Empréstimo destinado a financiar a compra de bens ou serviços de '
      'consumo (electrodomésticos, viagens, etc.).', catCredito),
  BankingTerm('Cartão de crédito revolving',
      'Cartão de crédito em que só precisas de pagar uma parte mínima '
      'todos os meses, ficando o resto a acumular juros.', catCredito),
  BankingTerm('Usura',
      'Prática ilegal de cobrar juros excessivamente altos, acima dos '
      'limites permitidos por lei.', catCredito),
  BankingTerm('Contrato de mútuo',
      'O nome legal dado ao contrato de empréstimo de dinheiro entre '
      'duas partes.', catCredito),
  BankingTerm('Devedor',
      'A pessoa ou entidade que deve dinheiro a outra.', catCredito),
  BankingTerm('Credor',
      'A pessoa ou entidade a quem é devido dinheiro.', catCredito),
  BankingTerm('Taxa de esforço',
      'A percentagem do rendimento mensal de uma pessoa que é gasta a '
      'pagar prestações de créditos — quanto maior, maior o risco.',
      catCredito),
  BankingTerm('Crédito colectivo (consórcio)',
      'Grupo de pessoas que juntam dinheiro periodicamente para, por '
      'sorteio ou licitação, um membro de cada vez aceder a um valor '
      'maior.', catCredito),
  BankingTerm('Aval bancário',
      'Garantia dada por um banco a favor de um cliente, comprometendo-se '
      'a pagar se este não o fizer.', catCredito),
  BankingTerm('Linha de crédito',
      'Valor máximo que um banco disponibiliza a um cliente, que pode '
      'usar (e voltar a usar) conforme precisar, dentro do limite.',
      catCredito),
  BankingTerm('Crédito malparado (NPL)',
      'Sigla internacional (Non-Performing Loan) para empréstimos que já '
      'não estão a ser pagos como previsto.', catCredito),

  // ---------- Dinheiro móvel (extra) ----------
  BankingTerm('e-Mola',
      'Serviço de dinheiro móvel moçambicano, operado pela Movitel, '
      'concorrente do M-Pesa.', catDinheiroMovel),
  BankingTerm('mKesh',
      'Serviço de dinheiro móvel moçambicano, operado pela Vodacom antes '
      'de se tornar M-Pesa.', catDinheiroMovel),
  BankingTerm('Conta virtual (dinheiro móvel)',
      'Outro nome para a carteira digital associada ao teu número de '
      'telefone num serviço de dinheiro móvel.', catDinheiroMovel),
  BankingTerm('Comissão de levantamento',
      'Valor cobrado ao retirares dinheiro da tua carteira móvel através '
      'de um agente.', catDinheiroMovel),
  BankingTerm('Comissão de transferência',
      'Valor cobrado ao enviares dinheiro de uma carteira móvel para '
      'outra pessoa.', catDinheiroMovel),
  BankingTerm('Registo SIM/KYC móvel',
      'Processo de associar os teus dados pessoais ao número de telefone, '
      'obrigatório para usares dinheiro móvel.', catDinheiroMovel),
  BankingTerm('Pagamento de serviços (bill pay)',
      'Função do dinheiro móvel que permite pagar água, luz ou TV '
      'directamente da carteira digital.', catDinheiroMovel),
  BankingTerm('Super agente',
      'Agente de dinheiro móvel de maior porte, que serve de "banco" para '
      'os agentes mais pequenos reporem o seu próprio saldo.',
      catDinheiroMovel),
  BankingTerm('Liquidez do agente',
      'A quantidade de dinheiro (físico e digital) que um agente tem '
      'disponível para atender pedidos de depósito e levantamento.',
      catDinheiroMovel),
  BankingTerm('Fatura eletrónica móvel',
      'Comprovativo digital de uma transacção de dinheiro móvel, enviado '
      'por SMS logo após a operação.', catDinheiroMovel),
  BankingTerm('Bloqueio de número',
      'Suspensão de uma carteira de dinheiro móvel, normalmente por '
      'perda do telemóvel ou suspeita de fraude.', catDinheiroMovel),
  BankingTerm('Transferência agente-a-agente',
      'Movimento de fundos entre dois agentes, usado para equilibrarem a '
      'sua liquidez entre si.', catDinheiroMovel),
  BankingTerm('PIN móvel',
      'Código secreto que protege a tua carteira de dinheiro móvel, '
      'diferente do PIN do cartão SIM.', catDinheiroMovel),
  BankingTerm('Histórico de transacções móvel',
      'Registo de todas as operações feitas numa carteira de dinheiro '
      'móvel, consultável na app ou por USSD.', catDinheiroMovel),
  BankingTerm('Limite mensal (dinheiro móvel)',
      'O valor total que podes movimentar numa carteira de dinheiro '
      'móvel ao longo de um mês, definido por regulação.',
      catDinheiroMovel),

  // ---------- Poupança e investimento (extra) ----------
  BankingTerm('Índice de bolsa',
      'Número que resume o desempenho médio de um grupo de acções, usado '
      'para acompanhar a "saúde" de um mercado.', catPoupanca),
  BankingTerm('ETF',
      'Exchange-Traded Fund — um fundo que reúne vários activos e se '
      'compra e vende na bolsa como se fosse uma única acção.',
      catPoupanca),
  BankingTerm('Rendimento fixo',
      'Categoria de investimentos (ex.: obrigações) em que o retorno é '
      'previsível e definido antecipadamente.', catPoupanca),
  BankingTerm('Rendimento variável',
      'Categoria de investimentos (ex.: acções) em que o retorno não é '
      'garantido e pode variar bastante.', catPoupanca),
  BankingTerm('Taxa livre de risco',
      'A taxa de retorno de um investimento considerado sem risco de '
      'perda (ex.: dívida pública de um país estável).', catPoupanca),
  BankingTerm('Horizonte de investimento',
      'O tempo que planeias manter um investimento antes de precisares '
      'do dinheiro de volta.', catPoupanca),
  BankingTerm('Perfil de investidor',
      'Classificação (conservador, moderado, agressivo) que descreve '
      'quanto risco uma pessoa está disposta a aceitar ao investir.',
      catPoupanca),
  BankingTerm('Juro capitalizado',
      'Juro que é somado ao capital e passa também a render juros nos '
      'períodos seguintes.', catPoupanca),
  BankingTerm('Poupança programada',
      'Serviço em que um valor fixo é automaticamente transferido para '
      'poupança todos os meses.', catPoupanca),
  BankingTerm('Certificado de depósito',
      'Documento que comprova um depósito a prazo feito num banco, com '
      'condições e prazo definidos.', catPoupanca),
  BankingTerm('Título do Tesouro',
      'Dívida emitida pelo Estado para se financiar, considerada um dos '
      'investimentos mais seguros de um país.', catPoupanca),
  BankingTerm('Corretora (broker)',
      'Empresa autorizada a comprar e vender activos financeiros em nome '
      'dos seus clientes.', catPoupanca),
  BankingTerm('Comissão de corretagem',
      'Valor cobrado por uma corretora por executar uma ordem de compra '
      'ou venda de um activo.', catPoupanca),
  BankingTerm('Volatilidade',
      'Medida de quanto o preço de um investimento varia ao longo do '
      'tempo — quanto maior, mais imprevisível.', catPoupanca),
  BankingTerm('Retorno esperado',
      'A estimativa de ganho que um investidor prevê obter de um '
      'investimento, com base em dados históricos ou análise.',
      catPoupanca),
  BankingTerm('Juro líquido',
      'O rendimento de um investimento depois de descontados impostos e '
      'comissões.', catPoupanca),
  BankingTerm('Aforro',
      'Sinónimo de poupança — dinheiro guardado em vez de gasto.',
      catPoupanca),
  BankingTerm('Mercado primário',
      'Onde os activos financeiros (acções, obrigações) são vendidos '
      'pela primeira vez, directamente pelo emissor.', catPoupanca),
  BankingTerm('Mercado secundário',
      'Onde os activos financeiros já emitidos são revendidos entre '
      'investidores, como a bolsa de valores.', catPoupanca),
  BankingTerm('Cotação',
      'O preço actual a que um activo (acção, moeda) está a ser '
      'negociado no mercado.', catPoupanca),

  // ---------- Seguros (extra) ----------
  BankingTerm('Seguro de saúde',
      'Seguro que cobre despesas médicas, consultas, internamentos ou '
      'medicamentos.', catSeguros),
  BankingTerm('Seguro de responsabilidade civil',
      'Seguro que cobre danos que causes, sem querer, a terceiros ou aos '
      'seus bens.', catSeguros),
  BankingTerm('Seguro multirriscos',
      'Seguro que junta várias coberturas diferentes (ex.: casa, '
      'incêndio, roubo) numa única apólice.', catSeguros),
  BankingTerm('Resseguro',
      'Um "seguro para seguradoras" — quando uma seguradora transfere '
      'parte do risco que assumiu para outra empresa.', catSeguros),
  BankingTerm('Subscritor',
      'A pessoa ou empresa que assina e é responsável pelo contrato de '
      'seguro (pode ser diferente do beneficiário).', catSeguros),
  BankingTerm('Indemnização',
      'O valor pago pela seguradora ao segurado ou beneficiário, quando '
      'ocorre um sinistro coberto.', catSeguros),
  BankingTerm('Renovação de apólice',
      'Processo de continuar um contrato de seguro por mais um período, '
      'normalmente um ano.', catSeguros),
  BankingTerm('Carência (seguro)',
      'Período inicial de um seguro em que certas coberturas ainda não '
      'estão activas.', catSeguros),
  BankingTerm('Seguro obrigatório',
      'Tipo de seguro exigido por lei para certas actividades (ex.: '
      'seguro automóvel contra terceiros).', catSeguros),
  BankingTerm('Corretor de seguros',
      'Profissional que ajuda a encontrar e negociar o seguro mais '
      'adequado às necessidades do cliente.', catSeguros),

  // ---------- Câmbio e internacional (extra) ----------
  BankingTerm('Par cambial',
      'A combinação de duas moedas cujo valor relativo está a ser '
      'comparado (ex.: USD/MZN).', catCambio),
  BankingTerm('Spread cambial',
      'A diferença entre o preço de compra e venda de uma moeda numa '
      'casa de câmbio ou banco.', catCambio),
  BankingTerm('Conta em moeda estrangeira',
      'Conta bancária que permite guardar dinheiro directamente em '
      'dólares, euros ou outra moeda, sem converter.', catCambio),
  BankingTerm('Balança comercial',
      'A diferença entre o valor total que um país exporta e o que '
      'importa.', catCambio),
  BankingTerm('Balança de pagamentos',
      'Registo de todas as transacções financeiras entre um país e o '
      'resto do mundo, num determinado período.', catCambio),
  BankingTerm('Investimento directo estrangeiro',
      'Dinheiro investido por uma empresa ou pessoa de outro país '
      'directamente num negócio local.', catCambio),
  BankingTerm('Carta de crédito',
      'Garantia bancária usada em comércio internacional, que assegura '
      'ao vendedor que vai receber o pagamento.', catCambio),
  BankingTerm('Incoterms',
      'Regras internacionais que definem responsabilidades entre '
      'comprador e vendedor no transporte de mercadorias.', catCambio),
  BankingTerm('Dívida externa',
      'O total que um país deve a credores estrangeiros (outros países, '
      'bancos ou instituições internacionais).', catCambio),
  BankingTerm('FMI',
      'Fundo Monetário Internacional — organização que empresta dinheiro '
      'a países com dificuldades financeiras, sob certas condições.',
      catCambio),

  // ---------- Regulação e segurança (extra) ----------
  BankingTerm('Compliance',
      'Área de uma empresa ou banco responsável por garantir que tudo o '
      'que se faz cumpre a lei e as normas internas.', catRegulacao),
  BankingTerm('Supervisão bancária',
      'Vigilância feita pelo Banco Central sobre os bancos, para '
      'garantir que operam de forma segura e legal.', catRegulacao),
  BankingTerm('Lei de protecção de dados',
      'Legislação que define como as instituições podem recolher, usar '
      'e guardar os teus dados pessoais e financeiros.', catRegulacao),
  BankingTerm('Identidade digital',
      'Conjunto de informações que te identificam de forma única online, '
      'usado para acederes a serviços financeiros digitais.',
      catRegulacao),
  BankingTerm('Assinatura electrónica qualificada',
      'Tipo de assinatura digital com o mesmo valor legal de uma '
      'assinatura manuscrita, reconhecida por lei.', catRegulacao),
  BankingTerm('Firewall bancário',
      'Sistema de segurança informática que protege os sistemas de um '
      'banco contra acessos não autorizados.', catRegulacao),
  BankingTerm('Encriptação',
      'Técnica que transforma informação em código, para que só quem '
      'tem a chave certa a consiga ler — protege dados financeiros.',
      catRegulacao),
  BankingTerm('Auditoria interna',
      'Revisão feita pela própria instituição para verificar se os seus '
      'processos e contas estão correctos.', catRegulacao),
  BankingTerm('Linha de denúncia (whistleblowing)',
      'Canal seguro onde funcionários ou clientes podem denunciar '
      'irregularidades ou fraudes num banco.', catRegulacao),
  BankingTerm('Sandbox regulatório',
      'Ambiente controlado onde novas empresas de tecnologia financeira '
      'podem testar produtos sob supervisão do regulador.', catRegulacao),

  // ---------- Banca digital (extra) ----------
  BankingTerm('Neobanco',
      'Banco que opera só digitalmente, sem agências físicas.',
      catDigital),
  BankingTerm('Chatbot bancário',
      'Assistente virtual automatizado que responde a perguntas ou '
      'ajuda em operações simples dentro da app do banco.', catDigital),
  BankingTerm('Onboarding digital',
      'Processo de abrir conta ou aderir a um serviço financeiro '
      'totalmente online, sem ires a um balcão.', catDigital),
  BankingTerm('Token de segurança',
      'Dispositivo físico ou digital que gera códigos temporários para '
      'autenticares operações bancárias online.', catDigital),
  BankingTerm('App bancária',
      'Aplicação de telemóvel que dá acesso à tua conta e serviços '
      'bancários a qualquer hora.', catDigital),
  BankingTerm('Wearable payment',
      'Pagamento feito através de um dispositivo vestível, como um '
      'relógio inteligente com tecnologia contactless.', catDigital),
  BankingTerm('Inteligência artificial (banca)',
      'Uso de sistemas automáticos para detectar fraude, avaliar crédito '
      'ou personalizar o atendimento bancário.', catDigital),
  BankingTerm('Nuvem (cloud) bancária',
      'Infra-estrutura tecnológica onde bancos guardam dados e sistemas, '
      'em vez de servidores físicos próprios.', catDigital),
  BankingTerm('API',
      'Application Programming Interface — forma padronizada de dois '
      'sistemas de computador "conversarem" entre si.', catDigital),
  BankingTerm('Stablecoin',
      'Criptomoeda cujo valor é atrelado a um activo estável, como o '
      'dólar americano, para evitar grandes oscilações.', catDigital),

  // ---------- Pagamentos (extra) ----------
  BankingTerm('Gateway de pagamento',
      'Serviço tecnológico que processa pagamentos online entre a loja e '
      'o banco do cliente, de forma segura.', catPagamentos),
  BankingTerm('Terminal virtual',
      'Página ou sistema que permite receber pagamentos com cartão sem '
      'precisar de uma máquina física.', catPagamentos),
  BankingTerm('Pagamento instantâneo',
      'Transferência de dinheiro que chega ao destinatário em segundos, '
      'em vez de horas ou dias.', catPagamentos),
  BankingTerm('Débito directo',
      'Autorização dada a uma empresa para retirar automaticamente um '
      'valor da tua conta, geralmente para facturas recorrentes.',
      catPagamentos),
  BankingTerm('Split payment',
      'Pagamento dividido automaticamente entre vários destinatários '
      'numa única transacção.', catPagamentos),
  BankingTerm('Adquirente (acquirer)',
      'Instituição financeira que processa pagamentos com cartão em '
      'nome de um comerciante.', catPagamentos),
  BankingTerm('Emissor (issuer)',
      'O banco ou operador que emitiu o teu cartão ou meio de pagamento.',
      catPagamentos),
  BankingTerm('Autorização de pagamento',
      'Confirmação em tempo real de que há fundos suficientes para uma '
      'transacção ser concluída.', catPagamentos),
  BankingTerm('Liquidação (settlement)',
      'Momento em que o dinheiro de uma transacção efectivamente muda de '
      'conta, depois de autorizada.', catPagamentos),
  BankingTerm('Comissão de intercâmbio',
      'Taxa paga entre bancos sempre que se usa um cartão para pagar '
      'numa loja.', catPagamentos),

  // ---------- Impostos e Estado (extra) ----------
  BankingTerm('IRPC',
      'Imposto sobre o Rendimento das Pessoas Colectivas — o imposto que '
      'incide sobre o lucro das empresas.', catImpostos),
  BankingTerm('ISPC',
      'Imposto Simplificado para Pequenos Contribuintes — regime fiscal '
      'simplificado para pequenos negócios em Moçambique.', catImpostos),
  BankingTerm('Autoridade Tributária',
      'A entidade estatal responsável por cobrar impostos e fiscalizar o '
      'seu cumprimento.', catImpostos),
  BankingTerm('Declaração de rendimentos',
      'Documento anual onde declaras ao Estado quanto ganhaste, usado '
      'para calcular o imposto devido.', catImpostos),
  BankingTerm('Evasão fiscal',
      'Prática ilegal de esconder rendimentos ou bens para pagar menos '
      'impostos do que devias.', catImpostos),
  BankingTerm('Elisão fiscal',
      'Uso de meios legais (mas por vezes questionáveis) para reduzir o '
      'imposto a pagar, sem infringir a lei directamente.', catImpostos),
  BankingTerm('Dívida pública',
      'O total que o Estado deve, resultante de todos os empréstimos que '
      'contraiu ao longo do tempo.', catImpostos),
  BankingTerm('Défice orçamental',
      'Quando o Estado gasta mais dinheiro do que arrecada em impostos '
      'num determinado ano.', catImpostos),
  BankingTerm('Superávit orçamental',
      'Quando o Estado arrecada mais dinheiro em impostos do que gasta '
      'num determinado ano.', catImpostos),
  BankingTerm('Subsídio estatal',
      'Apoio financeiro dado pelo Estado a uma pessoa, sector ou '
      'produto, para reduzir o seu custo.', catImpostos),

  // ---------- Empresas e negócios (extra) ----------
  BankingTerm('Sócio',
      'Pessoa que possui uma parte de uma empresa e partilha os seus '
      'lucros, riscos e decisões.', catEmpresas),
  BankingTerm('Accionista',
      'Pessoa ou entidade que possui acções de uma empresa, tornando-a '
      'parcialmente dona do negócio.', catEmpresas),
  BankingTerm('Lucro líquido',
      'O que sobra de uma empresa depois de pagos todos os custos, '
      'despesas e impostos.', catEmpresas),
  BankingTerm('Lucro bruto',
      'A diferença entre as vendas e o custo directo de produzir o que '
      'foi vendido, antes de outras despesas.', catEmpresas),
  BankingTerm('EBITDA',
      'Lucro de uma empresa antes de juros, impostos, depreciação e '
      'amortização — usado para avaliar o desempenho operacional puro.',
      catEmpresas),
  BankingTerm('Plano de negócios',
      'Documento que descreve como uma empresa vai funcionar, vender e '
      'gerar lucro, usado também para pedir financiamento.', catEmpresas),
  BankingTerm('Capital de giro',
      'Dinheiro que uma empresa precisa para cobrir as despesas do '
      'dia a dia, antes de receber pelas suas vendas.', catEmpresas),
  BankingTerm('Ponto morto',
      'Sinónimo de ponto de equilíbrio numa empresa — onde não há lucro '
      'nem prejuízo.', catEmpresas),
  BankingTerm('Due diligence',
      'Investigação cuidadosa feita antes de investir numa empresa ou '
      'assinar um negócio, para confirmar que está tudo em ordem.',
      catEmpresas),
  BankingTerm('Fusão',
      'Junção de duas empresas numa só.', catEmpresas),
  BankingTerm('Aquisição',
      'Compra de uma empresa por outra, que passa a controlá-la.',
      catEmpresas),
  BankingTerm('IPO',
      'Initial Public Offering — o momento em que uma empresa vende '
      'acções ao público pela primeira vez, entrando na bolsa.',
      catEmpresas),
  BankingTerm('Startup',
      'Empresa nova, normalmente ligada a tecnologia, com potencial de '
      'crescer rapidamente.', catEmpresas),
  BankingTerm('Capital de risco (venture capital)',
      'Dinheiro investido em startups com alto potencial mas também alto '
      'risco, em troca de uma parte da empresa.', catEmpresas),
  BankingTerm('Franquia (negócio)',
      'Modelo de negócio em que pagas para usar a marca e o sistema de '
      'uma empresa já estabelecida.', catEmpresas),

  // ---------- Imobiliário ----------
  BankingTerm('Hipoteca',
      'Garantia dada sobre um imóvel para assegurar o pagamento de um '
      'empréstimo — se não pagares, o banco pode ficar com a casa.',
      catImobiliario),
  BankingTerm('Avaliação imobiliária',
      'Estimativa profissional do valor de mercado de um imóvel, usada '
      'muitas vezes para pedir crédito habitação.', catImobiliario),
  BankingTerm('Escritura',
      'Documento legal que formaliza a compra e venda de um imóvel.',
      catImobiliario),
  BankingTerm('Registo predial',
      'Registo oficial que comprova quem é o dono legal de um imóvel.',
      catImobiliario),
  BankingTerm('Renda',
      'Valor pago periodicamente pelo uso de um imóvel que não é teu.',
      catImobiliario),
  BankingTerm('Arrendamento',
      'Contrato que permite usar um imóvel de outra pessoa, mediante o '
      'pagamento de renda.', catImobiliario),
  BankingTerm('Sinal (entrada)',
      'Parte do valor de um imóvel paga antecipadamente, para reservar '
      'ou iniciar a compra.', catImobiliario),
  BankingTerm('Valor residual',
      'O valor estimado de um bem no final de um contrato de leasing ou '
      'financiamento.', catImobiliario),
  BankingTerm('Taxa de ocupação',
      'Percentagem de um imóvel ou empreendimento que está efectivamente '
      'a ser usada ou arrendada.', catImobiliario),
  BankingTerm('Plusvalia',
      'O ganho obtido ao vender um imóvel (ou outro bem) por um preço '
      'mais alto do que o pago originalmente.', catImobiliario),

  // ---------- Macroeconomia ----------
  BankingTerm('PIB',
      'Produto Interno Bruto — o valor total de tudo o que um país '
      'produz num ano, um dos principais indicadores da sua economia.',
      catMacro),
  BankingTerm('Taxa de desemprego',
      'A percentagem de pessoas activas que estão sem trabalho e à '
      'procura de emprego, num país ou região.', catMacro),
  BankingTerm('Política monetária',
      'Conjunto de decisões do Banco Central (como a taxa de juro) para '
      'controlar a inflação e estabilizar a economia.', catMacro),
  BankingTerm('Política fiscal',
      'Decisões do governo sobre impostos e gastos públicos, usadas para '
      'influenciar a economia.', catMacro),
  BankingTerm('Taxa de referência (Banco Central)',
      'Taxa de juro definida pelo Banco Central que influencia todas as '
      'outras taxas do sistema financeiro de um país.', catMacro),
  BankingTerm('Crescimento económico',
      'Aumento, ao longo do tempo, da quantidade de bens e serviços '
      'produzidos por um país.', catMacro),
  BankingTerm('Ciclo económico',
      'Alternância natural entre períodos de crescimento e de '
      'abrandamento numa economia.', catMacro),
  BankingTerm('Estagflação',
      'Situação rara e difícil em que há inflação alta ao mesmo tempo '
      'que a economia não cresce (ou até encolhe).', catMacro),
  BankingTerm('Indicador económico',
      'Dado estatístico (como o PIB ou a inflação) usado para avaliar a '
      'saúde de uma economia.', catMacro),
  BankingTerm('Cabaz de bens',
      'Lista representativa de produtos e serviços usada para calcular a '
      'inflação de um país.', catMacro),

  // ---------- Mercados financeiros ----------
  BankingTerm('Derivado financeiro',
      'Contrato cujo valor depende do preço de outro activo (acção, '
      'moeda, matéria-prima), usado para investir ou proteger-se de '
      'riscos.', catMercados),
  BankingTerm('Futuro (contrato)',
      'Acordo para comprar ou vender um activo a um preço fixo, numa '
      'data futura definida.', catMercados),
  BankingTerm('Opção financeira',
      'Contrato que dá o direito (mas não a obrigação) de comprar ou '
      'vender um activo a um preço definido, até uma certa data.',
      catMercados),
  BankingTerm('Hedge (cobertura)',
      'Estratégia usada para reduzir o risco de perda num investimento, '
      'geralmente através de outro investimento que compensa o primeiro.',
      catMercados),
  BankingTerm('Especulação',
      'Comprar ou vender activos financeiros apenas para lucrar com a '
      'variação de preço, sem interesse real no activo em si.',
      catMercados),
  BankingTerm('Touro (mercado em alta)',
      'Termo usado quando os preços dos activos num mercado estão, de '
      'forma geral, a subir.', catMercados),
  BankingTerm('Urso (mercado em baixa)',
      'Termo usado quando os preços dos activos num mercado estão, de '
      'forma geral, a descer.', catMercados),
  BankingTerm('Liquidez de mercado',
      'A facilidade com que um activo pode ser comprado ou vendido sem '
      'afectar muito o seu preço.', catMercados),
  BankingTerm('Ordem de compra/venda',
      'Instrução dada a uma corretora para comprar ou vender um activo a '
      'um preço específico.', catMercados),
  BankingTerm('Análise fundamental',
      'Método de avaliar um investimento com base em dados económicos e '
      'financeiros reais da empresa ou activo.', catMercados),
  BankingTerm('Análise técnica',
      'Método de prever o preço futuro de um activo com base em padrões '
      'de preços passados e gráficos.', catMercados),

  // ---------- Fundamentos (extra 2) ----------
  BankingTerm('Correcção de mercado',
      'Queda moderada e temporária no preço de activos, depois de uma '
      'subida prolongada.', catFundamentos),
  BankingTerm('Bolha financeira',
      'Situação em que o preço de um activo sobe muito acima do seu '
      'valor real, antes de cair de forma abrupta.', catFundamentos),
  BankingTerm('Colapso financeiro (crash)',
      'Queda súbita e violenta no valor de um mercado ou economia.',
      catFundamentos),
  BankingTerm('Confiança do consumidor',
      'Medida de quão optimistas as pessoas estão sobre a economia, que '
      'influencia quanto gastam ou poupam.', catFundamentos),
  BankingTerm('Poupador',
      'Pessoa que prioriza guardar parte do seu rendimento em vez de o '
      'gastar todo.', catFundamentos),
  BankingTerm('Devedor solidário',
      'Pessoa que partilha, junto com outra(s), a responsabilidade total '
      'por uma dívida.', catFundamentos),
  BankingTerm('Insolvência',
      'Situação em que alguém não tem activos suficientes para cobrir as '
      'suas dívidas.', catFundamentos),
  BankingTerm('Falência',
      'Processo legal declarado quando uma empresa ou pessoa não '
      'consegue mais pagar as suas dívidas.', catFundamentos),
  BankingTerm('Recuperação judicial',
      'Processo legal que dá a uma empresa em dificuldades tempo para '
      'reorganizar as suas dívidas e evitar a falência.', catFundamentos),
  BankingTerm('Economia informal',
      'Actividades económicas que não são registadas nem tributadas '
      'oficialmente pelo Estado.', catFundamentos),
  BankingTerm('Inclusão financeira',
      'Acesso de toda a população, incluindo os mais pobres, a serviços '
      'financeiros básicos como conta bancária ou crédito.',
      catFundamentos),
  BankingTerm('Literacia financeira',
      'Sinónimo de educação financeira — capacidade de compreender e '
      'usar bem conceitos e produtos financeiros.', catFundamentos),

  // ---------- Contas e cartões (extra 2) ----------
  BankingTerm('Conta salário',
      'Conta bancária usada especificamente para receber o pagamento do '
      'trabalho, muitas vezes aberta pela entidade patronal.',
      catContasCartoes),
  BankingTerm('Conta jovem',
      'Conta bancária com condições especiais, pensada para clientes '
      'mais jovens.', catContasCartoes),
  BankingTerm('Conta institucional',
      'Conta bancária aberta em nome de uma organização, associação ou '
      'instituição, não de uma pessoa individual.', catContasCartoes),
  BankingTerm('Procuração bancária',
      'Autorização legal dada a outra pessoa para movimentar a tua conta '
      'em teu nome.', catContasCartoes),
  BankingTerm('Titularidade solidária',
      'Regime de conta conjunta em que qualquer titular pode movimentar '
      'o dinheiro sozinho, sem precisar da autorização dos outros.',
      catContasCartoes),
  BankingTerm('Titularidade conjunta obrigatória',
      'Regime de conta partilhada em que é preciso a autorização de '
      'todos os titulares para movimentar o dinheiro.', catContasCartoes),
  BankingTerm('Cartão bloqueado',
      'Cartão temporariamente impedido de ser usado, por segurança ou '
      'pedido do titular.', catContasCartoes),
  BankingTerm('PIN bloqueado',
      'Situação em que o PIN de um cartão deixa de funcionar depois de '
      'várias tentativas erradas seguidas.', catContasCartoes),
  BankingTerm('Reemissão de cartão',
      'Pedido de um novo cartão, geralmente por perda, roubo ou dano do '
      'anterior.', catContasCartoes),
  BankingTerm('Cartão internacional',
      'Cartão que pode ser usado fora do país de origem, em compras e '
      'levantamentos no estrangeiro.', catContasCartoes),

  // ---------- Crédito e empréstimos (extra 2) ----------
  BankingTerm('Crédito estudantil',
      'Empréstimo destinado a financiar estudos, geralmente com '
      'condições mais favoráveis que um crédito normal.', catCredito),
  BankingTerm('Crédito agrícola',
      'Empréstimo destinado a financiar actividades agrícolas, muitas '
      'vezes com condições especiais para pequenos produtores.',
      catCredito),
  BankingTerm('Fiança',
      'Garantia dada por uma pessoa (o fiador) de que vai pagar a dívida '
      'de outra, se esta não o fizer.', catCredito),
  BankingTerm('Empréstimo garantido',
      'Empréstimo em que o devedor oferece um bem como garantia, '
      'reduzindo o risco para o credor.', catCredito),
  BankingTerm('Empréstimo não garantido',
      'Empréstimo concedido apenas com base na confiança no devedor, sem '
      'nenhum bem como garantia.', catCredito),
  BankingTerm('Data de vencimento (prestação)',
      'O dia do mês em que uma prestação de crédito deve ser paga.',
      catCredito),
  BankingTerm('Pagamento antecipado',
      'Pagar uma dívida (ou parte dela) antes da data prevista, o que '
      'normalmente reduz o total de juros pagos.', catCredito),
  BankingTerm('Penalização por pagamento antecipado',
      'Taxa que alguns bancos cobram quando pagas um empréstimo antes do '
      'prazo, para compensar os juros que deixam de receber.',
      catCredito),
  BankingTerm('Contrato de adesão',
      'Contrato com condições já definidas pelo banco, que o cliente só '
      'pode aceitar ou recusar, sem negociar os termos.', catCredito),
  BankingTerm('Ficha de informação normalizada',
      'Documento padronizado que resume as condições de um crédito, para '
      'facilitar a comparação entre bancos.', catCredito),

  // ---------- Dinheiro móvel (extra 2) ----------
  BankingTerm('Interoperabilidade M-Pesa/banco',
      'Capacidade de mover dinheiro directamente entre a tua carteira '
      'M-Pesa e a tua conta bancária tradicional.', catDinheiroMovel),
  BankingTerm('Agente inactivo',
      'Agente de dinheiro móvel que, por falta de liquidez ou outro '
      'motivo, temporariamente não consegue processar operações.',
      catDinheiroMovel),
  BankingTerm('Comissão do agente',
      'Valor que o agente de dinheiro móvel recebe do operador por cada '
      'operação que processa para os clientes.', catDinheiroMovel),
  BankingTerm('Fundo de garantia (dinheiro móvel)',
      'Reserva de dinheiro que os operadores de dinheiro móvel mantêm '
      'num banco, equivalente ao saldo total das carteiras dos clientes.',
      catDinheiroMovel),
  BankingTerm('Wallet-to-wallet',
      'Transferência directa de dinheiro entre duas carteiras móveis, '
      'sem passar por dinheiro físico.', catDinheiroMovel),
  BankingTerm('Recibo digital',
      'Comprovativo electrónico de uma transacção de dinheiro móvel, '
      'guardado no histórico da app ou por SMS.', catDinheiroMovel),
  BankingTerm('Verificação de saldo',
      'Consulta ao valor disponível na carteira de dinheiro móvel, feita '
      'por USSD ou pela app.', catDinheiroMovel),
  BankingTerm('Serviço de valor acrescentado',
      'Serviços extra oferecidos através do dinheiro móvel, além de '
      'enviar/receber dinheiro — como crédito rápido ou seguros.',
      catDinheiroMovel),

  // ---------- Poupança e investimento (extra 2) ----------
  BankingTerm('Poupança de curto prazo',
      'Dinheiro guardado para ser usado dentro de pouco tempo (meses), '
      'em produtos de baixo risco e fácil acesso.', catPoupanca),
  BankingTerm('Poupança de longo prazo',
      'Dinheiro guardado com um horizonte de vários anos, podendo aceitar '
      'mais risco em troca de mais retorno.', catPoupanca),
  BankingTerm('Regra dos 72',
      'Truque simples: divide 72 pela taxa de juro anual para saberes '
      'aproximadamente em quantos anos o teu dinheiro duplica.',
      catPoupanca),
  BankingTerm('Rendimento passivo',
      'Dinheiro que ganhas sem trabalhar activamente por ele — juros, '
      'dividendos, rendas.', catPoupanca),
  BankingTerm('Reinvestimento',
      'Usar os ganhos de um investimento (juros, dividendos) para '
      'comprar mais do mesmo investimento, em vez de os gastar.',
      catPoupanca),
  BankingTerm('Custódia de activos',
      'Serviço de guardar e administrar os investimentos de um cliente '
      'em segurança, prestado por bancos ou corretoras.', catPoupanca),
  BankingTerm('Comissão de gestão',
      'Valor cobrado anualmente por quem gere um fundo de investimento '
      'em teu nome.', catPoupanca),
  BankingTerm('Benchmark',
      'Referência (como um índice de bolsa) usada para comparar se um '
      'investimento teve um bom ou mau desempenho.', catPoupanca),
  BankingTerm('Poupança em moeda estrangeira',
      'Guardar dinheiro numa moeda diferente da nacional, como forma de '
      'protecção contra a desvalorização local.', catPoupanca),
  BankingTerm('Investimento de impacto',
      'Investir com o objectivo duplo de ganhar dinheiro e gerar um '
      'benefício social ou ambiental positivo.', catPoupanca),

  // ---------- Seguros (extra 2) ----------
  BankingTerm('Seguro de viagem',
      'Seguro que cobre imprevistos durante uma viagem — problemas de '
      'saúde, bagagem perdida, cancelamentos.', catSeguros),
  BankingTerm('Seguro agrícola',
      'Seguro que protege agricultores contra perdas causadas por seca, '
      'pragas ou outros desastres naturais.', catSeguros),
  BankingTerm('Prémio anual',
      'O valor total pago por um seguro ao longo de um ano, podendo ser '
      'pago de uma vez ou em prestações.', catSeguros),
  BankingTerm('Bónus-malus',
      'Sistema em que o prémio de um seguro (normalmente automóvel) '
      'desce se não houver sinistros, e sobe se houver.', catSeguros),
  BankingTerm('Perito avaliador',
      'Profissional que avalia os danos de um sinistro, para determinar '
      'quanto a seguradora deve pagar.', catSeguros),
  BankingTerm('Cláusula contratual',
      'Cada condição específica escrita dentro de uma apólice de seguro '
      'ou outro contrato financeiro.', catSeguros),

  // ---------- Câmbio e internacional (extra 2) ----------
  BankingTerm('Moeda de reserva',
      'Moeda amplamente aceite e usada por bancos centrais em todo o '
      'mundo para guardar reservas, como o dólar americano.', catCambio),
  BankingTerm('Metical',
      'A moeda oficial de Moçambique, cujo código internacional é MZN.',
      catCambio),
  BankingTerm('Conversão cambial',
      'Acto de trocar um valor de uma moeda para outra, à taxa de câmbio '
      'do momento.', catCambio),
  BankingTerm('Comércio internacional',
      'Troca de bens e serviços entre diferentes países.', catCambio),
  BankingTerm('Tarifa aduaneira',
      'Imposto cobrado sobre bens que entram ou saem de um país, na '
      'fronteira.', catCambio),
  BankingTerm('Desembaraço aduaneiro',
      'Processo administrativo necessário para uma mercadoria poder '
      'entrar legalmente num país.', catCambio),
  BankingTerm('Banco correspondente',
      'Banco estrangeiro que presta serviços a outro banco, permitindo '
      'que este processe operações internacionais.', catCambio),

  // ---------- Regulação e segurança (extra 2) ----------
  BankingTerm('Banco de Moçambique',
      'O Banco Central de Moçambique, responsável por regular o sistema '
      'financeiro e emitir a moeda nacional.', catRegulacao),
  BankingTerm('Provedor de justiça bancária',
      'Entidade independente a quem podes recorrer se tiveres um '
      'conflito não resolvido com o teu banco.', catRegulacao),
  BankingTerm('Central de responsabilidades de crédito',
      'Base de dados nacional que regista todas as dívidas de crédito '
      'das pessoas e empresas de um país.', catRegulacao),
  BankingTerm('Prevenção de fraude',
      'Conjunto de medidas usadas por bancos para detectar e impedir '
      'transacções fraudulentas antes de acontecerem.', catRegulacao),
  BankingTerm('Verificação em duas etapas',
      'Sinónimo de autenticação de dois factores — exige duas '
      'confirmações diferentes para autorizar uma operação.',
      catRegulacao),
  BankingTerm('Golpe do falso banco',
      'Fraude em que alguém finge ligar do teu banco para te convencer a '
      'partilhar dados sensíveis ou fazer uma transferência.',
      catRegulacao),
  BankingTerm('Lista negra de crédito',
      'Registo informal ou formal de pessoas com histórico de não '
      'pagamento de dívidas.', catRegulacao),
  BankingTerm('Direitos do consumidor bancário',
      'Conjunto de protecções legais que garantem tratamento justo e '
      'transparente por parte dos bancos.', catRegulacao),

  // ---------- Banca digital (extra 2) ----------
  BankingTerm('Biometria facial',
      'Uso do reconhecimento do rosto para confirmar a tua identidade '
      'numa app bancária.', catDigital),
  BankingTerm('Biometria digital (impressão)',
      'Uso da impressão digital para desbloquear ou autorizar operações '
      'numa app bancária.', catDigital),
  BankingTerm('Transferência via app',
      'Envio de dinheiro feito directamente pela aplicação do banco, sem '
      'precisar de ir a um balcão ou caixa automático.', catDigital),
  BankingTerm('Pagamento por proximidade (NFC)',
      'Tecnologia que permite pagar aproximando o telemóvel ou cartão do '
      'terminal, sem contacto físico directo.', catDigital),
  BankingTerm('E-commerce',
      'Comércio electrónico — compra e venda de produtos ou serviços '
      'feita através da internet.', catDigital),
  BankingTerm('Carteira multi-moeda',
      'Carteira digital que permite guardar e gerir várias moedas '
      'diferentes ao mesmo tempo.', catDigital),
  BankingTerm('Robo-advisor',
      'Sistema automatizado que dá sugestões de investimento com base em '
      'algoritmos, sem intervenção humana directa.', catDigital),

  // ---------- Pagamentos (extra 2) ----------
  BankingTerm('Comerciante (merchant)',
      'Negócio que aceita pagamentos de clientes, seja em loja física ou '
      'online.', catPagamentos),
  BankingTerm('Ticket médio',
      'O valor médio gasto por cliente numa transacção, usado por '
      'negócios para analisar as suas vendas.', catPagamentos),
  BankingTerm('Pagamento fraccionado',
      'Dividir o valor de uma compra em várias prestações, com ou sem '
      'juros.', catPagamentos),
  BankingTerm('Conta de pagamento',
      'Conta simplificada, muitas vezes ligada a serviços digitais, '
      'usada só para fazer e receber pagamentos.', catPagamentos),
  BankingTerm('Reembolso',
      'Devolução de um valor pago, geralmente por cancelamento ou '
      'devolução de um produto/serviço.', catPagamentos),

  // ---------- Impostos e Estado (extra 2) ----------
  BankingTerm('Imposto directo',
      'Imposto cobrado directamente sobre o rendimento ou património de '
      'uma pessoa ou empresa (ex.: IRPS).', catImpostos),
  BankingTerm('Imposto indirecto',
      'Imposto cobrado sobre o consumo de bens e serviços, pago por '
      'todos independentemente do rendimento (ex.: IVA).', catImpostos),
  BankingTerm('Base tributável',
      'O valor sobre o qual um imposto é calculado.', catImpostos),
  BankingTerm('Fiscalização tributária',
      'Verificação feita pelo Estado para confirmar que os impostos '
      'declarados e pagos estão correctos.', catImpostos),
  BankingTerm('Regime fiscal simplificado',
      'Conjunto de regras fiscais mais simples, pensado para pequenos '
      'contribuintes ou negócios.', catImpostos),

  // ---------- Empresas e negócios (extra 2) ----------
  BankingTerm('Empresário em nome individual',
      'Pessoa que exerce uma actividade económica em seu próprio nome, '
      'sem criar uma empresa formalmente separada.', catEmpresas),
  BankingTerm('Sociedade por quotas',
      'Tipo de empresa cujo capital é dividido em quotas entre os '
      'sócios, comum em pequenos e médios negócios.', catEmpresas),
  BankingTerm('Sociedade anónima',
      'Tipo de empresa cujo capital é dividido em acções, podendo ser '
      'negociadas publicamente.', catEmpresas),
  BankingTerm('Registo comercial',
      'Processo oficial de registar legalmente uma empresa junto das '
      'autoridades competentes.', catEmpresas),
  BankingTerm('Alvará',
      'Licença oficial que autoriza uma empresa a exercer uma actividade '
      'específica.', catEmpresas),
  BankingTerm('Contabilidade organizada',
      'Sistema formal de registo de todas as operações financeiras de '
      'uma empresa, exigido por lei acima de certa dimensão.',
      catEmpresas),

  // ---------- Imobiliário (extra) ----------
  BankingTerm('Prestação da casa',
      'Valor mensal pago para amortizar um crédito habitação.',
      catImobiliario),
  BankingTerm('Seguro multirriscos habitação',
      'Seguro obrigatório em muitos créditos habitação, que cobre danos '
      'ao imóvel dado como garantia.', catImobiliario),
  BankingTerm('Taxa de esforço (habitação)',
      'Percentagem do rendimento familiar comprometida com a prestação '
      'da casa — bancos costumam limitar este valor.', catImobiliario),
  BankingTerm('Comparticipação',
      'Parte do valor de um imóvel que o comprador tem de pagar do seu '
      'próprio bolso, já que o banco raramente financia 100%.',
      catImobiliario),

  // ---------- Macroeconomia (extra) ----------
  BankingTerm('PIB per capita',
      'O PIB de um país dividido pelo número de habitantes — dá uma '
      'ideia da riqueza média por pessoa.', catMacro),
  BankingTerm('Índice de preços ao consumidor',
      'Indicador que mede a evolução média dos preços de um cabaz de '
      'bens e serviços — a base do cálculo da inflação.', catMacro),
  BankingTerm('Taxa de câmbio nominal',
      'O valor de troca directo entre duas moedas, sem ajustes pela '
      'inflação de cada país.', catMacro),
  BankingTerm('Taxa de câmbio real',
      'O valor de troca entre duas moedas ajustado pela diferença de '
      'inflação entre os dois países.', catMacro),

  // ---------- Mercados financeiros (extra) ----------
  BankingTerm('Capitalização de mercado',
      'O valor total de uma empresa cotada em bolsa, calculado '
      'multiplicando o preço da acção pelo número total de acções.',
      catMercados),
  BankingTerm('Free float',
      'A parte das acções de uma empresa que está disponível para ser '
      'livremente negociada no mercado.', catMercados),
  BankingTerm('Dividend yield',
      'Percentagem que relaciona o dividendo pago por uma acção com o '
      'seu preço de mercado actual.', catMercados),
  BankingTerm('Corretagem online',
      'Serviço que permite comprar e vender activos financeiros '
      'directamente através de uma app ou site.', catMercados),

  // ---------- Fundamentos (extra 3) ----------
  BankingTerm('Custo de vida ajustado',
      'Comparação do custo de vida entre lugares diferentes, tendo em '
      'conta o poder de compra local.', catFundamentos),
  BankingTerm('Salário mínimo',
      'O valor mais baixo que, por lei, uma entidade patronal pode pagar '
      'a um trabalhador.', catFundamentos),
  BankingTerm('Cesta básica',
      'Conjunto mínimo de produtos essenciais que uma família precisa '
      'para viver, usado para avaliar o custo de vida.', catFundamentos),
  BankingTerm('Dinheiro de bolso',
      'Pequena quantia guardada em numerário para despesas do dia a '
      'dia, fora da conta bancária.', catFundamentos),
  BankingTerm('Excedente orçamental pessoal',
      'A diferença positiva entre o que ganhas e o que gastas num mês — '
      'o que fica para poupar.', catFundamentos),

  // ---------- Contas e cartões (extra 3) ----------
  BankingTerm('Cartão co-branded',
      'Cartão bancário emitido em parceria com outra marca (ex.: uma '
      'companhia aérea), que dá benefícios extra ao usá-lo.',
      catContasCartoes),
  BankingTerm('Programa de pontos',
      'Sistema de recompensas em que ganhas pontos por usares um cartão, '
      'trocáveis depois por prémios ou descontos.', catContasCartoes),
  BankingTerm('Cashback',
      'Percentagem do valor gasto num cartão que é devolvida ao titular, '
      'como forma de incentivo ao uso.', catContasCartoes),
  BankingTerm('Seguro de cartão',
      'Protecção adicional, ligada a um cartão, contra fraude, roubo ou '
      'compras não reconhecidas.', catContasCartoes),

  // ---------- Crédito e empréstimos (extra 3) ----------
  BankingTerm('Crédito verde',
      'Empréstimo com condições vantajosas destinado a financiar '
      'projectos ambientalmente sustentáveis.', catCredito),
  BankingTerm('Crédito solidário',
      'Modelo de microcrédito em que um grupo de pessoas garante '
      'colectivamente o pagamento dos empréstimos uns dos outros.',
      catCredito),
  BankingTerm('Taxa de juro nominal',
      'A taxa de juro anunciada de um empréstimo, sem ajustes pela '
      'inflação ou capitalização.', catCredito),
  BankingTerm('Taxa de juro efectiva',
      'A taxa de juro realmente paga, já com o efeito da capitalização '
      'ao longo do ano incluído.', catCredito),

  // ---------- Dinheiro móvel (extra 3) ----------
  BankingTerm('Carteira congelada',
      'Situação em que uma carteira de dinheiro móvel fica '
      'temporariamente impedida de fazer operações, por segurança ou '
      'ordem legal.', catDinheiroMovel),
  BankingTerm('Reversão de transacção',
      'Anulação de um pagamento ou transferência de dinheiro móvel feito '
      'por engano, quando possível.', catDinheiroMovel),
  BankingTerm('Pin transaccional',
      'Código usado especificamente para confirmar uma operação de '
      'dinheiro móvel, podendo ser diferente do PIN de acesso.',
      catDinheiroMovel),

  // ---------- Poupança e investimento (extra 3) ----------
  BankingTerm('Poupança automática',
      'Sistema que arredonda ou desconta automaticamente pequenos '
      'valores das tuas compras para os guardares em poupança.',
      catPoupanca),
  BankingTerm('Meta de reforma',
      'Valor que estimas precisar de ter poupado até deixares de '
      'trabalhar, para viveres confortavelmente.', catPoupanca),
  BankingTerm('Juro pós-fixado',
      'Taxa de juro de um investimento que só é totalmente conhecida no '
      'final, por depender de um indicador que varia.', catPoupanca),
  BankingTerm('Juro pré-fixado',
      'Taxa de juro de um investimento definida à partida e que não '
      'muda até ao fim do prazo.', catPoupanca),

  // ---------- Seguros (extra 3) ----------
  BankingTerm('Seguro de crédito',
      'Seguro que cobre o banco (ou o próprio devedor) caso este não '
      'consiga pagar um empréstimo por morte, invalidez ou desemprego.',
      catSeguros),
  BankingTerm('Seguro dotal',
      'Seguro de vida que combina protecção com uma componente de '
      'poupança, pagando um valor ao titular se sobreviver ao prazo.',
      catSeguros),

  // ---------- Câmbio e internacional (extra 3) ----------
  BankingTerm('Mercado cambial paralelo',
      'Mercado informal de troca de moeda, fora do sistema bancário '
      'oficial, comum onde há restrições de câmbio.', catCambio),
  BankingTerm('Zona monetária',
      'Grupo de países que partilham a mesma moeda ou têm as suas moedas '
      'fortemente ligadas entre si.', catCambio),

  // ---------- Regulação e segurança (extra 3) ----------
  BankingTerm('Verificação de identidade remota',
      'Confirmação da tua identidade feita à distância (por exemplo, por '
      'vídeo-chamada), sem ires a um balcão.', catRegulacao),
  BankingTerm('Congelamento de conta',
      'Bloqueio temporário de uma conta bancária, geralmente por ordem '
      'judicial ou suspeita de actividade ilegal.', catRegulacao),
  BankingTerm('Lista de sanções',
      'Lista internacional de pessoas ou entidades com quem os bancos '
      'estão proibidos de fazer negócios.', catRegulacao),

  // ---------- Banca digital (extra 3) ----------
  BankingTerm('Assistente virtual financeiro',
      'Ferramenta digital que ajuda a gerir orçamento, poupança ou '
      'investimentos automaticamente.', catDigital),
  BankingTerm('Open finance',
      'Evolução do open banking que estende a partilha segura de dados a '
      'seguros, investimentos e outros produtos financeiros.',
      catDigital),

  // ---------- Pagamentos (extra 3) ----------
  BankingTerm('Pagamento peer-to-peer (P2P)',
      'Transferência de dinheiro directamente entre duas pessoas, sem '
      'passar por um intermediário comercial.', catPagamentos),
  BankingTerm('Carteira de comerciante',
      'Conta digital onde um negócio recebe e gere os pagamentos feitos '
      'pelos seus clientes.', catPagamentos),

  // ---------- Empresas e negócios (extra 3) ----------
  BankingTerm('Missão empresarial',
      'Declaração que resume o propósito principal de uma empresa e a '
      'razão da sua existência.', catEmpresas),
  BankingTerm('Concorrência de mercado',
      'Outras empresas que oferecem produtos ou serviços semelhantes no '
      'mesmo mercado.', catEmpresas),
  BankingTerm('Quota de mercado',
      'A percentagem das vendas totais de um sector que pertence a uma '
      'empresa específica.', catEmpresas),

  // ---------- Imobiliário (extra 2) ----------
  BankingTerm('Condomínio',
      'Conjunto de despesas partilhadas entre os moradores de um mesmo '
      'edifício, para manutenção de áreas comuns.', catImobiliario),
  BankingTerm('Imóvel dado em garantia',
      'Casa ou terreno usado como colateral de um empréstimo, que o '
      'banco pode reclamar em caso de incumprimento.', catImobiliario),

  // ---------- Macroeconomia (extra 2) ----------
  BankingTerm('Choque económico',
      'Evento inesperado (ex.: pandemia, seca) que afecta fortemente e '
      'de forma súbita uma economia.', catMacro),
  BankingTerm('Competitividade económica',
      'Capacidade de um país ou empresa produzir bens e serviços a '
      'preços atractivos face à concorrência internacional.', catMacro),

  // ---------- Mercados financeiros (extra 2) ----------
  BankingTerm('Título negociável',
      'Documento financeiro (como uma acção ou obrigação) que pode ser '
      'comprado e vendido livremente no mercado.', catMercados),
  BankingTerm('Carteira diversificada',
      'Conjunto de investimentos espalhados por vários tipos de activos, '
      'para reduzir o risco global.', catMercados),
  BankingTerm('Prazo de maturidade',
      'A data em que um investimento (como uma obrigação) termina e o '
      'capital investido é devolvido.', catMercados),
  BankingTerm('Yield',
      'A taxa de retorno gerada por um investimento, geralmente expressa '
      'em percentagem anual.', catMercados),
  BankingTerm('Risco sistémico',
      'Risco de que o colapso de uma instituição financeira arraste '
      'consigo todo o sistema financeiro de um país.', catFundamentos),
];
