FROM amazonlinux:2

# 必要なシステムパッケージをインストール
RUN yum update -y && yum install wget tar gzip zip make gcc make patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl11-devel tk-devel libffi-devel xz-devel -y \
    && rm -rf /var/cache/yum/* \
    && yum clean all

# gcc make patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl11-devel tk-devel libffi-devel xz-devel
# gcc make patch zlib-devel bzip2 bzip2-devel readline-devel sqlite-devel openssl-devel tk-devel libffi-devel xz-devel
# install amazon-linux-extras install
# RUN amazon-linux-extras install python3.11 -y

RUN cd /opt
RUN wget https://www.python.org/ftp/python/3.11.7/Python-3.11.7.tgz
RUN tar xzf Python-3.11.7.tgz
RUN ./Python-3.11.7/configure --enable-optimizations
RUN make altinstall
RUN rm -f /opt/Python-3.11.7.tgz
RUN python3 -m pip install --upgrade pip

WORKDIR /app

# Poetryをダウンロードしてインストール
# RUN curl -sSL https://install.python-poetry.org | python -

# # Pathを通す
# ENV PATH /root/.local/bin:$PATH
# # 仮想環境をたてない
# RUN poetry config virtualenvs.create false

RUN pip install poetry \
    && poetry config virtualenvs.create false

# アプリケーションの依存関係をインストール
COPY pyproject.toml poetry.lock /app/
RUN poetry install

COPY /src /app/src

CMD ["sh", "-c", "set -e; cd /app/src && uvicorn main:app --reload --host 0.0.0.0 --port 8080"]