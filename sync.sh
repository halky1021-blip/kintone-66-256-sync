#!/bin/bash
set -e

# ====== 環境変数（GitHub Secretsから注入予定） ======
NORMAL_BASE_URL=$NORMAL_BASE_URL
NORMAL_APP_ID=$NORMAL_APP_ID
NORMAL_API_TOKEN=$NORMAL_API_TOKEN

GUEST_BASE_URL=$GUEST_BASE_URL
GUEST_SPACE_ID=$GUEST_SPACE_ID
GUEST_APP_ID=$GUEST_APP_ID
GUEST_API_TOKEN=$GUEST_API_TOKEN

FILE_NORMAL_TO_GUEST=normal_to_guest.csv
FILE_GUEST_TO_NORMAL=guest_to_normal.csv

# 添付ファイルと record_no を除外したフィールド一覧（拠点市区町村名を使用）
FIELDS="文字列__1行__6,文字列__1行__2,文字列__1行_,文字列__1行__0,職種,現職・退社,有り無し,ラジオボタン,生年月日,年齢,ドロップダウン_1,当社との契約,文字列__1行__1,リンク,リンク_0,リンク_1,HP,ルックアップ,日付_0,ルックアップ_0,日付,ルックアップ_1,日付_1,ルックアップ_3,日付_2,ルックアップ_2,日付_3,許可区分,文字列__1行__3,インボイス,文字列__複数行_"

echo "===== 通常 → ゲスト 同期開始 ====="
npx @kintone/cli record export \
  --base-url "$NORMAL_BASE_URL" \
  --app "$NORMAL_APP_ID" \
  --api-token "$NORMAL_API_TOKEN" \
  --encoding utf8 \
  --fields "$FIELDS" \
  > "$FILE_NORMAL_TO_GUEST"

npx @kintone/cli record import \
  --base-url "$GUEST_BASE_URL" \
  --guest-space-id "$GUEST_SPACE_ID" \
  --app "$GUEST_APP_ID" \
  --api-token "$GUEST_API_TOKEN" \
  --file-path "$FILE_NORMAL_TO_GUEST" \
  --encoding utf8 \
  --update-key "文字列__1行__6"

echo "===== ゲスト → 通常 同期開始 ====="
npx @kintone/cli record export \
  --base-url "$GUEST_BASE_URL" \
  --guest-space-id "$GUEST_SPACE_ID" \
  --app "$GUEST_APP_ID" \
  --api-token "$GUEST_API_TOKEN" \
  --encoding utf8 \
  --fields "$FIELDS" \
  > "$FILE_GUEST_TO_NORMAL"

npx @kintone/cli record import \
  --base-url "$NORMAL_BASE_URL" \
  --app "$NORMAL_APP_ID" \
  --api-token "$NORMAL_API_TOKEN" \
  --file-path "$FILE_GUEST_TO_NORMAL" \
  --encoding utf8 \
  --update-key "文字列__1行__6"

echo "✅ 双方向同期完了（文字列__1行__6をキーに更新モード）"
