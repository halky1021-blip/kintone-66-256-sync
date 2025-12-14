#!/bin/bash
set -e

# ====== 環境変数 ======
NORMAL_BASE_URL=$NORMAL_BASE_URL
NORMAL_APP_ID=$NORMAL_APP_ID
NORMAL_API_TOKEN=$NORMAL_API_TOKEN

GUEST_BASE_URL=$GUEST_BASE_URL
GUEST_SPACE_ID=$GUEST_SPACE_ID
GUEST_APP_ID=$GUEST_APP_ID
GUEST_API_TOKEN=$GUEST_API_TOKEN

FILE_NORMAL_TO_GUEST=normal_to_guest.csv

# ====== 同期対象フィールド ======
# ※ 両アプリに存在し、update-key はユニーク設定必須
FIELDS="文字列__1行__6,文字列__1行__2,文字列__1行_,文字列__1行__0,職種,現職・退社,有り無し,ラジオボタン,生年月日,年齢,ドロップダウン_1,当社との契約,文字列__1行__1,リンク,リンク_0,リンク_1,HP,ルックアップ,日付_0,ルックアップ_0,日付,ルックアップ_1,日付_1,ルックアップ_3,日付_2,ルックアップ_2,日付_3,許可区分,文字列__1行__3,インボイス,文字列__複数行_"

echo "===== 通常 → ゲスト 同期開始 ====="

# --- 通常アプリからエクスポート ---
npx @kintone/cli record export \
  --base-url "$NORMAL_BASE_URL" \
  --app "$NORMAL_APP_ID" \
  --api-token "$NORMAL_API_TOKEN" \
  --encoding utf8 \
  --fields "$FIELDS" \
  > "$FILE_NORMAL_TO_GUEST"

# --- ゲストアプリへインポート（更新のみ） ---
npx @kintone/cli record import \
  --base-url "$GUEST_BASE_URL" \
  --guest-space-id "$GUEST_SPACE_ID" \
  --app "$GUEST_APP_ID" \
  --api-token "$GUEST_API_TOKEN" \
  --file-path "$FILE_NORMAL_TO_GUEST" \
  --encoding utf8 \
  --update-key "文字列__1行__6"

echo "✅ 通常 → ゲスト 同期完了（片方向・更新モード）"
