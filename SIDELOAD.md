# DriveTN — Guide de Sideload iOS

Guide pour installer une build de DriveTN sur ton iPhone depuis Windows, sans Mac et sans compte Apple Developer payant. On utilise GitHub Actions pour builder un IPA non signé, puis AltStore pour le signer avec ton Apple ID gratuit et l'installer sur l'iPhone.

---

## 1. Pré-requis

Avant de commencer, assure-toi d'avoir:

- **Windows 10 ou 11** (64-bit)
- **iPhone sous iOS 17 ou 18**
- **Câble USB Lightning ou USB-C** (Lightning fiable, pas un câble de charge no-name)
- **Apple ID** (compte gratuit, pas besoin du Developer Program à 99 $/an)
- **iTunes installé depuis le site Apple** (PAS la version Microsoft Store — AltServer ne la détecte pas correctement). Télécharge l'installeur `.exe` sur apple.com/itunes
- **iCloud pour Windows** installé (requis par AltServer pour la communication avec l'iPhone)
- **Compte GitHub** avec accès au repo `github.com/Mondher1999/DriveTN`
- Workflow `.github/workflows/ios-build.yml` déjà présent dans le repo

> Note: l'iPhone et le PC doivent être sur le **même réseau Wi-Fi** pour le refresh automatique tous les 7 jours.

---

## 2. Installation initiale d'AltStore (à faire une seule fois)

### 2.1. Télécharger AltServer

- Va sur [altstore.io](https://altstore.io)
- Télécharge **AltServer pour Windows**
- Décompresse le ZIP

### 2.2. Installer AltServer sur Windows

- Lance `Setup.exe`
- Accepte l'installation des dépendances si proposé
- AltServer démarre dans la **system tray** (icône en bas à droite, près de l'horloge — clique sur la flèche `^` si elle est cachée)

### 2.3. Connecter l'iPhone

- Branche l'iPhone au PC en USB
- Sur l'iPhone, tape **"Faire confiance à cet ordinateur"** quand la popup apparaît, puis entre le code PIN
- Ouvre iTunes une fois pour vérifier qu'il détecte l'iPhone (sinon AltServer ne le verra pas non plus)
- Dans iTunes: sélectionne l'iPhone → **Résumé** → coche **"Synchroniser avec cet iPhone en Wi-Fi"** → Appliquer

### 2.4. Installer AltStore sur l'iPhone

- Clic droit sur l'icône **AltServer** dans la system tray
- **Install AltStore** → choisis ton iPhone dans la liste
- Entre ton **Apple ID + mot de passe**
  - Si tu as la 2FA activée, génère un mot de passe spécifique app sur [appleid.apple.com](https://appleid.apple.com) → Sécurité → Mots de passe pour les apps
- Attends environ 1 minute. AltStore apparaît sur ton iPhone

### 2.5. Faire confiance au profil développeur

- Sur l'iPhone: **Réglages → Général → VPN et gestion de l'appareil**
- Tu vois ton Apple ID dans **"App de développeur"** → tape dessus → **Faire confiance**
- Lance AltStore sur l'iPhone, vérifie qu'il s'ouvre sans erreur

---

## 3. Workflow à chaque nouvelle build

C'est le cycle que tu répètes pour chaque test.

### 3.1. Déclencher la build

Deux options:

- **Push** sur la branche `main`, OU
- Va sur `github.com/Mondher1999/DriveTN/actions` → onglet **iOS Build (unsigned IPA for AltStore)** → bouton **Run workflow**

### 3.2. Attendre la fin de la build

- Compte environ **8 à 12 minutes**
- Quand le workflow passe au vert, ouvre le run

### 3.3. Récupérer l'IPA

- En bas de la page du run, section **Artifacts** → télécharge `DriveTN-ios-unsigned`
- Décompresse le ZIP → tu obtiens `DriveTN.ipa`

### 3.4. Installer via AltStore

- Sur Windows, AltServer doit tourner (system tray)
- iPhone branché en USB, déverrouillé
- Méthode recommandée: envoie le `DriveTN.ipa` sur l'iPhone via **iCloud Drive** (depuis Files Explorer Windows → iCloud Drive)
- Sur l'iPhone, ouvre **Fichiers → iCloud Drive → DriveTN.ipa** → tape **Partager → AltStore**
- AltStore signe avec ton Apple ID et installe sur l'iPhone (~30 s)

### 3.5. Premier lancement

- L'icône DriveTN apparaît sur l'écran d'accueil
- Premier tap → si "Untrusted Developer", retourne à l'étape **2.5** pour faire confiance au profil

---

## 4. Limites du Apple ID gratuit

À garder en tête:

- **Expiration 7 jours**: l'app cesse de se lancer après une semaine. Il faut la re-signer
- **Maximum 3 apps sideloadées en même temps** par Apple ID (AltStore compte pour 1, donc en pratique tu as 2 slots libres)
- **Pas de push notifications** (APNs)
- **Pas d'iCloud** (CloudKit, iCloud Drive depuis l'app)
- **Pas d'achats in-app**
- **Bundle ID forcé** par Apple à un préfixe lié à ton Apple ID (AltStore gère ça automatiquement)

### Refresh automatique des 7 jours

AltStore tourne en arrière-plan sur ton PC (AltServer system tray) et utilise mDNS sur le réseau local pour re-signer les apps avant expiration.

**Conditions pour que ça marche tout seul:**
1. AltServer lancé sur le PC (et PC allumé)
2. iPhone et PC sur **le même Wi-Fi**
3. AltStore ouvert au moins une fois en arrière-plan sur l'iPhone (Background App Refresh activé pour AltStore: **Réglages → Général → Actualisation en arrière-plan**)

Si une de ces conditions manque, tu devras re-signer manuellement: ouvre AltStore iPhone → **My Apps** → tape **Refresh** à côté de DriveTN.

---

## 5. Dépannage

### "AltServer ne voit pas mon iPhone"

- Vérifie que **iTunes (version Apple, pas Microsoft Store)** est installé et a déjà ouvert l'iPhone une fois
- Vérifie que **iCloud pour Windows** est installé
- Dans iTunes: **Synchronisation Wi-Fi activée** pour cet iPhone
- Débranche/rebranche le câble USB, "Faire confiance" à nouveau si demandé
- Redémarre AltServer (clic droit système tray → Quit → relance)

### "App won't install: bundle ID conflict"

- Désinstalle l'ancienne version de DriveTN sur l'iPhone (appui long → Supprimer l'app)
- Re-tente l'install via AltStore

### "Untrusted Developer" au premier lancement

- **Réglages → Général → VPN et gestion de l'appareil → ton Apple ID → Faire confiance**
- Relance l'app

### "App expirée après 7 jours"

- Ouvre AltStore iPhone → **My Apps** → tape **Refresh** à côté de DriveTN
- Si ça échoue, re-drag l'IPA dans AltStore (procédure 3.4)

### Erreur de signature au premier lancement (code signing error)

- Redémarre l'iPhone (vraiment, ça résout pas mal de cas)
- Refais l'étape 2.5 (faire confiance au profil)
- Si toujours bloqué: désinstalle l'app, redémarre, ré-installe via AltStore

### Erreur "Could not find Mail plugin" lors de l'install d'AltServer

- Lance **Mail** une fois sur Windows (l'app native), puis re-tente
- Sinon réinstalle AltServer en mode admin

### "Maximum number of apps installed" (3 apps max)

- Désinstalle une autre app sideloadée pour libérer un slot

---

## 6. Astuces

- **Épingle AltServer au démarrage de Windows**: Win+R → `shell:startup` → glisse un raccourci d'AltServer. Le refresh auto fonctionne uniquement si AltServer tourne
- **Garde l'iPhone sur le même Wi-Fi que le PC la nuit**: AltStore re-signe automatiquement avant expiration, tu n'as rien à faire
- **Active Background App Refresh** pour AltStore sur l'iPhone (Réglages → Général → Actualisation en arrière-plan → AltStore: ON)
- **Envoie l'IPA via iCloud Drive** depuis le PC vers l'iPhone — c'est le plus simple pour le passer à AltStore mobile (Files → iCloud Drive → DriveTN.ipa → Partager → AltStore)
- **Garde le câble USB sous la main** pour le premier install et en cas de souci de refresh
- **Nomme tes builds** dans `pubspec.yaml` (version + build number incrémenté à chaque push) pour t'y retrouver dans AltStore

### Install permanent (sans expiration 7 jours)

Les seules options valides sont **payantes**:
- **Apple Developer Program** à 99 $/an → signature ad-hoc valide 1 an, ou distribution via **TestFlight** (90 jours par build, jusqu'à 10 000 testeurs)

Pour du dev solo, le combo gratuit GitHub Actions + AltStore reste largement suffisant tant que tu acceptes le refresh hebdo.
