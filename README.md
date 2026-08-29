# 釣り 釣果×海況ログ

東京湾・相模湾・駿河湾（西伊豆〜三保）の釣果を、毎日自動で集めて
「潮回り・海水温・天気」とセットの一覧にする個人用ツール。予報は扱わない。

GitHub: `keidemoto-prog/fishing_info`（public）。スマホ閲覧は GitHub Pages。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `釣果ログ.html` | 閲覧ページ（PC用・編集の大元）。`data/*.js` を読むだけ。 |
| `docs/index.html` | GitHub Pages が配信するスマホ用ページ（＝データ同梱の単体版）。build-single.ps1 が生成。 |
| `tsuriha_all-in-one.html` | 同じ単体版（メール添付・オフライン用）。 |
| `dist/artifact.html` | 旧・claude.ai Artifact 用（任意・gitignore）。 |
| `artifact-url.txt` | 旧Artifact のURL（gitignore）。 |
| `data/catch-log.js` | 実データ（収集ジョブが毎日追記）。手編集も可。 |
| `data/catch-log.sample.js` | 画面確認用ダミー。実データが入ると使われない。 |
| `収集手順.md` | 毎日の収集プロンプト本体（＝エージェントの指示書）。 |
| `run-collect.ps1` | タスクスケジューラから呼ばれるランナー（収集→build→git push）。 |
| `build-single.ps1` | `釣果ログ.html`＋データ → `docs/index.html` ほかを生成。 |
| `logs/` | 日次の実行ログ。 |

## 使い方

### 見る
`釣果ログ.html` を開く。上のタブでエリア切替、下のタブでビュー切替。
- **最新** … 直近28日の釣果カード
- **一覧・検索** … 全記録の表。列クリックで並べ替え。絞り込みは **魚種（複数選択可）**・場所種別・潮回り・月・水温レンジ・期間。CSV書き出しあり。
- **魚種から探す** … 魚を選ぶと「釣れた月・水温レンジ・潮回り分布」がまとまる。（例：ブリ → 9〜12月中心／水温18〜25℃ が一目で分かる）
- **月 × 魚種** … いつ何が釣れているかのヒートマップ。セルクリックで一覧へ。

**水温・天気の見方**：太字（例 `25.2℃`）＝記事に書かれていた実測値。カッコ書き（例 `（27.0℃）`）＝釣行日・釣り場の近くの観測値（神奈川県水産技術センター リアルタイム海況／静岡県水産・海洋技術研究所／東京湾環境情報センター／Open-Meteo）。`≈` の行は近隣の天気・風・波・気温。水温レンジ検索・魚種サマリーはこの近隣値も含めて計算する。

### スマホで見る（GitHub Pages）

```
https://keidemoto-prog.github.io/fishing_info/
```

- スマホのブラウザで開いてブックマーク／ホーム画面に追加。
- **自動更新**：収集ジョブ（4回/日）が回るたびに `run-collect.ps1` が
  `docs/index.html` を作り直して `git push` → 1〜数分でPagesに反映。
- ローカルの `tsuriha_all-in-one.html` はメール添付・オフライン用の同じ内容。

（旧：claude.ai Artifact も残っているが手動更新。URLは `artifact-url.txt`。基本はPagesを使う。）

### 自動で集める（このPCで1日4回実行）

1. まず手動で動作確認：
   ```powershell
   cd "C:\Users\DEMOTO\Dropbox\Claude\Obsidian\釣り"
   .\run-collect.ps1
   ```
   `data/catch-log.js` に件数が増え、`logs/run-YYYY-MM-DD.log` が出て、`git push` が通れば成功
   （1〜数分で `https://keidemoto-prog.github.io/fishing_info/` に反映）。

2. タスクスケジューラに1日4回（0:00 / 6:00 / 12:00 / 18:00）で登録（1行）：
   ```
   schtasks /Create /TN "釣果ログ収集" /SC HOURLY /MO 6 /ST 00:00 /F /TR "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"C:\Users\DEMOTO\Dropbox\Claude\Obsidian\釣り\run-collect.ps1\""
   ```
   （`/SC HOURLY /MO 6 /ST 00:00` ＝ 0時起点で6時間おき）

3. （任意）PCがスリープしていて時刻を逃したとき用に、タスクスケジューラのGUIで
   当該タスク → プロパティ → 設定 →「スケジュールされた時刻にタスクを開始できなかった場合、すぐにタスクを実行する」にチェック。

登録内容の確認 / 手動実行 / 削除：
```
schtasks /Query /TN "釣果ログ収集" /V /FO LIST
schtasks /Run   /TN "釣果ログ収集"
schtasks /Delete /TN "釣果ログ収集" /F
```

## 調整したいとき
- 集める魚種・エリア・情報源 → `収集手順.md` を編集
- 実行時刻 → 上の schtasks を `/ST` 変えて再登録（`/F` で上書き）
- 画面の列・ビュー → `釣果ログ.html`

### GitHub Pages のセットアップ（初回だけ）

```powershell
cd "C:\Users\DEMOTO\Dropbox\Claude\Obsidian\釣り"
git push -u origin main        # ← 最初の1回。ブラウザ認証が出る。以後はキャッシュされる
```
その後 GitHub → リポジトリ Settings → Pages → Source =「Deploy from a branch」→
ブランチ `main` ／ フォルダ `/docs` → Save。数分で公開。

## 注意
- `run-collect.ps1` は無人実行のため `--dangerously-skip-permissions` で claude を起動する。
  処理は「Web閲覧 ＋ `data/catch-log.js` 追記」に限定した指示書（`収集手順.md`）で縛っている。
  そのあと `build-single.ps1` と `git add/commit/push` はランナー側で実行。
- 収集は claude CLI の通常利用分を消費する（別課金の定期実行サービスは使っていない）。
- `.ps1` は ASCII のみ・`$PSScriptRoot` 基準（Windows PowerShell 5.1 の日本語文字化け対策）。
  `claude.exe` のパスだけ `run-collect.ps1` 冒頭に直書き（環境依存）。
- 初回 `git push` を手でやらないと、無人実行の push が認証待ちで失敗する。
