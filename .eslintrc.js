// module.exports = require("./packages/config/eslint-preset");
module.exports = {
  "extends": "./packages/config/eslint-preset",
  "rules": {
    'prettier/prettier': [
      'error',
      {
        'endOfLine': 'auto',
      }
    ]
  }
}
