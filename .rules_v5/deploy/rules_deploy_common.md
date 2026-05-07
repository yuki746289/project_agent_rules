## 共通デプロイルール

- デプロイ前に、対象プロジェクト配下の `auto_deploy` フォルダを確認すること。
- `deploy_projects.psd1` を正本として、対象プロジェクトの `scriptId`、`deploymentId`、`supportsWebApp` を確認すること。
- `deploy_appscript.ps1` を原則的なデプロイ入口とすること。
- デプロイ後は `log/deploy_log.md` と、必要に応じて `log/task_checklist_log.md` を確認すること。
- Web アプリを持つプロジェクトでは、既存 URL を維持するか新規 deployment を作成するかを事前に確認すること。
- 新規 Apps Script プロジェクトの初回公開は、手動デプロイが必要になる可能性を考慮すること。

## 共通デプロイフロー

1. 対象プロジェクトを決める。
2. 対象プロジェクト配下の `auto_deploy/deploy_projects.psd1` を確認する。
3. `code` 配下、またはそのプロジェクトで定めた配置にある最新ファイルと固定名ファイルの対応を確認する。
4. `.clasp.json`、`.claspignore`、`code/appsscript.json` を確認する。
5. `deploy_appscript.ps1` を用いて `status`、`push`、`version` を行う。
6. `supportsWebApp=true` の場合は、`redeploy` か新規 deployment を実行する。
7. 新規 deployment を作成した場合は、新しい `deploymentId` を `deploy_projects.psd1` に反映する。
8. デプロイ結果を `log/deploy_log.md` に記録する。

## 初回手動デプロイ

- 新規 Apps Script プロジェクトでは、初回の Web アプリ公開を Apps Script 画面から手動で行う可能性がある。
- `clasp deploy` や `redeploy` だけで実行履歴が増えない場合は、手動デプロイを疑うこと。
- 手動デプロイ後に発行された `deploymentId` と `/exec` URL を、そのプロジェクト配下の `auto_deploy/deploy_projects.psd1` と記録用 md に反映すること。

## 初期設定

- `clasp` は `clasp.ps1` ではなく `clasp.cmd` を使うこと。
- 各プロジェクトの `.clasp.json`、`.claspignore`、`code/appsscript.json` を事前に確認すること。
- `rootDir`、対象ファイル、Web アプリ有無はプロジェクト配下の `auto_deploy` 設定に合わせること。

## トラブルシューティング

- `clasp` が実行できない場合は、`clasp.cmd` のパスとログイン状態を確認すること。
- `push` 対象が想定と違う場合は、`.clasp.json` の `rootDir` と `.claspignore` を確認すること。
- `redeploy` や `deployments` が失敗する場合は、ネットワークと権限を確認すること。
- Web アプリ URL が期待どおりでない場合は、既存 `deploymentId` の再利用か、新規 deployment かを見直すこと。
- `/exec` が期待どおりに反応しない場合は、`doGet()` / `doPost()`、`webapp.access`、`webapp.executeAs` を確認すること。
