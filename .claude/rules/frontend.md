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
