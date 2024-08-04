-- return {}
return {
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
          unreachable = false,
        },
        staticcheck = true,
        ["ui.inlayhint.hints"] = {
          rangeVariableTypes = true,
          parameterNames = true,
          constantValues = true,
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          functionTypeParameters = true,
        },
      },
    },
}
