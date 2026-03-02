import pytest
from app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as c:
        yield c


def test_index_with_user(client):
    resp = client.get("/", headers={"user": "admin"})
    assert resp.status_code == 200
    data = resp.get_json()
    assert data["message"] == "Echo from admin"
    assert data["headers"]["user"] == "admin"


def test_index_anonymous(client):
    resp = client.get("/")
    assert resp.status_code == 200
    data = resp.get_json()
    assert data["message"] == "Echo from anonymous"


def test_health(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "healthy"
