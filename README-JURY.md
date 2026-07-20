# IronPath — Déploiement jury

Ce paquet démarre l’API Spring Boot, PostgreSQL et une boîte email locale Mailpit.
L’application Flutter reste une application Android : elle s’installe avec l’APK fourni dans la release.

## Prérequis

- Docker Desktop récent, avec Docker Compose v2 ;
- pour installer l’APK : Android Platform Tools (`adb`) et un émulateur ou un appareil Android connecté.

## Démarrage depuis le dépôt

```bash
cp .env.example .env
docker compose up --build --wait --wait-timeout 240
```

Sous PowerShell :

```powershell
Copy-Item .env.example .env
docker compose up --build --wait --wait-timeout 240
```

## Adresses utiles

- API : http://localhost:8080
- Santé : http://localhost:8080/actuator/health
- Swagger : http://localhost:8080/swagger-ui/index.html
- Emails capturés : http://localhost:8025

Les inscriptions et demandes de réinitialisation envoient leurs emails dans Mailpit, pas sur Internet.

## Installation de l’APK jury

L’APK jury est compilé pour joindre `http://127.0.0.1:8080`.
Reliez d’abord ce port Android au port de la machine :

```bash
adb reverse tcp:8080 tcp:8080
adb install -r ironpath-jury-v1.0.0.apk
```

Cette commande fonctionne avec un appareil USB autorisé et avec la plupart des émulateurs Android.

## Vérification rapide

```bash
docker compose ps
curl http://localhost:8080/actuator/health
```

Créez ensuite un compte dans l’application et ouvrez Mailpit pour cliquer sur le lien de confirmation.

## Utilisation d’une image GHCR déjà publiée

Renseignez dans `.env` :

```dotenv
BACKEND_IMAGE=ghcr.io/VOTRE_COMPTE/ironpath-backend:v1.0.0
```

Puis :

```bash
docker compose -f compose.ghcr.yaml up --wait --wait-timeout 240
```

Le package GHCR doit être public, sinon Docker demandera une authentification.

## Logs et dépannage

```bash
docker compose ps
docker compose logs -f backend
docker compose logs -f postgres
docker compose logs -f mailpit
```

En cas de port occupé, changez `BACKEND_PORT` ou `MAILPIT_HTTP_PORT` dans `.env`.

## Arrêt

Conserver les données :

```bash
docker compose down
```

Réinitialiser entièrement la démonstration :

```bash
docker compose down --volumes --remove-orphans
```

## Sécurité

Les valeurs de `.env.example` sont exclusivement destinées à une démonstration locale. Elles ne doivent jamais être réutilisées en production.
