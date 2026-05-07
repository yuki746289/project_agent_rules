## デプロイルール

### 参照方針
- プロジェクト固有のデプロイ手順は、各プロジェクト配下の `auto_deploy` フォルダを正本として参照すること。
- 各プロジェクトは独立して扱い、他プロジェクトとの比較を前提に手順を組まないこと。

### 必ず守るルール
- 共通ルール: `_rules/rules_common.md`
- デプロイ共通ルール: `_rules/deploy/rules_deploy_common.md`

### プロジェクト別参照
- 対象プロジェクト配下の `auto_deploy/` を参照すること。
- 例:
  - `appScript/auto_deploy/`
  - `appScript_v2/auto_deploy/`
