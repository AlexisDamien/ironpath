# IronPath

Application mobile de suivi d'entraînement musculaire.

- **Backend** : Spring Boot 4 / Java 21 / PostgreSQL 17
- **Frontend** : Flutter 3.44 (Android)
- **Email** : Mailpit (démo locale)

Trois façons de lancer l'application pour la tester : Chrome/desktop, téléphone Android en USB, ou émulateur Android.

---

## Prérequis à installer

| Outil | Version | Lien |
|---|---|---|
| Docker Desktop (avec Compose v2) | récente | https://www.docker.com/products/docker-desktop/ |
| Git | récente | https://git-scm.com/downloads |
| Flutter SDK | 3.44.2 | https://docs.flutter.dev/get-started/install (ou script automatique, voir étape 2 ci-dessous) |

Le JDK 21 n'est **pas nécessaire** en local si vous utilisez Docker (le backend est compilé et exécuté dans le conteneur).

**Pour lancer sur téléphone Android (USB) ou émulateur** : le SDK Android est nécessaire pour compiler l'application (pas seulement l'outil `adb`). Deux façons de l'obtenir :

- **Le plus simple** : installer Android Studio (https://developer.android.com/studio), qui inclut le SDK Manager avec interface graphique.
- **Alternative plus légère, sans IDE complet** : installer uniquement les *Android command-line tools* (https://developer.android.com/studio#command-tools), puis accepter les licences :
  ```bash
  flutter doctor --android-licenses
  ```

Dans les deux cas, vérifiez que tout est en ordre avec :
```bash
flutter doctor
```

Non requis pour lancer l'app sur desktop ou navigateur (Windows, Chrome, Edge).

---

## Installation & lancement

### 1. Cloner le projet

```bash
git clone https://github.com/AlexisDamien/ironpath.git
cd ironpath
```

### 2. Installer le SDK Flutter (si pas déjà fait)

```bash
bash scripts/setup-flutter.sh
```

Détecte votre OS, télécharge et installe la version 3.44.2 sans écraser une installation existante ailleurs sur la machine. Si Flutter est déjà installé dans la bonne version, le script ne fait rien.

### 3. Configurer l'environnement

```bash
cp .env.example .env
```

*(Sous PowerShell : `Copy-Item .env.example .env`)*

### 4. Lancer le backend, PostgreSQL et Mailpit

**Avant de lancer la commande, assurez-vous que Docker Desktop est bien démarré** sur votre machine (icône baleine visible et stable dans la barre des tâches — l'ouvrir manuellement ne suffit pas toujours, attendez qu'il affiche "Engine running"). Sans ça, la commande échoue avec une erreur de connexion au démon Docker.

```bash
docker compose up --build --wait --wait-timeout 240
```

Premier lancement plus long (téléchargement des dépendances Gradle). Vérifier que tout est sain :

```bash
docker compose ps
curl http://localhost:8080/actuator/health
```

Doit retourner `{"status":"UP"}`.

| Service | URL | Notes |
|---|---|---|
| Swagger | http://localhost:8080/swagger-ui/index.html | Pour explorer/tester les endpoints manuellement |
| Emails reçus (Mailpit) | http://localhost:8025 | **À garder ouvert pendant vos tests** : à l'inscription, l'application envoie un email de vérification qu'il faut valider en cliquant le lien reçu ici (aucun vrai email n'est envoyé, tout reste local) |

### 5. Lancer l'application Flutter

```bash
cd frontend
flutter pub get
```

**Sous Windows**, si le mode développeur n'est pas déjà activé sur la machine, Flutter vous le demandera automatiquement (lien direct vers les paramètres Windows concernés) — nécessaire pour builder la cible desktop. Acceptez l'activation puis relancez la commande.

Choisissez ensuite l'une des trois cibles ci-dessous selon votre besoin.

#### Option A — Chrome ou desktop Windows (le plus simple, aucune config réseau)

```bash
flutter run \
  --dart-define=APP_ENV=local \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

`flutter run` propose de choisir la cible — sélectionnez Chrome, Edge ou Windows. `127.0.0.1` pointe directement sur votre machine, aucune étape supplémentaire.

#### Option B — Téléphone Android en USB

1. Activez le débogage USB sur le téléphone (Paramètres → Options développeur) et branchez-le.
2. Lancez la commande avec l'IP locale de votre PC (pas `127.0.0.1`, qui désignerait le téléphone lui-même) :
   ```bash
   flutter run \
     --dart-define=APP_ENV=local \
     --dart-define=API_BASE_URL=http://<IP_LOCALE_DE_VOTRE_PC>:8080
   ```
   Trouver son IP locale :
   - Windows : `ipconfig` → ligne "Adresse IPv4"
   - Linux/Mac : `ip a` ou `ifconfig`
3. **Le téléphone affiche une popup d'autorisation de débogage USB** au premier branchement/lancement — acceptez-la sur l'écran du téléphone.
4. **Relancez la commande après avoir accepté** : au premier essai, le téléphone n'est pas encore reconnu comme autorisé au moment où `flutter run` construit la liste des cibles, donc seuls Windows/Chrome/Edge sont proposés. Un second lancement après acceptation détecte correctement le téléphone.
5. Le téléphone et le PC doivent être sur le **même réseau WiFi** pour que l'IP locale soit joignable.

#### Option C — Émulateur Android

```bash
adb reverse tcp:8080 tcp:8080
flutter run \
  --dart-define=APP_ENV=local \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

Le `adb reverse` redirige le port 8080 de l'émulateur vers celui de votre machine, permettant de garder `127.0.0.1`.

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