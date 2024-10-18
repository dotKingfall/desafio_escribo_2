# desafio_tecnico_2

clonar repositório / download .zip
abrir pasta do projeto
executar ($ flutter pub get) na pasta do projeto para atualizar as dependências
utilizar um emulador ou celular pela IDE para instalar o aplicativo

OU

Instalar o apk "testeescbrio2.apk" e tá tudo certo kkkk

Existem 3 abas no aplicativo: Livros, Favoritos e Offline.
A aba de livros recebe os dados diretamente da API, e exibe mensagem de erro caso haja falha na conexão.

Infelizmente a aba de favoritos só funciona com internet, já que ele pega os dados da lista que a API manda.
Inicialmente Favoritos e Offline deveriam pegar dados do banco de dados, que está salvando e lendo arquivos, mas como perdi
tempo demais tentando fazer alguma verificação de diferença de dados para atualizar o banco de dados, só o backend ficou pronto,
mesmo que não tenha muita utilidade agora.

Os marcadores funcionam da maneira descrita no documento com as especificações.
A primeira vez que um livro for ser aberto, um dialog aparecerá informando que o livro está sendo baixado.
Não salvei o estado da leitura, mas parece simples, já que é só um JSON com as informações de onde o usuário parou no documento.

Após rever o documetno, vi que o versionamento precisava acontecer no github, quando me dei conta, parte da aba "Livros" estava concluída, ou
pelo menos o container no queal fica a foto.
