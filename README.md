# HelpPing

HelpPing is a mobile app and backend system that lets people send a help request that nearby users can see and respond to in real time. It is designed for situations like feeling unsafe on the street, needing quick assistance on campus, or asking for help from neighbours during an emergency.  

The project has:
- A **Flutter** mobile app (Android).
- A **Python FastAPI** backend with a local database.

---

## Features

- Register and log in as a HelpPing user.
- Send a help request with a short message and location.
- See open help requests around you.
- Accept a request so the requester knows help is coming.
- Basic notification flow between requester and helper.

### Range / Where it works

HelpPing is **internet‑based**, not Bluetooth‑based. That means there is **no fixed distance in meters** like 10 m or 50 m. As long as:
- The requester’s phone has internet (Wi‑Fi or mobile data), and  
- The helper’s phone has internet,  

they can communicate **from anywhere in the world**.  

If you ever add Bluetooth features in future, typical consumer Bluetooth works reliably up to about **10 meters**, and in ideal conditions some devices can reach around **100 meters**, but that is not relevant for the current version of HelpPing which uses the network. [web:75][web:105][web:113][web:116]

---

## Project Structure

This repository currently contains:

- `android/` and other Flutter folders – the **HelpPing mobile app**.
- `help_ping_backend/` – the **backend** (FastAPI + Python).
- Shared assets such as app icons and sounds.

You can run the app and backend independently during development.

---

## Prerequisites

Before running HelpPing you need:

- **Git**
- **Python 3.10+** for the backend
- **Flutter SDK** (stable channel) for the mobile app
- **Android Studio** or Android SDK + device/emulator
- **pip** or **uv** for Python package management [web:100][web:103][web:101]

---

## Backend: Running the API

1. Open a terminal in the backend folder:
cd help_ping_backend

2. (Recommended) Create and activate a virtual environment:
python -m venv venv
Windows PowerShell
venv\Scripts\Activate.ps1

3. Install Python dependencies:

pip install -r requirements.txt

4. Start the FastAPI server with Uvicorn:

uvicorn main:app --reload

5. The API will be available at:

- API root: `http://127.0.0.1:8000/`
- Interactive docs (Swagger UI): `http://127.0.0.1:8000/docs` [web:103]

Keep this terminal running while you test the Flutter app.

---

## Mobile App: Running the Flutter Client

1. In a new terminal, go to the Flutter project root (repository root):

cd HelpPing

2. Get Flutter dependencies:

flutter pub get

3. Make sure an Android emulator or physical device is connected.

4. Update the API base URL in your Dart code (for example in `api_service.dart`) so it points to the backend:

const String apiBaseUrl = 'http://10.0.2.2:8000'; // Android emulator to local backend

- Use `10.0.2.2` for Android emulator talking to backend on your development machine.  
- Use your machine’s local IP (e.g. `http://192.168.x.x:8000`) when testing on a real device on the same Wi‑Fi. [web:32][web:106]

5. Run the app:

flutter run

text

Log in or register from the app, then create a help request and see it appear on other devices logged into the same backend.

---

## Development Notes

- Do **not** commit your Python virtual environment (`venv/`), build outputs, or IDE files; they are ignored using `.gitignore`. [web:104][web:107][web:109][web:115]
- For production deployment (for example on a VPS or cloud platform), you would typically:
- Use a robust database instead of a local file DB.
- Run Uvicorn behind a process manager and reverse proxy (e.g. `gunicorn` + `nginx`). [web:103]
- Configure HTTPS and environment variables for secrets.

---

## Future Ideas

- In‑app notifications and better real‑time updates.
- Role‑based modes such as “trusted contacts”, “security staff”, or “neighbour volunteers”.
- Optional offline / Bluetooth‑based discovery for very close‑range alerts (would then be limited to roughly 10–100 meters depending on hardware and environment). [web:75][web:105]

---

## Contact

If you have any questions, ideas, or feedback about HelpPing, feel free to reach out.

- GitHub: [@tharz-06](https://github.com/tharz-06)
- Email: thaarani013@gmailcom

 






















