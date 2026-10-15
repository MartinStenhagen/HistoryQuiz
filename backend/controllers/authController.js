const authService = require('../services/authService');

//ska utarbetas mer för registrerandet av användare
exports.registerUser = (async (req, res) => {
    try{
        const {roleId, username, displayName, password} = req.body;
        if(!roleId || !username || !displayName || !password){
            return res.status(400).json({error: "role, username, displayname and password required"});
        }
        const user = await authService.registerUser(roleId, username, displayName, password);
        return res.status(201).json({message: "registration succesfull ", user})
     } catch(error){
        return res.status(400).json({error: error.message});
     }
});

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