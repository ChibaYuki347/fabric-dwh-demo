from fastapi import FastAPI

app = FastAPI(title="Branch Balance API")

@app.get("/branch-balances")
def get_branch_balances(businessDate: str, branchId: int | None = None):
    # Demo stub. In a real implementation, query a curated Fabric Warehouse view.
    return [
        {
            "branchId": branchId or 101,
            "businessDate": businessDate,
            "dailyAmount": 12345678.90,
            "transactionCount": 3456,
        }
    ]
