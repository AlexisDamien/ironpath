# IronPath

Application mobile de suivi d'entraînement musculaire.

- **Backend** : Spring Boot 4 / Java 21 / PostgreSQL 17
- **Frontend** : Flutter 3.44 (Android)
- **Email** : Mailpit (démo locale)

Deux façons de lancer l'application pour la tester : Chrome/desktop, ou téléphone Android en USB — détail à l'étape 5.

---

## Prérequis à installer

| Outil | Version | Installation |
|---|---|---|
| Docker Desktop (avec Compose v2) | récente | https://www.docker.com/products/docker-desktop/ |
| Git | récente | https://git-scm.com/downloads |
| Flutter SDK | 3.44.2 | Automatique, voir étape 2 ci-dessous |

Le JDK 21 n'est **pas nécessaire** en local si vous utilisez Docker (le backend est compilé et exécuté dans le conteneur). Non requis pour lancer l'app sur desktop ou navigateur (Windows, Chrome, Edge).

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

Vérifiez ensuite que l'ensemble de l'environnement est en ordre :
```bash
flutter doctor
```
Si la commande `flutter` (ou `flutter doctor`) n'est pas reconnue, vérifiez vos variables d'environnement et ajoutez le dossier d'installation à votre `PATH` :
- Windows : `C:\Users\<votre_nom_utilisateur>\dev\flutter\bin`
- Linux/Mac : `~/dev/flutter/bin`

Le script est censé le faire automatiquement (voir plus haut) — fermez et rouvrez votre terminal si ce n'est pas déjà pris en compte.

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

Choisissez ensuite l'une des deux cibles ci-dessous selon votre besoin.

#### Option A — Chrome ou desktop Windows (le plus simple, aucune config réseau)

```bash
flutter run \
  --dart-define=APP_ENV=local \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

`flutter run` propose de choisir la cible — sélectionnez Chrome, Edge ou Windows. `127.0.0.1` pointe directement sur votre machine, aucune étape supplémentaire.

#### Option B — Téléphone Android en USB

1. **Avant de brancher le téléphone**, activez manuellement le débogage USB : Paramètres → À propos du téléphone → tapez 7 fois sur "Numéro de build" pour activer les options développeur, puis Paramètres → Options développeur → activez "Débogage USB".
2. Branchez le téléphone au PC en USB.
3. Le téléphone et le PC doivent être sur le **même réseau WiFi** pour que l'IP locale soit joignable.
4. Lancez la commande avec l'IP locale de votre PC (pas `127.0.0.1`, qui désignerait le téléphone lui-même) :
   ```bash
   flutter run \
     --dart-define=APP_ENV=local \
     --dart-define=API_BASE_URL=http://<IP_LOCALE_DE_VOTRE_PC>:8080
   ```
   Trouver son IP locale :
   - Windows : `ipconfig` → ligne "Adresse IPv4"
   - Linux/Mac : `ip a` ou `ifconfig`

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