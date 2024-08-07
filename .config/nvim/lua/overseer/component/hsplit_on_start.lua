local util = require "overseer.util"

return {
  desc = "Open a hsplit on task start",
  -- Define parameters that can be passed in to the component
  params = {
    -- See :help overseer-params
  },
  -- Optional, default true. Set to false to disallow editing this component in the task editor
  editable = true,
  -- Optional, default true. When false, don't serialize this component when saving a task to disk
  serializable = true,
  -- The params passed in will match the params defined above
  constructor = function(params)
    -- You may optionally define any of the methods below
    return {
      on_init = function(self, task)
        -- Called when the task is created
        -- This is a good place to initialize resources, if needed
      end,
      ---@return nil|boolean
      on_pre_start = function(self, task)
        -- Return false to prevent task from starting
      end,
      on_start = function(self, task)
        -- Iterate over windows to find and close terminal splits
        for _, winid in ipairs(util.get_fixed_wins()) do
          local buf_type = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(winid), "buftype")
          if buf_type == "terminal" then vim.api.nvim_win_call(winid, function() vim.cmd [[close]] end) end
        end
        -- If we're currently in the task list, open a split in the nearest other window
        if vim.bo.filetype == "OverseerList" then
          for _, winid in ipairs(util.get_fixed_wins()) do
            if not vim.wo[winid].winfixwidth then
              util.go_win_no_au(winid)
              break
            end
          end
        end
        vim.cmd [[split | resize 5%]]
        util.set_term_window_opts()
        vim.fn.feedkeys("i", "n")
        vim.api.nvim_win_set_buf(0, task:get_bufnr())
        util.scroll_to_end(0)
      end,
      on_reset = function(self, task)
        -- Called when the task is reset to run again
      end,
      ---@return table
      on_pre_result = function(self, task)
        -- Called when the task is finalizing.
        -- Return a map-like table value here to merge it into the task result.
        return { foo = { "bar", "baz" } }
      end,
      ---@param result table A result table.
      on_preprocess_result = function(self, task, result)
        -- Called right before on_result. Intended for logic that needs to preprocess the result table and update it in-place.
      end,
      ---@param result table A result table.
      on_result = function(self, task, result)
        -- Called when a component has results to set. Usually this is after the command has completed, but certain types of tasks may wish to set a result while still running.
      end,
      ---@param status overseer.Status Can be CANCELED, FAILURE, or SUCCESS
      ---@param result table A result table.
      on_complete = function(self, task, status, result)
        -- Called when the task has reached a completed state.
      end,
      ---@param status overseer.Status
      on_status = function(self, task, status)
        -- Called when the task status changes
      end,
      ---@param data string[] Output of process. See :help channel-lines
      on_output = function(self, task, data)
        -- Called when there is output from the task
      end,
      ---@param lines string[] Completed lines of output, with ansi codes removed.
      on_output_lines = function(self, task, lines)
        -- Called when there is output from the task
        -- Usually easier to deal with than using on_output directly.
      end,
      ---@param code number The process exit code
      on_exit = function(self, task, code)
        -- Called when the task command has completed
      end,
      on_dispose = function(self, task)
        -- Called when the task is disposed
        -- Will be called IFF on_init was called, and will be called exactly once.
        -- This is a good place to free resources (e.g. timers, files, etc)
      end,
      ---@param lines string[] The list of lines to render into
      ---@param highlights table[] List of highlights to apply after rendering
      ---@param detail number The detail level of the task. Ranges from 1 to 3.
      render = function(self, task, lines, highlights, detail)
        -- Called from the task list. This can be used to display information there.
        -- table.insert(lines, "Here is a line of output")
        -- The format is {highlight_group, lnum, col_start, col_end}
        -- table.insert(highlights, {'Title', #lines, 0, -1})
      end,
    }
  end,
}
