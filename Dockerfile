# --- Etap 1: Skaner ---
# Nazwiemy ten etap 'scanner', aby móc się do niego odwoływać
FROM python:3.9-slim AS scanner

WORKDIR /app

# Skopiuj tylko plik z zależnościami, aby wykorzystać cache'owanie warstw
COPY requirements.txt .

# Zainstaluj zależności aplikacji ORAZ nasze narzędzie do skanowania
RUN pip install -r requirements.txt
RUN pip install pip-audit

# Uruchom skan SCA. Jeśli znajdzie podatności, zakończy się kodem błędu > 0,
# co spowoduje niepowodzenie całego 'docker build'.
RUN pip-audit

# --- Etap 2: Finalna Aplikacja ---
# Ten etap zostanie wykonany tylko, jeśli wszystkie kroki w etapie 'scanner' się powiodły.
FROM python:3.9-slim

WORKDIR /app

COPY . .
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000
CMD ["python3", "-m", "flask", "run", "--host=0.0.0.0"]
