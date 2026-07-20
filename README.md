# IronPath

Application mobile de suivi d'entraînement musculaire.

- **Backend** : Spring Boot 4 / Java 21 / PostgreSQL 17
- **Frontend** : Flutter 3.44 (Android)
- **Email** : Mailpit (démo locale)

---

## Prérequis à installer

| Outil | Version | Lien |
|---|---|---|
| Docker Desktop (avec Compose v2) | récente | https://www.docker.com/products/docker-desktop/ |
| Flutter SDK | 3.44.2 | https://docs.flutter.dev/get-started/install |

Le JDK 21 n'est **pas nécessaire** en local si vous utilisez Docker (le backend est compilé et exécuté dans le conteneur).

**Installation automatique du SDK Flutter** (si vous ne l'avez pas encore, ou une version différente) :

```bash
bash scripts/setup-flutter.sh
```

Détecte votre OS, télécharge et installe la version 3.44.2 sans écraser une installation existante ailleurs sur la machine.

**Optionnel** — uniquement pour tester sur émulateur Android ou téléphone en USB : Android Platform Tools (`adb`), inclus avec Android Studio ou seul : https://developer.android.com/tools/releases/platform-tools. Non requis pour lancer l'app sur desktop ou navigateur (Windows, Chrome, Edge).

---

## Installation & lancement

### 1. Cloner le projet

```bash
git clone https://github.com/AlexisDamien/ironpath.git
cd ironpath
```

### 2. Configurer l'environnement

```bash
cp .env.example .env
```

*(Sous PowerShell : `Copy-Item .env.example .env`)*

### 3. Lancer le backend, PostgreSQL et Mailpit

```bash
docker compose up --build --wait --wait-timeout 240
```

Premier lancement plus long (téléchargement des dépendances Gradle). Vérifier que tout est sain :

```bash
docker compose ps
curl http://localhost:8080/actuator/health
```

Doit retourner `{"status":"UP"}`.

| Service | URL |
|---|---|
| API | http://localhost:8080 |
| Swagger | http://localhost:8080/swagger-ui/index.html |
| Emails reçus (Mailpit) | http://localhost:8025 |

### 4. Lancer l'application Flutter

```bash
cd frontend
flutter pub get
flutter run \
  --dart-define=APP_ENV=local \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

`flutter run` propose de choisir la cible (Windows, Chrome, Edge, Android...).

- **Desktop ou navigateur** : `127.0.0.1` pointe directement sur votre machine, aucune étape supplémentaire.
- **Téléphone Android en USB, sur le même réseau WiFi que le PC** : remplacez `127.0.0.1` par l'IP locale de votre PC :
  ```bash
  flutter run \
    --dart-define=APP_ENV=local \
    --dart-define=API_BASE_URL=http://<IP_LOCALE_DE_VOTRE_PC>:8080
  ```
  Trouver son IP locale :
  - Windows : `ipconfig` → ligne "Adresse IPv4"
  - Linux/Mac : `ip a` ou `ifconfig`
- **Émulateur Android, ou téléphone sans accès au même réseau** : gardez `127.0.0.1` mais redirigez le port avec `adb` avant de lancer l'app :
  ```bash
  adb reverse tcp:8080 tcp:8080
  ```

---

## Arrêter le projet

```bash
docker compose down                             # conserve les données
docker compose down --volumes --remove-orphans  # réinitialise tout (base + emails)
```

---

## Problèmes fréquents

| Symptôme | Cause | Solution |
|---|---|---|
| `Port 8080 was already in use` | Un backend tourne déjà (local ou Docker) | `docker compose down`, ou fermer l'autre instance |
| `API_BASE_URL est absente` (Flutter) | Lancé sans `--dart-define` | Toujours passer `--dart-define=API_BASE_URL=...` |
| `docker compose up` échoue tout de suite | `.env` manquant | `cp .env.example .env` |