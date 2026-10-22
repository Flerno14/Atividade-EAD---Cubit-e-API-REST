import 'package:flutter_bloc/flutter_bloc.dart';
import 'transacao_state.dart';
import '../models/transacao.dart';
import '../repositories/transacao_repository.dart';

class TransacaoCubit extends Cubit<TransacaoState> {
  List<Transacao> _transacoes = [];
  final TransacaoRepository repository;

  TransacaoCubit({required this.repository})
      : super(TransacaoLoaded(
            transacoes: [],
            saldoTotal: 0.0,
            saldoReceitas: 0.0,
            saldoDespesas: 0.0));

  Future<void> carregarTransacoes() async {
    try {
      _transacoes = await repository.buscarTransacoes();
      _calcularSaldos();
    } catch (e) {
      emit(TransacaoError(message: 'Erro ao carregar dados do Supabase. $e'));
    }
  }

  Future<void> adicionarTransacao(Transacao transacao) async {
    final novaTransacao = await repository.criarTransacao(transacao);
    //_transacoes.add(novaTransacao);
    _transacoes.insert(0, novaTransacao);
    _calcularSaldos();
  }

  Future<void> atualizarTransacao(Transacao transacaoAtualizada) async {
    await repository.atualizarTransacao(transacaoAtualizada);
    await carregarTransacoes();
    /*final index = _transacoes.indexWhere((item) => item.id == transacaoAtualizada.id);

    if (index != -1) {
      _transacoes[index] = transacaoAtualizada;
      _calcularSaldos();
    }*/
  }

  Future<void> excluirTransacao(String id) async {
    try {
      await repository.excluirTransacao(id);
      await carregarTransacoes();
    } catch (e) {
      emit(TransacaoError(message: 'Erro ao excluir: $e'));
    }
    // _transacoes.removeWhere((item) => item.id == id);
    // _calcularSaldos();
  }

  void _calcularSaldos() {
    double saldoReceitas = 0.0;
    double saldoDespesas = 0.0;

    for (final item in _transacoes) {
      if (item.tipo == TipoTransacao.receita) {
        saldoReceitas += item.valor;
      } else {
        saldoDespesas += item.valor;
      }
    }

    final saldoTotal = saldoReceitas - saldoDespesas;

    emit(TransacaoLoaded(
        transacoes: List.unmodifiable(_transacoes),
        saldoTotal: saldoTotal,
        saldoReceitas: saldoReceitas,
        saldoDespesas: saldoDespesas));
  }
}
