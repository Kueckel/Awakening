# PI-Zeiterfassung – Einrichtung mit Supabase

Dauer: etwa 20 Minuten. Du brauchst einen Supabase-Account (kostenlos) und für das Hosting einen GitHub-Account (kostenlos).

## 1. Supabase-Projekt anlegen

1. Auf https://supabase.com registrieren bzw. anmelden.
2. **New project** → Name z. B. `pi-zeiterfassung`, ein starkes Datenbank-Passwort vergeben (irgendwo notieren, du brauchst es im Alltag aber nicht), Region **Frankfurt (eu-central-1)** wählen → **Create new project**. Das Anlegen dauert 1–2 Minuten.

## 2. Datenbank einrichten

1. Links im Menü **SQL Editor** öffnen → **New query**.
2. Den kompletten Inhalt von `setup.sql` einfügen und mit **Run** ausführen. Unten sollte „Success. No rows returned“ stehen.

Damit sind die Tabellen `features` und `entries` angelegt, Row Level Security ist aktiv (jeder Nutzer sieht nur seine eigenen Daten) und Realtime-Synchronisation zwischen deinen Geräten ist eingeschaltet.

## 3. Deinen Benutzer anlegen und Registrierung sperren

Die App hat bewusst keine Registrierungsseite – du legst deinen Zugang einmalig im Dashboard an:

1. **Authentication → Users → Add user → Create new user**.
2. Deine E-Mail und ein Passwort eintragen, **Auto Confirm User** aktivieren → **Create user**.
3. Damit sich sonst niemand registrieren kann: **Authentication → Sign In / Providers → Email** → Schalter **Allow new users to sign up** ausschalten → Save.

## 4. Zugangsdaten in die App eintragen

1. **Project Settings (Zahnrad) → API** (bzw. **API Keys**). Dort findest du die **Project URL** (`https://xxxx.supabase.co`) und den Key **anon public**.
2. `index.html` in einem Texteditor öffnen. Ganz oben im `<script>`-Block die beiden Zeilen ersetzen:

```js
const SUPABASE_URL = 'https://xxxx.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOi...';
```

Der anon-Key ist dafür gemacht, öffentlich im Browser zu liegen – geschützt werden die Daten durch Row Level Security und dein Login, nicht durch den Key.

**Erster Test:** `index.html` per Doppelklick öffnen, anmelden, ein Feature anlegen. Wenn das klappt, ist die Datenbank korrekt verbunden.

## 5. Hosting auf GitHub Pages (damit du von überall zugreifen kannst)

1. Auf https://github.com ein neues Repository anlegen: Name z. B. `pi-zeiterfassung`, **Private** ist in Ordnung – GitHub Pages funktioniert auch bei privaten Repos nur mit einem Pro-Account; beim kostenlosen Account muss das Repo **Public** sein. Das ist unkritisch, weil in der Datei nur die öffentliche URL und der anon-Key stehen und keine Daten.
2. **Add file → Upload files** → `index.html` hochladen → **Commit changes**.
3. **Settings → Pages** → unter *Build and deployment* bei *Source* **Deploy from a branch** wählen, Branch `main`, Ordner `/ (root)` → **Save**.
4. Nach ein bis zwei Minuten ist die App unter `https://<dein-github-name>.github.io/pi-zeiterfassung/` erreichbar. Lesezeichen setzen, auf dem Handy „Zum Startbildschirm hinzufügen“.

Alternative ohne GitHub: Auf https://app.netlify.com/drop den Ordner mit der `index.html` per Drag & Drop ablegen – fertig, kostenlos, mit zufälliger URL.

## 6. Daten aus der lokalen Version übernehmen (optional)

Falls du mit der ersten, lokalen Version schon getrackt hast: dort unter **Daten → Sicherung herunterladen (JSON)**, in der neuen App unter **Daten → Import aus Sicherung** die Datei auswählen.

## Gut zu wissen

- **Pausierung:** Kostenlose Supabase-Projekte werden nach 7 Tagen ohne Datenbankaktivität pausiert (z. B. nach dem Urlaub). Dann zeigt die App „Daten konnten nicht geladen werden“. Im Supabase-Dashboard das Projekt öffnen → **Restore project** klicken, nach 1–2 Minuten läuft alles weiter. Daten gehen dabei nicht verloren.
- **Passwort vergessen:** Im Dashboard unter **Authentication → Users** deinen Nutzer öffnen → *Reset password* bzw. neues Passwort setzen.
- **Sicherung:** Zusätzlich zur Datenbank kannst du jederzeit unter **Daten** ein JSON-Backup oder einen CSV-Export ziehen. Supabase legt im Free Plan keine automatischen Backups an.
- **Daten direkt anschauen:** **Table Editor** im Dashboard zeigt dir die Tabellen `features` und `entries` als Tabelle, du kannst dort auch von Hand korrigieren.
- **Mehrere Geräte gleichzeitig:** Änderungen erscheinen dank Realtime innerhalb von etwa einer Sekunde auch auf anderen offenen Geräten. Der grüne Punkt neben deiner E-Mail zeigt, dass die Verbindung steht.

## 7. Als App auf dem iPhone / Android installieren

Die App ist als Progressive Web App vorbereitet. Dafür müssen neben `index.html` auch diese Dateien im Repository liegen: `manifest.webmanifest`, `icon-180.png`, `icon-512.png`, `icon-512-maskable.png`, `favicon.png`.

**iPhone (Safari):** App-URL öffnen → Teilen-Symbol (Quadrat mit Pfeil) → **Zum Home-Bildschirm** → **Hinzufügen**. Das Icon erscheint auf dem Home-Bildschirm; die App öffnet im Vollbild ohne Browserleiste. Beim ersten Start musst du dich einmal neu anmelden, weil die installierte App einen eigenen Speicher hat.

**Android (Chrome):** App-URL öffnen → Drei-Punkte-Menü → **App installieren** bzw. **Zum Startbildschirm hinzufügen**.

Updates der App bekommst du automatisch: Beim nächsten Öffnen lädt die installierte App die aktuelle `index.html` von deiner URL.
