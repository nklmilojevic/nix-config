{ pkgs, ... }:
{
  config = {
    programs.lazygit = {
      enable = true;
      settings = {
        gui = {
          nerdFontsVersion = "3";
          showFileTree = true;
          showCommandLog = false;
          showRandomTip = false;
          expandFocusedSidePanel = true;
          border = "rounded";
        };
        customCommands = [
          {
            key = "<c-a>";
            command = "git commit -m {{.Form.CommitMsg | quote}}";
            context = "files";
            description = "AI commit message";
            prompts = [
              {
                type = "menuFromCommand";
                title = "AI Commit Message (enter to commit, esc to cancel)";
                key = "CommitMsg";
                command = ''bash -c 'git diff --cached | claude --model haiku -p "Write a single-line git commit message for this diff. Use conventional commit format (type: description). Under 72 chars. No backticks. Output ONLY the message, nothing else."' '';
                filter = "(.+)";
                valueFormat = "{{ .group_1 }}";
                labelFormat = "{{ .group_1 }}";
              }
            ];
          }
        ];
      };
    };
  };
}
