# 概要
dockerの立ち上げ
`docker compose up`

パッケージのインストール
`docker compose run --entrypoint "poetry add <package-name>" <container-name>`

パッケージをインストールしたら、イメージを再度ビルド
`docker compose build --no-cache`

# poetryでハマったところ
## rootlessに作りたい
dockerイメージを作ると、デフォルトでroot権限になってしまう。いろいろよろしくないので一般ユーザーを作成するのがベストプラクティス

そのために一般ユーザーを作成。

`RUN useradd ${USER_NAME}`

でユーザーを追加すると、自動的に以下のディレクトリが作成される

`/home/${USER_NAME}`

このディレクトリ内は一般ユーザーに書き込み権限があるので

`WORKDIR /home/${USER_NAME}/<root_dir_name>`

このようにwork_dirを変更して以降はこのディレクトリ内でいろいろ操作。

なお、<root_dir_name>をつけると、このディレクトリも自動で生成してくれる。

## 一般ユーザーを作成したら、poetry.toml pyproject.tomlに書き込めず、poetry installに失敗
--chownオプションをつけたら成功
Dockerfile内でコピーをすると、事前にユーザーを変更していても、コピーしたファイルがルート権限になってしまう。
そこでコピーする際に--chownを追加
```
# Before
RUN pyproject.toml* poetry.lock* ./
# After
RUN --chown=${USER_NAME}:${USER_NAME} pyproject.toml* poetry.lock* ./
```

## poetry コマンドが動かない
PATHを追加。一般ユーザーでcurlを行っているので、homeディレクトリ内に追加される。
なお、RUN コマンドでは環境変数をうまく追加できないらしい。
```
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH=$PATH:/home/${USER_NAME}/.local/bin:
```
## 仮想環境を作る or 作らないについて
Docker内なので、仮想環境を作らないオプションをつけている例も多かった
`RUN poetry config virtualenvs.create false`
このようにすると、グローバルにパッケージがインストールされる。
その後、poetry installを実行するとpython/site_packagesに書き込み権限がなくてエラーになってしまった。
エラーは結局解消できなかった。
インストール先のディレクトリの権限を変更すればいけるがまあ仮想環境は基本作るでいいのではないかと思う。

## virtualenvフォルダをプロジェクト直下に置くか、プロジェクト外に置くか
`RUN poetry config virtualenvs.in-project true`
としてプロジェクト直下に置くと、
`CMD ["poetry run uvicorn"]`
これでuvicornがないとなぜか怒られる。原因は不明。
コンテナ内を確認したところ、パッケージはインストールされていた。
一方ローカルの.venvにはインストールされていなかった。これが原因？しかし、dockerイメージ内からローカルの.venv参照する？
ちなみに、ローカルの.venvは、falseにすると当然作成されない。
trueだと`docker compose up`したタイミングで作成される。
原因はそれか、poetry run をしたときの参照先がなんかおかしいのだと思う。
しかし、poetry runをしたときの参照先を設定する方法は、公式ドキュメントにも載っていなかったのであきらめた。
プロジェクト外に置くとuvicornを呼び出せたので、まあ良しとする。
ちなみに、プロジェクト直下のときの参照パスは
`/home/hibarashi_user/normalized_order_data/.venv/lib/python3.11/site-packages`
プロジェクト外のときの参照パスは、
`/home/hibarashi_user/.cache/pypoetry/virtualenvs/demo-app-39aKjdOm-py3.11/lib/python3.11/site-packages`
仮想環境を作らないときの参照先
`/home/hibarashi_user/.cache/pypoetry/virtualenvs`

※※※解決※※※
原因、compose.yamlでroot_directoryごとコピーした際に、.venvが削除 or 上書きされてしまった模様
root_directory内のファイルは現状コピーする必要がなかったのでsrc内のみコピーすることにした。
⇒pyproject.tomlが連携されない可能性あるので調査
⇒連携されなかったのでファイルごとにcompose.yamlでマウント
※dockervenvはよく分からないのでちょっと調べる必要があるかも

## RUN&COPY, volume, CMDの順番
RUN&COPY ⇒volume ⇒ CMD
の順番。