-- Java-specific configuration for nvim-jdtls
local jdtls = require('jdtls')

-- Paths
local root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'})
local workspace_dir = vim.fn.expand('~/.local/share/eclipse/' .. vim.fn.fnamemodify(root_dir, ':p:h:t'))

-- Detect Java runtimes dynamically on macOS using /usr/libexec/java_home
local function detect_java_runtimes()
  local res = {}
  local function add(ver, name)
    local out = vim.fn.system('/usr/libexec/java_home -v ' .. ver)
    if vim.v.shell_error == 0 then
      local path = vim.fn.trim(out)
      if path ~= '' then
        table.insert(res, { name = name, path = path })
      end
    end
  end
  if vim.loop.os_uname().sysname == 'Darwin' then
    add('17', 'JavaSE-17')
    add('11', 'JavaSE-11')
  end
  return res
end
local java_runtimes = detect_java_runtimes()

-- Configuration
local config = {
  -- Command to start the language server
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '-Xmx2G',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', vim.fn.glob(vim.fn.expand('~/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar')),
    '-configuration', vim.fn.expand('~/.local/share/nvim/mason/packages/jdtls/config_mac'),
    '-data', workspace_dir,
  },

  -- Root directory
  root_dir = root_dir,

  -- Settings
  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = java_runtimes,
      },
      maven = {
        downloadSources = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      format = {
        enabled = true,
      },
    },
    signatureHelp = { enabled = true },
    completion = {
      favoriteStaticMembers = {
        "org.hamcrest.MatcherAssert.assertThat",
        "org.hamcrest.Matchers.*",
        "org.hamcrest.CoreMatchers.*",
        "org.junit.jupiter.api.Assertions.*",
        "java.util.Objects.requireNonNull",
        "java.util.Objects.requireNonNullElse",
        "org.mockito.Mockito.*",
      },
      importOrder = {
        "java",
        "javax",
        "com",
        "org"
      },
    },
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
    sources = {
      organizeImports = {
        starThreshold = 9999,
        staticStarThreshold = 9999,
      },
    },
    codeGeneration = {
      toString = {
        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
      },
      useBlocks = true,
    },
  },

  -- Flags
  flags = {
    allow_incremental_sync = true,
  },

  -- Capabilities
  capabilities = require('cmp_nvim_lsp').default_capabilities(),

  -- On attach function
  on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    
    -- LSP mappings
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)

    -- Java specific mappings
    -- Organize imports: static first, blank line, then others (no reordering among groups)
    local function organize_imports_static_first()
      -- 1) Let jdtls do its organize/import cleanup
      pcall(jdtls.organize_imports)

      -- 2) Reorder import section: static imports first, then blank line, then other imports
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local import_indices = {}
      for i, line in ipairs(lines) do
        if line:match('^%s*import%s') then
          table.insert(import_indices, i)
        end
      end
      if #import_indices == 0 then return end

      -- Determine continuous import block bounds
      local first_idx = import_indices[1]
      local last_idx = import_indices[#import_indices]
      -- Expand last_idx forward to include any trailing blank lines immediately following imports
      while last_idx < #lines and lines[last_idx + 1]:match('^%s*$') do
        last_idx = last_idx + 1
      end

      -- Collect import lines (ignore blanks inside; we reconstruct spacing)
      local static_imports = {}
      local other_imports = {}
      for i = first_idx, last_idx do
        local l = lines[i]
        if l:match('^%s*import%s') then
          if l:match('^%s*import%s+static%s') then
            table.insert(static_imports, l)
          else
            table.insert(other_imports, l)
          end
        end
      end

      -- Build new block
      local new_block = {}
      for _, l in ipairs(static_imports) do table.insert(new_block, l) end
      if #static_imports > 0 and #other_imports > 0 then table.insert(new_block, '') end -- blank line separator
      for _, l in ipairs(other_imports) do table.insert(new_block, l) end

      -- Replace block
      vim.api.nvim_buf_set_lines(bufnr, first_idx - 1, last_idx, false, new_block)
    end
    vim.keymap.set('n', '<leader>ji', organize_imports_static_first, bufopts)

    vim.keymap.set('n', '<leader>jv', jdtls.extract_variable, bufopts)
    vim.keymap.set('v', '<leader>jv', '<Esc><Cmd>lua require("jdtls").extract_variable(true)<CR>', bufopts)
    vim.keymap.set('n', '<leader>jc', jdtls.extract_constant, bufopts)
    vim.keymap.set('v', '<leader>jc', '<Esc><Cmd>lua require("jdtls").extract_constant(true)<CR>', bufopts)
    vim.keymap.set('v', '<leader>jm', '<Esc><Cmd>lua require("jdtls").extract_method(true)<CR>', bufopts)

    -- Auto-format on save (opt-in and safe)
    local function safe_format(bufnr_)
      local ok, err = pcall(function()
        vim.lsp.buf.format({
          async = false,
          bufnr = bufnr_,
          timeout_ms = 2000,
          filter = function(client) return client.name == "jdtls" end,
        })
      end)
      if not ok then
        vim.notify("Java format on save falhou: " .. tostring(err), vim.log.levels.WARN)
      end
    end

    -- default: disabled to prevent accidental buffer loss
    vim.b.java_format_on_save = false

    vim.api.nvim_create_user_command('JavaFormatOnSaveEnable', function()
      vim.b.java_format_on_save = true
      vim.notify("Format-on-save Java: ON")
    end, { buffer = bufnr })

    vim.api.nvim_create_user_command('JavaFormatOnSaveDisable', function()
      vim.b.java_format_on_save = false
      vim.notify("Format-on-save Java: OFF")
    end, { buffer = bufnr })

    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        if vim.b.java_format_on_save then
          safe_format(bufnr)
        end
      end,
    })
  end,

  -- Init options
  init_options = {
    bundles = {}
  },
}

-- Start the server
jdtls.start_or_attach(config)
