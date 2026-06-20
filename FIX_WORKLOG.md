# FIX_WORKLOG — KNOWN_ISSUES 対応の作業記録（codex 引き継ぎ用）

> `ISSUE_BACKLOG.md` の各項目に対し「いつ・何を・どのファイルのどこを・なぜ・どう検証
> したか」を記録する作業ログです。codex がそのまま続行できるよう、完了分と未対処分の
> 両方を残します。CTAN 配布物には含めません（`Makefile` の `CTAN_FILES` 非収録）。

## メタ情報

- 作業者: Claude Code (Opus 4.8)
- 着手: 2026-06-21 01:30 JST / リリース: 2026-06-21（v2.6.0）
- 基点コミット: `93c30de`（v2.5.3, master == dev）
- 対象環境: TeX Live 2026 (LuaHBTeX 1.24.0, e-upTeX), macOS (Hiragino 利用可)

### リリース後のブランチ構成

- `master` … v2.6.0（タグ `v2.6.0`）。`dev` をマージ。
- `dev` … v2.6.0。以降の開発はここから。
- 確実な修正・#1・引き継ぎは全て v2.6.0 に統合済み。作業用の `fix/known-issues` /
  `experiment/whitespace-lookahead` はマージ後に削除（dev + master の2本に統一）。

## 方針（ユーザー合意 2026-06-21）

1. 自信のある修正のみ実装し、必ずコンパイルで検証する。
2. 不安のある項目は別ブランチで実装案＋テストを行い、結果を記録して採否はメンテナへ。
3. upLaTeX 起因の不具合は対象外（gckanbun は LuaLaTeX 前提で開発）。
4. 機能/出力に改善が出た項目は version 更新・doc 更新・全 .tex 再コンパイル・zip・
   commit・push・master マージまで実施する。

---

## ステータス一覧

| # | 優先 | 対応 | 概要 |
|---|---|---|---|
| 1 | P1 | **Resolved (v2.6.0)** | コマンド間の空白/改行/コメントを無視（採用済み） |
| 2 | P1 | **Resolved（既存）** | doc.pdf が test.pdf に依存（Makefile に既存） |
| 3 | P1 | 未対応（案あり） | グリフ重なり/座標アサーション無し |
| 4 | P2 | **Resolved (v2.6.0)** | 不正 `intrusion` 値をエラー化 |
| 5 | P2 | **Resolved (v2.6.0)** | `make check`（LuaLaTeX ゲート）追加。upLaTeX は対象外 |
| 6 | P2 | **Resolved（既存）** | CTAN に upLaTeX edge を同梱済み |
| 7 | P2 | **対象外** | upLaTeX 回帰の限定性（LuaLaTeX 優先方針） |
| 8 | P2 | 未対応（案あり） | フォント非再現性（Hiragino 直指定） |
| 9 | P2 | 未対応（案あり） | 可変グローバル状態 |
| 10 | P3 | 未対応（案あり） | 横/縦テストの重複 |
| 11 | P3 | **Partly (v2.6.0)** | caption 警告解消。`paper=b5`・overfull は据え置き |
| 12 | P3 | 未対応（案あり） | CI 不在 |

---

## v2.6.0 で実装・検証済み

### #1 空白非感受性（採用）

- 原因: `\futurelet` 先読み（4 箇所）が直後トークン 1 個しか見ず、コマンド間の空白/
  改行で後続コマンド（`\返り`/`\送り` 等）を検出できず、重なり補正が外れ空白グルーも入る。
- 変更: `gckanbun.sty` の 4 箇所の `\futurelet\gckanbun@let@token <handler>` を
  `\peek_remove_spaces:n { … }` でラップ（全域 `\ExplSyntaxOn` 内、空白無視で安全）。
  対象ハンドラ: `\gcknbn@groupruby@trail`, `\gcknbn@furigana@okurigana`,
  `\gcknbn@okurigana@kaeriten`, `\gcknbn@kaeriten@kutoten`。
- 計測 (2026-06-21, LuaLaTeX/ltjsarticle/横組): 空白あり 26.45pt → 隣接と同一 23.12pt。
  jlreq 既定（HaranoAji）では隣接=空白=22.5pt。
- テスト: `gckanbun-edge-test-whitespace.tex` を追加（`\AssertSameWidth` で 6 ケース、
  改行ケース含む）。`make check` に組込み済み、全 PASS。
- 注意（既知の副作用）: `\peek_remove_spaces:n` は後続の明示的空白を全除去するため、
  横組で「ルビ付き文字直後に意図した空白＋欧文」を置くと空白が消え得る。漢文の縦組
  では通常問題にならない。気になる場合は「協調コマンド直後のみ除去」へ限定する余地あり。

### #4 不正 `intrusion` 値の検証

- 変更: `gckanbun.sty` の intrusion キーを `.tl_set:N` → l3keys `.choices:nn`。
  ruby=`{pre,post,both}`、okurigana/kaeriten=`{post,both}`。不正値で l3keys が自動エラー。
- 検証: probe `\振り[intrusion=typo]{天}{てん}` → exit=1
  （`Key 'gckanbun/ruby/intrusion' accepts only a fixed set of choices.`）。
  有効値は `make check` 全 PASS で挙動不変。

### #5 `make check`（LuaLaTeX 回帰ゲート）

- 変更: `Makefile` に `LUA_TESTS`/`LUA_TEST_PDFS` と `check` ターゲット。
  test / edge-test / edge-test-tate / **edge-test-whitespace** をビルド。
  latexmk は TeX エラーで非ゼロ終了するため成功＝対応エンジン通過。upLaTeX は方針で除外。

### #11 caption 警告（部分解消）

- 変更: `gckanbun-doc.tex` の `\usepackage{booktabs,caption}` → `booktabs`
  （`\caption` 系の使用なしを確認）。caption パッケージのロード自体が消え警告解消。
- 据え置き: `paper=b5`（→`paper=b5j` で JIS-B5 だが紙面寸法＝PDF が変わるため要判断）、
  overfull `\vbox`（約 0.71pt、軽微）。

### 既存対応の確認

- #2: `Makefile` に `gckanbun-doc.pdf: gckanbun-test.pdf` が既存（追加不要）。
- #6: `CTAN_FILES` に upLaTeX edge を同梱済み（方針上は開発専用扱いも可だが現状維持）。
- #7: LuaLaTeX 優先方針により対象外。

### リリース作業（2026-06-21）

- version: `gckanbun.sty`, `gckanbun-doc.tex`(\date と変更履歴), `README.md`,
  `CTAN-ANNOUNCEMENT.txt`, `CTAN-SUBMISSION.txt` を 2.6.0 に更新。
- doc: 「コマンド間の空白について」節と intrusion 検証の注記を追加。
- リネーム: `KNOWN_ISSUES.md` → `ISSUE_BACKLOG.md`、`KNOWN_ISSUES_HANDOFF.md` →
  `FIX_WORKLOG.md`（本ファイル）。Makefile/相互参照も更新。
- 全 .tex 再コンパイル＋ tracked PDF 更新、`make zip` 実施、commit/push/master マージ＋
  タグ `v2.6.0`。

---

## 未対応（実装案・codex 引き継ぎ）

### #3 重なり/座標アサーション（P1）

- 現状の edge-test は幅/高さ/深さのみ。グリフ実座標の重なりは検出不可。
- 案A（推奨）: `\directlua`/コールバックでノードリストを走査し隣接グリフの座標・境界箱を
  取得しアサーション化。既存アサーション機構に「重なりチェック」関数を追加。
- 案B: 安定 crop フィクスチャを生成し `pdftoppm`＋小許容差のピクセル比較。
- 着手点: 「返り点が親文字に重ならない」最小ケース 1 本を案A で。

### #8 フォント再現性（P2・要メンテナ判断）

- doc が macOS Hiragino を直指定（`gckanbun-doc.tex:24-38`）。他環境で代替/差異。
- 案: 既定ビルドを TeX Live 同梱の原ノ味（Harano Aji）へ（edge-test は既に HaranoAji
  で再現可能）。Hiragino は任意プロファイルとして残す。tracked PDF が変わる点に注意。
- 実験するなら別ブランチで Harano Aji 版を 1 度ビルドし体裁差を確認 → 採否。

### #9 可変グローバル状態（P2 risk）

- ルビ/送り/返りが複数のグローバル dim・bool で状態受け渡し。stale state の温床。
- 案（小・低リスク）: 各コマンド入口で intrusion 系 tl／group-follow フラグ／shift dim を
  防御的に初期化（既存 `\tl_clear:N` を網羅）。
- 案（大）: 注釈状態を単一の初期化/終了プロトコル（property list 等）へ集約。将来の
  メジャーで明示的合成コマンド化を検討。box/group/マクロ内/オプション解析失敗/ネスト時の
  テストを追加。

### #10 横/縦テストの重複（P3）

- `gckanbun-edge-test.tex` と `-tate.tex` が大半を手で重複。
- 案: 共有ケース＆アサーションを小サポートファイル（例 `gckanbun-edge-cases.tex`）に括り
  出し、各マトリクスは documentclass と direction ラッパのみに。別ブランチで `make check`
  一致確認後に採用。

### #12 CI（P3）

- 案: GitHub Actions に TeX Live 固定イメージで `make check`＋doc ビルド＋ログスキャン＋
  `make zip` を実行。TeX error / undefined / アサーション失敗 / 想定外 overfull で fail。
  upLaTeX はゲート外（任意で非ゲートジョブ）。ローカル検証不可のため別 PR 推奨。雛形:

```yaml
# .github/workflows/ci.yml （草案）
name: build
on: [push, pull_request]
jobs:
  lualatex:
    runs-on: ubuntu-latest
    container: texlive/texlive:latest
    steps:
      - uses: actions/checkout@v4
      - run: make check
      - run: make doc
      - run: make zip
```
