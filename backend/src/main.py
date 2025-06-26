# main.py
from fastapi import FastAPI
import oracledb
import os

app = FastAPI()

# OCI Autonomous Database 접속 정보
# 이 정보는 Docker 환경 변수에서 가져옵니다.
db_user = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")
tns_alias = os.getenv("TNS_ALIAS")
tns_admin_path = os.getenv("TNS_ADMIN")

# Oracle Client Wallet 경로를 설정합니다.
if tns_admin_path:
    os.environ['TNS_ADMIN'] = tns_admin_path

@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI!"}

@app.get("/db-status")
def check_db_connection():
    conn = None
    try:
        conn = oracledb.connect(
            user=db_user,
            password=db_password,
            dsn=tns_alias
        )
        print("Successfully connected to the database!")
        return {"db_status": "connected"}
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return {"db_status": f"disconnected: {e}"}
    finally:
        if conn:
            conn.close()
