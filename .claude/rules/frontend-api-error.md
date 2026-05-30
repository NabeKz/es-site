# API エラーハンドリング

## orval 生成クライアントはHTTPエラーで throw しない

生成された fetch クライアントは非2xx のレスポンスでも例外を投げず、ステータスコードをオブジェクトで返す。
`try/catch` だけでは 403・409 などを拾えず、成功扱いになってしまう。

## toResult / isOk を使う

`shared/lib/api.ts` の `toResult` でレスポンスを `ApiResult` に変換し、`isOk` で分岐する。

```ts
const result = toResult(await cancelReservation(id))
if (isOk(result)) {
  // result.data が使える
} else {
  // result.status でエラー種別を判別
  setState(result.status === 409 ? "deadline_passed" : "error")
}
```

## narrowing の注意

`if (result.ok)` を直接使うと TypeScript が else ブランチで narrowing しないケースがある（void 型との組み合わせ等）。必ず `isOk(result)` を使う。
