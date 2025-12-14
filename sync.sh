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
FIELDS="作成日時,紹介先,顧客・見込み,会社名,会社名_0,文字列__1行_,担当者名,部署名,ドロップダウン,郵便番号,都道府県,市区町村名_0,町域名,住所,電話番号,FAX,メールアドレス,代表者,資本金,従業員数,ホームページ,文字列__複数行_,拠点_郵便番号,拠点_都道府県,拠点市区町村名,拠点町域名,拠点_住所,拠点_住所2,拠点_電話番号,拠点_FAX,拠点_メールアドレス,デザイナー・設計,営業担当,点検担当,現場主担当,契約日,工事開始日,点検日,完工日,引渡日,備考"

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
  --update-key "会社名"

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
  --update-key "会社名"

echo "✅ 双方向同期完了（会社名をキーに更新モード）"
