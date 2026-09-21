import 'package:flutter/material.dart';
import '../data/banking_terms.dart';
import '../services/term_of_day_service.dart';
import '../theme/pulso_theme.dart';

const _coresCategoria = {
  catFundamentos: Color(0xFF6E93F5),
  catContasCartoes: Color(0xFF2FA9C9),
  catCredito: Color(0xFFE8A13C),
  catDinheiroMovel: Color(0xFF1FA971),
  catPoupanca: Color(0xFF9C6BE0),
  catSeguros: Color(0xFFC2528B),
  catCambio: Color(0xFFE5484D),
  catRegulacao: Color(0xFF707784),
  catDigital: Color(0xFF3D72D8),
  catFinancasPessoais: Color(0xFF388E3C),
  catPagamentos: Color(0xFF2FA9C9),
  catImpostos: Color(0xFF707784),
  catEmpresas: Color(0xFFE8A13C),
  catImobiliario: Color(0xFFC2528B),
  catMacro: Color(0xFF3D72D8),
  catMercados: Color(0xFF1FA971),
};

const _iconesCategoria = {
  catFundamentos: Icons.school_rounded,
  catContasCartoes: Icons.credit_card_rounded,
  catCredito: Icons.request_quote_rounded,
  catDinheiroMovel: Icons.phone_android_rounded,
  catPoupanca: Icons.trending_up_rounded,
  catSeguros: Icons.shield_rounded,
  catCambio: Icons.public_rounded,
  catRegulacao: Icons.verified_user_rounded,
  catDigital: Icons.smartphone_rounded,
  catFinancasPessoais: Icons.savings_rounded,
  catPagamentos: Icons.point_of_sale_rounded,
  catImpostos: Icons.account_balance_rounded,
  catEmpresas: Icons.business_center_rounded,
  catImobiliario: Icons.home_work_rounded,
  catMacro: Icons.language_rounded,
  catMercados: Icons.show_chart_rounded,
};

Color _corDe(String categoria) => _coresCategoria[categoria] ?? const Color(0xFF707784);
IconData _iconeDe(String categoria) => _iconesCategoria[categoria] ?? Icons.info_rounded;

/// Lista de todos os termos bancários/financeiros, agrupados por categoria,
/// com pesquisa e o termo de hoje em destaque no topo.
class BankingTermsScreen extends StatefulWidget {
  const BankingTermsScreen({super.key});

  @override
  State<BankingTermsScreen> createState() => _BankingTermsScreenState();
}

class _BankingTermsScreenState extends State<BankingTermsScreen> {
  final _searchCtrl = TextEditingController();
  String _pesquisa = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hoje = TermOfDayService.today();
    final query = _pesquisa.trim().toLowerCase();

    final filtrados = query.isEmpty
        ? bankingTerms
        : bankingTerms
            .where((t) =>
                t.termo.toLowerCase().contains(query) ||
                t.definicao.toLowerCase().contains(query))
            .toList();

    final porCategoria = <String, List<BankingTerm>>{};
    for (final t in filtrados) {
      porCategoria.putIfAbsent(t.categoria, () => []).add(t);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Termos bancários')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _pesquisa = v),
              decoration: InputDecoration(
                hintText: 'Pesquisar termo',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _pesquisa.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _pesquisa = '');
                        },
                      ),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PulsoRadius.lg),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (query.isEmpty) ...[
                  Text('TERMO DE HOJE',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 8),
                  _TermCard(
                    termo: hoje,
                    destaque: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => BankingTermDetailScreen(termo: hoje)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (filtrados.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('Nenhum termo encontrado.',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  )
                else
                  for (final categoria in porCategoria.keys) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Icon(_iconeDe(categoria),
                              size: 16, color: _corDe(categoria)),
                          const SizedBox(width: 6),
                          Text(categoria.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: _corDe(categoria))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Divider(color: _corDe(categoria)
                                  .withValues(alpha: 0.25))),
                        ],
                      ),
                    ),
                    for (final t in porCategoria[categoria]!)
                      if (query.isNotEmpty || t.termo != hoje.termo)
                        _TermCard(
                          termo: t,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    BankingTermDetailScreen(termo: t)),
                          ),
                        ),
                    const SizedBox(height: 20),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TermCard extends StatelessWidget {
  final BankingTerm termo;
  final VoidCallback onTap;
  final bool destaque;

  const _TermCard({
    required this.termo,
    required this.onTap,
    this.destaque = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = PulsoPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    final cor = _corDe(termo.categoria);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: destaque ? scheme.primary.withValues(alpha: 0.08) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PulsoRadius.md),
          side: BorderSide(
              color: destaque ? scheme.primary : p.borderSubtle,
              width: destaque ? 1.4 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(PulsoRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: cor.withValues(alpha: 0.14),
                  foregroundColor: cor,
                  child: Icon(
                    destaque ? Icons.today_rounded : _iconeDe(termo.categoria),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(termo.termo,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Icon(Icons.chevron_right_rounded, color: p.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BankingTermDetailScreen extends StatelessWidget {
  final BankingTerm termo;
  const BankingTermDetailScreen({super.key, required this.termo});

  @override
  Widget build(BuildContext context) {
    final cor = _corDe(termo.categoria);
    final p = PulsoPalette.of(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
              color: cor.withValues(alpha: 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_iconeDe(termo.categoria), size: 32, color: cor),
                  ),
                  const SizedBox(height: 18),
                  Text(termo.termo,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(height: 1.15)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(PulsoRadius.sm),
                    ),
                    child: Text(termo.categoria,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: cor, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Text(
                termo.definicao,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.65, fontSize: 16, color: p.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
