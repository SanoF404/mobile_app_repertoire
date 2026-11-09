from datetime import datetime, timedelta, timezone
import hashlib, hmac, json, os, sqlite3, base64, secrets
from pathlib import Path
from typing import Optional
from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel, Field

DB_PATH = Path(os.getenv('CONTACTS_DB', Path(__file__).with_name('contacts.db')))
SECRET = os.getenv('JWT_SECRET', 'development-only-change-this-secret')
TOKEN_TTL_HOURS = 12
app = FastAPI(title='Peopleo Contacts API', version='1.0.0')
app.add_middleware(CORSMiddleware, allow_origins=['*'], allow_credentials=False, allow_methods=['*'], allow_headers=['*'])
oauth2 = OAuth2PasswordBearer(tokenUrl='/login')

def db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute('PRAGMA foreign_keys = ON')
    return conn

def init_db():
    with db() as conn:
        conn.executescript('''CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY, email TEXT UNIQUE NOT NULL, password_hash TEXT NOT NULL);
        CREATE TABLE IF NOT EXISTS persons(id INTEGER PRIMARY KEY, nom TEXT NOT NULL, prenom TEXT NOT NULL, telephone TEXT UNIQUE NOT NULL, owner_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE);''')

@app.on_event('startup')
def startup(): init_db()

def b64(data: bytes) -> str: return base64.urlsafe_b64encode(data).rstrip(b'=').decode()
def make_token(user_id: int) -> str:
    head=b64(b'{"alg":"HS256","typ":"JWT"}')
    payload=b64(json.dumps({'sub':str(user_id),'exp':int((datetime.now(timezone.utc)+timedelta(hours=TOKEN_TTL_HOURS)).timestamp())},separators=(',',':')).encode())
    body=f'{head}.{payload}'
    sig=b64(hmac.new(SECRET.encode(),body.encode(),hashlib.sha256).digest())
    return f'{body}.{sig}'
def current_user(token: str = Depends(oauth2)) -> int:
    try:
        head,payload,sig=token.split('.'); body=f'{head}.{payload}'
        expected=b64(hmac.new(SECRET.encode(),body.encode(),hashlib.sha256).digest())
        data=json.loads(base64.urlsafe_b64decode(payload+'='*(-len(payload)%4)))
        if not hmac.compare_digest(sig,expected) or data['exp'] < int(datetime.now(timezone.utc).timestamp()): raise ValueError()
        return int(data['sub'])
    except Exception: raise HTTPException(status_code=401,detail='Jeton invalide ou expiré',headers={'WWW-Authenticate':'Bearer'})
def password_hash(password: str) -> str:
    salt=secrets.token_bytes(16)
    digest=hashlib.pbkdf2_hmac('sha256',password.encode(),salt,310000)
    return salt.hex()+'$'+digest.hex()
def verify_password(password: str, stored: str) -> bool:
    try:
        salt_hex,digest_hex=stored.split('$',1)
        digest=hashlib.pbkdf2_hmac('sha256',password.encode(),bytes.fromhex(salt_hex),310000).hex()
        return hmac.compare_digest(digest,digest_hex)
    except (ValueError,TypeError): return False
def find_user(email: str):
    with db() as conn: return conn.execute('SELECT * FROM users WHERE email=?',(email.lower().strip(),)).fetchone()
class Signup(BaseModel): email: str; password: str = Field(min_length=8)
class PersonIn(BaseModel): nom: str = Field(min_length=1,max_length=80); prenom: str = Field(min_length=1,max_length=80); telephone: str = Field(min_length=6,max_length=30)
class Person(PersonIn): id: int
class Token(BaseModel): access_token: str; token_type: str='bearer'
@app.get('/health')
def health(): return {'status':'ok'}
@app.post('/signup',status_code=201)
def signup(data: Signup):
    try:
        with db() as conn: cur=conn.execute('INSERT INTO users(email,password_hash) VALUES(?,?)',(data.email.lower().strip(),password_hash(data.password))); user_id=cur.lastrowid
    except sqlite3.IntegrityError: raise HTTPException(409,'Cette adresse e-mail est déjà utilisée')
    return {'access_token':make_token(user_id),'token_type':'bearer'}
@app.post('/login',response_model=Token)
def login(form: OAuth2PasswordRequestForm=Depends()):
    user=find_user(form.username)
    if not user or not verify_password(form.password,user['password_hash']): raise HTTPException(status.HTTP_401_UNAUTHORIZED,'Identifiants invalides',headers={'WWW-Authenticate':'Bearer'})
    return Token(access_token=make_token(user['id']))
@app.get('/personnes',response_model=list[Person])
def list_people(user: int=Depends(current_user)):
    with db() as conn: rows=conn.execute('SELECT id,nom,prenom,telephone FROM persons WHERE owner_id=? ORDER BY nom,prenom',(user,)).fetchall()
    return [dict(r) for r in rows]
@app.post('/personnes',response_model=Person,status_code=201)
def create_person(data: PersonIn,user: int=Depends(current_user)):
    try:
        with db() as conn: cur=conn.execute('INSERT INTO persons(nom,prenom,telephone,owner_id) VALUES(?,?,?,?)',(data.nom.strip(),data.prenom.strip(),data.telephone.strip(),user)); row=conn.execute('SELECT id,nom,prenom,telephone FROM persons WHERE id=?',(cur.lastrowid,)).fetchone()
    except sqlite3.IntegrityError: raise HTTPException(409,'Ce numéro existe déjà')
    return dict(row)
@app.get('/personnes/{person_id}',response_model=Person)
def get_person(person_id:int,user:int=Depends(current_user)):
    with db() as conn: row=conn.execute('SELECT id,nom,prenom,telephone FROM persons WHERE id=? AND owner_id=?',(person_id,user)).fetchone()
    if not row: raise HTTPException(404,'Contact introuvable')
    return dict(row)
@app.put('/personnes/{person_id}',response_model=Person)
def update_person(person_id:int,data:PersonIn,user:int=Depends(current_user)):
    try:
        with db() as conn:
            cur=conn.execute('UPDATE persons SET nom=?,prenom=?,telephone=? WHERE id=? AND owner_id=?',(data.nom.strip(),data.prenom.strip(),data.telephone.strip(),person_id,user))
            if not cur.rowcount: raise HTTPException(404,'Contact introuvable')
            row=conn.execute('SELECT id,nom,prenom,telephone FROM persons WHERE id=?',(person_id,)).fetchone()
    except sqlite3.IntegrityError: raise HTTPException(409,'Ce numéro existe déjà')
    return dict(row)
@app.delete('/personnes/{person_id}',status_code=204)
def delete_person(person_id:int,user:int=Depends(current_user)):
    with db() as conn: cur=conn.execute('DELETE FROM persons WHERE id=? AND owner_id=?',(person_id,user))
    if not cur.rowcount: raise HTTPException(404,'Contact introuvable')
