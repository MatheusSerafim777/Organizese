# ⚠️ ATENÇÃO - google-services.json

## 🚨 NÃO EDITE ESTE ARQUIVO MANUALMENTE

Este arquivo é **gerado automaticamente** a partir das variáveis de ambiente definidas no arquivo `.env` na raiz do projeto.

## 🔄 Como Atualizar

Se você precisa alterar as configurações do Firebase:

1. Edite o arquivo `.env` na raiz do projeto
2. Execute o comando: `dart run scripts/generate_google_services.dart`
3. Este arquivo será regenerado automaticamente

## 🔐 Segurança

- ✅ Este arquivo está no `.gitignore` e **NÃO** será commitado
- ✅ Cada desenvolvedor gera sua própria versão local
- ✅ As credenciais reais ficam no arquivo `.env`

## 📝 Estrutura

Este arquivo contém:
- API Key do Firebase
- Project ID
- Storage Bucket
- Mobile SDK App IDs
- Package Names

Todas essas informações vêm do arquivo `.env`.

## 🆘 Problemas?

Se este arquivo estiver faltando ou desatualizado:

```powershell
dart run scripts/generate_google_services.dart
```

---

**Arquivo gerado automaticamente - Última geração:** ${DateTime.now().toString()}
