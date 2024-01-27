FROM python:3.11-slim

# Pythonの標準出力、標準エラー出力を行うための設定
ENV PYTHONUNBUFFERED=1

# Dockerはデフォルトではrootユーザー。権限的によろしくないので一般ユーザーを作成
ARG USER_NAME=hibarashi_user
RUN useradd ${USER_NAME}

# 不要なキャッシュを削除しイメージを軽量化
RUN apt-get update -y && apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER ${USER_NAME}

WORKDIR /home/hibarashi_user/normalized_order_data

RUN curl -sSL https://install.python-poetry.org | python3 -

# poetryのパスを通す
ENV PATH=$PATH:/home/hibarashi_user/.local/bin:

# poetryの定義ファイルをコピー (存在する場合)
# chownを入れないとrootユーザーがownerになってしまうので追加する必要あり。
# COPY --chown=${USER_NAME}:${USER_NAME} pyproject.toml* poetry.lock* ./

# poetryでライブラリをインストール (pyproject.tomlが既にある場合)
# 仮想環境のインストール先は、プロジェクト内にする
# イメージ作成時はまだ、src内をマウントしていない。なので--no-rootオプションをつけないとエラーになる。
# RUN poetry config virtualenvs.in-project true
# RUN if [ -f pyproject.toml ]; then poetry install --no-root; fi

# uvicornのサーバーを立ち上げる
ENTRYPOINT ["bash", "entrypoint.sh"]


