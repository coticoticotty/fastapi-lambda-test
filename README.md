# 概要
dockerの立ち上げ
`docker compose up`

パッケージのインストール
`docker compose run --entrypoint "poetry add <package-name>" <container-name>`

パッケージをインストールしたら、イメージを再度ビルド
`docker compose build --no-cache`