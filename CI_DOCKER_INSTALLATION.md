# Installation CI/CD et Docker — IronPath

## Arborescence à copier

Copier le contenu de ce paquet à la racine du monorepo, où se trouvent `backend/` et `frontend/`.

Les deux anciens workflows peuvent être remplacés par les versions de `.github/workflows/` présentes ici.

## Secret GitHub requis

Créer dans `Settings > Secrets and variables > Actions` :

- `NVD_API_KEY` : clé NVD utilisée par OWASP Dependency-Check.

Le scan hebdomadaire est ignoré avec un avertissement si cette clé n’est pas encore configurée.

## Test local avant push

```bash
cp .env.example .env
docker compose config
docker compose up --build --wait --wait-timeout 240
bash scripts/docker-smoke-test.sh
docker compose down --volumes --remove-orphans
```

Puis :

```bash
cd backend
./gradlew clean check spotbugsMain bootJar
cd ../frontend
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage
```

## Branche de travail

```bash
git switch develop
git pull --ff-only origin develop
git switch -c chore/ci-cd-docker
```

Après copie des fichiers :

```bash
git add .github backend/Dockerfile backend/.dockerignore \
  backend/src/main/resources/application-docker.properties \
  compose.yaml compose.ghcr.yaml .env.example \
  README-JURY.md scripts

git status
git diff --cached --stat
git commit -m "ci: strengthen quality gates and add Docker deployment"
git push -u origin chore/ci-cd-docker
```

Ouvrir une pull request `chore/ci-cd-docker -> develop`.

## Contrôles à rendre obligatoires

Après leur première exécution réussie, configurer un ruleset sur `main` :

- pull request obligatoire ;
- branche à jour avant fusion ;
- conversations résolues ;
- force push interdit ;
- checks requis :
  - `Backend / Quality` ;
  - `Frontend / Quality` ;
  - `Docker / Smoke test`.

## Fusion finale

Quand `develop` est entièrement vert :

1. ouvrir une PR `develop -> main` ;
2. relire la liste des commits et fichiers ;
3. attendre les trois checks requis ;
4. effectuer un merge commit ;
5. créer le tag :

```bash
git switch main
git pull --ff-only origin main
git tag -a v1.0.0 -m "IronPath 1.0.0"
git push origin v1.0.0
```

Le tag déclenche `release.yml`, publie l’image backend sur GHCR et crée une GitHub Release avec l’APK et les fichiers de déploiement.

## Après la première publication GHCR

Dans la page du package `ironpath-backend`, rendre le package public pour permettre au jury de le télécharger sans compte GitHub.
