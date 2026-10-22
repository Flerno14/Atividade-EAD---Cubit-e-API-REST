enum TipoTransacao { receita, despesa }

class Transacao {
  final String id;
  final String descricao;
  final double valor;
  final TipoTransacao tipo;
  final DateTime data;
  final String? categoriaId;

  Transacao({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.data,
    this.categoriaId,
  });

  Map<String, dynamic> toJson() {
    return {
      'descricao': descricao,
      'valor': valor,
      'tipo': tipo.toString(),
      'categoria_id': categoriaId,
    };
  }

  factory Transacao.fromJson(Map<String, dynamic> json) {
    return Transacao(
      id: json['id'] as String,
      descricao: json['descricao'] as String,
      valor: (json['valor'] as num).toDouble(),
      tipo: (json['tipo'] as String) == TipoTransacao.receita.toString()
          ? TipoTransacao.receita
          : TipoTransacao.despesa,
      data: DateTime.parse(json['created_at'] as String),
      categoriaId: json['categoria_id']?.toString(),
    );
  }
}
