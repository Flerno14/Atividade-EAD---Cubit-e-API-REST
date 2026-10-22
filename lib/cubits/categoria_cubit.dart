import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/categoria_repository.dart';
import 'categoria_state.dart';

class CategoriaCubit extends Cubit<CategoriaState> {
  final CategoriaRepository repository;

  CategoriaCubit({required this.repository}) : super(const CategoriaState());

  Future<void> carregarCategorias() async {
    if (state.carregando || state.salvando) return;
    emit(CategoriaState(categorias: state.categorias, carregando: true));
    try {
      final categorias = await repository.buscarCategorias();
      if (!isClosed) {
        emit(CategoriaState(categorias: List.unmodifiable(categorias)));
      }
    } catch (e) {
      if (!isClosed) {
        emit(CategoriaState(categorias: state.categorias, erro: '$e'));
      }
    }
  }

  Future<void> salvarCategoria(String nome) async {
    if (state.salvando || state.carregando) return;
    nome = nome.trim();
    if (nome.isEmpty || nome.length > 100) {
      emit(CategoriaState(
        categorias: state.categorias,
        erro: 'Informe um nome entre 1 e 100 caracteres.',
      ));
      return;
    }
    emit(CategoriaState(categorias: state.categorias, salvando: true));
    try {
      final categoria = await repository.criarCategoria(nome);
      if (isClosed) return;
      final categorias = [...state.categorias, categoria]
        ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      emit(CategoriaState(
        categorias: List.unmodifiable(categorias),
        mensagem: 'Categoria cadastrada com sucesso!',
      ));
    } catch (e) {
      if (!isClosed) {
        emit(CategoriaState(categorias: state.categorias, erro: '$e'));
      }
    }
  }
}
