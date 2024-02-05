from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
import pytest
from core.config import settings
from db.database import Base, get_db
from main import app

engine = create_engine(
    settings.sqlalchemy_unittest_database_url,
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


Base.metadata.create_all(bind=engine)


def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)

# @pytest.fixture(scope='session')
# def engine():
#     return create_engine(TEST_DATABASE_URI)

# @pytest.fixture(scope='session')
# def tables(engine):
#     Base.metadata.create_all(engine)
#     yield
#     Base.metadata.drop_all(engine)

# @pytest.fixture
# def db_session(engine, tables):
#     """セッションを作成し、テスト後にクリーンアップする"""
#     connection = engine.connect()
#     transaction = connection.begin()
#     session = sessionmaker()(bind=connection)
#     yield session
#     session.close()
#     transaction.rollback()
#     connection.close()

def test_create_user():
    response = client.post(
        "/users/",
        json={"email": "deadpool2@example.com", "password": "chimichangas4life"},
    )
    assert response.status_code == 200, response.text
    data = response.json()
    assert data["email"] == "deadpool2@example.com"
    assert "id" in data
    user_id = data["id"]

    response = client.get(f"/users/{user_id}")
    assert response.status_code == 200, response.text
    data = response.json()
    assert data["email"] == "deadpool2@example.com"
    assert data["id"] == user_id

if __name__ == '__main__':
    test_create_user()
    print("done!")