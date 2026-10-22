-- Execute uma vez no SQL Editor. Requer public.transacoes já existente.
-- Catálogo compartilhado pelos usuários autenticados do aplicativo.
begin;
create table public.categorias (
  id uuid primary key default gen_random_uuid(),
  nome text not null check (char_length(btrim(nome)) between 1 and 100),
  created_at timestamptz not null default now()
);
create unique index categorias_nome_unico on public.categorias (lower(btrim(nome)));
alter table public.categorias enable row level security;
revoke all on public.categorias from anon;
grant select, insert on public.categorias to authenticated;
create policy categorias_leitura on public.categorias
  for select to authenticated using (true);
create policy categorias_cadastro on public.categorias
  for insert to authenticated with check (true);
alter table public.transacoes
  add column categoria_id uuid references public.categorias(id) on delete restrict;
create index transacoes_categoria_id_idx on public.transacoes(categoria_id);
-- Preserva registros antigos. Novas inserções e edições exigem categoria.
alter table public.transacoes add constraint transacoes_categoria_obrigatoria
  check (categoria_id is not null) not valid;
commit;
-- Após categorizar os registros antigos:
-- alter table public.transacoes validate constraint transacoes_categoria_obrigatoria;
