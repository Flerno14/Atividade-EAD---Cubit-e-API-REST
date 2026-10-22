class Categoria {
  final String id;
  final String nome;

  const Categoria({required this.id, required this.nome});

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        id: json['id'].toString(),
        nome: json['nome'] as String,
      );

  Map<String, dynamic> toJson() => {'nome': nome};
}
