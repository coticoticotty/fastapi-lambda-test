poetry config virtualenvs.in-project true
poetry install
poetry run uvicorn src.main:app --host 0.0.0.0 --reload