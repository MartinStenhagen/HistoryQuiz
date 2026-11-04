# Databas

Starta MySQL och se till att `backend/.env` har rätt värden.

Kör från projektroten med en tom databas:

```sh
cd backend
npm run db:init
npm run db:check
npm start
```

`db:init` skapar databasen och tabellerna från `schema.sql` och lägger in grunddata från `seed.sql`. Kör det en gång mot en tom databas. Om ytterligare frågor läggs till i `seed.sql` gör det före initieringen.

`db:check` kontrollerar anslutningen. `npm start` startar backend; vid senare starter räcker det kommandot från backend-mappen.
