# Atividade-EAD---Cubit-e-API-REST


Unidade Curricular: Desenvolvimento para Dispositivos Móveis 
Professor: Felipe Demarchi 

Continue o desenvolvimento do aplicativo de sistema financeiro criado em sala de aula 
para adicionar as seguintes funcionalidades. - - 

Cadastro de Categorias - 

    Criar uma tabela no Supabase para o cadastro das categorias. - - 
    
    Criar uma tela para o Cadastro de Categorias, seguindo o padrão de utilização das classes de Modelo, Repository e Cubit. 
    
    Analisar e desenvolver uma opção para acesso a tela de categorias. 

Solicitar uma categoria no cadastro de transação: - 

    Na tabela de cadastro de transações no Supabase, criar uma chave estrangeira para a tabela de categorias. - - 
    
    No formulário de cadastro de transação, criar um novo campo para selecionar a categoria referente a transação. Este campo deve apresentar apenas as categorias cadastradas na tela anterior. 
    
    Ao salvar uma nova transação, deverá salvar juntamente na tabela do Supabase o id da categoria selecionada. 

Critérios de Avaliação 
  1) Criou e implementou a classe de modelo para a Categoria. 
  2) Criou e implementou a classe de repository para a Categoria. 
  3) Criou e implementou a classe de State para a Categoria. 
  4) Criou e implementou a classe de Cubit para a Categoria. 
  5) Criou uma tela de cadastro de categoria. 
  6) Na tela de cadastro de categoria, fez uso da estrutura de Cubits implementada. 
  7) A tela de cadastro de categoria está salvando as novas categorias. 
  8) Criou uma forma de acesso a tela de cadastro de categoria a partir do aplicativo 
  já existente? 
  9) No formulário de transações, adicionou um campo para seleção da categoria. 
  10) As categorias apresentadas são obtidas a partir do banco de dados, com base nas 
  categorias cadastradas na tela de cadastro de categorias. 
  11) Ao salvar uma transação, está salvando o ID da Categoria relacionada a 
  transação.
