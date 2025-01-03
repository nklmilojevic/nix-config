{...}: {
  programs.k9s = {
    enable = true;

    aliases = {
      aliases = {
        dp = "deployments";
        sec = "v1/secrets";
        jo = "jobs";
        cr = "clusterroles";
        crb = "clusterrolebindings";
        ro = "roles";
        rb = "rolebindings";
        np = "networkpolicies";
      };
    };

    settings = {
      k9s = {
        liveViewAutoRefresh = false;
        refreshRate = 2;
        maxConnRetry = 5;
        readOnly = false;
        noExitOnCtrlC = false;
        ui = {
          enableMouse = false;
          headless = false;
          logoless = false;
          crumbsless = false;
          reactive = false;
          noIcons = false;
        };
        skipLatestRevCheck = false;
        disablePodCounting = false;
        shellPod = {
          image = "busybox";
          namespace = "default";
          limits = {
            cpu = "100m";
            memory = "100Mi";
          };
        };
        imageScans = {
          enable = false;
          exclusions = {
            namespaces = [];
            labels = {};
          };
        };
        logger = {
          tail = 100;
          buffer = 5000;
          sinceSeconds = -1;
          fullScreen = false;
          textWrap = false;
          showTime = false;
        };
        thresholds = {
          cpu = {
            critical = 90;
            warn = 70;
          };
          memory = {
            critical = 90;
            warn = 70;
          };
        };
      };
    };

    skins = {
      dracula = {
        k9s = {
          body = {
            fgColor = "#f8f8f2";
            bgColor = "default";
            logoColor = "#bd93f9";
          };
          prompt = {
            fgColor = "#f8f8f2";
            bgColor = "default";
            suggestColor = "#bd93f9";
          };
          info = {
            fgColor = "#ff79c6";
            sectionColor = "#f8f8f2";
          };
          dialog = {
            fgColor = "#f8f8f2";
            bgColor = "default";
            buttonFgColor = "#f8f8f2";
            buttonBgColor = "#bd93f9";
            buttonFocusFgColor = "#f1fa8c";
            buttonFocusBgColor = "#ff79c6";
            labelFgColor = "#ffb86c";
            fieldFgColor = "#f8f8f2";
          };
          frame = {
            border = {
              fgColor = "#44475a";
              focusColor = "#44475a";
            };
            menu = {
              fgColor = "#f8f8f2";
              keyColor = "#ff79c6";
              numKeyColor = "#ff79c6";
            };
            crumbs = {
              fgColor = "#f8f8f2";
              bgColor = "#44475a";
              activeColor = "#44475a";
            };
            status = {
              newColor = "#8be9fd";
              modifyColor = "#bd93f9";
              addColor = "#50fa7b";
              errorColor = "#ff5555";
              highlightColor = "#ffb86c";
              killColor = "#6272a4";
              completedColor = "#6272a4";
            };
            title = {
              fgColor = "#f8f8f2";
              bgColor = "#44475a";
              highlightColor = "#ffb86c";
              counterColor = "#bd93f9";
              filterColor = "#ff79c6";
            };
          };
          views = {
            charts = {
              bgColor = "default";
            };
            table = {
              fgColor = "#f8f8f2";
              bgColor = "default";
              header = {
                fgColor = "#f8f8f2";
                bgColor = "default";
                sorterColor = "#8be9fd";
              };
            };
            xray = {
              fgColor = "#f8f8f2";
              bgColor = "default";
              cursorColor = "#44475a";
              graphicColor = "#bd93f9";
              showIcons = false;
            };
            yaml = {
              keyColor = "#ff79c6";
              colonColor = "#bd93f9";
              valueColor = "#f8f8f2";
            };
            logs = {
              fgColor = "#f8f8f2";
              bgColor = "default";
              indicator = {
                fgColor = "#f8f8f2";
                bgColor = "default";
                toggleOnColor = "#50fa7b";
                toggleOffColor = "#8be9fd";
              };
            };
          };
        };
      };
    };
  };
}
