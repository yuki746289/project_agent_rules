## 詳細設計書の確認

- 作成した詳細設計書と、参照した前バージョンの詳細設計書を比較して、詳細設計書の仕様通りの修正が出来ているかを確認して下さい。
- 詳細設計の確認が完了したら、実装に入る前に、全仕様を以下の形式のJSONにコンパイル（出力）して下さい。<br>
  ファイル名は、`{filename}_v{n}.{m}_4_detail.json`とします。<br>
  実装コードはこのJSONの項目を1つも漏らさずカバーしなければなりません。

  ``` json
  {
    "version": "21.1",
    "features": [
      {"id":"L101","type":"KEEP","summary":"EMA計算処理を維持","targetFunction":"selectEma"},
      {"id":"L103","type":"MOD","summary":"アラート条件を変更","targetFunction":"updateAlertCondition"},
      {"id":"L104","type":"ADD","summary":"ログ出力切替を追加","targetFunction":"selectIsOutputLog"}
    ],
    "deleted_features": ["L099"],
    "constraints": ["request_limit_40"],
    "invariants": ["KEEPタグ部分の既存出力を変えない"]
  }
  ```

