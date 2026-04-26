## 詳細設計書の確認

- [ ] **S-ID対応の整合性:** Markdown内の各 `[Lxxx]` の説明末尾に、対応する基本設計のステップID `(Sxxx)` が漏れなく記載されているか。

- JSONファイル（_3_detail.json）の確認
  - [ ] **IDの重複と漏れ:** Markdown内のロジック（`[Lxxx]`）から呼び出されている全ての関数・変数が、JSONファイル（_3_detail.json）に `[Fxxx]`, `[Vxxx]` として漏れなく定義されているか。
  - [ ] **命名の整合性:** Markdown内の説明文で使用している変数名・関数名が、JSONの定義と完全に一致しているか。
  - [ ] **JSONの完全性:** 実装時に迷いが生じないよう、JSON側に引数の型、戻り値、役割、使用箇所、状態が網羅されているか。

- 作成した詳細設計書と、参照した前バージョンの詳細設計書を比較して、詳細設計書の仕様通りの修正が出来ているかを確認して下さい。

- 詳細設計の確認が完了したら、実装に入る前に、全仕様を以下の形式のJSONにコンパイル（出力）して下さい。  
  ファイル名は、`{filename}_v{n}.{m}_4_detail.json` とします。  
  実装コードはこのJSONの項目を1つも漏らさずカバーしなければなりません。

  ```json
  {
    "version": "21.1",
    "features": [
      {"id":"L101","sourceStepId":"S001","type":"KEEP","summary":"EMA計算処理を維持","targetFunction":"selectEma"},
      {"id":"L103","sourceStepId":"S002","type":"MOD","summary":"アラート条件を変更","targetFunction":"updateAlertCondition"},
      {"id":"L104","sourceStepId":"S003","type":"ADD","summary":"ログ出力切替を追加","targetFunction":"selectIsOutputLog"}
    ],
    "functions": [
      {"id":"F101","type":"KEEP","name":"selectEma"},
      {"id":"F103","type":"MOD","name":"updateAlertCondition"},
      {"id":"F104","type":"ADD","name":"selectIsOutputLog"}
    ],
    "variables": [
      {"id":"V101","type":"KEEP","name":"listEma"},
      {"id":"V104","type":"ADD","name":"isOutputLog"}
    ],
    "deleted_features": ["L099"],
    "deleted_functions": ["F099"],
    "deleted_variables": ["V099"],
    "constraints": ["request_limit_40"],
    "invariants": ["KEEPタグ部分の既存出力を変えない"]
  }
  ```
