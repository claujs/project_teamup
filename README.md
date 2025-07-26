# TeamUp - Rede Social Interna

**TeamUp** é uma aplicação móvel Flutter desenvolvida para conectar funcionários dentro de uma empresa, facilitando a descoberta de perfis e interação básica entre equipes.

## 📱 Funcionalidades

### ✅ Implementadas

- **Autenticação**: Login com e-mail e senha com persistência de sessão
- **Listagem de Usuários**: Consumo da API ReqRes.in com paginação e busca por nome
- **Perfil de Usuário**: Tela de detalhes com informações simuladas (cargo, área, biografia)
- **Feed de Postagens**: Feed com postagens simuladas contendo texto, autor, data e fotos
- **Modo Offline**: Cache local para usuários e posts funcionando sem conexão
- **Testes**: Testes unitários e de widget implementados
- **Favoritos**: Adição e remoção de usuários favoritos com persistência local para modo offline.

## 🏗️ Arquitetura

### Clean Architecture

O projeto utiliza **Clean Architecture** com separação clara de responsabilidades:

```
lib/
├── core/                    # Configurações globais e utilitários
│   ├── constants/          # Constantes da aplicação
│   ├── errors/             # Classes de erro personalizadas
│   ├── network/            # Cliente HTTP e gerenciamento de rede
│   ├── storage/            # Persistência local
│   └── providers.dart      # Providers Riverpod
├── features/               # Funcionalidades por módulo
│   ├── auth/              # Autenticação
│   │   ├── data/          # Repositórios e fontes de dados
│   │   ├── domain/        # Entidades e contratos
│   │   └── presentation/  # UI e gerenciamento de estado
│   ├── users/             # Usuários
│   └── posts/             # Postagens
└── shared/                # Componentes compartilhados
    ├── screens/           # Telas compartilhadas
    └── widgets/           # Widgets reutilizáveis
```

### Por que Clean Architecture?

- **Escalabilidade**: Facilita a adição de novas funcionalidades
- **Testabilidade**: Camadas independentes permitem testes isolados
- **Manutenibilidade**: Separação clara de responsabilidades
- **Flexibilidade**: Permite mudanças de tecnologia sem impacto nas regras de negócio

## 🛠️ Tecnologias e Bibliotecas

### Gerenciamento de Estado

**Riverpod** foi escolhido por:

- Performance superior ao Provider
- Melhor developer experience com compile-time safety
- Facilidade para testes
- Sintaxe mais limpa e moderna

### Persistência Local

**Hive + SharedPreferences**:

- **Hive**: Para objetos complexos (cache de usuários e posts)
- **SharedPreferences**: Para dados simples (tokens, configurações)

### Principais Dependências

```yaml
dependencies:
  # Estado
  flutter_riverpod: ^2.5.1

  # HTTP
  dio: ^5.4.3+1

  # Persistência
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.3

  # Navegação
  go_router: ^14.1.4

  # Serialização
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

  # Utils
  faker: ^2.1.0
  dartz: ^0.10.1

  # UI
  cached_network_image: ^3.3.1

  # Network
  connectivity_plus: ^6.0.3
```

## 🚀 Como Executar

### Pré-requisitos

- Flutter 3.8.1 ou superior
- Dart SDK compatível

### Comandos

```bash
# 1. Instalar dependências
flutter pub get

# 2. Gerar código (freezed, json_serializable)
dart run build_runner build

# 3. Executar aplicação
flutter run

# 4. Executar testes
flutter test
```

## 🔐 Credenciais de Teste

Para testar a aplicação, use as credenciais da API ReqRes.in:

- **E-mail**: eve.holt@reqres.in
- **Senha**: cityslicka

## 📊 Funcionalidades Offline

O aplicativo mantém funcionalidade completa offline através de:

- **Cache de Usuários**: Lista de usuários fica disponível mesmo sem internet
- **Cache de Posts**: Feed continua funcionando offline
- **Persistência de Autenticação**: Usuário permanece logado
- **Detecção de Conectividade**: Interface adaptável ao status da conexão

## 🧪 Testes

### Cobertura Implementada

- **Testes Unitários**: Entidades, modelos e lógicas de negócio
- **Testes de Widget**: Componentes visuais isolados
- **Estrutura Preparada**: Para testes de integração futuros

```bash
# Executar todos os testes
flutter test

# Executar testes com cobertura
flutter test --coverage
```

## 🎨 Design e UX

### Características

- **Material Design 3**: Interface moderna e consistente
- **Responsivo**: Adaptável a diferentes tamanhos de tela
- **Loading States**: Feedback visual durante carregamento
- **Error Handling**: Tratamento elegante de erros
- **Pull-to-Refresh**: Atualização intuitiva de dados

### Responsividade Avançada

O app foi desenvolvido com responsividade avançada para tablets, oferecendo layouts adaptativos que aproveitam melhor o espaço disponível em telas maiores:

#### 🎨 Recursos de Responsividade

**1. Layouts Adaptativos**

- **Mobile**: Layout tradicional com navegação inferior
- **Tablet Portrait**: NavigationBar expandida e conteúdo mais espaçoso
- **Tablet Landscape**: NavigationRail lateral com layout Master-Detail

**2. Breakpoints Inteligentes**

```dart
- Mobile: < 600px
- Tablet: 600px - 900px
- Desktop: > 900px
```

**3. Componentes Responsivos**

- **ResponsiveBuilder**: Renderiza diferentes layouts baseado no tamanho da tela
- **ResponsiveContainer**: Aplica constraints e padding responsivos automaticamente
- **ResponsiveGrid**: Grid adaptativo que ajusta número de colunas
- **ResponsiveMasterDetail**: Layout Master-Detail para tablets em landscape

**4. Exemplos de Uso**

```dart
// Widget com layouts diferentes para cada tamanho
ResponsiveBuilder(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)

// Container com largura máxima responsiva
ResponsiveContainer(
  child: MyContent(),
)

// Grid que se adapta ao tamanho da tela
ResponsiveGrid(
  children: items,
  spacing: 16,
)
```

**5. Experiência do Usuário**

- **Feed**: Grid de posts em tablets, lista em mobile
- **Usuários**: Cards em grid para tablets, lista para mobile
- **Navegação**: NavigationRail em tablets landscape para mais espaço útil
- **Formulários**: Campos maiores e melhor espaçamento em tablets
- **Master-Detail**: Visualização lado a lado em tablets landscape

#### 📱 Testando Responsividade

Para testar os diferentes layouts:

1. **No Chrome DevTools**: Use o modo dispositivo e teste diferentes tamanhos
2. **Em Dispositivos Físicos**: Teste em tablets reais para melhor experiência
3. **Orientação**: Gire o dispositivo para ver transições entre layouts

## 📱 Estrutura de Navegação

```
LoginScreen → HomeScreen
                ├── FeedScreen (Tab 1)
                └── UsersScreen (Tab 2)
                    └── UserDetailScreen
```

## 🔄 Fluxo de Dados

1. **API Request** → **Repository** → **Cache Local**
2. **Offline Detection** → **Cache Retrieval**
3. **State Management** → **UI Update**

## 🌍 Internacionalização (i18n)

A aplicação suporta múltiplos idiomas com mudança dinâmica:

### Idiomas Suportados

- **Português (pt)** - Idioma padrão
- **English (en)** - Idioma secundário

### Como Funciona

- **Mudança de Idioma**: Botão na AppBar principal (ícone de mundo 🌍)
- **Persistência**: Idioma selecionado é salvo localmente
- **Atualização em Tempo Real**: Interface atualiza instantaneamente

### Estrutura

```
lib/l10n/
├── app_pt.arb          # Strings em português
├── app_en.arb          # Strings em inglês
└── app_localizations.dart  # Classes geradas automaticamente
```

### Adicionar Novas Strings

1. Adicione a string em `app_pt.arb` e `app_en.arb`
2. Execute `flutter gen-l10n` para gerar as classes
3. Use `AppLocalizations.of(context)!.suaString` no código

## 🚧 Melhorias Futuras

### Funcionalidades Extras (Diferenciais)

- [x] **Internacionalização (i18n)**: Suporte a múltiplos idiomas (Português/Inglês)
- [ ] **CI/CD**: GitHub Actions para testes e build automático
- [ ] **Modularização**: Separação em packages independentes
- [x] **Responsividade Avançada**: Layouts adaptativos para tablets
- [ ] **Tema Escuro**: Suporte a dark mode
- [ ] **Notificações Push**: Sistema de notificações
- [x] **Chat em Tempo Real**: Mensagens entre usuários
- [x] **Filtros Avançados**: Busca por departamento, cargo, etc.
- [x] **Favoritos com Offline Support**

## 📝 Decisões Técnicas

### Arquitetura

- **Clean Architecture**: Para escalabilidade e manutenibilidade
- **Feature-first**: Organização por funcionalidades ao invés de camadas

### Clean Code e SOLID

O projeto segue princípios de Clean Code e SOLID:

- **Single Responsibility Principle (SRP)**: Cada classe e módulo tem uma única responsabilidade (ex: repositórios lidam apenas com dados).
- **Open-Closed Principle (OCP)**: Entidades e repositórios são extensíveis sem modificação.
- **Liskov Substitution Principle (LSP)**: Classes derivadas podem substituir as bases sem alterar o comportamento.
- **Interface Segregation Principle (ISP)**: Interfaces específicas por funcionalidade.
- **Dependency Inversion Principle (DIP)**: Dependências injetadas via Riverpod.
- **Clean Code Practices**: Nomes descritivos, funções curtas, comentários onde necessário, e código legível.

### Estado

- **Riverpod**: Para gerenciamento de estado reativo e performático
- **Freezed**: Para imutabilidade e serialização automática

### Persistência

- **Estratégia Híbrida**: Hive para complexidade, SharedPreferences para simplicidade
- **Cache First**: Prioriza dados locais para melhor performance

### Rede

- **Dio**: Cliente HTTP robusto com interceptors
- **Error Handling**: Tratamento específico por tipo de erro

## 👥 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

**Desenvolvido com ❤️ usando Flutter**
