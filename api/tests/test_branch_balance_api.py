"""Smoke tests for the demo Branch Balance API.

These tests exercise the FastAPI stub in src/branch_balance_api.py. They do not
connect to a real Fabric Warehouse; they validate request/response contract only.
"""

from fastapi.testclient import TestClient

from api.src.branch_balance_api import app

client = TestClient(app)


def test_get_branch_balances_requires_business_date():
    response = client.get("/branch-balances")
    assert response.status_code == 422


def test_get_branch_balances_returns_list_for_valid_date():
    response = client.get("/branch-balances", params={"businessDate": "2026-05-01"})
    assert response.status_code == 200
    payload = response.json()
    assert isinstance(payload, list)
    assert payload, "expected at least one synthetic row from the demo stub"
    row = payload[0]
    assert set(row.keys()) >= {"branchId", "businessDate", "dailyAmount", "transactionCount"}
    assert row["businessDate"] == "2026-05-01"


def test_get_branch_balances_honors_branch_filter():
    response = client.get(
        "/branch-balances",
        params={"businessDate": "2026-05-01", "branchId": 202},
    )
    assert response.status_code == 200
    payload = response.json()
    assert payload[0]["branchId"] == 202
