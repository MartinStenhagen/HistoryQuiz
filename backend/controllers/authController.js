const authService = require('../services/authService');

exports.registerUser = async (req, res) => {
    try {
        const { username, displayName, password } = req.body ?? {};

        if (
            typeof username !== 'string' || !username.trim() ||
            typeof displayName !== 'string' || !displayName.trim() ||
            typeof password !== 'string' || !password
        ) {
            return res.status(400).json({
                error: 'Användarnamn, visningsnamn och lösenord krävs.',
            });
        }

        if (username.trim().length > 64 || displayName.trim().length > 100) {
            return res.status(400).json({
                error: 'Användarnamn får ha högst 64 tecken och visningsnamn högst 100.',
            });
        }

        // Rollen bestäms av backend, oavsett vad klienten skickar.
        const user = await authService.registerUser(
            username.trim(), displayName.trim(), password
        );

        return res.status(201).json({ message: 'Kontot är skapat.', user });
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ error: 'Användarnamnet är redan upptaget.' });
        }

        console.error('Kunde inte registrera användaren:', error);
        return res.status(500).json({ error: 'Kunde inte skapa kontot. Försök igen.' });
    }
};

exports.loginAttempt = (async (req, res) => {
    try {
      const { username, password } = req.body;
      if (!username || !password) {
        return res.status(400).json({ error: 'username and password required' });
      }
      const user = await authService.login(username, password);
      if (!user) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }
      return res.status(200).json({ message: 'Login successful', user });
    } catch (error) { 
        console.error('Login error:', error); 
        return res.status(500).json({ error: 'Internal server error' });
    }
})
