class SmsTransaction {
  final double amount;
  final String type;
  final String? reference;
  final String source;
  final String? description;

  SmsTransaction({
    required this.amount,
    required this.type,
    this.reference,
    required this.source,
    this.description,
  });
}

class SmsParser {
  static final List<_ParserRule> _rules = [
    // 1. M-Pesa
    _ParserRule(
      source: 'M-Pesa',
      regex: RegExp(
        r'(Recebeu|Pagou|Transferiu|Depositou)\s+([\d,]+\.?\d*)\s*MT',
        caseSensitive: false,
      ),
      extractType: (match) {
        final action = match.group(1)?.toLowerCase() ?? '';
        if (action.contains('recebeu') || action.contains('depositou')) {
          return 'receita';
        }
        return 'despesa';
      },
      extractAmount: (match) {
        final amountStr = match.group(2)?.replaceAll(',', '') ?? '0';
        return double.tryParse(amountStr) ?? 0;
      },
      extractReference: (text) {
        final refMatch =
            RegExp(r'Ref:\s*(\S+)', caseSensitive: false).firstMatch(text);
        return refMatch?.group(1);
      },
    ),

    // 2. BIM
    _ParserRule(
      source: 'BIM',
      regex: RegExp(
        r'(Compra|Pagamento|Transferencia|Deposito|Levantamento)\s+'
        r'(?:de\s+)?([\d,]+\.?\d*)\s*MT',
        caseSensitive: false,
      ),
      extractType: (match) {
        final action = match.group(1)?.toLowerCase() ?? '';
        if (action.contains('deposito')) {
          return 'receita';
        }
        // Transferencia pode ser receita se contiver "para a sua conta"
        return 'despesa';
      },
      extractAmount: (match) {
        final amountStr = match.group(2)?.replaceAll(',', '') ?? '0';
        return double.tryParse(amountStr) ?? 0;
      },
      extractReference: (text) {
        final refMatch = RegExp(
          r'(?:Ref|Transacao)\s*:?\s*(\S+)',
          caseSensitive: false,
        ).firstMatch(text);
        return refMatch?.group(1);
      },
    ),
  ];

  static SmsTransaction? parse(String smsBody, String sender) {
    for (final rule in _rules) {
      final match = rule.regex.firstMatch(smsBody);
      if (match != null) {
        final amount = rule.extractAmount(match);
        final type = rule.extractType(match);
        final reference = rule.extractReference(smsBody);
        return SmsTransaction(
          amount: amount,
          type: type,
          reference: reference,
          source: rule.source,
          description: 'SMS de $sender',
        );
      }
    }
    return null;
  }
}

class _ParserRule {
  final String source;
  final RegExp regex;
  final String Function(Match match) extractType;
  final double Function(Match match) extractAmount;
  final String? Function(String text) extractReference;

  _ParserRule({
    required this.source,
    required this.regex,
    required this.extractType,
    required this.extractAmount,
    required this.extractReference,
  });
}