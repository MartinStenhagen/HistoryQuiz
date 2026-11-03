# Backend för HistoryQuiz

Kör kommandona från backendmappen. Node läser `.env` via `database/connection.js`.

## Konfiguration

- `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`: befintlig MySQL-databas.
- `APP_ORIGIN`: frontendens exakta origin, lokalt normalt `http://localhost:5173`.
- `SESSION_SECRET`: en beständig hemlighet, genererad med exempelvis
  `node -e "console.log(require('node:crypto').randomBytes(32).toString('hex'))"`.
- `NODE_ENV=production` kräver HTTPS för sessionscookien. Vid TLS-terminering
  i en reverse proxy behöver Express `trust proxy` konfigureras för just den proxyn.
- `PORT`: valfri API-port, standard 3000.

Hemligheter hör endast hemma i backendens miljö, aldrig i Git eller frontendens Vite-variabler.

## Databas och start

För en ny databas: använd `database/schema.sql`, som skapar `historyQuizDb`.
Se till att `DB_NAME` i `.env` matchar databasens namn.
För en befintlig databas: kör `npm run db:migrate` för att lägga till sessionstabellen
och `answer_attempts.response_json`. Migreringen kan köras igen och tar inte bort data.
Kör inte hela `schema.sql` över en befintlig databas.

```sh
npm install
npm run db:check
npm run db:migrate
npm start
```

Frontendens `/api`-proxy används för cookies. Skrivande API-anrop kräver JSON,
godkänd `Origin` och `X-HistoryQuiz-Request: 1`; den gemensamma frontendhjälparen
skickar rätt headers. `GET /api/me` verifierar inloggningen och
`POST /api/logout` förstör sessionen.

Gäster använder `POST /api/questions/:id/check` utan sparande.
Inloggade använder `POST /api/questions/:id/answer` med `selectedOptionId` och
en UUID v4 i `requestKey`. Omsändningar använder samma nyckel och alternativ.
Ägaren hämtas alltid från sessionen. `X-HistoryQuiz-Account` kan ange klientens
förväntade konto för att avbryta ett försök om sessionen bytt konto i en annan flik.

Statistik och tilldelade utmärkelser läses via `GET /api/me/achievements`.
Nya försök och tilldelningar sparas i samma transaktion. Redan sparad återkoppling
återanvänds vid omsändning. Äldre rader utan `response_json` ger 409 vid omsändning
men räknas fortfarande i statistiken. Om sådana historiska svar finns kan
`achievementService.awardAchievements` köras en gång per användare inuti
`withUserTransaction` för att tilldela redan intjänade utmärkelser.

## Verifiering

`npm test` testar Express-routes, sessionscookies, behörighet, återförsök och
statistikregler med isolerade ersättningar för databasen. Dessa tester behöver
ingen MySQL-server. De ersätter inte en kontroll mot en riktig MySQL-databas av
migrering, samtidiga transaktioner och sessionslagring.
