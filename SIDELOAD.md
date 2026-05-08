# DriveTN — Guide de Sideload iOS (Sideloadly, depuis la Tunisie)

Guide pour installer une build de DriveTN sur ton iPhone depuis Windows, sans Mac et sans compte Apple Developer payant. On utilise GitHub Actions pour builder un IPA non signé, puis **Sideloadly** pour le signer avec ton Apple ID gratuit et l'installer sur l'iPhone.

> Pourquoi Sideloadly et pas AltStore ? AltServer (côté Windows d'AltStore) demande iCloud pour Windows qui est instable/restrictif en Tunisie. Sideloadly est un seul `.exe`, pas d'iCloud requis, fonctionne partout dans le monde.

---

## 1. Pré-requis

- **Windows 10 ou 11** (64-bit)
- **iPhone sous iOS 17 ou 18**
- **Câble USB Lightning ou USB-C** fiable
- **Apple ID** (compte gratuit, pas de Developer Program nécessaire)
- **iTunes installé depuis apple.com/itunes** (PAS la version Microsoft Store — ses pilotes USB ne sont pas reconnus par Sideloadly)
- **Compte GitHub** avec accès au repo `github.com/Mondher1999/DriveTN`

> Pas besoin d'iCloud pour Windows. Pas besoin d'AltServer.

---

## 2. Installation de Sideloadly (à faire une seule fois)

### 2.1. Télécharger Sideloadly

- Va sur **[sideloadly.io](https://sideloadly.io)**
- Télécharge **Sideloadly pour Windows** (`Sideloadly.exe` ou `.msi`)
- Lance l'installeur

### 2.2. Installer iTunes (si pas déjà fait)

- Télécharge iTunes depuis **apple.com/itunes** (version classique, pas Microsoft Store)
- Installe-le et lance-le une fois pour qu'il enregistre les pilotes USB de l'iPhone

### 2.3. Connecter l'iPhone

- Branche l'iPhone au PC en USB
- Sur l'iPhone, tape **"Faire confiance à cet ordinateur"** quand la popup apparaît, puis entre le code PIN
- Ouvre iTunes une fois pour vérifier qu'il détecte bien l'iPhone (sinon Sideloadly ne le verra pas non plus)

### 2.4. Préparer ton Apple ID pour le sideloading

Si tu as la **2FA activée** (vérification en deux étapes — recommandée par Apple) :
- Va sur **[appleid.apple.com](https://appleid.apple.com)** → connecte-toi
- Section **Connexion et sécurité → Mots de passe pour les apps**
- Génère un nouveau mot de passe (libellé : "Sideloadly DriveTN")
- Copie-le quelque part — c'est ce mot de passe que tu utiliseras dans Sideloadly, **pas** ton mot de passe Apple ID normal

Si tu n'as pas la 2FA, ton mot de passe Apple ID classique fonctionne (mais active la 2FA, c'est plus sûr).

---

## 3. Workflow à chaque nouvelle build

C'est le cycle que tu répètes pour chaque test (et tous les 7 jours pour re-signer l'app).

### 3.1. Déclencher la build sur GitHub

Deux options :
- **Push** sur la branche `main`, OU
- Va sur `github.com/Mondher1999/DriveTN/actions` → onglet **iOS Build (unsigned IPA for AltStore)** → bouton **Run workflow**

### 3.2. Attendre la fin de la build

- Compte environ **8 à 12 minutes**
- Quand le workflow passe au vert, ouvre la page du run

### 3.3. Récupérer l'IPA

- En bas de la page du run, section **Artifacts** → télécharge `DriveTN-ios-unsigned`
- Décompresse le ZIP → tu obtiens `DriveTN.ipa`

### 3.4. Installer via Sideloadly

1. iPhone branché en USB et déverrouillé
2. Lance **Sideloadly** sur Windows
3. **Drag-and-drop** `DriveTN.ipa` dans la fenêtre Sideloadly (zone "Drag & Drop IPA file here")
4. Vérifie que **Apple ID** est rempli avec ton email Apple
5. Vérifie que ton iPhone est sélectionné dans **Device** (s'il n'apparaît pas, débranche/rebranche le câble + assure-toi qu'iTunes le détecte)
6. Clique **Start**
7. Sideloadly demande ton **mot de passe Apple ID** (ou le mot de passe spécifique app si 2FA) — entre-le
8. Sideloadly signe et installe l'IPA sur l'iPhone (~1-2 min, tu vois la progress bar)
9. Quand c'est marqué **"DONE"**, l'app DriveTN apparaît sur l'écran d'accueil de l'iPhone

### 3.5. Faire confiance au profil développeur (premier lancement uniquement)

- Tape sur l'icône DriveTN sur l'iPhone → tu vois **"Untrusted Developer"**
- Va dans **Réglages → Général → VPN et gestion de l'appareil**
- Tu vois ton Apple ID sous **"App de développeur"** → tape dessus → **Faire confiance**
- Relance DriveTN — ça marche

---

## 4. Limites du Apple ID gratuit

À garder en tête :

- **Expiration 7 jours** : l'app cesse de se lancer après une semaine. Pour la renouveler, tu refais l'étape 3.4 avec le même IPA (Sideloadly re-signe, l'app reste installée mais avec une nouvelle signature)
- **Maximum 3 apps sideloadées en même temps** par Apple ID
- **Pas de push notifications** (APNs)
- **Pas d'iCloud** (CloudKit, iCloud Drive depuis l'app)
- **Pas d'achats in-app**
- **Pas de Sign in with Apple**

### Re-signer tous les 7 jours

Sideloadly **ne re-signe pas automatiquement** (contrairement à AltStore). Tu dois :
1. Brancher l'iPhone tous les ~6 jours
2. Lancer Sideloadly
3. Drag le **même** IPA, **Start**, c'est re-signé

Ça prend ~2 minutes. Mets-toi un rappel hebdomadaire.

> Si tu as déjà téléchargé un IPA depuis GitHub, garde-le quelque part — pas besoin de re-télécharger pour juste re-signer.

---

## 5. Dépannage

### "Sideloadly ne voit pas mon iPhone"

- Lance **iTunes** et vérifie qu'il détecte l'iPhone. Si non : pilote USB pas installé → réinstalle iTunes (version Apple, pas Microsoft Store)
- Débranche / rebranche le câble USB
- Sur l'iPhone, refais "Faire confiance à cet ordinateur"
- Essaie un autre port USB ou un autre câble

### "Could not connect to Apple servers" / erreur 1011 / "An error occurred while logging in"

- Vérifie que ta connexion internet est stable
- En Tunisie, certains réseaux mobiles bloquent des endpoints Apple — essaie en Wi-Fi
- Si tu as la 2FA, tu **dois** utiliser un mot de passe spécifique app (étape 2.4), pas ton mot de passe normal
- Désactive temporairement antivirus / firewall Windows pour tester

### "App won't install: bundle ID conflict"

- Désinstalle l'ancienne version de DriveTN sur l'iPhone (appui long sur l'icône → Supprimer l'app)
- Re-tente l'install

### "Untrusted Developer" au premier lancement

- **Réglages → Général → VPN et gestion de l'appareil → ton Apple ID → Faire confiance**
- Relance l'app

### "App expirée après 7 jours"

- Refais l'étape 3.4 avec le même IPA. C'est ce qu'on appelle "re-signer".

### Erreur "Provisioning profile" ou "guru meditation"

- L'Apple ID a peut-être atteint la limite de 3 apps. Désinstalle d'autres apps sideloadées
- OU : Apple a invalidé tes profils → connecte-toi sur appleid.apple.com et re-essaie

### "Maximum number of free certificates" (rare)

- Apple limite à ~10 certificats actifs par Apple ID. Si tu changes souvent de PC ou réinstalles Sideloadly, tu peux les épuiser
- Va dans Sideloadly → menu → **Tools → Reset certificates** pour libérer les anciens

---

## 6. Astuces

- **Garde le câble USB sous la main** — il sert à chaque install et à chaque re-sign
- **Conserve le dernier IPA** dans un dossier dédié (`~/DriveTN/builds/`) pour pouvoir re-signer rapidement sans re-télécharger
- **Mot de passe spécifique app** : crées-en un et stocke-le dans un gestionnaire de mots de passe — tu le réutiliseras à chaque re-sign
- **Nomme tes builds** dans `pubspec.yaml` (incrémente `version: 0.1.0+1` à chaque push significatif) pour t'y retrouver
- **VPN si réseau capricieux** : si ton FAI tunisien bloque des endpoints Apple, un VPN gratuit (ProtonVPN, Cloudflare WARP) règle le souci

### Install permanent (sans expiration 7 jours)

Les seules options valides sont **payantes** :
- **Apple Developer Program** à 99 $/an → signature ad-hoc valide 1 an, ou distribution via **TestFlight** (90 jours par build, jusqu'à 10 000 testeurs, pas besoin de câble)

Pour du dev solo, le combo gratuit GitHub Actions + Sideloadly reste largement suffisant tant que tu acceptes le re-sign hebdo.
