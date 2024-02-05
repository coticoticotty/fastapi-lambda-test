from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session

from schemas import schemas
from crud import crud
from db.database import SessionLocal, engine, get_db

def create_user_batch(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return crud.create_user(db=db, user=user)

if __name__ == '__main__':
    user_info = {"email": "aaa@aaa.com", "password": "passpass"}
    user = schemas.UserCreate(**user_info)
    create_user_batch(
        user
    )