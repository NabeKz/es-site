---
paths:
  - "frontend/**"
---

# フロントエンド設計方針

## ディレクトリ構造（FSD）

Feature-Sliced Design に沿ってファイルを配置する。

```
src/
├── app/          # ルーター・プロバイダーなどアプリ全体の設定
├── pages/
│   └── <page>/
│       ├── index.tsx   # Page エントリーポイントのみ
│       └── ui/         # ページ固有の UI コンポーネント
└── shared/
    ├── ui/        # 複数ページで使う共通コンポーネント・スタイル
    ├── lib/       # ユーティリティ関数
    └── generated/ # コード生成ファイル（手動編集禁止）
```

- コンポーネント（`.tsx`）はかならず `ui/` サブディレクトリに置く
- ユーティリティ（`.ts`）は `lib/` に置く
- ページをまたいで使うスタイルは `shared/ui/` に置く

## 日付操作

- 日付操作は `shared/lib/date.ts` に集約する
- `Intl.DateTimeFormatOptions` を呼び出し側に毎回渡さない
- 使うフォーマットパターンをあらかじめ関数として定義して提供する

```ts
// good
export const formatDateTime = (d: Date) =>
  d.toLocaleString("ja-JP", { month: "numeric", day: "numeric", hour: "2-digit", minute: "2-digit" })

// bad — 呼び出し側でオプションを組み立てる
export const formatDate = (d: Date, opts: Intl.DateTimeFormatOptions) =>
  d.toLocaleString("ja-JP", opts)
```

## API エラーハンドリング

### orval 生成クライアントはHTTPエラーで throw しない

生成された fetch クライアントは非2xx のレスポンスでも例外を投げず、ステータスコードをオブジェクトで返す。
`try/catch` だけでは 403・409 などを拾えず、成功扱いになってしまう。

### toResult / isOk を使う

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

### narrowing の注意

`if (result.ok)` を直接使うと TypeScript が else ブランチで narrowing しないケースがある（void 型との組み合わせ等）。必ず `isOk(result)` を使う。
