# Sistema financeiro — Exercício 04

## Acesso local (padrão)

- Usuário: `admin`
- Senha: `admin123`
- Execute: `flutter run -d chrome --web-port=5173`

Não requer Supabase. Categorias e transações ficam salvas no armazenamento do
navegador, no mesmo endereço e perfil. Limpar os dados do site remove os registros.
O login é de demonstração local, não uma autenticação segura de servidor.
Não há cadastro de outras contas neste modo.

Cadastro de categorias com Modelo, Repository, State e Cubit; aba Categorias;
seleção obrigatória de categoria na criação e edição de transações;
persistência do ID em categoria_id e tratamento de carregamento e erros.

## Implementação anterior do Supabase (opcional)

O aplicativo usa repositórios locais por padrão. Os repositórios REST e o SQL
foram mantidos como referência e não são utilizados no modo local. Para retomá-los,
troque os repositórios em lib/main.dart e configure o banco conforme abaixo.

1. Execute supabase/exercicio_04.sql uma vez no SQL Editor do Supabase.
   O script pressupõe a tabela public.transacoes já existente das aulas.
2. As categorias formam um catálogo compartilhado pelos usuários autenticados.
   A tabela usa RLS para permitir leitura/cadastro autenticados e negar acesso anônimo.
   As políticas existentes de transações não são alteradas.
3. A chave estrangeira é transacoes.categoria_id. Transações antigas são preservadas;
   novas transações e edições exigem uma categoria. Após categorizar as antigas,
   a restrição pode ser validada conforme o comentário no SQL.
4. Execute com a URL e a chave publicável/anon do projeto (nunca service_role):

```powershell
flutter pub get
flutter run -d chrome --web-port=5173 --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=SUA_CHAVE_PUBLICAVEL
```

## Conferência manual

1. Faça login e cadastre uma categoria na aba Categorias.
2. Em Novo Lançamento, selecione a categoria e salve uma transação.
3. Edite pelo extrato e confira a seleção da categoria.
4. Reabra o aplicativo e confira a persistência dos dados.

## Validação local sem credenciais

```powershell
flutter analyze
flutter test
flutter build web
```

Os testes usam HTTP simulado para validar cadastro, falhas, seleção na interface,
serialização do ID e erro na edição. Eles não validam o banco remoto.
