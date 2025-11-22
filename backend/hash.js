const bcrypt = require('bcryptjs');
bcrypt.hash('Talamar49!', 10).then(hash => console.log(hash));
