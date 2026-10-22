import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/categoria_cubit.dart';
import 'repositories/local_repositories.dart';
import 'cubits/auth_cubit.dart';
import 'cubits/auth_state.dart';
import 'cubits/transacao_form_cubit.dart';
import 'cubits/transacao_cubit.dart';
import 'views/tela_principal.dart';
import 'views/login_page.dart';

void main() {
  runApp(const FinanceiroApp());
}

class FinanceiroApp extends StatelessWidget {
  const FinanceiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(repository: LocalAuthRepository()),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Controle Financeiro',
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
          home: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
            if (state is Authenticated) {
              final transacaoRepository = LocalTransacaoRepository();
              return MultiBlocProvider(providers: [
                BlocProvider<CategoriaCubit>(
                  create: (context) => CategoriaCubit(
                    repository: LocalCategoriaRepository(),
                  )..carregarCategorias(),
                ),
                BlocProvider<TransacaoCubit>(
                    create: (context) =>
                        TransacaoCubit(repository: transacaoRepository)
                          ..carregarTransacoes()),
                BlocProvider<TransacaoFormCubit>(
                    create: (context) => TransacaoFormCubit(
                        transacaoCubit: context.read<TransacaoCubit>()))
              ], child: const TelaPrincipal());
            }

            return const LoginPage();
          })),
    );
  }
}
