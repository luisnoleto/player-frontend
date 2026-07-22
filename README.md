# Sistema de Registro de Ponto — Frontend

Aplicação Flutter para controle de jornadas, atividades e indicadores de uma
equipe. O frontend consome a API Spring Boot do projeto e oferece experiências
separadas para os perfis `GESTOR` e `COLABORADOR`.

## Funcionalidades

### Gestor

- Visão geral de jornadas, atividades planejadas e concluídas.
- Cadastro, inativação e reativação de colaboradores.
- Definição de perfil Gestor ou Colaborador no cadastro.
- Consulta de jornadas com filtros e detalhes expansíveis.
- Horas trabalhadas por colaborador nos últimos 30 dias.
- Relatórios consolidados por período e colaborador.
- Listagem dos planos, recursos, benefícios e contatos importados pelo RPA.

### Colaborador

- Início de jornada com planejamento de atividades.
- Encerramento de jornada com conclusão de atividades da jornada atual ou de
  jornadas anteriores.
- Registro de atividades não planejadas.
- Consulta de atividades pendentes e concluídas.
- Histórico de jornadas com detalhes e atividades expansíveis.

### Autenticação

- Login real por usuário e senha através de JWT.
- Redirecionamento de rota conforme o perfil retornado pela API.
- Envio automático do header `Authorization: Bearer <token>`.
- Logout e retorno automático ao login quando o token deixa de ser válido.
- Integração com o autofill do navegador/sistema para oferecer o salvamento das
  credenciais. A aplicação não armazena a senha diretamente.

O token JWT é mantido apenas em memória. Atualizar completamente a página ou
encerrar o aplicativo exige um novo login.

## Tecnologias

- Flutter e Dart
- Provider para gerenciamento de estado
- Dio para comunicação HTTP e interceptação do JWT
- go_router para navegação e proteção das rotas
- FlexColorScheme para o tema
- Lucide Icons
- flutter_animate
- intl

## Pré-requisitos

- Flutter compatível com Dart `3.12.2` ou superior
- API Spring Boot do projeto em execução
- PostgreSQL configurado no backend
- Chrome, emulador ou dispositivo compatível com Flutter

Confira a instalação do ambiente:

```powershell
flutter doctor
```

## Configuração da API

O endereço está centralizado em
[`lib/core/constants.dart`](lib/core/constants.dart):

```dart
const String apiServerUrl = 'http://localhost:8080';
```

Use o endereço adequado para o ambiente:

| Ambiente | Endereço |
|---|---|
| Flutter Web | `http://localhost:8080` |
| Simulador iOS | `http://localhost:8080` |
| Emulador Android | `http://10.0.2.2:8080` |
| Dispositivo físico | `http://IP_DA_MAQUINA:8080` |

Em um dispositivo físico, o computador e o aparelho precisam estar na mesma
rede, e a porta `8080` deve estar acessível.

## Instalação e execução

Instale as dependências:

```powershell
flutter pub get
```

Inicie o backend antes do frontend. Para executar no navegador:

```powershell
flutter run -d chrome
```

Para listar e escolher outro dispositivo:

```powershell
flutter devices
flutter run -d ID_DO_DISPOSITIVO
```

## Acesso de demonstração

O backend cria o gestor solicitado no desafio quando o seed está habilitado:

- Usuário: `playercontabilidade`
- Senha: o valor definido em `ADMIN_PASSWORD` no `.env` do backend — para a
  avaliação local, use `administrador`.

Colaboradores adicionais podem ser cadastrados pela Área de Gestão com perfil e
credenciais próprios.

## Integração com o RPA

A tela **Conteúdo do Portal Ponto Ágil** apenas consulta os dados persistidos
pela API. Para visualizar planos, recursos, benefícios e contatos, execute antes
o projeto Python `registro-ponto-rpa` seguindo o README daquele repositório.

## Estrutura principal

```text
lib/
├── core/       # Cliente HTTP, sessão, constantes e rotas
├── models/     # Modelos recebidos e enviados para a API
├── providers/  # Estado das jornadas, atividades, relatórios e colaboradores
├── screens/    # Telas de autenticação, gestão e colaborador
├── services/   # Integrações com os endpoints Spring Boot
├── theme/      # Tema visual da aplicação
└── widgets/    # Cards, indicadores e componentes reutilizáveis
```

O `ApiClient` é compartilhado por todos os services. Seu interceptor inclui o
JWT nas requisições autenticadas e encerra a sessão ao receber HTTP `401`.

## Testes e análise estática

```powershell
flutter test
flutter analyze
```

Para gerar uma versão Web:

```powershell
flutter build web
```

Os arquivos gerados ficam em `build/web` e não devem ser versionados.
