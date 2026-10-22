import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/categoria_cubit.dart';
import '../cubits/categoria_state.dart';

class CadastroCategoriaPage extends StatefulWidget {
  const CadastroCategoriaPage({super.key});

  @override
  State<CadastroCategoriaPage> createState() => _CadastroCategoriaPageState();
}

class _CadastroCategoriaPageState extends State<CadastroCategoriaPage> {
  final _nomeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Categorias'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: BlocConsumer<CategoriaCubit, CategoriaState>(
            listener: (context, state) {
              if (state.mensagem != null) {
                _nomeController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.mensagem!)),
                );
              }
            },
            builder: (context, state) {
              final ocupado = state.carregando || state.salvando;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextField(
                    controller: _nomeController,
                    enabled: !ocupado,
                    maxLength: 100,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nome da categoria',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: ocupado
                        ? null
                        : (nome) => context
                            .read<CategoriaCubit>()
                            .salvarCategoria(nome),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: ocupado
                        ? null
                        : () => context
                            .read<CategoriaCubit>()
                            .salvarCategoria(_nomeController.text),
                    icon: const Icon(Icons.add),
                    label: Text(
                        state.salvando ? 'Salvando...' : 'Salvar categoria'),
                  ),
                  if (state.erro != null) ...[
                    const SizedBox(height: 12),
                    Text(state.erro!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  Row(children: [
                    const Expanded(
                        child: Text('Categorias cadastradas',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))),
                    IconButton(
                      tooltip: 'Atualizar categorias',
                      onPressed: ocupado
                          ? null
                          : () => context
                              .read<CategoriaCubit>()
                              .carregarCategorias(),
                      icon: const Icon(Icons.refresh),
                    ),
                  ]),
                  if (state.carregando) const LinearProgressIndicator(),
                  if (!state.carregando && state.categorias.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                          'Nenhuma categoria cadastrada. Cadastre a primeira acima.'),
                    ),
                  for (final categoria in state.categorias)
                    Card(
                        child: ListTile(
                      leading: const Icon(Icons.category_outlined),
                      title: Text(categoria.nome),
                    )),
                ],
              );
            },
          ),
        ),
      );
}
