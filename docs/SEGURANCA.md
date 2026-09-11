# Pulso — Segurança

## Resolvido

### Password de serviço embutida na app — RESOLVIDO (Setembro 2026)

Até Setembro de 2026 a app fazia login automático com um email/password fixos
(`AuthConfig`), embutidos no binário. A password chegou a estar em texto no
repositório (commits `737dd34` e anteriores) — **já foi rodada no Supabase**
(o utilizador antigo foi apagado e recriado com a mesma conta de email, nova
password), o que torna a password antiga inútil mesmo continuando visível no
histórico do git.

A causa raiz foi corrigida: a app passou a ter um **ecrã de login real**
(`login_screen.dart` / `auth_service.dart`) — o utilizador escreve o seu
próprio email/password, geridos inteiramente pelo Supabase Auth. **Não há
nenhuma credencial de conta em código, ficheiro ou binário.** Quem não tiver
conta pode continuar a usar a app só localmente ("Continuar sem conta").

Não foi feita limpeza do histórico do git (`git filter-repo` + force-push) —
decisão consciente do utilizador, por ser destrutivo e desnecessário depois de
rodar a password.

## Acções pendentes (não urgentes)

### RLS por utilizador (multi-conta)

As políticas em `docs/supabase_rls.sql` são `to authenticated` — qualquer
conta autenticada vê as mesmas linhas. Está bem para uma única conta real
(a do dono da app). Se um dia mais do que uma pessoa usar o mesmo projecto
Supabase com conta própria, trocar para `user_id = auth.uid()` — ver plano em
`docs/ARQUITECTURA.md` §7.

## O que já está tratado no código

| Item | Estado |
|---|---|
| Login | Real, por utilizador, via Supabase Auth — sem credenciais na app |
| `lib/config/supabase_config.dart` | Opcional, fora do git (`.gitignore`), com modelo `.example.dart` |
| URL + anon key | Via `--dart-define-from-file=secrets.json` (`secrets.example.json` no repo, `secrets.json` fora) |
| RLS | Activo nas 3 tabelas (`docs/supabase_rls.sql`), testado com `curl` sem sessão → bloqueia |
| `lib.zip`, `pulso_backup.json`, `android/build/` | Ignorados pelo `.gitignore` |
| Restauro de backup / eliminações | Pedem confirmação; import é atómico (transação) |
| Falhas de sync/backup | Visíveis ao utilizador (SnackBar vermelho), não silenciosas |

---

## Notas para publicação (Play Store)

- A permissão **SMS** (`telephony`) é sensível. A Google exige justificação e
  normalmente rejeita apps que não sejam SMS-handler por omissão. Se a app for
  publicada, ou remover a leitura de SMS, ou preparar o formulário de
  declaração de permissões.
- A permissão de **acesso a notificações** (`notification_listener_service`)
  é igualmente sensível e escrutinada — precisa de justificação clara na ficha
  da Play Store.
- Não commitar `key.properties`, keystores (`*.jks`/`*.keystore`) nem
  `google-services.json` com chaves reais.
