# Pulso — Segurança

## ⚠️ Acções manuais obrigatórias (ainda por fazer)

Estas não podem ser feitas só com código — dependem do painel do Supabase e do
histórico do git.

### 1. Rodar a password do Supabase — URGENTE

A password do utilizador de serviço esteve em texto no repositório e **continua
visível no histórico do git** (commit `737dd34` e anteriores):

```bash
git show 737dd34:lib/config/auth_config.dart   # a password aparece aqui
```

Remover o ficheiro do `HEAD` (feito no commit `78a26eb`) **não apaga o
histórico**. Enquanto a password não for mudada, considera-a comprometida.

**Fazer:**
1. Supabase → Authentication → Users → mudar a password do utilizador de serviço.
2. Actualizar o `lib/config/auth_config.dart` local (que está gitignored) **ou**
   passar por `--dart-define=AUTH_PASSWORD=...`.

**Opcional (limpar o histórico):** reescrever o histórico com
[`git filter-repo`](https://github.com/newren/git-filter-repo) ou a BFG e fazer
`push --force`. É destrutivo e afecta qualquer clone existente — só vale a pena
se o repositório vier a ser público.

### 2. Confirmar Row Level Security (RLS) no Supabase

A `anonKey` é pública por design. **Só é segura com RLS activo.** Sem RLS,
qualquer pessoa com a chave (que está no APK) lê e apaga todas as tabelas.

**Fazer:** Supabase → Table Editor → para `goals`, `tasks`, `transactions`:
- `Enable RLS`
- Criar políticas. Enquanto for conta única partilhada, no mínimo exigir
  utilizador autenticado:
  ```sql
  create policy "auth pode tudo" on public.transactions
    for all using (auth.role() = 'authenticated')
    with check (auth.role() = 'authenticated');
  ```
- Quando existir login por utilizador: adicionar coluna `user_id uuid default auth.uid()`
  e trocar as políticas para `user_id = auth.uid()`.

---

## O que já está tratado no código

| Item | Estado |
|---|---|
| `lib/config/auth_config.dart` | Fora do git (`.gitignore`), com modelo `.example.dart` |
| `lib/config/supabase_config.dart` | Idem |
| Segredos por `--dart-define` | Suportado (`String.fromEnvironment`) — permite não ter segredos no disco |
| `lib.zip`, `pulso_backup.json`, `android/build/` | Ignorados pelo `.gitignore` |
| Restauro de backup / eliminações | Pedem confirmação; import é atómico (transação) |
| Falhas de sync/backup | Já visíveis ao utilizador (SnackBar vermelho), não silenciosas |

---

## Notas para publicação (Play Store)

- A permissão **SMS** (`telephony`) é sensível. A Google exige justificação e
  normalmente rejeita apps que não sejam SMS-handler por omissão. Se a app for
  publicada, ou remover a leitura de SMS, ou preparar o formulário de
  declaração de permissões.
- Não commitar `key.properties`, keystores (`*.jks`/`*.keystore`) nem
  `google-services.json` com chaves reais.
