import '../models/categoria.dart';

class CategoriaState {
  final List<Categoria> categorias;
  final bool carregando;
  final bool salvando;
  final String? erro;
  final String? mensagem;

  const CategoriaState({
    this.categorias = const [],
    this.carregando = false,
    this.salvando = false,
    this.erro,
    this.mensagem,
  });
}
