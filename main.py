from datetime import datetime
from fastapi import FastAPI, Query, HTTPException, Body
from sqlmodel import SQLModel, Field, Session, create_engine, select, delete

# -------------------- DATABASE -------------------- #

DATABASE_URL = "sqlite:///help_ping.db"  # local SQLite file
engine = create_engine(DATABASE_URL, echo=True)  # echo=True to see SQL in logs [web:84]


class HelpRequest(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    description: str
    urgency: str
    created_by: str
    status: str = "pending"          # pending / accepted / finished
    helper_id: str | None = None
    is_alarm: bool = False
    is_active: bool = True


class ChatMessage(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    request_id: int = Field(index=True)
    sender_id: str
    message: str
    created_at: datetime = Field(default_factory=datetime.utcnow)


def create_db_and_tables():
    # Creates all tables defined by SQLModel models if they don't exist [web:89][web:116]
    SQLModel.metadata.create_all(engine)


# Create DB and tables on import, before app is used
create_db_and_tables()

# -------------------- APP INIT -------------------- #

app = FastAPI()


# -------------------- BASIC ROUTES -------------------- #

@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.get("/")
def root():
    return {"message": "HelpPing backend running"}


@app.get("/api/requests")
def get_all_requests():
    with Session(engine) as session:
        statement = select(HelpRequest)
        results = session.exec(statement).all()
        return results


@app.post("/api/requests")
def create_request(req: HelpRequest):
    with Session(engine) as session:
        session.add(req)
        session.commit()
        session.refresh(req)
        return req


@app.get("/api/my-requests")
def get_my_requests(created_by: str = Query(...)):
    with Session(engine) as session:
        statement = (
            select(HelpRequest)
            .where(HelpRequest.created_by == created_by)
            .order_by(HelpRequest.id.desc())
        )
        results = session.exec(statement).all()
        return results


@app.get("/api/nearby-requests")
def nearby_requests(created_by: str, limit: int = 10):
    with Session(engine) as session:
        statement = (
            select(HelpRequest)
            .where(HelpRequest.created_by != created_by)
            .where(HelpRequest.status == "pending")
            .order_by(HelpRequest.id.desc())
            .limit(limit)
        )
        results = session.exec(statement).all()
        return [r.__dict__ for r in results]


@app.post("/api/requests/{request_id}/accept")
def accept_request(request_id: int, helper_id: str):
    with Session(engine) as session:
        req = session.get(HelpRequest, request_id)
        if not req:
            raise HTTPException(status_code=404, detail="Request not found")

        req.status = "accepted"
        req.helper_id = helper_id

        session.add(req)
        session.commit()
        session.refresh(req)
        return req


@app.delete("/api/requests")
def delete_all_requests():
    with Session(engine) as session:
        session.exec(delete(HelpRequest))
        session.commit()
    return {"status": "deleted"}


@app.get("/api/helping-requests")
def helping_requests(helper_id: str):
    with Session(engine) as session:
        try:
            statement = (
                select(HelpRequest)
                .where(HelpRequest.helper_id == helper_id)
                .where(HelpRequest.status == "accepted")
                .order_by(HelpRequest.id.desc())
            )
            results = session.exec(statement).all()
            return [r.__dict__ for r in results]
        except Exception as e:
            print("helping_requests error:", e)
            raise HTTPException(status_code=500, detail="Server error")


# -------------------- CHAT ROUTES -------------------- #

@app.post("/api/requests/{request_id}/messages")
def add_message(
    request_id: int,
    sender_id: str = Query(...),
    payload: dict = Body(...)
):
    message_text = payload.get("message")
    if not message_text:
        raise HTTPException(status_code=400, detail="message is required")

    with Session(engine) as session:
        req = session.get(HelpRequest, request_id)
        if not req:
            raise HTTPException(status_code=404, detail="Request not found")

        msg = ChatMessage(
            request_id=request_id,
            sender_id=sender_id,
            message=message_text,
        )
        session.add(msg)
        session.commit()
        session.refresh(msg)
        return msg


@app.get("/api/requests/{request_id}/messages")
def list_messages(request_id: int):
    with Session(engine) as session:
        statement = (
            select(ChatMessage)
            .where(ChatMessage.request_id == request_id)
            .order_by(ChatMessage.id.asc())
        )
        results = session.exec(statement).all()
        return [m.__dict__ for m in results]


# -------------------- ALARM + DISCONNECT -------------------- #

@app.post("/api/requests/{request_id}/alarm")
def set_alarm(request_id: int, payload: dict = Body(...)):
    # Expect JSON: { "on": true/false }
    on = payload.get("on")
    if on is None:
        raise HTTPException(status_code=400, detail="'on' is required")

    with Session(engine) as session:
        req = session.get(HelpRequest, request_id)
        if not req:
            raise HTTPException(status_code=404, detail="Request not found")

        req.is_alarm = bool(on)
        session.add(req)
        session.commit()
        session.refresh(req)
        return {"status": "ok", "is_alarm": req.is_alarm}


@app.post("/api/requests/{request_id}/disconnect")
def disconnect_request(request_id: int):
    with Session(engine) as session:
        req = session.get(HelpRequest, request_id)
        if not req:
            raise HTTPException(status_code=404, detail="Request not found")

        req.is_active = False
        req.status = "finished"
        session.add(req)
        session.commit()
        session.refresh(req)
        return {"status": "ok", "is_active": req.is_active}
