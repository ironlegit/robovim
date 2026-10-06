-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

----------------------------------------------------
--- Navigation
----------------------------------------------------

-- Open new tab
vim.api.nvim_set_keymap("n", "<leader>än", ":tabnew<CR>", { noremap = true, silent = true, desc = "Open new tab" })

-- Close current tab
vim.api.nvim_set_keymap(
  "n",
  "<leader>äc",
  ":tabclose:<CR>",
  { noremap = true, silent = true, desc = "Close current tab" }
)

-- Open Dashboard
vim.api.nvim_set_keymap(
  "n",
  "<leader>äd",
  ":Dashboard<CR>",
  { noremap = true, silent = true, desc = "Open Dashboard" }
)

----------------------------------------------------
--- Python
----------------------------------------------------

-- Setup ToggleTerm split screens
local Terminal = require("toggleterm.terminal").Terminal

local python = Terminal:new({
  direction = "horizontal",
  size = 25,
  close_on_exit = false,
})

local pytest = Terminal:new({
  direction = "horizontal",
  size = 15,
  close_on_exit = false,
})

-- Run current script
vim.keymap.set("n", "<leader>üü", function()
  if vim.bo.filetype ~= "python" then
    print("Not a Python file")
    return
  end

  vim.cmd("write")
  local file = vim.fn.expand("%:p")

  python:shutdown() -- kill previous job if running
  python.cmd = "poetry run python " .. file

  python:toggle()
end, { desc = "Run Current Python File" })

--TODO: Wrap this into which-key notation
-- Run all tests
vim.keymap.set("n", "<leader>üta", function()
  vim.cmd("write")

  local root = require("lazyvim.util").root()

  pytest:shutdown()
  pytest.dir = root
  pytest.cmd = "poetry run pytest tests"
  pytest:toggle()
end, { desc = "Run pytest folder (poetry)" })

-- Run current test file
vim.keymap.set("n", "<leader>ütt", function()
  vim.cmd("write")

  local root = require("lazyvim.util").root()
  local file = vim.fn.expand("%:p")

  pytest:shutdown()
  pytest.dir = root
  pytest.cmd = "poetry run pytest " .. file
  pytest:toggle()
end, { desc = "Run pytest file (poetry)" })

-- Create f-string type print of highlighted variable
-- TODO: Also use which-key for the next two funcs
vim.keymap.set("n", "<leader>üp", function()
  local line = vim.api.nvim_get_current_line()

  -- capture indentation
  local indent = line:match("^(%s*)")

  -- extract variable before =
  local var = line:match("^%s*([%w_%.]+)%s*=")

  if not var then
    print("No variable assignment found")
    return
  end

  local print_line = indent .. string.format('print(f"%s : {%s}")', var, var)

  vim.api.nvim_put({ print_line }, "l", true, true)
end, { desc = "Print variable with name" })

-- Simple f-print
vim.keymap.set("n", "<leader>üo", function()
  -- Save the current cursor position
  local pos = vim.api.nvim_win_get_cursor(0)
  -- Get the current line
  local line = vim.api.nvim_get_current_line()
  -- Capture indentation
  local indent = line:match("^(%s*)")
  -- Surround the line with print(), preserving indentation
  local new_line = indent .. "print(" .. line .. ")"
  -- Set the new line
  vim.api.nvim_set_current_line(new_line)
  -- Restore the cursor position (adjust column if needed)
  vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + 6 + #indent }) -- +6 to account for 'print('
end, { desc = "Surround line print()" })

-- f-print with line number
vim.keymap.set("n", "<leader>üi", function()
  -- Get current line and cursor position
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local linenr = row

  -- Capture indentation
  local indent = line:match("^(%s*)")

  -- Extract the expression under the cursor (Python syntax)
  -- This regex matches most Python expressions, including parentheses and brackets
  local expr = line:match("([%w_%.%[%]\"'%.%(%):]+)")

  -- If no expression found, try to get the word under cursor
  if not expr then
    local word = vim.fn.expand("<cword>")
    if word == "" then
      print("No expression found under cursor")
      return
    end
    expr = word
  end

  -- Build the print line with indentation
  local print_line = indent .. string.format("print(f'Line %d: {%s}')", linenr, expr)

  -- Insert the print line below
  vim.api.nvim_put({ print_line }, "l", true, true)
end, { desc = "Print debug w line #" })

vim.keymap.set("n", "<leader>ül", function()
  local file = vim.fn.expand("%")
  vim.cmd("!ruff check --fix " .. file)
  vim.cmd("edit") -- Reload the file to see changes
end, { noremap = true, silent = false, desc = "Ruff fix current file" })
----------------------------------------------------
--- Quarto and Markdown Stuff
----------------------------------------------------

--- Quarto
local quarto = require("quarto")
quarto.setup()
vim.keymap.set("n", "<leader>öp", quarto.quartoPreview, { silent = true, noremap = true, desc = "QuartoPreview" })

--- Disable LSP Diagnostic disabling
vim.keymap.set("n", "<leader>öl", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { silent = true, noremap = true, desc = "Toggle LSP-Diagnostic" })

--- ToC for Markdown
vim.keymap.set("n", "<leader>öt", ":Mtoc i[nsert]<CR>", { noremap = true, silent = true, desc = "Add ToC" })

--- Add LateX math equation with alignment environment
vim.keymap.set("n", "<leader>öm", function()
  vim.api.nvim_put({
    "$$",
    "\\begin{align*}",
    "y &= x",
    "\\end{align*}",
    "$$",
  }, "l", true, true)

  -- Move cursor into the empty line inside align*
  vim.cmd("normal! 2k$")
end, { desc = "Insert aligned LaTeX math env" })

--- Add Quarto Callout Block
--- https://quarto.org/docs/authoring/callouts.html
vim.keymap.set("n", "<leader>öc", function()
  vim.api.nvim_put({
    '::: {.callout-note collapse="false"}',
    "",
    ":::",
  }, "l", true, true)

  -- Move cursor into the empty line inside align*
  vim.cmd("normal! 2k$")
end, { desc = "Insert Callout Block" })

--- Add div tag for center alignment

vim.keymap.set("n", "<leader>öd", function()
  vim.api.nvim_put({
    '<div style="text-align: center;">',
    "",
    "<div>",
  }, "l", true, true)

  -- Move cursor into the empty line inside align*
  vim.cmd("normal! 2k$")
end, { desc = "Insert centered <div> tag" })
