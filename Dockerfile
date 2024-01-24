FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1

ARG USER_NAME=hibarashi_user
RUN useradd ${USER_NAME}

RUN apt-get update -y && apt-get install -y curl pipx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER ${USER_NAME}

WORKDIR /home/hibarashi_user/normalized_order_data

RUN curl -sSL https://install.python-poetry.org | python3 -

# パスを通す
ENV PATH=$PATH:/home/hibarashi_user/.local/bin:

# poetryの定義ファイルをコピー (存在する場合)
COPY --chown=${USER_NAME}:${USER_NAME} pyproject.toml* poetry.lock* ./

# poetryでライブラリをインストール (pyproject.tomlが既にある場合)
RUN poetry config virtualenvs.in-project false
RUN if [ -f pyproject.toml ]; then poetry install --no-root; fi

# uvicornのサーバーを立ち上げる
CMD ["poetry", "run", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--reload"]