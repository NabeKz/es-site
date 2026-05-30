# テスト方針

## ファイル構成

- テストは `test/features/<feature>_<usecase>_test.gleam` に配置する
- 1ファイル = 1ユースケース（1ユーザーストーリー）

## ユーザーストーリーとの紐づけ

テストファイルの先頭に対応するユーザーストーリーをコメントで記載する。

```gleam
// User Story: スタッフとして、レッスンのスケジュールを登録したい（requirements.md）
```

これによりテストファイルが Living Documentation として機能する。

## TDD の進め方

1. **Red** — `todo` でテスト関数を書いて観点を定義する
2. **Green** — アサーションを実装して通過させる
3. **Refactor** — 重複を整理する

未実装のシナリオは `todo` のまま残してよい。テストの存在自体がストーリーの未達を示す。

## テスト戦略：IO を外側に置く

このプロジェクトは「IO（DB・時刻・HTTP）を外側に追いやり、内側を純粋関数にする」設計を採用している。

```
[外側] handler / rdb.gleam  ← IO が集まる。実機テストで確認
[内側] command / query       ← 純粋関数。ユニットテストで網羅
```

- **内側（`command.gleam` / `query.gleam`）**: 副作用がないのでユニットテストが速くて安定する。ここを厚くする
- **外側（ハンドラー / アダプター）**: 薄いグルーコードなのでユニットテストの費用対効果が低い。実機（E2E・統合テスト）でまとめて確認する

ハンドラーのユニットテストを書かない理由もここにある。ビジネスロジックがなく、フレームワークの動作を検証するだけになるため。

## テストの書き方

- DB・HTTP に依存しない純粋なユニットテスト
- アダプターはクロージャで差し替える（本番実装と同じ依存性注入パターン）
- フィクスチャ関数（`fixture_lesson()` など）はファイル内に定義する

```gleam
pub fn create_lesson_success_test() {
  let save = fn(lesson: Lesson) { Ok(lesson) }
  let assert Ok(lesson) = command.create(save)(input)
  lesson.remaining_slots |> should.equal(lesson.capacity)
}
```

## テスト関数の命名

`<usecase>_<scenario>_test` の形式にする。

関数の1行上に `// test: <日本語名>` を書くと、CI の Step Summary にテスト名として表示される。

```gleam
// test: 作成直後の remaining_slots は capacity と同じになる
pub fn create_lesson_remaining_slots_equals_capacity_test() { ... }
```
