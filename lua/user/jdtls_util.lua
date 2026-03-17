local M = {}

local function is_normal_java_buffer()
  if vim.bo.filetype ~= 'java' then return false end
  local bt = vim.bo.buftype
  local mod = vim.bo.modifiable
  local listed = (vim.fn.buflisted(0) == 1)
  local cfg = vim.api.nvim_win_get_config(0)
  local is_float = (cfg and cfg.relative and cfg.relative ~= '')
  if bt ~= '' or not listed or not mod or is_float then
    return false
  end
  return true
end

local function detect_platform_dir()
  local uname = vim.uv.os_uname()
  local sys = uname.sysname
  local arch = uname.machine
  if sys == 'Darwin' then
    if arch == 'arm64' or arch == 'aarch64' then return 'config_mac_arm' else return 'config_mac' end
  elseif sys:match('Windows') or vim.fn.has('win32') == 1 then
    return 'config_win'
  else
    if arch == 'arm64' or arch == 'aarch64' then return 'config_linux_arm' else return 'config_linux' end
  end
end

local function build_config()
  local home = os.getenv('HOME')
  local jdtls_base = home .. '/.local/share/nvim/mason/packages/jdtls'
  local root_markers = { 'gradlew', 'mvnw', 'pom.xml', 'build.gradle', '.git' }
  local root_dir = require('jdtls.setup').find_root(root_markers)
  if not root_dir or root_dir == '' then return nil end

  -- Use the project folder name (tail), not the parent folder
  local project_name = vim.fn.fnamemodify(root_dir, ':p:t')
  local workspace_dir = home .. '/.local/share/jdtls-workspaces/' .. project_name

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  pcall(function()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
  end)

  -- Resolve a Java 21/17 runtime if available
  local function pick_java()
    local jh = os.getenv('JAVA_HOME')
    if jh and #jh > 0 and vim.uv.fs_stat(jh .. '/bin/java') then
      return jh .. '/bin/java'
    end
    if vim.uv.os_uname().sysname == 'Darwin' then
      local function jhome(ver)
        local out = vim.fn.system('/usr/libexec/java_home -v ' .. ver)
        if vim.v.shell_error == 0 then
          local p = vim.fn.trim(out)
          if p ~= '' and vim.uv.fs_stat(p .. '/bin/java') then return p .. '/bin/java' end
        end
        return nil
      end
      return jhome('21') or jhome('17') or 'java'
    end
    return 'java'
  end

  local cmd = {
    pick_java(),
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.level=ERROR',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', vim.fn.glob(jdtls_base .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration', jdtls_base .. '/' .. detect_platform_dir(),
    '-data', workspace_dir,
  }

  local tb = require('telescope.builtin')
  local function on_attach(_, bufnr)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end
    map('n', '<leader>gr', tb.lsp_references, 'LSP references (Telescope)')
    map('n', 'gd', tb.lsp_definitions, 'Go to definition')
    map('n', 'gi', tb.lsp_implementations, 'Go to implementation')
    map('n', 'gt', tb.lsp_type_definitions, 'Go to type')
  end

  return {
    cmd = cmd,
    root_dir = root_dir,
    capabilities = capabilities,
    settings = {
      java = {
        signatureHelp = { enabled = true },
        completion = { importOrder = { 'java', 'javax', 'com', 'org' } },
        configuration = { updateBuildConfiguration = 'interactive' },
      },
    },
    init_options = { bundles = {} },
    on_attach = on_attach,
  }
end

function M.ensure_started()
  if not is_normal_java_buffer() then return false end
  local ok, jdtls = pcall(require, 'jdtls')
  if not ok then return false end

  -- Block any implicit DAP setup from requesting main class
  local ok_dap, jdtls_dap = pcall(require, 'jdtls.dap')
  if ok_dap then
    jdtls_dap.setup_dap_main_class_configs = function() end
    jdtls_dap.setup_dap = function() end
  end

  local cfg = build_config()
  if not cfg then return false end
  jdtls.start_or_attach(cfg)
  return true
end

return M