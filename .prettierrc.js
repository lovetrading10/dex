module.exports = {
  overrides: [
    {
      files: "*.sol",
      options: {
        bracketSpacing: false,
        printWidth: 100,
        useTabs: false,
        singleQuote: false,
        explicitTypes: "always",
      },
    },
    {
      files: "*.ts",
      options: {
        printWidth: 145,
        semi: false,
        trailingComma: "es5",
      },
    },
  ],
};
