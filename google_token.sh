
#!/bin/bash

# 参考：
# http://qiita.com/shin1ogawa/items/49a076f62e5f17f18fe5
# http://kinsentansa.blogspot.jp/2012/07/google-drivecurl.html

# -----------------------------------------------------------------------------

function usage() {
cat <<_EOT_
Usage:
  $0 code|token|refresh|check|revoke

Description:
  Get Google authentication data

Options:
  code    Get Authorization Code
  token   Get Token from code
  refresh Refresh Token from refresh_token
  check   Check Token status
  revoke  Revoke Token

_EOT_
exit 1 
}

# -----------------------------------------------------------------------------

# CLIENT_ID/CLIENT_SECRET は GoogleDeveloperConsle にて作成したものを使用する
CLIENT_ID="277852333898-malab85hvq4fcl5551jqijnsbkdaonop.apps.googleusercontent.com"
CLIENT_SECRET="8c74yGKXUt0V5hFlsZKoCNvh"

# REDIRECT_URI/SCOPE は固定値
REDIRECT_URI="urn:ietf:wg:oauth:2.0:oob"
SCOPE="https://spreadsheets.google.com/feeds"

# 最初にAUTHORIZATION_CODEを取得するためのもの（これをブラウザに入力し、承認してコードを得る）
function code() {
    echo "https://accounts.google.com/o/oauth2/v2/auth?response_type=code&client_id=$CLIENT_ID&redirect_uri=$REDIRECT_URI&scope=$SCOPE&access_type=offline"
}

# 運用中は保持する必要のない値
AUTHORIZATION_CODE="4/WuZnYwu1p2XZlLinR7eXhjZmPJZ8XUqCVzQuAGu2K2k"

# AUTHORIZATION_CODEからAccessToken/RefreshTokenを入手する
function token() {
    curl -X POST https://accounts.google.com/o/oauth2/token \
        -d "code=$AUTHORIZATION_CODE" \
        -d "client_id=$CLIENT_ID" \
        -d "client_secret=$CLIENT_SECRET" \
        -d "redirect_uri=$REDIRECT_URI" \
        -d "grant_type=authorization_code"
}

# Response:
# {
#   "access_token" : "ya29.Glv-A4xUBjEYjghap_XovN9Cgv77mo3uT02Mixq0cmQ5O2dgdwUERSL6YMDxsh0noBSKTbxdWatr4bqV-nm4sUGLbBhrNdqO4yWMrfaJ-PAUrXEPpL9ZszNVAvL4",
#   "expires_in" : 3600,
#   "refresh_token" : "1/PVwfwD-QvNg3GXUFzHXaJ_P7yHObWH5A70gONERpb-s",
#   "token_type" : "Bearer"
# }

# これを運用時は覚えておく（これを元にAccessTokenを生成する）
REFRESH_TOKEN="1/PVwfwD-QvNg3GXUFzHXaJ_P7yHObWH5A70gONERpb-s"

# RefreshTokenからAccessTokenを得る
function refresh() {
    curl -X POST https://accounts.google.com/o/oauth2/token \
        -d "refresh_token=$REFRESH_TOKEN" \
        -d "client_id=$CLIENT_ID" \
        -d "client_secret=$CLIENT_SECRET" \
        -d "grant_type=refresh_token"
}

# 変化するものなので注意
ACCESS_TOKEN="ya29.Glz-A-DWe8T_VQ7qltVONUANov6CUBNpw8e2oIl7XH9gXh1ALTT81r-DSCAxmsIzn-KG36vn1NjDUXyYncoIaXjLeuUE5fz1C4iSHwYTAT0aBWGG_sTQ7YFI138sWw"

function check() {
    curl "https://www.googleapis.com/oauth2/v3/tokeninfo?access_token=$ACCESS_TOKEN"
}

# TokenをRevokeする
function revoke() {
    curl "https://accounts.google.com/o/oauth2/revoke?token=$REFRESH_TOKEN"
}

function create_sheet() {
    curl -X POST https://sheets.googleapis.com/v4/spreadsheets \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-length: 0"
}

SPREADSHEET_ID="1Vr2yvR1QMWM-73eNaxh9FwEb0L_j4QEvPtAPXSRnjDQ"

function sheet() {
    # curl "https://sheets.googleapis.com/v4/spreadsheets/1R6gP99ML8bWfaRUZ-CkbbTkwxstJ7BgTxUIeZ9UyZFE/values/Sheet1!A1:D5&access_token=$ACCESS_TOKEN"
    curl -X POST https://sheets.googleapis.com/v4/spreadsheets/$SPREADSHEET_ID:batchUpdate \
        -H "Authorization: Bearer ya29.Glv-AzfFqlIiqTc-ha1JsSAgFwB_d8V9fZ8M-dMNTYj539i0sfCt1GGpyPxVZbzKKRDrmE-q84n8SXXF019DrEpvkLWzfPnwV3mewS6f8u83cuSCgEXqA8jjdria" \
        -H "Accept: application/json" \
        -d "{\"requests\": [{\"updateCells\": {\"start\": {\"sheetId\": 0,\"rowIndex\": 0,\"columnIndex\": 0},\"rows\": [{\"values\": [{},{\"userEnteredValue\": {\"stringValue\": \"国語\"}},{\"userEnteredValue\": {\"stringValue\": \"算数\"}},{\"userEnteredValue\": {\"stringValue\": \"理科\"}},{\"userEnteredValue\": {\"stringValue\": \"合計\"}}],},{\"values\": [{\"userEnteredValue\": {\"stringValue\": \"A\"}},{\"userEnteredValue\": {\"numberValue\": \"80\"}},{\"userEnteredValue\": {\"numberValue\": \"70\"}},{\"userEnteredValue\": {\"numberValue\": \"60\"}},{\"userEnteredValue\": {\"formulaValue\": \"=SUM(B2:D2)\"}}]},{\"values\": [{\"userEnteredValue\": {\"stringValue\": \"B\"}},{\"userEnteredValue\": {\"numberValue\": \"90\"}},{\"userEnteredValue\": {\"numberValue\": \"40\"}},{\"userEnteredValue\": {\"numberValue\": \"50\"}},{\"userEnteredValue\": {\"formulaValue\": \"=SUM(B3:D3)\"}}]},{\"values\": [{\"userEnteredValue\": {\"stringValue\": \"C\"}},{\"userEnteredValue\": {\"numberValue\": \"30\"}},{\"userEnteredValue\": {\"numberValue\": \"90\"}},{\"userEnteredValue\": {\"numberValue\": \"70\"}},{\"userEnteredValue\": {\"formulaValue\": \"=SUM(B4:D4)\"}}]}],\"fields\": \"userEnteredValue\"}}]}"
}

case $1 in
  code)
    code
    ;;
  token)
    token
    ;;
  refresh)
    refresh
    ;;
  check)
    check
    ;;
  revoke)
    revoke
    ;;
  sheet)
    sheet
    ;;
  *)
    usage
    ;;
esac

