# Organizese - Sistema de Gestão de Folha de Pagamento

Um aplicativo Flutter completo para gerenciamento de funcionários, contracheques, benefícios, descontos e faltas.

##  Funcionalidades Principais

### Gestão de Funcionários
- Cadastro completo de funcionários
- Gerenciamento de cargos
- Controle de salários
- Vínculo com benefícios

### Contracheques
- Geração automática de contracheques mensais
- Cálculo automático de descontos obrigatórios:
  - **INSS** (progressivo conforme tabela 2025)
  - **IRRF** (calculado sobre base: Salário - INSS)
- Desconto automático de faltas não justificadas
- Adição de acréscimos (horas extras, bônus, etc.)
- Histórico completo por funcionário

### Controle de Faltas
- Registro de faltas com data e motivo
- Diferenciação entre faltas justificadas e não justificadas
- Cálculo automático de descontos (1/30 do salário por dia)
- Integração com contracheques

### Benefícios
- Cadastro de benefícios diversos
- Vínculo de benefícios aos funcionários
- Controle de valores

##  Tecnologias Utilizadas

- **Flutter** ^3.9.2
- **Firebase**
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Core
- **Intl** (formatação de datas e valores)
- **Motion Toast** (notificações)
- **Email Validator** (validação de e-mails)
- **Shared Preferences** (armazenamento local)

## Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada da aplicação
├── controller/                  # Lógica de negócio e controladores
│   ├── beneficio_controller.dart
│   ├── cargo_controller.dart
│   ├── contracheque_controller.dart
│   ├── controller_funcionario.dart
│   ├── desconto_controller.dart
│   ├── falta_controller.dart
│   └── funcionario_beneficio_controller.dart
├── domain/                      # Modelos de dados
│   ├── beneficio.dart
│   ├── cargo.dart
│   ├── contracheque.dart
│   ├── desconto.dart
│   ├── falta.dart
│   └── funcionario.dart
├── view/                        # Interfaces de usuário
│   ├── tela_inicial01.dart
│   ├── tela_cadastro_contracheque.dart
│   ├── tela_contracheques_funcionario.dart
│   ├── tela_cadastro_falta.dart
│   └── controle_interacao/      # Controladores de UI
└── util/                        # Utilitários e formatadores
    └── formatadores.dart
```

## Como Executar

### Pré-requisitos
- Flutter SDK (versão 3.9.2 ou superior)
- Dart SDK
- Android Studio / VS Code
- Conta Firebase configurada

### Instalação

1. Clone o repositório:
```bash
git clone <url-do-repositorio>
cd organizese
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Configure o Firebase:
   - Adicione o arquivo `google-services.json` em `android/app/`
   - Consulte `android/app/README_GOOGLE_SERVICES.md` para mais detalhes

4. Execute o aplicativo:
```bash
flutter run
```

## Cálculo de Descontos (2025)

### INSS - Progressivo
| Faixa Salarial | Alíquota |
|---------------|----------|
| Até R$ 1.518,00 | 7,5% |
| R$ 1.518,01 - R$ 2.793,88 | 9% |
| R$ 2.793,89 - R$ 4.190,83 | 12% |
| R$ 4.190,84 - R$ 8.157,41 | 14% |
| Acima de R$ 8.157,41 | Teto |

### IRRF - Sobre (Salário - INSS)
| Faixa | Alíquota | Dedução |
|-------|----------|---------|
| Até R$ 2.259,20 | Isento | - |
| R$ 2.259,21 - R$ 2.826,65 | 7,5% | R$ 169,44 |
| R$ 2.826,66 - R$ 3.751,05 | 15% | R$ 381,44 |
| R$ 3.751,06 - R$ 4.664,68 | 22,5% | R$ 662,77 |
| Acima de R$ 4.664,68 | 27,5% | R$ 896,00 |

### Faltas
- Desconto = (Salário ÷ 30 dias) × Número de faltas não justificadas

## Exemplo de Cálculo

**Funcionário:** Gerente  
**Salário Bruto:** R$ 10.000,00  
**Faltas não justificadas:** 1 dia

```
Salário Bruto:     R$ 10.000,00
(-) INSS:          R$    951,63
(-) IRRF:          R$  1.592,30
(-) Falta (1 dia): R$    333,33
= Salário Líquido: R$  7.122,74
```

## Segurança

- Autenticação via Firebase Authentication
- Dados armazenados no Firebase Database

