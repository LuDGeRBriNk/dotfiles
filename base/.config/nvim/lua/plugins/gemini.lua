-- This file configures Gemini AI integration for autocompletion and chat.
-- It uses the 'kiddos/gemini.nvim' plugin which bridges Neovim with Google's Gemini models.

return {
  {
    "kiddos/gemini.nvim",
    -- 'build' runs commands after the plugin is installed or updated.
    build = "UpdateRemotePlugins",

    config = function()
      -- The .setup() function initializes the plugin with your preferences.
      require("gemini").setup({
        -- Specifies which Gemini model to use for processing requests.
        model = "gemini-3.1-pro",

        -- 'hints' provides ghost-text style autocompletion as you type.
        hints = { enabled = true },

        -- 'chat' enables an interactive window to talk to the AI about your code.
        chat = { enabled = true },
      })
    end,
  },
}
